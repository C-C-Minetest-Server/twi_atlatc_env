assert(is_loading)

local UNIFONT_TEX = "signs_lib_uni%02x.png\\^[sheet\\:16x16\\:%d,%d"

F.flat = {}

-- AI-generated
local function peek_utf8(str, index)
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

function F.flat.new_buffer(w, h, base_texture)
    return {
        w = w,
        h = h,
        base_texture = base_texture,
        parts = {},
    }
end

function F.flat.overlay_texture(buf, x, y, texture)
    buf.parts[#buf.parts + 1] = {
        x = x,
        y = y,
        texture = texture,
    }
end

function F.flat.render_texture(buf)
    local strparts = {}
    for i, part in ipairs(buf.parts) do
        strparts[i] = string.format("%d,%d=%s", part.x, part.y, F.formspec_escape_combine(part.texture))
    end

    return string.format(
        "%s[combine:%dx%d:%s",
        (buf.base_texture == "" and "" or (buf.base_texture .. "^")), buf.w, buf.h, table.concat(strparts, ":")
    )
end

function F.flat.get_text_texture(str, color)
    local tw, th = 0, 16
    local ptx, pty = 0, 0
    local combine_txtparts = {}
    local max_linew = 0
    local linews = {}

    local i = 1
    while i <= #str do
        local code, new_i = peek_utf8(str, i)
        i = new_i
        if code == 0x0A then
            linews[#linews+1] = ptx
            max_linew = math.max(max_linew, ptx)

            th = th + 16
            ptx, pty = 0, pty + 16
        elseif code == 0x20 then
            combine_txtparts[#combine_txtparts+1] = ptx .. "," .. pty .. "=[fill\\:8x16\\:#000000"
            ptx = ptx + 8
            tw = math.max(tw, ptx)
        else
            local page = math.floor(code / 256)
            local idx = code % 256
            local tx = idx % 16
            local ty = math.floor(idx / 16)
            local tex = UNIFONT_TEX:format(page, tx, ty)

            combine_txtparts[#combine_txtparts+1] = ptx .. "," .. pty .. "=" .. tex

            local cw = F.flat_unifont_halfwidth[code] and 8 or 16
            ptx = ptx + cw
            tw = math.max(tw, ptx)
        end
    end

    linews[#linews+1] = ptx
    max_linew = math.max(max_linew, ptx)

    if tw == 0 or th == 0 then
        return
    end

    -- Fill the space after shorter lines with solid colors so that they later become alpha
    for j, linew in ipairs(linews) do
        if linew < max_linew then
            local tex = "[fill\\:" .. (max_linew - linew + 1) .. "x16\\:#000000"
            combine_txtparts[#combine_txtparts+1] = linew .. "," .. ((j - 1) * 16) .. "=" .. tex
        end
    end

    return string.format(
        "[fill:%dx%d:%s^[combine:%dx%d:%s^[makealpha:0,0,0",
        tw, th, color, tw, th, table.concat(combine_txtparts, ":")
    ), tw, th
end

function F.flat.overlay_text(buf, x, y, str, color, scale, anchor)
    assert(math.floor(scale) == scale and scale >= 1)
    local txt, tw, th = F.flat.get_text_texture(str, color)

    if not txt then return end

    if scale > 1 then
        tw, th = tw * scale, th * scale
        txt = txt .. "^[resize:" .. tw .. "x" .. th
    end

    -- (x,y) are 0-indexed
    if anchor == "ct" then
        x = x - math.floor(tw / 2)
    elseif anchor == "rt" then
        -- (x,y) will be the right-top
        x = x - tw
    elseif anchor == "lm" then
        -- (x,y) will be the left-middle
        y = y - math.floor(th / 2)
    elseif anchor == "cm" or anchor == "center" then
        -- (x,y) will be the absolute center
        x = x - math.floor(tw / 2)
        y = y - math.floor(th / 2)
    elseif anchor == "rm" then
        -- (x,y) will be the right-middle
        x = x - tw
        y = y - math.floor(th / 2)
    elseif anchor == "lb" then
        -- (x,y) will be the left-bottom
        y = y - th
    elseif anchor == "cb" then
        -- (x,y) will be the middle-bottom
        x = x - math.floor(tw / 2)
        y = y - th
    elseif anchor == "rb" then
        -- (x,y) will be the right-bottom
        x = x - tw
        y = y - th
    end

    F.flat.overlay_texture(buf, x, y, txt)
end
