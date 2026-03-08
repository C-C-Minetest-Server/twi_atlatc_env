assert(is_loading)

-- Returns data for twi_mods/twi_pis_export/init.lua. Called passively.
function F.export_data()
    local list_of_trains = {}

    for track_key, trains_data in pairs(F.pis_list_of_trains) do
        F.make_sure_sorted_trains_exist(track_key)

        local station_data = {}
        list_of_trains[track_key] = station_data
        list_of_trains[track_key].order = F.pis_list_of_trains_sorted[track_key]

        for atc_id, train_data in pairs(trains_data) do
            station_data[atc_id] = {
                train_status   = train_data.train_status,
                line_code      = train_data.line_code,

                -- Handle variable-length strings
                line_name      = F.handle_variable_length_string(train_data.line_name),
                heading_to     = F.handle_variable_length_string(train_data.heading_to),

                -- Convert RWTs into strings
                estimated_time = train_data.estimated_time and rwt.t_str(train_data.estimated_time, 2),
            }
        end
    end

    return {
        -- For ticking the clock without frequent updates
        time_generated     = os.time(),
        time_generated_rwt = rwt.now(), -- table of c, h, m, s

        list_of_trains     = list_of_trains,
    }
end
