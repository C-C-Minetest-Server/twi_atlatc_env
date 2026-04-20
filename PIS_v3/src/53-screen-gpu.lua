assert(is_loading)

F.gpu = {}

-- We work on integer representation until it's time to send it
-- i.e. the only place we would like to see string form is in to_array

--[[
We avoid excess creation of new tables by creating new layers that stores new information
in a buffer.
]]

function F.gpu._new_layer_raw(w, h, background)
    local layer_content = {}
    for i = 1, h do
        local layer_row = {}
        for j = 1, w do
            layer_row[#layer_row + 1] = background
        end
        layer_content[#layer_content + 1] = layer_row
    end
    return {
        content = layer_content
    }
end

function F.gpu.new_buffer(w, h, background)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.new_buffer
    local buf = { w = w, h = h, layers = {} }
    buf.layers[1] = F.gpu._new_layer_raw(w, h, background)

    -- tracy: ZoneEnd
    return buf
end

function F.gpu.add_layer(buf)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.add_layer
    buf.layers[#buf.layers+1] = F.gpu._new_layer_raw(buf.w, buf.h, false)
    -- tracy: ZoneEnd
end

function F.gpu.copy_buffer(buf)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.copy_buffer

    local new_buf = { w = buf.w, h = buf.h, layers = {} }

    -- Shallow copy the layers
    for i, layer in ipairs(buf.layers) do
        new_buf.layers[i] = layer
    end

    new_buf.top_layer_immutable = true

    -- tracy: ZoneEnd
    return new_buf
end

function F.gpu.read_pixel(buf, x, y)
    assert(x >= 1 and x <= buf.w, "Invalid x coordinate")
    assert(y >= 1 and y <= buf.h, "Invalid y coordinate")
    for i = #buf.layers, 1, -1 do
        local layer = buf.layers[i]
        local lookup_x = x + (layer.offset_x or 0)
        local lookup_y = y + (layer.offset_y or 0)
        local layer_content = layer.content

        if layer_content[lookup_y] and layer_content[lookup_y][lookup_x] ~= nil and layer_content[lookup_y][lookup_x] ~= false then
            return layer_content[lookup_y][lookup_x]
        end
    end

    return false
end

function F.gpu.write_pixel(buf, x, y, color)
    assert(x >= 1 and x <= buf.w, "Invalid x coordinate")
    assert(y >= 1 and y <= buf.h, "Invalid y coordinate")

    if buf.top_layer_immutable then
        buf.top_layer_immutable = nil
        F.gpu.add_layer(buf)
    end
    
    buf.layers[#buf.layers].content[y][x] = color
end

function F.gpu.overlay_apply(buf, buf2, x, y, apply)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.overlay_apply
    for i = 1, buf2.h do
        for j = 1, buf2.w do
            local pix = F.gpu.read_pixel(buf2, j, i)
            local write_x = j + x - 1
            local write_y = i + y - 1

            if apply then
                pix = apply(j, i, pix)
            end

            if write_x >= 1 and write_x <= buf.w and write_y >= 1 and write_y <= buf.h then
                F.gpu.write_pixel(buf, write_x, write_y, pix)
            end
        end
    end
    -- tracy: ZoneEnd
end

function F.gpu.overlay_buf(buf, buf2, x, y)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.overlay_buf
    buf.top_layer_immutable = true

    for _, layer in ipairs(buf2.layers) do
        buf.layers[#buf.layers+1] = {
            offset_x = x - 1 + (layer.offset_x or 0),
            offset_y = y - 1 + (layer.offset_y or 0),
            content = layer.content
        }
    end
    -- tracy: ZoneEnd
end

function F.gpu.squash_layers(buf)
    if #buf.layers <= 1 then return end
    -- tracy: ZoneBeginN PIS_v3::F.gpu.squash_layers
    local new_layer = F.gpu._new_layer_raw(buf.w, buf.h, false)
    for y = 1, buf.h do
        for x = 1, buf.w do
            new_layer.content[y][x] = F.gpu.read_pixel(buf, x, y)
        end
    end
    buf.layers = { new_layer }
    -- tracy: ZoneEnd
end

function F.gpu.to_screen(buf, x, y, w, h, bkg)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.to_screen
    local arr = {}
    bkg = bkg or 0

    for i = y, y + h - 1 do
        local arr_row = {}
        for j = x, x + w - 1 do
            local pix = F.gpu.read_pixel(buf, j, i)
            if pix == false then
                pix = bkg
            end
            arr_row[#arr_row + 1] = string.format("%06X", pix)
        end
        arr[#arr+1] = arr_row
    end

    -- tracy: ZoneEnd
    return arr
end

function F.gpu.apply(buf, func)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.apply
    for y = 1, buf.h do
        for x = 1, buf.w do
            F.gpu.write_pixel(buf, x, y, func(x, y, F.gpu.read_pixel(buf, x, y)))
        end
    end
    -- tracy: ZoneEnd
end

function F.gpu.apply_color(buf, color)
    return F.gpu.apply(buf, function(x, y, pix)
        if pix then
            return color
        end
        return pix
    end)
end

function F.gpu.fill(buf, color, x, y, w, h)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.fill
    for i = y, y + h - 1 do
        for j = x, x + w - 1 do
            F.gpu.write_pixel(buf, j, i, color)
        end
    end
    -- tracy: ZoneEnd
end

function F.gpu.rectangle(buf, color, x, y, w, h)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.rectangle

    -- Top and bottom lines
    for _, i in ipairs({ y, y + h - 1 }) do
        for j = x, x + w - 1 do
            F.gpu.write_pixel(buf, j, i, color)
        end
    end

    if h >= 2 then
        -- The remaining two sides
        for i = y + 1, y + h - 2 do
            for _, j in ipairs({ x, x + w - 1 }) do
                F.gpu.write_pixel(buf, j, i, color)
            end
        end
    end

    -- tracy: ZoneEnd
end

-- Create an enlarged version of a buffer
-- This is a generator
function F.gpu.int_enlarge(buf, ratio)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.int_enlarge

    -- Input validation: ratio should be a positive integer
    ratio = math.max(1, math.floor(ratio or 1))
    
    local old_h = buf.h
    local old_w = buf.w
    
    -- Calculate new dimensions
    local new_w = old_w * ratio
    local new_h = old_h * ratio
    
    -- Create the new target buffer
    local new_buf = F.gpu.new_buffer(new_w, new_h, false)
    
    for y = 1, buf.h do
        for x = 1, buf.w do
            local pix = F.gpu.read_pixel(buf, x, y)
            -- If the pixel is not transparent, fill the corresponding block
            if pix ~= false then
                -- Calculate the starting bounds in the new buffer
                local start_y = (y - 1) * ratio + 1
                local start_x = (x - 1) * ratio + 1
                
                -- Fill the ratio * ratio block with the pixel color
                F.gpu.fill(new_buf, pix, start_x, start_y, ratio, ratio)
            end
        end
    end

    -- tracy: ZoneEnd
    
    return new_buf
end

-- Fonts

-- Render a string onto the screen
function F.gpu.render_font(buf, str, x, y, color)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.render_font

    if type(str) ~= "string" then
        -- tracy: ZoneEnd
        error("string expected", 2)
    end

    color = color or 0xFFFFFF

    local offset_x = x - 6
    for i = 1, #str do
        offset_x = offset_x + 6

        local char = string.byte(str, i)
        if char ~= 32 then -- short-circuit spaces
            local font = F.screen_chars[char] or F.screen_chars[32]
            F.gpu.overlay_apply(buf, font, offset_x, y, function(x, y, pix)
                if pix == false then return false end
                return color
            end)
        end
    end

    -- tracy: ZoneEnd
end

-- Constructor that returns a new buffer for that string
function F.gpu.get_string_buffer(str, color)
    if type(str) ~= "string" then
        error("string expected", 2)
    end
    local buf_w = #str * 6
    local buf = F.gpu.new_buffer(buf_w, 12, false)

    F.gpu.render_font(buf, str, 1, 1, color)
    return buf
end

