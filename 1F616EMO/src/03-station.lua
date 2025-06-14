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

function F.set_outside_01700(def)
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
        elseif F.has_rc("WG-01700", rc) then
            F.set_outside_01700(def)
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

if not S.stn_status then
    S.stn_status = {}
end

F.rev_dirs = {
    N = "S",
    E = "W",
    S = "N",
    W = "E",

    CW = "ACW",
    ACW = "CW",

    U = "D",
    D = "U",
}

F.dir_short_name = {
    N = "Northbound",
    E = "Eastbound",
    S = "Southbound",
    W = "Westbound",

    CW = "Clockwise",
    ACW = "Anti-clockw.",

    U = "Up",
    D = "Down",
}

F.get_stn_status_key = function(def)
    local track = def.track or def.platform_id
    if not (def.here and track) then return end
    return def.here .. ":" .. track
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

    if event.approach and not event.has_entered and atc_arrow then
        for line_id, def in pairs(lines_def) do
            def.line = line_id
            for _, key in ipairs({
                "track", "platform_id",
                "here", "door_dir",
                "signal", "rev_signal",
            }) do
                def[key] = def[key] or basic_def[key] or nil
            end
            def.line = line_id
            local line_def = F.lines[line_id]
            if train and match_train(line_def, train) then
                atc_set_ars_disable(true)
                atc_set_lzb_tsr(2)
                local stn_name = F.stations[here] or here
                atc_set_text_inside("Stopping at: " .. stn_name .. generate_interchange_string(here, line_id))
                F.set_outside(def, atc_id)

                if status_key and (not S.stn_status[status_key] or S.stn_status[status_key].atc_id ~= atc_id) then
                --if status_key then
                    local now = os.time()
                    local index = train.get_index and train:get_index() or 0
                    local max_speed = train:get_max_speed()
                    local arr_after = floor(((max_speed + sqrt(abs(max_speed * max_speed - 30 - 3 * index))) / 3)
                        + (def.approach_correction or 0) + F.GLOBAL_APPROACH_CORRECTION - 1)
                    local arr_at = arr_after + now
                    S.stn_status[status_key] = {
                        status = "arriving",
                        time = now,
                        def = def,
                        atc_id = atc_id,
                        max_speed = max_speed,
                        arr_at = arr_at,
                        index = index,
                    }
                    F.set_arrive_data_from_last_stn(def, arr_after + (def.delay or 10) + 2)
                end

                if basic_def.alt_tracks then
                    for _, alt_track in basic_def.alt_tracks do
                        local alt_status_key = basic_def.here .. ":" .. alt_track
                        S.stn_status[alt_status_key] = {
                            status = "opposite",
                            time = os.time(),
                            atc_id = atc_id,
                        }
                    end
                end

                return
            end
        end

        -- No match
        if status_key then
            S.stn_status[status_key] = {
                status = "nonstop",
                time = os.time(),
                atc_id = atc_id,
            }
        end
    elseif event.train and atc_arrow then
        if status_key and S.stn_status[status_key] and S.stn_status[status_key].status == "nonstop" then
            S.stn_status[status_key] = nil
        end

        for line_id, def in pairs(lines_def) do
            def.line = line_id
            for k, v in pairs(basic_def) do
                def[k] = v
            end
            def.line = line_id
            local line_def = F.lines[line_id]
            if train and match_train(line_def, train) then
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
                if def.rpt_interval then
                    rwnext = rwtime
                    repeat
                        rwnext = rwt.next_rpt(rwnext, def.rpt_interval, def.rpt_offset or 0)
                    until rwt.diff(rwtime, rwnext) >= (def.min_stop_time or 5)
                else
                    rwnext = rwt.add(rwtime, def.delay or 10)
                end
                def.rwnext = rwnext
                if rwt.diff(rwnext, rwtime) > 1 then
                    schedule(rwt.sub(rwnext, 1), {
                        type = "enable_ars",
                        line_id = line_id,
                    })
                elseif def.reverse then
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
                time_str = "\nArr. " .. rwt.to_string(rwtime, true) .. " Dep. " .. rwt.to_string(rwnext, true)

                atc_send("B0WO" .. (def.door_dir or "C") .. (def.kick and "K" or ""))

                local stn_name = F.stations[here] or here
                local through = def.reverse and def.rev_through or def.through or nil
                atc_set_text_inside(stn_name .. time_str .. generate_interchange_string(def.here, def.line, through))
                F.set_outside(def, atc_id)

                if status_key then
                    S.stn_status[status_key] = {
                        status = "arrived",
                        time = os.time(),
                        def = def,
                        atc_id = atc_id,
                    }
                end

                F.set_arrive_data_from_last_stn(def, (def.delay or 10) + 2)

                return
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
            F.set_arrive_data_from_last_stn(def)

            local next = def.reverse and def.rev_next or def.next
            local next_name = F.stations[next] or next or ""
            local inside_text = ""
            if next and next_name then
                local stn_name = F.stations[next] or next or ""
                local through = def.reverse and def.rev_through or def.through or nil
                inside_text = "Next stop: " .. stn_name .. generate_interchange_string(next, line_id, through)
            end
            atc_set_text_inside(inside_text)

            if status_key then
                S.stn_status[status_key] = nil
            end

            if basic_def.alt_tracks then
                for _, alt_track in basic_def.alt_tracks do
                    local alt_status_key = basic_def.here .. ":" .. alt_track
                    S.stn_status[alt_status_key] = nil
                end
            end
        end
    end
end

-- { stn: { atc_id: { arr_time, line, dir } } }
S.arrive_time_from_last_stn = S.arrive_time_from_last_stn or {}

F.set_arrive_data = function(atc_id, dest, track, line, dir, time)
    local key = dest .. ":" .. track
    if not S.arrive_time_from_last_stn[key] then
        S.arrive_time_from_last_stn[key] = {}
    end
    S.arrive_time_from_last_stn[key][atc_id] = {
        os.time() + time,
        line,
        dir
    }
end

F.set_arrive_data_from_last_stn = function(def, additional_time)
    local line = def.through or def.line
    local dir = def.reverse and def.rev_dir or def.dir or nil
    if not line then return end
    local next_stn = def.reverse and def.rev_next or def.next or nil
    local next_track = def.reverse and def.rev_next_track or def.next_track or nil
    local next_time = def.reverse and def.rev_next_time or def.next_time or nil
    if not (next_stn and next_track and next_time) then return end

    if dir then
        local line_def = F.lines[line]
        if line_def[dir] == next_stn and line_def[F.rev_dirs[dir]] then -- Term
            dir = F.rev_dirs[dir]
        end
    end

    F.set_arrive_data(atc_id, next_stn, next_track, line, dir, next_time + (additional_time or 0))
end

F.set_arrive_data_on_runover = function(defs)
    if not (event.train and atc_arrow) then return end
    local train = get_train(atc_id)
    if not train then return end
    for line_id, def in pairs(defs) do
        local line_def = F.lines[line_id]
        if line_def and train and match_train(line_def, train) then
            if def.next and def.next_track and def.next_time then
                F.set_arrive_data(atc_id, def.next, def.next_track, line_id, def.dir, def.next_time)
            end
            return
        end
    end
end

F.get_arrive_data_from_last_stn = function(def)
    local this_key = F.get_stn_status_key(def)
    local this_data = S.arrive_time_from_last_stn[this_key]
    if not (this_key and this_data) then return end

    local now = os.time()
    local earlist_data
    for train_id, data in pairs(this_data) do
        if data[1] < now then
            this_data[train_id] = nil
        else
            if not earlist_data or data[1] < earlist_data[1] then
                earlist_data = data
            end
        end
    end

    if not next(this_data) then
        S.arrive_time_from_last_stn[this_key] = nil
    end

    return earlist_data
end

F.get_station_status = function(def)
    local now = os.time()
    local status = S.stn_status[F.get_stn_status_key(def)]
    if status then
        local stn_def = status.def or {}
        local dir = stn_def.reverse and stn_def.rev_dir or stn_def.dir or nil
        if status.status == "arriving" and status.arr_at then
            return "ARR", (status.arr_at - now), stn_def.line, dir
        elseif status.status == "arrived" then
            local leaving_in
            if stn_def.rwnext then
                leaving_in = rwt.diff(rwt.now(), stn_def.rwnext)
            else
                local delay = stn_def.delay or 10
                leaving_in = delay - now + status.time + 2
            end
            return "DEP", leaving_in, stn_def.line, dir
        end
    end

    local arr_from_last_stn = F.get_arrive_data_from_last_stn(def)
    if arr_from_last_stn then
        local status_code = status
            and (status.status == "nonstop" and "NON"
                or status.status == "opposite" and "OPP")
            or "ARR"
        return status_code,
            (arr_from_last_stn[1] - now),
            arr_from_last_stn[2],
            arr_from_last_stn[3]
    end
end

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
        table.insert(rtexts, string.format("%26s", y))
    end
    display(table.concat(texts, "\n"), table.concat(rtexts, "\n"))
end

function F.show_textline_r(_, texts)
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%26s", y))
    end
    display(table.concat(rtexts, "\n"), table.concat(texts, "\n"))
end


F.set_textline = function(def)
    if not def.track then
        def.track = def.platform_id
    end
    local texts = {
        (def.platform_prefix or "PLATFORM") .. " " .. (def.track or "?") .. ":",
    }

    local timer_str
    local stn_event, time_left, line_id, dir = F.get_station_status(def)
    if stn_event == "ARR" then
        timer_str = "Arriving in " .. time_left .. " sec."
    elseif stn_event == "DEP" then
        timer_str = "Leaving " .. (time_left > 0 and ("in " .. time_left .. " sec.") or "now")
    elseif def.line then
        line_id = line_id or def.line or nil
        dir = def.reverse and def.rev_dir or def.dir or nil
    end

    if stn_event == "NON" then
        local linedef = F.lines[line_id]
        texts[#texts + 1] = def.custom_line or linedef and linedef.textline_name or linedef.name or line_id or ""
        texts[#texts + 1] = "!! NONSTOP TRAIN !!"
        texts[#texts + 1] = "!!    ARRIVING   !!"
    elseif stn_event == "OPP" then
        local linedef = F.lines[line_id]
        texts[#texts + 1] = def.custom_line or linedef and linedef.textline_name or linedef.name or line_id or ""
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

        texts[#texts + 1] = def.custom_line or linedef and linedef.textline_name or linedef.name or line_id
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
            if stn_event == "ARR" or (stn_event == "NON" and time_left) then
                append_text = string.format("Arr. %2s", time_left)
            elseif stn_event == "DEP" then
                append_text = string.format("Dep. %2s", time_left > 0 and time_left or "  ")
            elseif disp_def.line then
                line_id = line_id or disp_def.line or nil
                dir = dir or disp_def.dir or nil
            end

            if line_id then
                local linedef = F.lines[line_id]
                disp = disp .. (linedef.code or line_id)

                local term_text = linedef.custom_term_desc_short or linedef.custom_term_desc
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