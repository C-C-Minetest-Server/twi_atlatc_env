assert(is_loading)

local TEXTURE_BASE = "additional_textures_pisv3_base.png"
local TEXTURE_APPROACHING = "additional_textures_pisv3_approaching.png"
local TEXTURE_ARRIVED = "additional_textures_pisv3_arrived.png"

F.flat_marquee_text = ""
F.flat_marquee_last = 0

function F.flat_update_marquee()
    while #F.flat_marquee_text < 32 do
        local ad_id
        repeat
            ad_id = math.random(1, #F.marquee_advertisements)
        until ad_id ~= F.flat_marquee_last or #F.marquee_advertisements == 1
        F.flat_marquee_last = ad_id
        F.flat_marquee_text = F.flat_marquee_text .. F.marquee_advertisements[ad_id][1] .. "     "
    end
    F.flat_marquee_text = string.sub(F.flat_marquee_text, 2)
end

function F.get_flat_display_buffer(def)
    F.handle_pis_option_alternatives(def)

    local track_key = def.station_id .. ":" .. def.track_id
    local list_of_trains = F.pis_list_of_trains[track_key]
    local train_stopped_id = F.pis_train_stopped_on_track[track_key]
    local train_stopped_data = list_of_trains and list_of_trains[train_stopped_id] or nil

    local buf
    local mode = "idle"

    if train_stopped_data and not def.no_current_train then
        buf = F.flat.new_buffer(252, 84, TEXTURE_ARRIVED)
        mode = "arrived"
    else
        buf = F.flat.new_buffer(252, 84, TEXTURE_BASE)
    end

    local text_left = {
        def.custom_header or ("PLATFORM " .. def.track_id .. ":"),
    }

    local text_right = {
        rwt_to_string_minutes(rwt.now()),
    }

    F.flat.overlay_text(buf, 2 + 2, 2, def.custom_header or ("PLATFORM " .. def.track_id .. ":"), "#010101", 1)
    F.flat.overlay_text(buf, 251 - 4, 2, rwt_to_string_minutes(rwt.now()), "#010101", 1, "rt")

    if mode == "arrived" then
        local line_code = train_stopped_data.line_code
        local line_name = train_stopped_data.line_name
        local heading_to = train_stopped_data.heading_to

        -- Large line code display
        F.flat.overlay_text(buf, 5 + (4 - #line_code) * 8, 4 + 12, line_code, "#010101", 2)

        -- Basic information
        local time_diff = rwt.diff(rwt.now(), train_stopped_data.estimated_time)
        local line_name_str = F.handle_variable_length_string(line_name, 21, true)
        local dest_str_len = train_stopped_data.no_to_prefix and 21 or 18
        local dest_str = F.handle_variable_length_string(heading_to, dest_str_len, true)
        local time_str = "Leaving " .. (time_diff > 0 and ("in " .. F.seconds_to_string_shorter(time_diff)) or "now")
        local full_str = line_name_str ..
            (train_stopped_data.no_to_prefix and "\n" or "\nTo ") .. dest_str .. "\n" .. time_str

        F.flat.overlay_text(buf, 76, 2 + 16, full_str, "#010101", 1)
        
        F.flat.overlay_text(buf, 125, 2 + 16 * 4, "Walk inside and stop moving.", "#94FF6F", 1, "ct")
    else
        F.make_sure_sorted_trains_exist(track_key)
        local train_sorted_ids = F.pis_list_of_trains_sorted[track_key] or {}

        local left_txts = {}
        local right_txts = {}

        local max_line = 3
        local pt = 1
        local i = 1
        while i <= max_line and pt <= #train_sorted_ids do
            local train_id = train_sorted_ids[pt]
            local train_data = F.pis_list_of_trains[track_key][train_id]

            if rwt.is_before(rwt.now(), rwt.add(train_data.estimated_time, 10)) then
                local station_name_length = 20
                local arrive_time_string = rwt_to_string_minutes(train_data.estimated_time)

                if train_data.train_status == "stopped" then
                    station_name_length = station_name_length - 4
                    right_txts[#right_txts+1] = "Dep." .. arrive_time_string
                else
                    right_txts[#right_txts+1] = "    " .. arrive_time_string
                end

                if def.no_line_id then
                    station_name_length = station_name_length + 5
                    left_txts[#left_txts+1] =
                        F.handle_variable_length_string(train_data.heading_to, station_name_length, true)
                else
                    -- Line code
                    left_txts[#left_txts+1] = string.format(
                        "%-4s %s", train_data.line_code,
                        F.handle_variable_length_string(train_data.heading_to, station_name_length, true)
                    )
                end

                if i == 1 and train_data.train_status == "approaching" and not def.no_current_train then
                    max_line = 2

                    F.flat.overlay_texture(buf, 2, 50, "[fill:250x32:#DDDD00")

                    local color = os.time() % 2 == 0 and "#BE0302" or "#010101"
                    F.flat.overlay_text(buf, 125, 2 + 16 * 3, "TRAIN APPROACHING", color, 1, "ct")
                    F.flat.overlay_text(buf, 125, 2 + 16 * 4, "STAY IN YELLOW LINE", color, 1, "ct")
                end

                i = i + 1
            end

            pt = pt + 1
        end

        F.flat.overlay_text(buf, 4, 2 + 16, table.concat(left_txts, "\n"), "#010101", 1)
        F.flat.overlay_text(buf, 251 - 4, 2 + 16, table.concat(right_txts, "\n"), "#010101", 1, "rt")

        if max_line == 3 then
            F.flat.overlay_text(buf, 125, 2 + 16 * 4, string.sub(F.flat_marquee_text, 1, 31), "#94FF6F", 1, "ct")
        end
    end

    return buf
end

function F.get_flat_display(def)
    return {
        texture_front = F.flat.render_texture(F.get_flat_display_buffer(def)),
        visual_size = { x = 3, y = 1, z = 1 },
    }
end
