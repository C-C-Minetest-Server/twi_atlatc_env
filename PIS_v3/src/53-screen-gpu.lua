assert(is_loading)

F.gpu = {}

-- We work on integer representation until it's time to send it
-- i.e. the only place we would like to see string form is in to_array

-- Basic I/O

-- Constructor of new buffer
function F.gpu.new_buffer(w, h, background)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.new_buffer

    local buf = {}
    background = type(background) == "number" and background or false

    for i = 1, h do
        local buf_row = {}
        for j = 1, w do
            buf_row[#buf_row + 1] = background
        end
        buf[#buf + 1] = buf_row
    end

    -- tracy: ZoneEnd
    return buf
end

-- Deep copy a buffer
function F.gpu.copy_buffer(buf)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.copy_buffer

    local new_buf = {}

    for i, buf_row in ipairs(buf) do
        new_buf[i] = {}
        for j, pix in ipairs(buf_row) do
            new_buf[i][j] = pix
        end
    end

    -- tracy: ZoneEnd
    return new_buf
end

-- Convert the buffer into something recognized by digiscreen
-- x:y+w+h (we don't validate whether the buffe is big enough)
function F.gpu.to_screen(buf, x, y, w, h, background)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.to_screen

    local arr = {}
    background = background or 0

    for i = y, y + h - 1 do
        local arr_row = {}
        local buf_row = buf[i]
        for j = x, x + w - 1 do
            local pix = buf_row[j]
            if pix == false then
                pix = background
            end
            arr_row[#arr_row + 1] = string.format("%06X", pix)
        end
        arr[#arr+1] = arr_row
    end

    -- tracy: ZoneEnd
    return arr
end

-- Overlay etc

-- Overlay buf2 onto buf
function F.gpu.overlay_buf(buf, buf2, x, y, apply)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.overlay_buf

    for i, buf2_row in ipairs(buf2) do
        for j, buf2_pix in ipairs(buf2_row) do
            local new_x = j + x - 1
            local new_y = i + y - 1

            -- It is possible that we are out of range
            -- e.g. when overlaying a marquee, shifting part of it out of bound
            -- In that case, just ignore it

            local buf_row = buf[new_y]
            if buf[new_y] and buf[new_y][new_x] ~= nil then
                if apply then
                    buf2_pix = apply(j, i, buf2_pix)
                end

                if buf2_pix ~= false then
                    buf[new_y][new_x] = buf2_pix
                end
            end
        end
    end

    -- tracy: ZoneEnd
end

function F.gpu.apply(buf, func)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.apply

    for y, buf_row in ipairs(buf) do
        for x, pix in ipairs(buf_row) do
            buf[y][x] = func(x, y, pix)
        end
    end

    -- tracy: ZoneEnd
end

-- Apply color on non-false bits of a buffer
-- Used to apply color onto fonts or change an icon into monochrome
function F.gpu.apply_color(buf, color)
    return F.gpu.apply(buf, function(x, y, pix)
        if pix then
            return color
        end
        return pix
    end)
end

-- Shapes and bulk drawings

function F.gpu.fill(buf, color, x, y, w, h)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.fill

    for i = y, y + h - 1 do
        for j = x, x + w - 1 do
            buf[i][j] = color
        end
    end

    -- tracy: ZoneEnd
end

function F.gpu.rectangle(buf, color, x, y, w, h)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.rectangle

    -- Top and bottom lines
    for _, i in ipairs({ y, y + h - 1 }) do
        for j = x, x + w - 1 do
            buf[i][j] = color
        end
    end

    if h >= 2 then
        -- The remaining two sides
        for i = y + 1, y + h - 2 do
            for _, j in ipairs({ x, x + w - 1 }) do
                buf[i][j] = color
            end
        end
    end

    -- tracy: ZoneEnd
end

function F.gpu._circle_plot_point(buf, color, xc, yc, x, y)
    buf[yc+y][xc+x] = color
    buf[yc+y][xc-x] = color
    buf[yc-y][xc+x] = color
    buf[yc-y][xc-x] = color
    buf[yc+x][xc+y] = color
    buf[yc+x][xc-y] = color
    buf[yc-x][xc+y] = color
    buf[yc-x][xc-y] = color
end

function F.gpu.circle(buf, color, xc, yc, r)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.circle
    local x = 0
    local y = r
    local d = 3 - 2 * r
    F.gpu._circle_plot_point(buf, color, xc, yc, x, y)

    while y >= x do
        if d > 0 then
            y = y - 1
            d = d + 4 * (x - y) + 10
        else
            d = d + 4 * x + 6
        end

        x = x + 1

        F.gpu._circle_plot_point(buf, color, xc, yc, x, y)
    end

    -- tracy: ZoneEnd
end

function F.gpu.line(buf, color, x0, y0, x1, y1)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.line

    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    local err = dx - dy

    while true do
        -- Safety check to ensure we are within buffer bounds
        if buf[y0] and buf[y0][x0] ~= nil then
            buf[y0][x0] = color
        end

        if x0 == x1 and y0 == y1 then break end
        
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x0 = x0 + sx
        end
        if e2 < dx then
            err = err + dx
            y0 = y0 + sy
        end
    end

    -- tracy: ZoneEnd
end


-- Scaling

-- Create an enlarged version of a buffer
-- This is a generator
function F.gpu.int_enlarge(buf, ratio)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.int_enlarge

    -- Input validation: ratio should be a positive integer
    ratio = math.max(1, math.floor(ratio or 1))
    
    local old_h = #buf
    local old_w = #buf[1]
    
    -- Calculate new dimensions
    local new_w = old_w * ratio
    local new_h = old_h * ratio
    
    -- Create the new target buffer
    local new_buf = F.gpu.new_buffer(new_w, new_h, false)
    
    for y, row in ipairs(buf) do
        for x, pix in ipairs(row) do
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
function F.gpu.render_font(buf, str, x, y, color, bkg)
    -- tracy: ZoneBeginN PIS_v3::F.gpu.render_font

    if type(str) ~= "string" then
        -- tracy: ZoneEnd
        error("string expected", 2)
    end

    color = color or 0xFFFFFF
    bkg = bkg or false

    local offset_x = x - 6
    for i = 1, #str do
        offset_x = offset_x + 6

        local char = string.byte(str, i)
        local font = F.screen_chars[char] or F.screen_icons.font_not_found
        F.gpu.overlay_buf(buf, font, offset_x, y, function(x, y, pix)
            if pix == false then return bkg end
            return color
        end)
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
