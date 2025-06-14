F.garbage_cleaner = function()
    -- S.arrive_time_from_last_stn
    for this_key, this_data in pairs(S.arrive_time_from_last_stn) do
        local now = os.time()
        for train_id, data in pairs(this_data) do
            if data[1] < now then
                this_data[train_id] = nil
            end
        end

        if not next(this_data) then
            S.arrive_time_from_last_stn[this_key] = nil
        end
    end
end
