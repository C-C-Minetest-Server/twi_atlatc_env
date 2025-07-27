local here = "CED"

local data1 = F.get_express_station_display_lines({
    here = here,
    track = "1",
    -- line = "",
    -- dir = "",
})

local data2 = F.get_express_station_display_lines({
    here = here,
    track = "2",
    -- line = "",
    -- dir = "",
})

display(table.concat(data1, "\n"), table.concat(data2, "\n"))