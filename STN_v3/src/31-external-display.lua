assert(is_loading)

function F.set_external_display_regular(train, line_id, point_id)
    local line_def = F.stn_v3_lines[line_id]
    local station_def = line_def.stations[point_id]
    local disp_lines = {}

    disp_lines[#disp_lines + 1] = line_def.name and F.handle_variable_length_string(line_def.name) or line_id

    local next_point_id = station_def.next
    local next_point_id_components = string_split(next_point_id, ":")
    local next_station_id = next_point_id_components[1]
    local next_station_name = F.station_names[next_station_id]
    disp_lines[#disp_lines + 1] = "Next: " ..
        (next_station_name and F.handle_variable_length_string(next_station_name) or next_station_id)

    local train_dir = station_def.dir
    local terminus_id = line_def.termini[train_dir]
    local terminus_name = F.station_names[terminus_id]
    disp_lines[#disp_lines + 1] = terminus_name
        and ("Terminus: " .. F.handle_variable_length_string(terminus_name)) or terminus_id

    train:set_text_outside(table.concat(disp_lines, "\n"))
end

function F.set_external_display_subway(train, line_id, point_id, disp_max_len)
    local line_def = F.stn_v3_lines[line_id]
    local station_def = line_def.stations[point_id]
    local disp_lines = {}

    local train_dir = station_def.dir
    local terminus_id = line_def.termini[train_dir]
    local terminus_name = F.station_names[terminus_id]
    disp_lines[#disp_lines + 1] =
        terminus_name and F.handle_variable_length_string(terminus_name, disp_max_len) or terminus_id

    disp_lines[#disp_lines + 1] = line_def.name and F.handle_variable_length_string(line_def.name) or line_id

    local next_point_id = station_def.next
    local next_point_id_components = string_split(next_point_id, ":")
    local next_station_id = next_point_id_components[1]
    local next_station_name = F.station_names[next_station_id]
    disp_lines[#disp_lines + 1] = "Next: " ..
        (next_station_name and F.handle_variable_length_string(next_station_name) or next_station_id)

    disp_lines[#disp_lines + 1] = terminus_name
        and ("Terminus: " .. F.handle_variable_length_string(terminus_name)) or terminus_id

    train:set_text_outside(table.concat(disp_lines, "\n"))
end

function F.set_external_display(train, line_id, point_id)
    if train:has_rc("WG-01700") then
        return F.set_external_display_subway(train, line_id, point_id, 11)
    elseif train:has_rc("WG-MPL16") then
        return F.set_external_display_subway(train, line_id, point_id, 14)
    else
        return F.set_external_display_regular(train, line_id, point_id)
    end
end
