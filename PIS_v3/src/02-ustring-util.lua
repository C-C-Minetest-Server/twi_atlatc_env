assert(is_loading)

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

function F.count_unicode_string_vislength(str)
    local length = 0
    local pt = 1
    local code

    while pt <= #str do
        code, pt = F.peek_utf8(str, pt)

        if code then
            length = length + (F.flat_unifont_halfwidth[code] and 1 or 2)
        else
            break
        end
    end

    return length
end

function F.remove_unicode_characters(str)
    local res = {}

    local pt = 1

    while pt <= #str do
        local code, new_pt = F.peek_utf8(str, pt)

        if not code then
            break
        end

        if code >= 0x12 and code <= 0x7E then
            res[#res+1] = string.sub(str, pt, new_pt - 1)
        else
            res[#res+1] = F.flat_unifont_halfwidth[code] and " " or "  "
        end

        pt = new_pt
    end

    return table.concat(res)
end

function F.validate_variable_length_string(str)
    if type(str) == "string" then return true end
    if type(str) ~= "table" or #str <= 0 then return false end

    local last_len = F.count_unicode_string_vislength(str[1])
    for i = 2, #str do
        if F.count_unicode_string_vislength(str[i]) >= last_len then
            return false
        end
    end

    return true
end

function F.handle_variable_length_string(str, max_len, use_unicode)
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
        if F.count_unicode_string_vislength(choice) <= max_len then
            if use_unicode then
                return F.remove_unicode_characters(choice)
            end

            return choice
        end
    end

    return string.sub(str[#str], 1, max_len)
end