-- luacheck: no unused

assert(is_loading)

local F, S = F, S
local rwt = rwt

-- AI-generated
function F.peek_utf8(str, index)
    index = index or 1
    if index > #str then
        return nil, nil -- Out of bounds
    end

    local byte1 = string.byte(str, index)
    local code, next_index

    -- 1-byte ASCII (0xxxxxxx)
    if byte1 < 0x80 then
        code = byte1
        next_index = index + 1

        -- 2-byte sequence (110xxxxx 10xxxxxx)
    elseif byte1 >= 0xC0 and byte1 < 0xE0 then
        if index + 1 > #str then return nil, nil end
        local byte2 = string.byte(str, index + 1)

        code = ((byte1 - 0xC0) * 64) + (byte2 - 0x80)
        next_index = index + 2

        -- 3-byte sequence (1110xxxx 10xxxxxx 10xxxxxx)
    elseif byte1 >= 0xE0 and byte1 < 0xF0 then
        if index + 2 > #str then return nil, nil end
        local byte2 = string.byte(str, index + 1)
        local byte3 = string.byte(str, index + 2)

        code = ((byte1 - 0xE0) * 4096) + ((byte2 - 0x80) * 64) + (byte3 - 0x80)
        next_index = index + 3

        -- 4-byte sequence (11110xxx 10xxxxxx 10xxxxxx 10xxxxxx)
    elseif byte1 >= 0xF0 and byte1 < 0xF8 then
        if index + 3 > #str then return nil, nil end
        local byte2 = string.byte(str, index + 1)
        local byte3 = string.byte(str, index + 2)
        local byte4 = string.byte(str, index + 3)

        code = ((byte1 - 0xF0) * 262144) + ((byte2 - 0x80) * 4096) + ((byte3 - 0x80) * 64) + (byte4 - 0x80)
        next_index = index + 4
    else
        -- Invalid UTF-8 starting byte or continuation byte passed as start
        return nil, nil
    end

    return code, next_index
end

function F.validate_variable_length_string(str)
    if type(str) == "string" then return true end
    if type(str) ~= "table" or #str <= 0 then return false end

    local last_len = #str[1]
    for i = 2, #str do
        if #str[i] >= last_len then
            return false
        end
    end

    return true
end

function F.handle_variable_length_string(str, max_len)
    if type(str) == "string" then
        return max_len and string.sub(str, 1, max_len) or str
    end

    assert(type(str) == "table" and #str > 0, "Invalid type of str in F.handle_variable_length_string")

    if not max_len then
        assert(type(str[1]) == "string", "Invalid type of str[1] in F.handle_variable_length_string")
        return str[1]
    end

    for i, choice in ipairs(str) do
        assert(type(choice) == "string", "Invalid type of str[" .. i .. "] in F.handle_variable_length_string")
        if #choice <= max_len then
            return choice
        end
    end

    return string.sub(str[#str], 1, max_len)
end

do
    local formspec_escapes = {
        ["\\"] = "\\\\",
        ["["] = "\\[",
        ["]"] = "\\]",
        [";"] = "\\;",
        [","] = "\\,",
        ["$"] = "\\$",
        [":"] = "\\:",
        ["^"] = "\\^",
    }
    function F.formspec_escape(text)
        -- Use explicit character set instead of dot here because it doubles the performance
        return text and ("").gsub(text, "[\\%[%];,$]", formspec_escapes)
    end
    function F.formspec_escape_combine(text)
        -- Use explicit character set instead of dot here because it doubles the performance
        return text and ("").gsub(text, "[\\%[%];,$:^]", formspec_escapes)
    end
end

function F.seconds_to_string_shorter(seconds_raw)
    seconds_raw = math.floor(seconds_raw)
    if seconds_raw <= 0 then
        return seconds_raw .. " sec."
    end

    local minutes = math.floor(seconds_raw / 60)
    local seconds = seconds_raw % 60

    local components = {}
    components[#components + 1] = minutes ~= 0 and (minutes .. " m") or nil
    components[#components + 1] = seconds .. " sec." -- So it does not blink

    return table.concat(components, " ")
end

--[[ { [station_id:track_id] = { [atc_id] = {
    train_status = "arriving" / "approaching" / "stopped",
    line_code = "<line code>",
    line_name = "<line name>", -- variable-length string
    heading_to = "<heading to>", -- variable-length string
    arriving_at = rwt(), -- "arriving" / "approaching"
    leaving_at = rwt(), -- "stopped"
} } } ]]
F.pis_list_of_trains = {}

-- Sorted arrays of atc_ids in ascending order of ETA
-- The closer the train, the upper it's position in the array
--[[ { [station_id:track_id] = atc_id[] } ]]
F.pis_list_of_trains_sorted = {}

-- Cache of the currently stopped train's atc_id
-- Then we avoid O(n) lookup
-- Assume there can only be one train stopping; in the buggy state
-- that a train is registered "stopped" before another deregisters,
-- the later train takes presedence.
--[[ { [station_id:track_id] = atc_id or nil } ]]
F.pis_train_stopped_on_track = {}
