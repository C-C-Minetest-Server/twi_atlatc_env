assert(is_loading)

F.control_room_track = function(station, track)
    local displays = {}

    local header = station .. ":" .. track
    header = string.format("%-20s %s", header, rwt.to_string(rwt.now(), true))
    displays[#displays+1] = header

    local plat_disp_data = F.platform_display_control[station .. ":" .. track]
    if plat_disp_data then
        displays[#displays+1] =
            plat_disp_data.status .. " " ..
            plat_disp_data.atc_id .. " " ..
            (plat_disp_data.line_id or "") .. " " ..
            (plat_disp_data.line_dir or "") .. " " ..
            (plat_disp_data.rwt_end and rwt.to_string(plat_disp_data.rwt_end, true) or "")
    else
        displays[#displays+1] = "---"
    end

    local data = F.sort_track_destination_data(station .. ":" .. track)
    for _, line in ipairs(data) do
        displays[#displays+1] =
            line.atc_id .. " " ..
            line.from .. " " ..
            line.line_code .. " " ..
            line.line_dir .. " " ..
            rwt.to_string(rwt.add(rwt.now(), line.time_left), true)
    end

    return displays
end