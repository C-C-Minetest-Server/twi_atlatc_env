assert(is_loading)

-- Generate station-to-line mapping
F.lines_on_stopping_point = {}

for line_id, line_def in pairs(F.stn_v3_lines) do
    local stations = line_def.stations
    for point_id in pairs(stations) do
        F.lines_on_stopping_point[point_id] = F.lines_on_stopping_point[point_id] or {}
        table.insert(F.lines_on_stopping_point[point_id], line_id)
    end
end

function F.track_match_train(point_id, train)
    local lines = F.lines_on_stopping_point[point_id]
    if not lines then return end

    for _, line_id in ipairs(lines) do
        local line_def = F.stn_v3_lines[line_id]

        if line_def.rc and train:has_rc(line_def.rc)
            or line_def.line and train:get_line() == line_def.line then
            return line_id
        end
    end

    return
end

function F.validate_station_track_params(params)
    params.station_id = params.station_id or params.here or params.platform_id
    params.track_id = params.track_id or params.track
    params.door_dir = params.door_dir or "C"

    assert(type(params) == "table", "Invalid type of params")
    assert(type(params.station_id) == "string", "Invalid type of params.station_id")
    assert(type(params.track_id) == "string", "Invalid type of params.track_id")
    assert(type(params.point_id) == "string", "Invalid type of params.point_id")
    assert(params.door_dir == "L" or params.door_dir == "R" or params.door_dir == "C",
        "Invalid value of params.door_dir")
end

function F.stn_v3(params)
    __approach_callback_mode = 1
    F.validate_station_track_params(params)

    local event, train = event, get_train()
    if not train then return end

    local point_id = params.station_id .. ":" .. params.track_id .. ":" .. params.point_id
    local line_id = type(event.msg) == "table" and event.msg.src == "F.stn_v3"
        and event.msg.line_id or F.track_match_train(point_id, train)
    local line_def = F.stn_v3_lines[line_id]
    local station_def = line_def and line_def.stations[point_id]

    if event.approach and not event.has_entered and atc_arrow and station_def then
        atc_set_ars_disable(true)
        atc_set_lzb_tsr(1)

        if not F.check_if_train_has_approached(atc_id) then
            F.register_train_on_checkpont(atc_id, point_id .. ":a", true)
            F.send_train_to_pis_v3(atc_id)
        end

        F.set_external_display(train, line_id, point_id)
        train:set_text_inside("Stopping at: " .. F.get_internal_display(line_id, params.station_id))
    elseif event.train and atc_arrow and station_def then
        local atc = "B0W"

        if params.door_dir ~= "C" then
            atc = atc .. "O" .. params.door_dir
        end

        if params.kick then
            atc = atc .. "K"
        end

        train:atc_send(atc)

        local rwtime = rwt.now()
        local rwnext
        if station_def.depoff and line_def.base_depint then
            local door_time = line_def.delay or 5
            local next_door_close = rwt.next_rpt(
                rwt.add(rwtime, door_time),
                line_def.base_depint,
                rwt.add(line_def.base_depoff or rwt.new(), station_def.depoff)
            )

            rwnext = next_door_close
        else
            local door_time = line_def.delay or 10
            rwnext = rwt.add(rwtime, door_time)
        end

        schedule(rwt.sub(rwnext, 1), {
            src = "F.stn_v3",
            type = "enable_ars",
            line_id = line_id,
        })

        local time_str = "Arr. " .. rwt.to_string(rwtime, true)
            .. " Dep. " .. rwt.to_string(rwnext, true)

        F.set_external_display(train, line_id, point_id)
        train:set_text_inside(F.get_internal_display(line_id, params.station_id, time_str))

        local train_dir = station_def.dir
        local terminus_id = line_def.termini[train_dir]
        local terminus_name = F.station_names[terminus_id]

        F.register_train_arrival(atc_id, point_id)
        interrupt_pos(PIS_V3_EXT_INT_POS, {
            type = "update_train",

            source_id = "F.stn_v3 " .. atc_id .. " (" ..
                atc_pos.x .. "," .. atc_pos.y .. "," .. atc_pos.z .. ")",

            atc_id = atc_id,
            train_status = "stopped",

            station_id = params.station_id,
            track_id = params.track_id,

            line_code = line_def.code or line_id,
            line_name = line_def.name or line_def.code or line_id,
            heading_to = terminus_name,
            direction_code = train_dir,

            estimated_time = rwnext,
        })
        F.send_train_to_pis_v3(atc_id)
    elseif type(event.msg) == "table" and event.msg.src == "F.stn_v3" then
        if not station_def then
            atc_set_text_inside("Station track misconfigured. Contact railway operator.")
            atc_set_text_outside("Station track misconfigured. Contact railway operator.")
            return
        end

        if event.msg.type == "enable_ars" then
            if station_def.reverse then
                train:atc_send("BBWRA1")
            else
                train:atc_send("A1")
            end

            interrupt(1 , {
                src = "F.stn_v3",
                type = "go",
                line_id = line_id,
            })
        elseif event.msg.type == "go" then
            local checkpoints = train:get_lzb_checkpoints()
            local first_checkpoint = checkpoints and checkpoints[1]
            if first_checkpoint == nil or first_checkpoint.speed ~= 0 then
                train:atc_send("OCD1A1SM")

                local next_track_id = station_def.next
                local next_track_id_parts = string_split(next_track_id, ":")
                local next_station_id = next_track_id_parts[1]
                train:set_text_inside("Next station: " .. F.get_internal_display(line_id, next_station_id))

                -- In case there are no PIS data yet, do not show "leave now" forever
                interrupt_pos(PIS_V3_EXT_INT_POS, {
                    type = "update_train",

                    source_id = "F.stn_v3 " .. atc_id .. " (" ..
                        atc_pos.x .. "," .. atc_pos.y .. "," .. atc_pos.z .. ")",

                    atc_id = atc_id,
                    train_status = "deregister",

                    station_id = params.station_id,
                    track_id = params.track_id,
                })

                F.add_train_to_track(atc_id, line_id, train:get_max_speed(), station_def.next)
                F.register_train_on_checkpont(atc_id, point_id)
                F.send_train_to_pis_v3(atc_id)
            else
                train:set_text_inside(F.get_internal_display(line_id, params.station_id, "Waiting for train ahead..."))
                interrupt(1, {
                    src = "F.stn_v3",
                    type = "go",
                    line_id = line_id,
                })
            end
        end
    end
end
