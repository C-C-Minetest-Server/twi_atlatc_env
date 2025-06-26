--luacheck: ignore

local station = "GRO"
local track = "2"
local number_displays = 2

if not event.display and not event.refresh then
    return
end

if event.refresh or not display_cache then
    display_cache = F.get_track_status_textline_info_lines(station, track)
end

local header = station .. " Track " .. track
header = string.format("%-20s %s", header, rwt.to_string(rwt.now(), true))

local displaying_to = 1
local display_buffer = { header }
for _, line in ipairs(display_cache) do
    if displaying_to > number_displays then
        break
    end

    display_buffer[#display_buffer + 1] = line
    if #display_buffer >= 4 then
        digiline_send(tostring(displaying_to), table.concat(display_buffer, "\n"))
        display_buffer = {}
        displaying_to = displaying_to + 1
    end
end

if #display_buffer ~= 0 and displaying_to <= number_displays then
    digiline_send(tostring(displaying_to), table.concat(display_buffer, "\n"))
    displaying_to = displaying_to + 1
end

if displaying_to <= number_displays then
    for i = displaying_to, number_displays + 1 do
        digiline_send(tostring(i), "")
    end
end
