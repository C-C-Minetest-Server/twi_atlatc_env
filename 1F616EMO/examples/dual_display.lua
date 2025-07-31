local here = "SPN"
local track1 = "1"
local track2 = "2"

local data1 = F.get_express_station_display_lines({
    here = here,
    track = track1,
})

local data2 = F.get_express_station_display_lines({
    here = here,
    track = track2,
})

display(table.concat(data1, "\n"), table.concat(data2, "\n"))