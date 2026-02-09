assert(is_loading)

function F.get_interchange_string(line_id, station_id)
    local disp = ""
    local counter = 0
    line_id = F.interchange_line_alias[line_id] or line_id

    local interchanges = F.station_interchange[station_id] or {}
    for _, int_line_id in ipairs(interchanges) do
        if line_id ~= int_line_id then
            local int_line_def = F.stn_v3_lines[int_line_id]
            counter = counter + 1
            disp = disp
                .. (int_line_def and F.handle_variable_length_string(int_line_def.name) or int_line_id)
                .. (counter % 3 == 0 and ",\n" or ", ")
        end
    end

    return disp == "" and "" or ("\nInterchanges: " .. disp)
end

function F.get_internal_display(line_id, station_id, additional_info)
    local station_name = F.station_names[station_id]

    return (station_name and F.handle_variable_length_string(station_name) or station_id)
        .. (additional_info and ("\n" .. additional_info) or "")
        .. F.get_interchange_string(line_id, station_id)
end
