--luacheck: ignore

local station = "GRH"
local track = "1"
local number_displays = 2

if not event.display or not event.refresh then
    return
end

if event.refresh or not display_cache then
    display_cache = F.get_track_status_textline_info_lines(station, track)
end

local header = station .. " Track " .. track
header = string.format("%20s %s", header, rwt.to_string(rwt.now()))

local displaying_to = 1
local display_buffer = { header }
for _, line in ipairs(display_cache) do
    if displaying_to > number_displays then
        break
    end

    display_buffer[#display_buffer+1] = line
    if #display_buffer >= 4 then
        digiline_send(tostring(displaying_to), table.concat(display_buffer, "\n"))
        display_buffer = {}
        displaying_to = displaying_to + 1
    end
end