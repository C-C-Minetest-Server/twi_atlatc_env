-- luacheck: no unused

local F, S = F, S
local rwt = rwt
local sqrt, floor, abs, fmod = math.sqrt, math.floor, math.abs, math.fmod

local function string_split(str, delim, include_empty, max_splits, sep_is_pattern)
    delim = delim or ","
    if delim == "" then
        error("string.split separator is empty", 2)
    end
    max_splits = max_splits or -2
    local items = {}
    local pos, len = 1, #str
    local plain = not sep_is_pattern
    max_splits = max_splits + 1
    repeat
        local np, npe = string.find(str, delim, pos, plain)
        np, npe = (np or (len + 1)), (npe or (len + 1))
        if (not np) or (max_splits == 1) then
            np = len + 1
            npe = np
        end
        local s = string.sub(str, pos, np - 1)
        if include_empty or (s ~= "") then
            max_splits = max_splits - 1
            items[#items + 1] = s
        end
        pos = npe + 1
    until (max_splits == 0) or (pos > (len + 1))
    return items
end

local function table_indexof(list, val)
    for i, v in ipairs(list) do
        if v == val then
            return i
        end
    end
    return -1
end

local function cascade_index(...)
    local tables = { ... }
    return function(k)
        for _, tb in ipairs(tables) do
            if tb[k] ~= nil then return tb[k] end
        end
    end
end

local function aspect_is_free(asp)
    if type(asp.main) == "table" then
        return asp.main.free
    else
        return asp.main ~= 0
    end
end

local function merge_key_tables(tables)
    local rtn = {}
    for _, tb in ipairs(tables) do
        for k, v in pairs(tb) do
            rtn[k] = v
        end
    end
    return rtn
end

F.has_rc = function(query, rc_list) -- query = string, single entry
    if not rc_list then return false end
    for word in rc_list:gmatch("[^%s]+") do
        if word == query then return true end
    end
    return false
end

F.get_rc_safe = function()
    if not atc_id then return "" end
    return get_rc() or ""
end

F.get_line_safe = function()
    if not atc_id then return "" end
    return get_line() or ""
end

F.get_rc_list = function(rc)
    rc = rc or F.get_rc_safe()
    return string_split(rc, " ")
end

--[[
F.t_acc_all = {
	[0] = -10,
	[1] = -3,
	[11] = -2, -- calculation base for LZB
	[2] = -0.5,
	[4] = 0.5,
}

F.t_accel_eng = {
	[0] = 0,
	[1] = 0,
	[11] = 0,
	[2] = 0,
	[4] = 1.5,
}

F.VLEVER = {
    EMERG = 0,
    BRAKE = 1,
    LZBCALC = 11,
    ROLL = 2,
    HOLD = 3,
    ACCEL = 4,
}

F.get_train_accleration = function(train, lever)
    local acc_all = F.t_accel_all[lever]
	if not acc_all then return 0 end

	local acc_eng = F.t_accel_eng[lever]
	local nwagons = train:train_length()
    local nlocomotives = train:locomotives_in_train()
	if nwagons == 0 or nwagons == false or nlocomotives == false then
		-- empty train! avoid division through zero
		return -1
	end
	local acc = acc_all + (acc_eng*nlocomotives)/nwagons
	return acc
end
]]

F.rev_dirs = {
    N = "S",
    E = "W",
    S = "N",
    W = "E",

    CW = "ACW",
    ACW = "CW",

    U = "D",
    D = "U",
}

F.dir_short_name = {
    N = "Northbound",
    E = "Eastbound",
    S = "Southbound",
    W = "Westbound",

    CW = "Clockwise",
    ACW = "Anti-clockw.",

    U = "Up",
    D = "Down",
}

F.right_pad_textline = function(lines)
    local rtns = {}
    for i, y in ipairs(lines) do
        rtns[i] = string.format("%26s", y)
    end
    return rtns
end

F.right_pad_luaatc_textline = function(lines)
    local rtns = {}
    for i, y in ipairs(lines) do
        rtns[i] = string.format("%27s", y)
    end
    return rtns
end

F.slice_textline = function(lines, no_display, digiline_prefix)
    for i = 0, (no_display or 1) - 1 do
        digiline_send((digiline_prefix or "") .. (i + 1),
            (lines[(i * 4) + 1] or "") .. "\n" ..
            (lines[(i * 4) + 2] or "") .. "\n" ..
            (lines[(i * 4) + 3] or "") .. "\n" ..
            (lines[(i * 4) + 4] or ""))
    end
end

function F.show_lr(def, texts)
    digiline_send(def.left_disp or "l", table.concat(texts, "\n"))
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%26s", y))
    end
    digiline_send(def.right_disp or "r", table.concat(rtexts, "\n"))
end

function F.show_textline(_, texts)
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%27s", y))
    end
    display(table.concat(texts, "\n"), table.concat(rtexts, "\n"))
end

function F.show_textline_r(_, texts)
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%27s", y))
    end
    display(table.concat(rtexts, "\n"), table.concat(texts, "\n"))
end

local debug = print
-- local debug = function() end
