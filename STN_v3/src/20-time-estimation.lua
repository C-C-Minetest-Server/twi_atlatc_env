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
    local train = get_train(atc_id)
    if not train then
        return {}
    end

    local train_data = F.running_trains_data[atc_id]
    if not train_data then return {} end

    -- Do not re-calculate within 2 seconds
    do
        local cached_times_to_stations = train_data.times_to_stations
        local cached_time = train_data.times_to_stations_time

        if cached_time and (cached_time + 2) > os.time() then
            return cached_times_to_stations
        end

        train_data.times_to_stations = nil
        train_data.times_to_stations_time = nil
    end

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
        -- S.time_from_checkpoint_to_trackpoint[checkpoint][dest_key][max_speed_cat]
        local average_delta = S.time_from_checkpoint_to_trackpoint[latest_checkpoint]
            and S.time_from_checkpoint_to_trackpoint[latest_checkpoint][station_pointer]
            and S.time_from_checkpoint_to_trackpoint[latest_checkpoint][station_pointer][max_speed_cat]

        -- Just halt if delta is unavaliable - we might be still collecting data
        if not average_delta then break end

        local est_arrival = rwt.add(time_standpoint, average_delta)
        times_to_stations[station_pointer] = { est_arrival }

        local station_def = line_stations[station_pointer]

        if type(station_def) == "function" then
            -- func(train: train, arrival_time: rwt?, estimated: bool)
            station_def = station_def(train, est_arrival, true)

            if not station_def then
                -- The dynamic station function may decide "it is not the time yet"
                -- and give us nil, we should stop here
                -- This leaves times_to_stations[station_pointer][2] = nil, which is desired
                break
            end
        end

        times_to_stations[station_pointer][2] = station_def

        if station_def.depoff and station_def.depint then
            local door_time = line_def.delay or 5
            local next_door_close =
                rwt.next_rpt(rwt.add(est_arrival, door_time), station_def.depint, station_def.depoff)

            time_standpoint = next_door_close
        else
            local door_time = line_def.delay or 10
            time_standpoint = rwt.add(est_arrival, door_time)
        end

        latest_checkpoint = station_pointer
        station_pointer = station_def.next
    until station_pointer == dest

    train_data.times_to_stations = times_to_stations
    train_data.times_to_stations_time = os.time()

    return times_to_stations
end

function F.get_train_arrival_time_at(atc_id, track_key)
    local times_to_stations = F.list_train_arrival_times(atc_id)

    if times_to_stations[track_key] then
        return unpack(times_to_stations[track_key])
    end
end

function F.send_train_to_pis_v3(atc_id)
    local train = get_train(atc_id)
    if not train then return end

    local train_data = F.running_trains_data[atc_id]
    local line_id = train_data and train_data.line_id
    local line_def = F.stn_v3_lines[line_id]
    local line_stations = line_def and line_def.stations

    if not line_stations then return false end

    local arrival_times = F.list_train_arrival_times(atc_id)
    local send_batch = {}

    for track_key, data in pairs(arrival_times) do
        local eta, line_station_def = data[1], data[2]
        if not line_station_def then
            -- "It is not yet the time" to calculate anything onwards
            break
        end

        -- Discard point_id (track_key_components[3]), PIS doesn't care where exactly we stop
        local track_key_components = string_split(track_key, ":")
        local station_id, track_id = track_key_components[1], track_key_components[2]

        local line_code = line_def.code or string.sub(line_id, 1, 4)
        local line_name = line_def.name or line_id
        local line_color = line_def.color
        local line_background_color = line_def.background_color

        local dir_code = line_station_def.dir
        if type(dir_code) == "function" then
            dir_code = dir_code(train)
        end
        local term_code = line_def.termini[dir_code]
        local heading_to = F.station_names[term_code] or term_code

        local no_to_prefix = line_def.no_to_prefix
        local is_approaching = track_key == train_data.dest and train_data.is_approaching

        send_batch[#send_batch + 1] = {
            type = "update_train",

            source_id = "F.send_train_to_pis_v3 " .. atc_id .. " (" ..
                atc_pos.x .. "," .. atc_pos.y .. "," .. atc_pos.z .. ")",

            atc_id = atc_id,
            train_status = is_approaching and "approaching" or "arriving",

            station_id = station_id,
            track_id = track_id,

            line_code = line_code,
            line_name = line_name,
            line_color = line_color,
            line_background_color = line_background_color,
            heading_to = heading_to,
            no_to_prefix = no_to_prefix,
            direction_code = dir_code,

            estimated_time = eta,
        }
    end

    interrupt_pos(PIS_V3_EXT_INT_POS, {
        type = "batch",
        batch = send_batch,
    })
end
