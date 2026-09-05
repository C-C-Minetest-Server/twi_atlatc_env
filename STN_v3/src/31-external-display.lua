assert(is_loading)

function F.set_external_display_regular(train, line_id, point_id)
    local disp_lines = {}

    local line_def = F.stn_v3_lines[line_id]
    local station_def = line_def.stations[point_id]

    if type(station_def) == "function" then
        local _, new_station_def = F.get_train_arrival_time_at(train:get_id(), point_id)
        station_def = new_station_def
    end

    disp_lines[#disp_lines + 1] = line_def.name and F.handle_variable_length_string(line_def.name) or line_id

    if station_def and station_def.next then
        local next_point_id = station_def.next
        local next_point_id_components = string_split(next_point_id, ":")
        local next_station_id = next_point_id_components[1]
        local next_station_name = F.station_names[next_station_id]
        disp_lines[#disp_lines + 1] = "Next: " ..
            (next_station_name and F.handle_variable_length_string(next_station_name) or next_station_id)
    else
        disp_lines[#disp_lines + 1] = "Next: Unknown"
    end

    local terminus_name = "Unknown"
    if station_def and station_def.dir then
        local train_dir = station_def.dir

        if type(train_dir) == "function" then
            train_dir = train_dir(train)
        end

        local terminus_id = line_def.termini[train_dir] or "Unknown"

        terminus_name = F.handle_variable_length_string(F.station_names[terminus_id] or terminus_id)
    end

    disp_lines[#disp_lines + 1] = line_def.no_to_prefix and terminus_name or ("Terminus: " .. terminus_name)

    train:set_text_outside(table.concat(disp_lines, "\n"))
end

function F.set_external_display_subway(train, line_id, point_id, disp_max_len)
    local disp_lines = {}

    local line_def = F.stn_v3_lines[line_id]
    local station_def = line_def.stations[point_id]

    if type(station_def) == "function" then
        local _, new_station_def = F.get_train_arrival_time_at(train:get_id(), point_id)
        station_def = new_station_def
    end

    local terminus_name = "Unknown"
    if station_def and station_def.dir then
        local train_dir = station_def.dir

        if type(train_dir) == "function" then
            -- func(train: train)
            train_dir = train_dir(train)
        end

        local terminus_id = line_def.termini[train_dir]

        terminus_name = F.station_names[terminus_id] or terminus_id
        disp_lines[#disp_lines + 1] = F.handle_variable_length_string(terminus_name, disp_max_len)
    else
        disp_lines[#disp_lines + 1] = "Unknown terminus"
    end

    disp_lines[#disp_lines + 1] = line_def.name and F.handle_variable_length_string(line_def.name) or line_id

    if station_def and station_def.next then
        local next_point_id = station_def.next
        local next_point_id_components = string_split(next_point_id, ":")
        local next_station_id = next_point_id_components[1]
        local next_station_name = F.station_names[next_station_id]
        disp_lines[#disp_lines + 1] = "Next: " ..
            (next_station_name and F.handle_variable_length_string(next_station_name) or next_station_id)
    else
        disp_lines[#disp_lines + 1] = "Next: Unknown"
    end

    disp_lines[#disp_lines + 1] = ("Terminus: " .. F.handle_variable_length_string(terminus_name))

    train:set_text_outside(table.concat(disp_lines, "\n"))
end

function F.set_external_display(train, line_id, point_id)
    if train:has_rc("WG-01700") then
        return F.set_external_display_subway(train, line_id, point_id, 11)
    elseif train:has_rc("WG-MPL16") or train:has_rc("WG-30000") then
        return F.set_external_display_subway(train, line_id, point_id, 14)
    else
        return F.set_external_display_regular(train, line_id, point_id)
    end
end
