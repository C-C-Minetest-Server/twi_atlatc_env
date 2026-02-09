assert(is_loading)

local function rwt_copy(rwtime)
    local rwtimet = rwt.to_table(rwtime)
    return {
        c = rwtimet.c or 0,
		h = rwtimet.h or 0,
        m = rwtimet.m or 0,
        s = rwtimet.s or 0
    }
end

function F.resort_track_trains(track_key)
    if not F.pis_list_of_trains[track_key] then return end

    local atc_id_list = {}

    for atc_id in pairs(F.pis_list_of_trains[track_key]) do
        atc_id_list[#atc_id_list + 1] = atc_id
    end

    if #atc_id_list == 0 then
        F.pis_list_of_trains[track_key] = nil
        F.pis_list_of_trains_sorted[track_key] = nil
        return
    end

    table.sort(atc_id_list, function(a, b)
        local data_a = F.pis_list_of_trains[track_key][a]
        local data_b = F.pis_list_of_trains[track_key][b]

        if data_a.train_status == "stopped" and data_b.train_status ~= "stopped" then
            return true
        elseif data_a.train_status ~= "stopped" and data_b.train_status == "stopped" then
            return false
        end

        local eta_a = data_a.estimated_time
        local eta_b = data_b.estimated_time

        if not eta_a then
            return false
        elseif not eta_b then
            return true
        end

        return rwt.is_before(eta_a, eta_b)
    end)

    F.pis_list_of_trains_sorted[track_key] = atc_id_list
end

function F.make_sure_sorted_trains_exist(track_key)
    if not F.pis_list_of_trains_sorted[track_key] then
        F.resort_track_trains(track_key)
    end
end

function F.validate_train_event(data)
    if type(data) ~= "table" then return false, "data" end

    if data.type == "update_train" or data.type == "deregister_train" then
        if type(data.atc_id) == "number" then
            if data.atc_id > 0 then
                data.atc_id = tostring(data.atc_id)
            else
                return false, "data.atc_id"
            end
        elseif type(data.atc_id) == "string" and not data.atc_id:match("^%d+$") then
            return false, "data.atc_id"
        end

        if data.type == "update_train" and (data.train_status == "arriving"
                or data.train_status == "approaching"
                or data.train_status == "stopped"
                or data.train_status == "deregister") then
            if type(data.station_id) ~= "string" then
                return false, "data.station_id"
            end

            if type(data.track_id) ~= "string" then
                return false, "data.track_id"
            end

            if data.train_status ~= "deregister" then
                if type(data.line_code) ~= "string" or #data.line_code > 4 then
                    return false, "data.line_code"
                end

                if type(data.direction_code) ~= "string" then
                    return false, "data.direction_code"
                end

                if not F.validate_variable_length_string(data.line_name) then
                    return false, "data.line_name"
                end

                if not F.validate_variable_length_string(data.heading_to) then
                    return false, "data.heading_to"
                end

                if not rwt.to_table(data.estimated_time)
                    and data.estimated_time ~= nil and data.train_status ~= "stopped" then
                    return false, "data.estimated_time"
                end
            end
        else
            return false, "data.train_status"
        end
    else
        return false, "data.type"
    end

    return true
end

function F.register_train_event(data)
    do
        local validate_status, validate_err = F.validate_train_event(data)
        if not validate_status then
            return false, validate_err
        end
    end

    if data.type == "update_train" then
        local track_key = data.station_id .. ":" .. data.track_id

        if data.train_status == "arriving" or data.train_status == "approaching" or data.train_status == "stopped" then
            F.pis_list_of_trains[track_key] = F.pis_list_of_trains[track_key] or {}
            F.pis_list_of_trains[track_key][data.atc_id] = {
                train_status = data.train_status,
                line_code = data.line_code,
                line_name = data.line_name,
                heading_to = data.heading_to,
                direction_code = data.direction_code,
                estimated_time = rwt_copy(data.estimated_time),
            }
            F.pis_list_of_trains_sorted[track_key] = nil

            if data.train_status == "stopped" then
                F.pis_train_stopped_on_track[track_key] = data.atc_id
            elseif F.pis_train_stopped_on_track[track_key] == data.atc_id then
                F.pis_train_stopped_on_track[track_key] = nil
            end
        elseif data.train_status == "deregister" then
            if F.pis_list_of_trains[track_key] then
                F.pis_list_of_trains[track_key][data.atc_id] = nil
                F.pis_list_of_trains_sorted[track_key] = nil

                if F.pis_train_stopped_on_track[track_key] == data.atc_id then
                    F.pis_train_stopped_on_track[track_key] = nil
                end
            end
        end
    elseif data.type == "deregister_train" then
        for track_key, track_data in pairs(F.pis_list_of_trains) do
            if track_data[atc_id] then
                track_data[atc_id] = nil
                F.pis_list_of_trains_sorted[track_key] = nil

                if F.pis_train_stopped_on_track[track_key] == data.atc_id then
                    F.pis_train_stopped_on_track[track_key] = nil
                end
            end
        end
    end

    return true
end

function F.external_interrupt_handler()
    if event.punch then
        print("F.external_interrupt_handler up and running: (" ..
            atc_pos.x .. "," .. atc_pos.y .. "," .. atc_pos.z .. ")")
        return
    end

    if not event.ext_int then return end
    if type(event.message) ~= "table" then return end

    local batch = event.message.type == "batch" and event.message.batch or { event.message }

    for i, message in ipairs(batch) do
        local status, err = F.register_train_event(message)
        if not status then
            print("ERROR when handling event from " ..
                ((type(message.source_id) == "string") and message.source_id or "an unknown source") ..
                " batch #" .. i .. ": " .. err, message)
        end

        if event.return_to and event.return_iid then
            interrupt_pos(event.return_to, {
                iid = event.return_iid,
                ok = status,
                error = err,
            })
        end
    end
end
