-- luacheck: no unused

assert(is_loading)

local F, S = F, S
local rwt = rwt

do
    local formspec_escapes = {
        ["\\"] = "\\\\",
        ["["] = "\\[",
        ["]"] = "\\]",
        [";"] = "\\;",
        [","] = "\\,",
        ["$"] = "\\$",
        [":"] = "\\:",
        ["^"] = "\\^",
    }
    function F.formspec_escape(text)
        -- Use explicit character set instead of dot here because it doubles the performance
        return text and ("").gsub(text, "[\\%[%];,$]", formspec_escapes)
    end
    function F.formspec_escape_combine(text)
        -- Use explicit character set instead of dot here because it doubles the performance
        return text and ("").gsub(text, "[\\%[%];,$:^]", formspec_escapes)
    end
end

function F.seconds_to_string_shorter(seconds_raw)
    seconds_raw = math.floor(seconds_raw)
    if seconds_raw <= 0 then
        return seconds_raw .. " sec."
    end

    local minutes = math.floor(seconds_raw / 60)
    local seconds = seconds_raw % 60

    local components = {}
    components[#components + 1] = minutes ~= 0 and (minutes .. " m") or nil
    components[#components + 1] = seconds .. " sec." -- So it does not blink

    return table.concat(components, " ")
end

function F.rwt_to_string_minutes(rwt_obj)
    return string.sub(rwt.to_string(rwt_obj, true), 4)
end

-- Update interval for faster-ticking displays (e.g. platform screens)
if type(F.PIS_UPDATE_INTERVAL) ~= "number" or F.PIS_UPDATE_INTERVAL <= 0 then
    F.PIS_UPDATE_INTERVAL = 2
end

-- Update interval for slower-ticking displays (e.g. status billboards)
if type(F.PIS_UPDATE_INTERVAL_LONG) ~= "number" or F.PIS_UPDATE_INTERVAL_LONG <= 0 then
    F.PIS_UPDATE_INTERVAL_LONG = 5
end

--[[ { [station_id:track_id] = { [atc_id] = {
    train_status = "arriving" / "approaching" / "stopped",
    line_code = "<line code>",
    line_name = "<line name>", -- variable-length string
    heading_to = "<heading to>", -- variable-length string
    arriving_at = rwt(), -- "arriving" / "approaching"
    leaving_at = rwt(), -- "stopped"
} } } ]]
F.pis_list_of_trains = {}

-- Sorted arrays of atc_ids in ascending order of ETA
-- The closer the train, the upper it's position in the array
--[[ { [station_id:track_id] = atc_id[] } ]]
F.pis_list_of_trains_sorted = {}

-- Cache of the currently stopped train's atc_id
-- Then we avoid O(n) lookup
-- Assume there can only be one train stopping; in the buggy state
-- that a train is registered "stopped" before another deregisters,
-- the later train takes presedence.
--[[ { [station_id:track_id] = atc_id or nil } ]]
F.pis_train_stopped_on_track = {}

-- Set of station IDs where graphical displays are paused
if type(S.pis_stations_graphical_paused) ~= "table" then
    S.pis_stations_graphical_paused = {}
end

-- Global flag of whether all graphical displays are paused
if type(S.pis_stations_graphical_paused) ~= "boolean" then
    S.pis_global_graphical_paused = false
end
