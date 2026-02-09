-- luacheck: no unused

assert(is_loading)

local PIS_V3_EXT_INT_POS = "PIS_v3_ext_int"

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