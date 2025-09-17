-- luacheck: no unused

F.GLOBAL_APPROACH_CORRECTION = 0


local function get_term_id(line, dir)
    local linedata = F.lines[line]
    if not linedata then return end
    if linedata[dir] then return linedata[dir] end
    if linedata["through_" .. dir] then return get_term_id(linedata["through_" .. dir], dir) end
end

local function get_line_term_string(line, dir)
    local linedef = F.lines[line]
    if not linedef then return "Unknown Terminus" end
    if linedef.custom_term_desc then return linedef.custom_term_desc end

    local term_id = get_term_id(line, dir)
    if term_id and F.stations[term_id] then
        return "Terminus: " .. F.stations[term_id]
    end
    return "Unknown Terminus"
end

local function get_line_term_short_string(line, dir)
    local linedef = F.lines[line]
    if not linedef then return "Unknown Terminus" end
    if linedef.custom_term_desc then return linedef.custom_term_desc end

    local term_id = get_term_id(line, dir)
    if term_id and (F.stations_short[term_id] or F.stations[term_id]) then
        return "Terminus: " .. (F.stations_short[term_id] or F.stations[term_id])
    end
    return "Unknown Terminus"
end

local function get_line_term_short_disp_string(line, dir)
    local linedef = F.lines[line]
    if not linedef then return "Unknown" end
    if linedef.custom_term_desc then return linedef.custom_term_desc end

    local term_id = get_term_id(line, dir)
    if term_id and (F.stations_short[term_id] or F.stations[term_id]) then
        return (F.stations_short[term_id] or F.stations[term_id])
    end
    return "Unknown"
end

local outside_text = "%s\nNext stop: %s\n%s"
local waiting_signal_text = "%s\nWaiting for train ahead..."

function F.set_outside_regular(def)
    local dir = def.reverse and def.rev_dir or def.dir
    local next = def.reverse and def.rev_next or def.next
    local term_name = get_line_term_string(def.line, dir)
    local line_name = F.lines[def.line] and F.lines[def.line].name or def.line
    local next_name = F.stations[next] or next or ""
    atc_set_text_outside(string.format(outside_text, line_name, next_name, term_name))
end

local k105_foreground = "#fdf6e3"
local k105_background = "#002b36"
function F.set_outside_k105(def)
    local line = def.line
    local linedef = F.lines[line]
    local dir = def.reverse and def.rev_dir or def.dir
    local next = def.reverse and def.rev_next or def.next
    local term_name = linedef.custom_term_desc_short or F.stations[get_term_id(def.line, dir)] or "Unknown"
    local next_name = F.stations[next] or next or ""
    atc_set_text_outside(("{b:%s}{t:%s}%s{b:%s}{t:%s};%s;%s"):format(
        linedef and linedef.background_color or k105_background,
        linedef and linedef.color or k105_foreground,
        ("{[]|%s}"):format(linedef.code or line),
        k105_background, k105_foreground,
        term_name, next_name))
end

function F.set_outside_subway(def)
    local line = def.line
    local linedef = F.lines[line]

    local dir = def.reverse and def.rev_dir or def.dir
    local next = def.reverse and def.rev_next or def.next
    local term_name = linedef.custom_term_desc or get_line_term_string(line, dir)
    local term_short_name = linedef.custom_term_desc_short or get_line_term_short_disp_string(line, dir)
    local line_name = linedef and linedef.name or def.line
    local next_name = F.stations[next] or next or ""
    if term_name then
        atc_set_text_outside(string.format(
            "%s\n" .. outside_text,
            term_short_name, line_name, next_name, term_name
        ))
    end
end

F.set_outside = function(def, train_id)
    if def.line then
        local train = get_train(train_id)
        local rc = train and train:get_rc() or ""
        if F.has_rc("WG-K105", rc) then
            F.set_outside_k105(def)
        elseif F.has_rc("WG-01700", rc) or F.has_rc("WG-MPL16") then
            F.set_outside_subway(def)
        else
            F.set_outside_regular(def)
        end
    end
end

local function generate_interchange_string(stn, curr_line, through_line_id)
    curr_line = F.interchange_line_alias[curr_line] or curr_line
    local rtn = ""
    if through_line_id then
        local through_line = F.lines[through_line_id]
        rtn = rtn .. "\nThrough Service: " .. (through_line and through_line.name or through_line_id)
    end
    if F.station_interchange[stn] then
        local counter = 0
        for _, line in ipairs(F.station_interchange[stn]) do
            if line ~= curr_line and line ~= through_line_id then
                local line_def = F.lines[line]
                local line_name = line_def and line_def.name or line
                if counter == 0 then
                    rtn = rtn .. "\nInterchanges:\n" .. line_name
                else
                    rtn = rtn .. ", " .. (counter % 3 == 0 and "\n" or "") .. line_name
                end
                counter = counter + 1
            end
        end
    end
    return rtn
end

F.stn = function(def)
    if not def.line then return end
    return F.stn_v2(def, {
        [def.line] = def,
    })
end

local function match_train(line_def, train)
    if line_def.rc then
        if F.has_rc(line_def.rc, train:get_rc()) then
            return true
        end
    end

    if line_def.line then
        if train:get_line() == line_def.line then
            return true
        end
    end

    return false
end

F.stn_v2 = function(basic_def, lines_def)
    __approach_callback_mode = 1
    local event = event
    local train = get_train(atc_id)
    if not train then return end

    local here = basic_def.here
    if not here then return end

    local status_key = F.get_stn_status_key(basic_def)

    for line_id, def in pairs(lines_def) do
        for _, key in ipairs({
            "track", "platform_id",
            "here", "door_dir",
            "signal", "rev_signal",
        }) do
            def[key] = def[key] or basic_def[key] or nil
        end
        def.line = line_id

        local line_def = F.lines[line_id]
        if not def.dir and line_def then
            def.dir = line_def.default_dir
        end
        if (not def.next or not def.next_track)
            and def.here and def.track
            and line_def and line_def.adjacent_stations
            and line_def.adjacent_stations[def.here .. ":" .. def.track] then
            local adjacent_station_data = line_def.adjacent_stations[def.here .. ":" .. def.track]
            if adjacent_station_data[1] then
                def.next = adjacent_station_data[1][1]
                def.next_track = adjacent_station_data[1][2]
            end
        end
    end

    if event.approach and not event.has_entered and atc_arrow and train then
        if basic_def.on_approach then
            basic_def.on_approach(train)
        end

        local stn_line_def

        for _, def in pairs(lines_def) do
            if match_train(F.lines[def.line], train) then
                stn_line_def = def
                break
            end
        end

        if stn_line_def then
            local line_id = stn_line_def.line
            atc_set_ars_disable(true)
            atc_set_lzb_tsr(1)
            local stn_name = F.stations[here] or here
            atc_set_text_inside(
                "Stopping at: " ..
                stn_name ..
                generate_interchange_string(here, line_id) ..
                (stn_line_def.additional_text and ("\n" .. stn_line_def.additional_text) or ""))
            F.set_outside(stn_line_def, atc_id)

            local approach_status_key = F.get_approach_status_key(stn_line_def, atc_id)
            if approach_status_key then
                F.register_train_on_checkpoint(approach_status_key, atc_id, true)
            end

            if basic_def.alt_tracks then
                for _, alt_track in basic_def.alt_tracks do
                    local alt_status_key = basic_def.here .. ":" .. alt_track
                    F.platform_display_control[alt_status_key] = {
                        status = "OPP",
                        atc_id = atc_id,
                    }
                end
            end
        elseif status_key then
            F.platform_display_control[status_key] = {
                status = "NON",
                atc_id = atc_id,
            }
        end
    elseif event.train and atc_arrow then
        if status_key
            and F.platform_display_control[status_key]
            and F.platform_display_control[status_key].status == "NON" then
            F.platform_display_control[status_key] = nil
        end

        if status_key then
            F.register_train_arrive(status_key, atc_id)
        end

        local stn_line_def

        for _, def in pairs(lines_def) do
            if train and match_train(F.lines[def.line], train) then
                stn_line_def = def
                break
            end
        end

        if stn_line_def then
            local line_id = stn_line_def.line
            atc_set_ars_disable(true)

            if atc_speed and atc_speed > 10 then
                atc_send("BB")
                local dt = os.date()
                atc_set_text_outside("BrakeFail speed=" ..
                    atc_speed .. " at " .. dt.year .. "-" .. dt.month .. "-" .. dt.day ..
                    " " .. dt.hour .. ":" .. dt.min .. ":" .. dt.sec)
                error("Train " .. atc_id .. " has passed rail at speed of " .. atc_speed)
            end

            local time_str
            local rwtime = rwt.now()
            local rwnext
            if stn_line_def.rpt_interval then
                rwnext = rwtime
                repeat
                    rwnext = rwt.next_rpt(rwnext, stn_line_def.rpt_interval, stn_line_def.rpt_offset or 0)
                until rwt.diff(rwtime, rwnext) >= (stn_line_def.min_stop_time or 5)
            else
                rwnext = rwt.add(rwtime, stn_line_def.delay or 10)
            end
            stn_line_def.rwnext = rwnext
            if rwt.diff(rwnext, rwtime) > 1 then
                schedule(rwt.sub(rwnext, 1), {
                    type = "enable_ars",
                    line_id = line_id,
                })
            elseif stn_line_def.reverse then
                schedule(rwnext, {
                    type = "reverse",
                    line_id = line_id,
                })
            else
                schedule(rwnext, {
                    type = "go",
                    line_id = line_id,
                })
            end
            time_str = "\n" ..
                (status_key and (status_key .. " ") or "") ..
                "Arr. " .. rwt.to_string(rwtime, true) .. " Dep. " .. rwt.to_string(rwnext, true)

            atc_send("B0WO" .. (stn_line_def.door_dir or "C") .. (stn_line_def.kick and "K" or ""))

            local stn_name = F.stations[here] or here
            local through = stn_line_def.reverse and stn_line_def.rev_through or stn_line_def.through or nil
            atc_set_text_inside(
                stn_name ..
                time_str ..
                generate_interchange_string(stn_line_def.here, line_id, through) ..
                (stn_line_def.additional_text and ("\n" .. stn_line_def.additional_text) or ""))
            F.set_outside(stn_line_def, atc_id)

            if status_key then
                F.platform_display_control[status_key] = {
                    status = "DEP",
                    rwt_end = rwnext,
                    line_id = line_id,
                    atc_id = atc_id,
                    line_dir = stn_line_def.reverse and stn_line_def.rev_dir or stn_line_def.dir,
                }

                local next = stn_line_def.reverse and stn_line_def.rev_next or stn_line_def.next or nil
                local next_track =
                    stn_line_def.reverse and stn_line_def.rev_next_track
                    or stn_line_def.next_track or nil
                if next and next_track then
                    local dest_key = next .. ":" .. next_track
                    local line_dir = stn_line_def.reverse and stn_line_def.rev_dir or stn_line_def.dir or nil
                    if line_dir then
                        if F.lines[line_id]
                            and F.lines[line_id][line_dir] == next
                            and F.lines[line_id][F.rev_dirs[line_dir]] then
                            -- Terminus
                            line_dir = F.rev_dirs[line_dir]
                        end
                        F.register_train_depart(
                            status_key .. ":s",
                            status_key,
                            dest_key,
                            through or line_id,
                            line_dir,
                            atc_id)
                    end
                end
            end
        end
    elseif event.msg and type(event.msg) == "table" then
        local msg_type = event.msg.type
        local line_id = event.msg.line_id
        local def = lines_def[line_id]

        if not def then
            atc_set_text_inside("Station track misconfigured. Contact railway operator.")
            atc_set_text_outside("Station track misconfigured. Contact railway operator.")
        elseif msg_type == "enable_ars" then
            if def.reverse then
                atc_send("RA1")
            else
                atc_set_ars_disable(false)
            end
            local signal = def.reverse and def.rev_signal or def.signal or nil
            if def.route and can_set_route(signal, def.route) then
                set_route(signal, def.route)
            end

            interrupt(1, {
                type = "go",
                line_id = line_id,
            })
        elseif msg_type == "reverse" then
            atc_send("R")
            interrupt(0, {
                type = "go",
                line_id = line_id,
            })
        elseif msg_type == "go" then
            local state = false
            local signal = def.reverse and def.rev_signal or def.signal or nil
            if signal then
                if def.route and can_set_route(signal, def.route) then
                    set_route(signal, def.route)
                    state = true
                else
                    state = aspect_is_free(get_aspect(signal)) and true or false
                end
            else
                atc_set_ars_disable(false)
                local checkpoints = train:get_lzb_checkpoints()
                -- If checkpoint is nil, wait for LZB init
                if checkpoints then
                    local first_checkpoint = checkpoints[1]
                    if first_checkpoint == nil then
                        -- No signal
                        state = true
                    else
                        state = first_checkpoint.speed ~= 0
                    end
                end
            end
            atc_set_ars_disable(false)

            if state ~= true then
                local stn_name = F.stations[def.here] or def.here or ""
                interrupt(0.5, {
                    type = "go",
                    line_id = line_id,
                })
                atc_set_text_inside(string.format(waiting_signal_text, stn_name))
                return true
            end

            atc_send("OCD1S" .. (def.speed or "M"))

            local next = def.reverse and def.rev_next or def.next or nil
            local next_name = F.stations[next] or next or ""
            local inside_text = ""
            if next and next_name then
                local stn_name = F.stations[next] or next or ""
                local through = def.reverse and def.rev_through or def.through or nil
                inside_text = "Next stop: " .. stn_name .. generate_interchange_string(next, line_id, through)
            end
            atc_set_text_inside(inside_text)

            if def.on_leave then
                def.on_leave(train)
            end

            if status_key then
                local next_track = def.reverse and def.rev_next_track or def.next_track or nil
                local through = def.reverse and def.rev_through or def.through or nil

                if next and next_track then
                    local dest_key = next .. ":" .. next_track
                    local line_dir = def.reverse and def.rev_dir or def.dir or nil
                    if line_dir then
                        if F.lines[line_id]
                            and F.lines[line_id][line_dir] == next
                            and F.lines[line_id][F.rev_dirs[line_dir]] then
                            -- Terminus
                            line_dir = F.rev_dirs[line_dir]
                        end
                        F.register_train_depart(status_key, status_key, dest_key, through or line_id, line_dir,
                            atc_id)
                    end
                end

                if F.lines[line_id] and F.lines[line_id].adjacent_stations then
                    local line_dir = def.reverse and def.rev_dir or def.dir or nil
                    local adj_stn_data = F.lines[line_id].adjacent_stations[status_key]
                    if adj_stn_data then
                        if adj_stn_data[1] and adj_stn_data[1][3] then
                            line_dir = F.rev_dirs[line_dir] or line_dir
                        end
                        local base_string = def.here .. ":" .. def.track
                        for i = 2, #adj_stn_data do
                            base_string = base_string .. "!!" .. adj_stn_data[i - 1][1]
                            local targ_stn = adj_stn_data[i][1]
                            local targ_track = adj_stn_data[i][2]
                            local targ_key = targ_stn .. ":" .. targ_track
                            local targ_line_id = adj_stn_data[i][4] or line_id
                            if adj_stn_data[i][3] then
                                line_dir = F.rev_dirs[line_dir] or line_dir
                            end
                            F.register_train_depart(base_string, status_key, targ_key, targ_line_id, line_dir, atc_id,
                                true)
                        end
                    end
                end

                F.platform_display_control[status_key] = nil
            end

            if basic_def.alt_tracks then
                for _, alt_track in basic_def.alt_tracks do
                    local alt_status_key = basic_def.here .. ":" .. alt_track
                    F.platform_display_control[alt_status_key] = nil
                end
            end
        end
    end
end

--[[
    Persistant data tables
    * S.station_from_checkpoint:
        { [station key]: { [checkpoint key]: [duration in seconds] } }
    * F.trains_by_destination:
        {
            [station key]: {
                [atc_id]: {
                    checkpoints: { [checkpoint key]: [start time in seconds] },
                    from: [station key],
                    line_id: [line id],
                    line_dir: [direction],
                    latest: [checkpoint key]
                }
            }
        }
        Intentionally not kept between restarts to prevent noises
    * F.trains_to_destination:
        { [atc_id]: [station_key] }
        For easier garbage cleaning
    * F.platform_display_control:
        {
            [station key]: {
                status:
                    "DEP" (Departing in)
                    "NON" (Non-stop train)
                    "OPP" (Doors not opening),
                rwt_end: [end time in rwt]?,
                line_id: [line id]?,
                line_dir: [direction]?,
            }
        }
]]

-- Accumulate this value if the saved data need to be resetted
local time_arrival_estimation_reset = 3
if time_arrival_estimation_reset == S.time_arrival_estimation_reset then
    S.station_from_checkpoint = S.station_from_checkpoint or {}
else
    S.station_from_checkpoint       = {}
    S.time_arrival_estimation_reset = time_arrival_estimation_reset
end
F.trains_by_destination    = {}
F.trains_to_destination    = {}
F.platform_display_control = {}

-- Weight of old data
F.AVERGING_FACTOR          = 0.6

--[[
    Status key is:
    1. For station leaves: <code>:<track No.>
        (Technically also checkpoints)
    2. For station arrives: <code>:<track No.>:s
    3. For approaches: <dest code>:<dest track No.>:<src code>:<src track No.>:a
    4. For checkpoints: <system name>:<checkpoint ID>
        (Technically arbitary)
    5. For far-away station (>= 2 stations):
        <this station code>:<this track No.>!![..via..]!!<second last station code>

    For departure points, '~~<train max speed>' is appended.
]]

F.get_stn_status_key = function(def)
    local track = def.track or def.platform_id
    if not (def.here and track) then return end
    return def.here .. ":" .. track
end

F.get_approach_status_key = function(def, atc_id)
    local stn_status_key = F.get_stn_status_key(def)
    if not stn_status_key then return end
    local train_data = F.trains_by_destination[stn_status_key] and F.trains_by_destination[stn_status_key][atc_id]
    if train_data and train_data.from then
        return stn_status_key .. ":" .. train_data.from .. ":a"
    end
end

---Called when a train leaves a station.
---@param src_key string
---@param stn_key string
---@param dest_key string
---@param atc_id integer
---@param line_id string
---@param line_dir string
---@param is_station boolean
---@param no_override boolean
F.register_train_depart = function(src_key, stn_key, dest_key, line_id, line_dir, atc_id, remote_set)
    local train = get_train(atc_id)
    local max_speed = train and train:get_max_speed() or 0
    if not max_speed then return end
    src_key = src_key .. "~~" .. max_speed

    if not remote_set then
        F.trains_to_destination[atc_id] = dest_key
    end

    F.trains_by_destination[dest_key] = F.trains_by_destination[dest_key] or {}
    F.trains_by_destination[dest_key][atc_id] = F.trains_by_destination[dest_key][atc_id] or {}
    local train_dest_data = F.trains_by_destination[dest_key][atc_id]

    train_dest_data.from = stn_key
    train_dest_data.latest = src_key
    train_dest_data.line_id = line_id
    train_dest_data.line_dir = line_dir
    train_dest_data.checkpoints = train_dest_data.checkpoints or {}
    if not train_dest_data.checkpoints[src_key] or not remote_set then
        train_dest_data.checkpoints[src_key] = os.time()
    end
end

---Called when a train circulates a chekpoint.
---@param checkpoint_id string
---@param atc_id integer
---@param no_override boolean
F.register_train_on_checkpoint = function(checkpoint_id, atc_id, no_override)
    local train = get_train(atc_id)
    local max_speed = train and train:get_max_speed() or 0
    if not max_speed then return end
    checkpoint_id = checkpoint_id .. "~~" .. max_speed

    local dest_key = F.trains_to_destination[atc_id]
    if not dest_key then return end

    local train_dest_data = F.trains_by_destination[dest_key] and F.trains_by_destination[dest_key][atc_id]
    if not train_dest_data then return end

    train_dest_data.checkpoints = train_dest_data.checkpoints or {}
    if not train_dest_data.checkpoints[checkpoint_id] or not no_override then
        train_dest_data.latest = checkpoint_id
        train_dest_data.checkpoints[checkpoint_id] = os.time()
    end
end

---Called when a train arrives a station
---@param dest_key string
---@param atc_id integer
F.register_train_arrive = function(dest_key, atc_id)
    local train_dest_data = F.trains_by_destination[dest_key] and F.trains_by_destination[dest_key][atc_id]
    if not train_dest_data then return end
    F.trains_by_destination[dest_key][atc_id] = nil

    S.station_from_checkpoint[dest_key] = S.station_from_checkpoint[dest_key] or {}
    local station_checkpoint_data = S.station_from_checkpoint[dest_key]

    local now = os.time()
    for src_key, src_start_time in pairs(train_dest_data.checkpoints) do
        local old_data = station_checkpoint_data[src_key]
        local delta_time = now - src_start_time
        if old_data then
            delta_time = old_data * F.AVERGING_FACTOR + delta_time * (1 - F.AVERGING_FACTOR)
        end
        station_checkpoint_data[src_key] = delta_time
    end
end

---@return string status
---@return integer? seconds_left
---@return string? line_id
---@return string? line_dir
---@return string? atc_id
F.get_station_status = F.cache_function(1, F.get_stn_status_key, function(def)
    local dest_key = F.get_stn_status_key(def)
    local now = os.time()

    if F.platform_display_control[dest_key] then
        local data = F.platform_display_control[dest_key]
        if data.status == "DEP" then
            return "DEP", rwt.diff(rwt.now(), data.rwt_end), data.line_id, data.line_dir
        end
        return data.status
    end

    local station_checkpoint_data = S.station_from_checkpoint[dest_key]
    local dest_data = F.trains_by_destination[dest_key]
    if not dest_data or not station_checkpoint_data then return end

    local closest_time_left = math.huge
    local closest_line_id
    local closest_line_dir
    local closest_atc_id
    for atc_id, train_dest_data in pairs(dest_data) do
        local latest_checkpoint = train_dest_data.latest
        local latest_checkpoint_arr_time =
            train_dest_data.checkpoints and train_dest_data.checkpoints[latest_checkpoint]
        local latest_checkpoint_time_needed = station_checkpoint_data[latest_checkpoint]

        if latest_checkpoint_arr_time and latest_checkpoint_time_needed then
            local est_arrival_time = latest_checkpoint_arr_time + latest_checkpoint_time_needed
            local time_left = est_arrival_time - now

            if time_left > -10 then
                -- time_left < -10 is probably not meaningful
                if time_left < closest_time_left then
                    closest_time_left = time_left
                    closest_line_id = train_dest_data.line_id
                    closest_line_dir = train_dest_data.line_dir
                    closest_atc_id = atc_id
                end
            elseif time_left < -500 then
                -- Something had absolutely gone wrong, delete this data
                dest_data[atc_id] = nil
            end
        end
    end

    if closest_line_id then
        return "ARR", floor(closest_time_left), closest_line_id, closest_line_dir, closest_atc_id
    end
end)

function F.show_lr(def, texts)
    digiline_send(def.left_disp or "l", table.concat(texts, "\n"))
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%26s", y))
    end
    digiline_send(def.right_disp or "r", table.concat(rtexts, "\n"))
end

function F.show_textline(_, texts)
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%27s", y))
    end
    display(table.concat(texts, "\n"), table.concat(rtexts, "\n"))
end

function F.show_textline_r(_, texts)
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%27s", y))
    end
    display(table.concat(rtexts, "\n"), table.concat(texts, "\n"))
end

F.get_textline_display = function(def)
    if not def.track then
        def.track = def.platform_id
    end
    local texts = {
        (def.platform_prefix or "PLATFORM") .. " " .. (def.track or "?") .. ":",
    }

    local timer_str
    local stn_event, time_left, line_id, dir = F.get_station_status(def)
    if stn_event == "ARR" then
        if time_left > 59 then
            timer_str = string.format("Arriving in %.1f min.", time_left / 60)
        else
            timer_str = "Arriving in " .. time_left .. " sec."
        end
    elseif stn_event == "DEP" then
        timer_str = "Leaving " .. (time_left > 0 and ("in " .. time_left .. " sec.") or "now")
    elseif def.line then
        line_id = line_id or def.line or nil
        dir = def.reverse and def.rev_dir or def.dir or nil
    end

    if stn_event == "NON" then
        local linedef = F.lines[line_id]
        texts[#texts + 1] = def.custom_line or (linedef and (linedef.textline_name or linedef.name)) or line_id or ""
        texts[#texts + 1] = "!! NONSTOP TRAIN !!"
        texts[#texts + 1] = "!!    ARRIVING   !!"
    elseif stn_event == "OPP" then
        local linedef = F.lines[line_id]
        texts[#texts + 1] = def.custom_line or (linedef and (linedef.textline_name or linedef.name)) or line_id or ""
        texts[#texts + 1] = "!!   DOORS NOT   !!"
        texts[#texts + 1] = "!!    OPENING    !!"
    elseif line_id then
        local linedef = F.lines[line_id]

        local term_text =
            linedef.custom_term_desc_textline or linedef.custom_term_desc_short or linedef.custom_term_desc
        if not term_text then
            term_text = "Unknown Terminus"
            if dir then
                local term_id = get_term_id(line_id, dir)
                if term_id then
                    local station_name
                    if def.custom_stations then
                        station_name = cascade_index(def.custom_stations, F.stations)(term_id)
                    else
                        station_name = F.stations[term_id]
                    end
                    term_text = "To " .. (station_name or term_id)
                end
            end
        end

        texts[#texts + 1] = def.custom_line or (linedef and (linedef.textline_name or linedef.name)) or line_id
        texts[#texts + 1] = term_text
        if timer_str then
            texts[#texts + 1] = timer_str
        end
    elseif def.custom_text then
        for _, text in ipairs(def.custom_text) do
            texts[#texts + 1] = text
        end
    else
        texts[#texts + 1] = "Not in service"
        texts[#texts + 1] = "!! NEVER WALK !!"
        texts[#texts + 1] = "!! ON TRACKS  !!"
    end

    return texts
end

F.set_textline = function(def)
    local texts = F.get_textline_display(def)
    local show_func = def.show_func or F.show_lr
    show_func(def, texts)
end

F.set_textline_minimal = function(def)
    local disp = ""

    local timer_str
    local stn_event, time_left, line_id, dir = F.get_station_status(def)
    line_id = line_id or def.line or nil
    local linedef = F.lines[line_id]
    if stn_event == "ARR" then
        timer_str = "Arr. " .. time_left
    elseif stn_event == "DEP" then
        timer_str = "Dep. " .. (time_left > 0 and time_left or "now")
    end
    dir = dir or (linedef and linedef.custom_dir_abbr) or def.dir or nil

    if line_id then
        disp = disp .. (linedef and linedef.code or line_id)

        if timer_str then
            if dir then
                disp = disp .. " " .. dir .. ": " .. timer_str
            else
                disp = disp .. ": " .. timer_str
            end
        elseif dir then
            disp = disp .. " " .. (F.dir_short_name[dir] or dir)
        end
    else
        disp = disp .. "NOT IN SERVICE"
    end

    local texts = {
        (def.platform_prefix or "PLATFORM") .. " " .. (def.track or "?") .. ":",
        disp,
    }

    digiline_send(def.left_disp or "l", table.concat(texts, "\n"))
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%26s", y))
    end
    digiline_send(def.right_disp or "r", table.concat(rtexts, "\n"))
end

F.set_status_textline = function(lines)
    local show_lines = {}
    for i, disp_def in ipairs(lines) do
        if type(disp_def) ~= "table" then
            show_lines[i] = tostring(disp_def)
        else
            local disp
            local track = disp_def.track

            if track then
                disp = track .. ": "
            else
                disp = "?: "
            end

            local append_text
            local stn_event, time_left, line_id, dir = F.get_station_status(disp_def)
            if (stn_event == "ARR" or (stn_event == "NON" and time_left)) and time_left <= 99 then
                append_text = string.format("Arr. %2s", time_left)
            elseif stn_event == "DEP" then
                append_text = string.format("Dep. %2s", time_left > 0 and time_left or "  ")
            elseif disp_def.line then
                line_id = line_id or disp_def.line or nil
                dir = dir or disp_def.dir or nil
            end

            if line_id then
                local linedef = F.lines[line_id]
                disp = disp .. (linedef and linedef.code or line_id)

                local term_text = linedef and (linedef.custom_term_desc_short or linedef.custom_term_desc)
                if not term_text then
                    if dir then
                        local term_id = get_term_id(line_id, dir)
                        term_text = "-> " .. (term_id or "??")
                    else
                        term_text = "-> ??"
                    end
                end
                disp = disp .. " " .. term_text

                if append_text then
                    disp = string.format("%-" .. (26 - #append_text) .. "s", disp) .. append_text
                end
            elseif disp_def.custom_text then
                disp = disp .. disp_def.custom_text
            else
                disp = disp .. "Not in service"
            end

            show_lines[i] = disp
        end
    end

    if lines.mode == "return" then
        return table.concat(show_lines, "\n")
    else
        for i = 0, math.ceil(#show_lines / 4) - 1 do
            digiline_send((lines.display or "lcd") .. (i + 1),
                (show_lines[i * 4 + 1] or "") .. "\n" ..
                (show_lines[i * 4 + 2] or "") .. "\n" ..
                (show_lines[i * 4 + 3] or "") .. "\n" ..
                (show_lines[i * 4 + 4] or "")
            )
        end
    end
end

F.sort_track_destination_data = F.cache_function(3, function(status_key)
    return status_key
end, function(status_key)
    local track_data = F.trains_by_destination[status_key]
    if not track_data then return {} end

    local data = {}
    for atc_id, train_data in pairs(track_data) do
        local latest_time = train_data.checkpoints and train_data.checkpoints[train_data.latest]

        if latest_time then
            local line_dir = train_data.line_dir or nil
            local line_data = F.lines[train_data.line_id]
            local line_code = line_data and line_data.code or train_data.line_id
            local line_term = line_data and line_data.custom_term_desc_short or line_data[line_dir] or nil
            local avg_time = S.station_from_checkpoint[status_key]
                and S.station_from_checkpoint[status_key][train_data.latest]
            local time_left = avg_time and (avg_time - (os.time() - latest_time)) or nil

            if time_left and time_left >= 0 then
                data[#data + 1] = {
                    atc_id = atc_id,
                    from = train_data.from,
                    line_code = line_code,
                    line_dir = line_dir,
                    line_term = line_term,
                    time_left = time_left,
                }
            end
        end
    end

    table.sort(data, function(a, b)
        return a.time_left < b.time_left
    end)

    return data
end)

F.get_track_status_textline_info_lines = function(station, track, custom_stations)
    local data = F.sort_track_destination_data(station .. ":" .. track)

    local display_texts = {}
    for _, entry_data in ipairs(data) do
        local line_term =
            (custom_stations and custom_stations[entry_data.line_term])
            or F.stations_short[entry_data.line_term]
            or F.stations[entry_data.line_term] or entry_data.line_term
        display_texts[#display_texts + 1] = string.format(
            "%-4s %-15s %s",
            entry_data.line_code,
            string.sub(line_term, 1, 15),
            rwt.to_string(rwt.add(rwt.now(), entry_data.time_left), true)
        )
    end
    return display_texts
end


F.get_station_status_textline_info_lines = function(station, tracks)
    local data = {}

    for _, track in ipairs(tracks) do
        local track_data = F.trains_by_destination[station .. ":" .. track] or {}

        for atc_id, train_data in pairs(track_data) do
            local latest_time = train_data.checkpoints and train_data.checkpoints[train_data.latest]

            if latest_time then
                local line_dir = train_data.line_dir or nil
                local line_data = F.lines[train_data.line_id]
                local line_code = line_data and line_data.code or train_data.line_id
                local line_term = line_data and line_data.custom_term_desc_short or line_data[line_dir] or "Unknown"
                line_term = F.stations_short[line_term] or F.stations[line_term] or line_term
                local avg_time = S.station_from_checkpoint[station .. ":" .. track]
                    and S.station_from_checkpoint[station .. ":" .. track][train_data.latest]
                local time_left = avg_time and (avg_time - (os.time() - latest_time)) or nil

                if time_left and time_left >= 0 then
                    data[#data + 1] = {
                        atc_id = atc_id,
                        track_id = track,
                        line_code = line_code,
                        line_term = line_term,
                        time_left = time_left,
                    }
                end
            end
        end
    end

    table.sort(data, function(a, b)
        return a.time_left < b.time_left
    end)

    local display_texts = {}
    for _, entry_data in ipairs(data) do
        display_texts[#display_texts + 1] = string.format(
            "%-2s %-4s %-12s %s",
            entry_data.track_id,
            entry_data.line_code,
            string.sub(entry_data.line_term, 1, 12),
            rwt.to_string(rwt.add(rwt.now(), entry_data.time_left), true)
        )
    end
    return display_texts
end

F.get_express_station_display_lines = function(def)
    local dest_key = F.get_stn_status_key(def)

    if not def.no_current_train and F.platform_display_control[dest_key]
        and F.platform_display_control[dest_key].status == "DEP" then
        return F.get_textline_display(def)
    end

    def.track = def.track or def.platform_id

    local info_lines = def.here and def.track
        and F.get_track_status_textline_info_lines(def.here, def.track, def.custom_stations) or {}

    local header = (def.platform_prefix or "PLATFORM") .. " " .. (def.track or "?") .. ":"
    header = string.format("%-20s %s", header, rwt.to_string(rwt.now(), true))

    return {
        header,
        info_lines[1] or "",
        info_lines[2] or "",
        info_lines[3] or "",
    }
end
