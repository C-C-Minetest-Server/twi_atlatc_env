assert(is_loading)

local function rwt_to_string_minutes(rwt_obj)
    return string.sub(rwt.to_string(rwt_obj, true), 4)
end

F.show_advertisement = 0
F.last_advertisement = 0

function F.handle_pis_option_alternatives(def)
    def.station_id = def.station_id or def.here or nil
    def.track_id = def.track_id or def.track or def.platform_id or nil
    def.line_id = def.line_id or def.line or nil
end

function F.get_pis_single_line(def)
    F.handle_pis_option_alternatives(def)

    local lines = {}
    lines[#lines + 1] = string.format("%-20s %s",
        def.custom_header or ("PLATFORM " .. def.track_id .. ":"), rwt_to_string_minutes(rwt.now()))

    local track_key = def.station_id .. ":" .. def.track_id
    F.make_sure_sorted_trains_exist(track_key)
    local train_coming_id = F.pis_list_of_trains_sorted[track_key] and F.pis_list_of_trains_sorted[track_key][1]
    local train_coming_data =
        F.pis_list_of_trains[track_key] and F.pis_list_of_trains[track_key][train_coming_id] or nil

    local line_name = train_coming_data and train_coming_data.line_name or def.line_name or nil
    local heading_to = train_coming_data and train_coming_data.heading_to or def.heading_to or nil

    if line_name and heading_to then
        lines[#lines + 1] = F.handle_variable_length_string(line_name, 29)
        lines[#lines + 1] = "To " .. F.handle_variable_length_string(heading_to, 26)

        if train_coming_data and train_coming_data.estimated_time then
            local time_diff = rwt.diff(rwt.now(), train_coming_data.estimated_time)
            local prefix = train_coming_data.train_status == "stopped" and "Leaving " or "Arriving "
            if time_diff > 0 then
                lines[#lines + 1] = prefix .. "in " .. time_diff .. " sec."
            else
                lines[#lines + 1] = prefix .. " now"
            end
        end
    else
        lines[#lines + 1] = "Not in Service"
        lines[#lines + 1] = "!! NEVER WALK !!"
        lines[#lines + 1] = "!! ON TRACKS  !!"
    end

    return lines
end

function F.get_pis_multi_line(def)
    F.handle_pis_option_alternatives(def)

    local track_key = def.station_id .. ":" .. def.track_id
    local train_stopped_id = F.pis_train_stopped_on_track[track_key]
    local train_stopped_data =
        F.pis_list_of_trains[track_key] and F.pis_list_of_trains[track_key][train_stopped_id] or nil

    if train_stopped_data and not def.no_current_train then
        return F.get_pis_single_line(def)
    end

    F.make_sure_sorted_trains_exist(track_key)
    local train_sorted_ids = F.pis_list_of_trains_sorted[track_key] or {}
    local lines = {}
    lines[#lines + 1] = string.format("%-20s %s",
        def.custom_header or ("PLATFORM " .. def.track_id .. ":"), rwt_to_string_minutes(rwt.now()))

    for i = 1, math.min(#train_sorted_ids, 3) do
        local train_id = train_sorted_ids[i]
        local train_data = F.pis_list_of_trains[track_key][train_id]

        local station_name_length = 15
        local format_base = "%-4s %-15s %s"
        if train_data.train_status == "stopped" then
            station_name_length = 13
            format_base = "%-4s %-13s D.%s"
        end

        lines[#lines + 1] = string.format(format_base,
            train_data.line_code, F.handle_variable_length_string(train_data.heading_to, station_name_length),
            rwt_to_string_minutes(train_data.estimated_time))

        if i == 1 and train_data.train_status == "approaching" and not def.no_current_train then
            lines[#lines + 1] = F.approach_warning[1]
            lines[#lines + 1] = F.approach_warning[2]
            break
        elseif F.show_advertisement ~= 0 then
            lines[#lines + 1] = F.pis_advertisements[F.show_advertisement][1]
            lines[#lines + 1] = F.pis_advertisements[F.show_advertisement][2]
            break
        end
    end

    if #lines == 1 then
        local show_lines =
            F.show_advertisement == 0 and F.yellow_line_warning or F.pis_advertisements[F.show_advertisement]

        lines[#lines + 1] = " "
        lines[#lines + 1] = show_lines[1]
        lines[#lines + 1] = show_lines[2]
    end

    return lines
end

function F.get_pis_compat(def)
    F.handle_pis_option_alternatives(def)

    local lines = {}
    lines[#lines + 1] = def.custom_header or ("PLATFORM " .. def.track_id .. ":")

    local track_key = def.station_id .. ":" .. def.track_id
    F.make_sure_sorted_trains_exist(track_key)
    local train_coming_id = F.pis_list_of_trains_sorted[track_key] and F.pis_list_of_trains_sorted[track_key][1]
    local train_coming_data =
        F.pis_list_of_trains[track_key] and F.pis_list_of_trains[track_key][train_coming_id] or nil

    local line_id = train_coming_data and train_coming_data.line_id or def.line_id or nil
    local direction_code = train_coming_data and train_coming_data.direction_code or def.direction_code or nil
    local eta_string = "NO DATA"
    if train_coming_data then
        local eta = train_coming_data.estimated_time
        eta_string = (train_coming_data.train_status == "stopped" and " Dep. " or " Arr. ") ..
            (eta and rwt.diff(rwt.now(), eta) or "?")
    end

    if line_id and direction_code then
        lines[#lines + 1] = line_id .. " " .. direction_code .. ": " .. eta_string
    else
        lines[#lines + 1] = "NOT IN SERVICE"
    end

    return lines
end

function F.get_status_textline_line(def)
    F.handle_pis_option_alternatives(def)
    local track_key = def.station_id .. ":" .. def.track_id
    F.make_sure_sorted_trains_exist(track_key)

    local disp = def.track_id .. ": "

    local train_coming_id = F.pis_list_of_trains_sorted[track_key] and F.pis_list_of_trains_sorted[track_key][1]
    local train_coming_data =
        F.pis_list_of_trains[track_key] and F.pis_list_of_trains[track_key][train_coming_id] or nil

    local line_id = train_coming_data and train_coming_data.line_id or def.line_id or nil
    local heading_to_id = train_coming_data and train_coming_data.heading_to_id or def.heading_to_id or nil
    local heading_to = train_coming_data and train_coming_data.heading_to or def.heading_to or nil

    disp = disp .. line_id .. " "
    if heading_to_id then
        disp = disp .. "-> " .. heading_to_id
    else
        disp = disp .. F.handle_variable_length_string(heading_to, 10)
    end

    local eta = train_coming_data and train_coming_data.estimated_time
    local append_text = eta and ((train_coming_data.train_status == "stopped" and " Dep. " or " Arr. ") ..
        (eta and rwt.diff(rwt.now(), eta) or "?")) or ""
    disp = string.format("%-" .. (26 - #append_text) .. "s", disp) .. append_text

    return disp
end

function F.update_advertisement()
    local now = os.time()
    local sec_in_minute = now % 20

    -- Pick advertisement
    if sec_in_minute < 7 then
        if F.show_advertisement == 0 then
            repeat
                F.show_advertisement = math.random(1, #F.pis_advertisements)
            until F.show_advertisement ~= F.last_advertisement or #F.pis_advertisements == 1
        end
    elseif F.show_advertisement ~= 0 then
        F.last_advertisement = F.show_advertisement
        F.show_advertisement = 0
    end
end
