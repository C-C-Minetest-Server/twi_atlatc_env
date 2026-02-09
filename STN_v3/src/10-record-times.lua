assert(is_loading)

local AVERGING_FACTOR = 0.8

-- stn_id:track_id:point_id -> table
-- stn_id:track_id:point_id":a" -> table
-- !CHK:checkpoint_identifier -> table
-- The table: max_speed_cat -> (stn_id:track_id:point_id -> seconds)
S.time_from_checkpoint_to_trackpoint = {}

-- atc_id -> table:
--   dest = stn_id:track_id:point_id
--   checkpoints = table:
--     stn_id:track_id:point_id -> time in second
--     stn_id:track_id:point_id":a" -> time in second
--     !POS:x:y:z -> time in second
F.running_trains_data = {}

-- Add the train to the track. Does NOT add initial checkpoints.
-- Usually called at station tracks. F.register_train_on_checkpont is most probably
-- called subsequently to register the leaving station as a checkpoint.
function F.add_train_to_track(atc_id, line_id, max_speed, dest_key)
    F.running_trains_data[atc_id] = {
        dest = dest_key,
        line_id = line_id,
        max_speed_cat = math.floor((max_speed / 5) + 0.5) * 5,
        checkpoints = {},
    }
end


-- Registers a checkpoint. It can be one of the following:
--   `stn_id:track_id:point_id`: Leaving a station
--   `stn_id:track_id:point_id:a`: Approaching the station, most probably used when approaching the destination
--   `!CHK:checkpoint_identifier`: Reaching a fixed checkpoint on the tracks.
function F.register_train_on_checkpont(atc_id, checkpoint, is_approaching)
    if not F.running_trains_data[atc_id] then return false end

    F.running_trains_data[atc_id].is_approaching =
        (F.running_trains_data[atc_id].is_approaching or is_approaching) and true or nil
    F.running_trains_data[atc_id].latest_checkpoint = checkpoint
    F.running_trains_data[atc_id].checkpoints[checkpoint] = os.time()
end

-- Check if a train has triggered the approach event.
function F.check_if_train_has_approached(atc_id)
    return F.running_trains_data[atc_id] and F.running_trains_data[atc_id].is_approaching
end

-- Called when the train arrives. Should be called before resending train data to the PIS.
-- Handles exponential averaging for checkpoints -> station of the speed category.
function F.register_train_arrival(atc_id, dest_key)
    if not F.running_trains_data[atc_id] then return false end
    if dest_key ~= nil and dest_key ~= F.running_trains_data[atc_id].dest then
        -- We've entered a weird state, probably from manually switching lines
        -- Don't take these samples
        F.running_trains_data[atc_id] = nil
        return false
    end

    dest_key = dest_key or F.running_trains_data[atc_id].dest
    local max_speed_cat = F.running_trains_data[atc_id].max_speed_cat
    local checkpoints = F.running_trains_data[atc_id].checkpoints
    local now = os.time()

    for checkpoint, time_on_checkpoint in pairs(checkpoints) do
        S.time_from_checkpoint_to_trackpoint[checkpoint] =
            S.time_from_checkpoint_to_trackpoint[checkpoint] or {}
        S.time_from_checkpoint_to_trackpoint[checkpoint][dest_key] =
            S.time_from_checkpoint_to_trackpoint[checkpoint][dest_key] or {}

        local time_delta = now - time_on_checkpoint
        local old_time = S.time_from_checkpoint_to_trackpoint[checkpoint][dest_key][max_speed_cat]
        local new_time = old_time == nil and time_delta
            or (old_time * AVERGING_FACTOR + time_delta * (1 - AVERGING_FACTOR))

        S.time_from_checkpoint_to_trackpoint[checkpoint][dest_key][max_speed_cat] = new_time
    end

    F.running_trains_data[atc_id] = nil
    return true
end

-- Removed the train, when e.g. it enters a depot or othewise instructed so
function F.deregister_train(atc_id)
    F.running_trains_data[atc_id] = nil
end
