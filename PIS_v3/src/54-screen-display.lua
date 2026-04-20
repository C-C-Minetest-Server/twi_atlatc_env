assert(is_loading)

F.screen_background = F.gpu.new_buffer(64 * 3, 64, 0)
F.gpu.rectangle(F.screen_background, 0xA0A0A0, 1, 1, 64 * 3, 64) -- frame
F.gpu.rectangle(F.screen_background, 0xA0A0A0, 2, 2, 64 * 3 - 2, 64 - 2) -- frame
F.gpu.fill(F.screen_background, 0xDEDEDE, 3, 3, 64 * 3 - 4, 64 - 4) -- bkg
F.gpu.fill(F.screen_background, 0xC2C2C2, 3, 15, 64 * 3 - 4, 12) -- strip 1
F.gpu.fill(F.screen_background, 0xC2C2C2, 3, 39, 64 * 3 - 4, 12) -- strip 2
F.gpu.fill(F.screen_background, 0x00ABFF, 3, 64 - 13, 64 * 3 - 4, 12) -- marquee bkg

F.screen_arrived_background = F.gpu.copy_buffer(F.screen_background)
F.gpu.fill(F.screen_arrived_background, 0xADADAD, 3, 15, 4 * 6 * 2 + 6, 24) -- ID background
F.gpu.render_font(F.screen_arrived_background, "Walk inside and stop moving.", 12, 4 + 12 * 4, 0x94FF6F) -- hard-coded message

F.screen_approaching_overlay = F.gpu.new_buffer(188, 24)
F.gpu.fill(F.screen_approaching_overlay, 0xDDDD00, 1, 1, 188, 24)
F.gpu.render_font(F.screen_approaching_overlay, "TRAIN APPROACHING", 43, 1, 0xBE0302)
F.gpu.render_font(F.screen_approaching_overlay, "STAY IN YELLOW LINE", 37, 13, 0xBE0302)

F.screen_approaching_overlay_alt = F.gpu.new_buffer(188, 24)
F.gpu.fill(F.screen_approaching_overlay_alt, 0xDDDD00, 1, 1, 188, 24)
F.gpu.render_font(F.screen_approaching_overlay_alt, "TRAIN APPROACHING", 43, 1, 0)
F.gpu.render_font(F.screen_approaching_overlay_alt, "STAY IN YELLOW LINE", 37, 13, 0)

-- 192x64 buffer to three screens
-- It is proved via Tracy profiling that sending partial buffer is more efficient
function F.wide_buffer_to_screen(buf, screen1, screen2, screen3)
    -- tracy: ZoneBeginN PIS_v3::F.wide_buffer_to_screen
    digiline_send(screen1, buf)
    -- tracy: ZoneEnd
end


-- Marquees
local MARQUEE_MAX_CHAR = 31
local MARQUEE_SPACER = "     " -- 5 spaces
local MARQUEE_COLOR = 0x94FF6F
local MARQUEE_BKG = 0x00ABFF

F.marquee_shift = false
F.marquee_last = 0
F.marquee_current = ""
F.marquee_buffer_int = F.gpu.new_buffer((MARQUEE_MAX_CHAR + 1) * 6, 12, MARQUEE_BKG)
F.marquee_buffer = F.gpu.new_buffer(MARQUEE_MAX_CHAR * 6, 12, MARQUEE_BKG)

-- Run every 0.5 seconds by panel self-interrupt
function F.update_marquee()
    -- tracy: ZoneBeginN PIS_v3::F.update_marquee
    while #F.marquee_current < 1 do
        local ad_id
        repeat
            ad_id = math.random(1, #F.marquee_advertisements)
        until ad_id ~= F.marquee_last
        F.marquee_last = ad_id
        F.marquee_current = F.marquee_current .. F.marquee_advertisements[ad_id][1] .. MARQUEE_SPACER
    end

    if F.marquee_shift then
        -- Append one char to the internal buffer
        F.gpu.render_font(F.marquee_buffer_int, string.sub(F.marquee_current, 1, 1), MARQUEE_MAX_CHAR * 6 + 1, 1, MARQUEE_COLOR, MARQUEE_BKG)

        -- Apply to the public buffer
        F.gpu.overlay_buf(F.marquee_buffer, F.marquee_buffer_int, -2, 1)

        -- Eat one character away
        F.marquee_current = string.sub(F.marquee_current, 2)
    else
        -- left shift everything in the internal buffer
        -- A trick that works very well
        F.gpu.overlay_buf(F.marquee_buffer_int, F.marquee_buffer_int, -5, 1)

        -- Apply to the public buffer
        F.gpu.overlay_buf(F.marquee_buffer, F.marquee_buffer_int, 1, 1)
    end

    F.marquee_shift = not F.marquee_shift
    -- tracy: ZoneEnd
end

local function seconds_to_string_shorter(seconds_raw)
    seconds_raw = math.floor(seconds_raw)
    if seconds_raw <= 0 then
        return seconds_raw .. " sec."
    end

    local minutes = floor_div(seconds_raw, 60)
    local seconds = seconds_raw % 60

    local components = {}
    components[#components + 1] = minutes ~= 0 and (minutes .. " m") or nil
    components[#components + 1] = seconds .. " sec." -- So it does not blink

    return table.concat(components, " ")
end

function F.get_screen_buffer(def)
    F.handle_pis_option_alternatives(def)
    -- tracy: ZoneBeginN PIS_v3::F.get_screen_buffer

    local track_key = def.station_id .. ":" .. def.track_id
    local list_of_trains = F.pis_list_of_trains[track_key]
    local train_stopped_id = F.pis_train_stopped_on_track[track_key]
    local train_stopped_data = list_of_trains and list_of_trains[train_stopped_id] or nil
    
    local buf
    local mode = "idle"


    -- tracy: ZoneBeginN PIS_v3::F.get_screen_buffer::copy_buffer
    if train_stopped_data and not def.no_current_train then
        buf = F.gpu.copy_buffer(F.screen_arrived_background)
        mode = "arrived"
    else
        buf = F.gpu.copy_buffer(F.screen_background)
    end
    -- tracy: ZoneEnd

    -- Header
    -- tracy: ZoneBeginN PIS_v3::F.get_screen_buffer::render_header
    F.gpu.render_font(buf, def.custom_header or ("PLATFORM " .. def.track_id .. ":"), 4, 3, 0)
    F.gpu.render_font(buf, rwt_to_string_minutes(rwt.now()), 192 - 1 - 5 * 6, 3, 0)
    -- tracy: ZoneEnd


    if mode == "arrived" then
        -- tracy: ZoneBeginN PIS_v3::F.get_screen_buffer::render_arrive
        local line_code = train_stopped_data.line_code
        local line_name = train_stopped_data.line_name
        local heading_to = train_stopped_data.heading_to

        -- Large line code display
        local insert_x = 6
        local line_buf = F.gpu.get_string_buffer(line_code, 0)
        local line_scaled_buf = F.gpu.int_enlarge(line_buf, 2)
        F.gpu.overlay_buf(buf, line_scaled_buf, 6 + (4 - #line_code) * 6, 4 + 12)

        -- Basic information
        local time_diff = rwt.diff(rwt.now(), train_stopped_data.estimated_time)
        local line_name_str = F.handle_variable_length_string(line_name, 21)
        local dest_str_len = train_stopped_data.no_to_prefix and 21 or 18
        local dest_str = F.handle_variable_length_string(heading_to, dest_str_len)
        local time_str = "Leaving " .. (time_diff > 0 and ("in " .. seconds_to_string_shorter(time_diff)) or "now")

        F.gpu.render_font(buf, line_name_str, 3 + 4 * 6 * 2 + 6 + 2, 4 + 12, 0)
        F.gpu.render_font(buf, (train_stopped_data.no_to_prefix and "" or "To ") .. dest_str, 3 + 4 * 6 * 2 + 6 + 2, 4 + 12 * 2, 0)
        F.gpu.render_font(buf, time_str, 3 + 4 * 6 * 2 + 6 + 2, 4 + 12 * 3, 0)

        -- tracy: ZoneEnd
    else
        -- tracy: ZoneBeginN PIS_v3::F.get_screen_buffer::render_idle
        F.make_sure_sorted_trains_exist(track_key)
        local train_sorted_ids = F.pis_list_of_trains_sorted[track_key] or {}

        local max_line = 3
        local pt = 1
        local i = 1
        while i <= max_line and pt <= #train_sorted_ids do
            local train_id = train_sorted_ids[pt]
            local train_data = F.pis_list_of_trains[track_key][train_id]

            if rwt.is_before(rwt.now(), rwt.add(train_data.estimated_time, 10)) then
                local station_name_length = 20
                local station_name_pos = 4 + 5 * 6
                local arrive_time_string = rwt_to_string_minutes(train_data.estimated_time)

                if def.no_line_id then
                    station_name_length = station_name_length + 5
                    station_name_pos = station_name_pos - 5 * 6
                else
                    -- Line code
                    F.gpu.render_font(buf, train_data.line_code, 4, 3 + 12 * i, 0)
                end

                if train_data.train_status == "stopped" then
                    station_name_length = station_name_length - 4
                    F.gpu.render_font(buf, "Dep." .. arrive_time_string, 192 - 1 - 9 * 6, 3 + 12 * i, 0)
                else
                    F.gpu.render_font(buf, arrive_time_string, 192 - 1 - 5 * 6, 3 + 12 * i, 0)
                end

                local station_nae_str = F.handle_variable_length_string(train_data.heading_to, station_name_length)
                F.gpu.render_font(buf, station_nae_str, station_name_pos, 3 + 12 * i, 0)

                if i == 1 and train_data.train_status == "approaching" then
                    max_line = 2
                    local overlay = os.time() % 2 == 0 and F.screen_approaching_overlay or F.screen_approaching_overlay_alt
                    F.gpu.overlay_buf(buf, overlay, 3, 39)
                end

                i = i + 1
            end

            pt = pt + 1
        end

        if max_line == 3 then
            F.gpu.overlay_buf(buf, F.marquee_buffer, 4, 3 + 12 * 4)
        end

        -- tracy: ZoneEnd
    end

    -- tracy: ZoneEnd

    return buf
end
