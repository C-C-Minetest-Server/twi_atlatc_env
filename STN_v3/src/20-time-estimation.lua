assert(is_loading)

--[[
Time estimation algorthm:

time_standpoint <- current_time
last_checkpoint <- train_last_checkpoint
for station in future_path
    avg <- get average time used between last_checkpoint and station
    if no avg avaliable
        break

    estimated_time <- time_standpoint + avg
    yield estimated_time as "time to <station>"

    if station has scheduled leaving time
        time_standpoint <- next scheduled leaving time of the station from time_standpoint
    else
        time_standpoint <- estimated_time + door open time at station

    last_checkpoint <- station
]]

function F.list_train_arrival_times(atc_id)
    local train_data = F.running_trains_data[atc_id]
    if not train_data then return {} end

    local dest = train_data.dest
    local line_id = train_data.line_id
    local line_def = F.stn_v3_lines[line_id]
    local line_stations = line_def and line_def.stations
    local latest_checkpoint = train_data.latest_checkpoint
    local max_speed_cat = train_data.max_speed_cat

    if not dest or not line_stations or not max_speed_cat or not latest_checkpoint then
        return {}
    end

    local times_to_stations = {}
    local time_standpoint = rwt.now()
    local station_pointer = dest
    repeat
        local station_def = line_stations[station_pointer]

        -- S.time_from_checkpoint_to_trackpoint[checkpoint][dest_key][max_speed_cat]
        local average_delta = S.time_from_checkpoint_to_trackpoint[latest_checkpoint]
            and S.time_from_checkpoint_to_trackpoint[latest_checkpoint][station_pointer]
            and S.time_from_checkpoint_to_trackpoint[latest_checkpoint][station_pointer][max_speed_cat]

        -- Just halt if delta is unavaliable - we might be still collecting data
        if not average_delta then break end

        local est_arrival = rwt.add(time_standpoint, average_delta)
        times_to_stations[station_pointer] = est_arrival

        if station_def.depoff and line_def.base_depint then
            local door_time = line_def.delay or 5
            local next_door_close = rwt.next_rpt(
                rwt.add(est_arrival, door_time),
                line_def.base_depint,
                rwt.add(line_def.base_depoff or rwt.new(), station_def.depoff)
            )

            time_standpoint = next_door_close
        else
            local door_time = line_def.delay or 10
            time_standpoint = rwt.add(est_arrival, door_time)
        end

        latest_checkpoint = station_pointer
        station_pointer = station_def.next
    until station_pointer == dest

    return times_to_stations
end

function F.send_train_to_pis_v3(atc_id)
    local train_data = F.running_trains_data[atc_id]
    local line_id = train_data and train_data.line_id
    local line_def = F.stn_v3_lines[line_id]
    local line_stations = line_def and line_def.stations

    if not line_stations then return false end

    local arrival_times = F.list_train_arrival_times(atc_id)
    local send_batch = {}

    for track_key, eta in pairs(arrival_times) do
        -- Discard point_id (track_key_components[3]), PIS doesn't care where exactly we stop
        local track_key_components = string_split(track_key, ":")
        local station_id, track_id = track_key_components[1], track_key_components[2]

        local line_station_def = line_def.stations[track_key]

        local line_code = line_def.code or string.sub(line_id, 1, 4)
        local line_name = line_def.name or line_id
        local term_code = line_def.termini[line_station_def.dir]
        local heading_to = F.station_names[term_code]
        local direction_code = line_station_def.dir
        local is_approaching = track_key == train_data.dest and train_data.is_approaching

        send_batch[#send_batch+1] = {
            type = "update_train",

            source_id = "F.send_train_to_pis_v3 " .. atc_id .. " (" ..
                atc_pos.x .. "," .. atc_pos.y .. "," .. atc_pos.z .. ")",

            atc_id = atc_id,
            train_status = is_approaching and "approaching" or "arriving",

            station_id = station_id,
            track_id = track_id,

            line_code = line_code,
            line_name = line_name,
            heading_to = heading_to,
            direction_code = direction_code,

            estimated_time = eta,
        }
    end

    interrupt_pos(PIS_V3_EXT_INT_POS, {
        type = "batch",
        batch = send_batch,
    })
end
