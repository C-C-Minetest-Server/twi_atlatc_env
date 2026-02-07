-- luacheck: no unused

assert(is_loading)

local F, S = F, S
local rwt = rwt

function F.handle_variable_length_string(str, max_len)
    if type(str) == "string" then
        return max_len and string.sub(str, 1, max_len) or str
    end

    assert(type(str) == "table" and #str > 0, "Invalid type of str in F.handle_variable_length_string")

    if not max_len then
        assert(type(str[1]) == "string", "Invalid type of str[1] in F.handle_variable_length_string")
        return str[1]
    end

    for i, choice in ipairs(str) do
        assert(type(choice) == "string", "Invalid type of str[" .. i .. "] in F.handle_variable_length_string")
        if #choice <= max_len then
            return choice
        end
    end

    return string.sub(str[#str], 1, max_len)
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
