assert(is_loading)

function F.passing_loop(def)
    __approach_callback_mode = 1

    local passing_loop_defs = def.passing_loops
    local checked_sections = def.checked_sections
    local speed_difference = def.speed_difference or 5

    local signal = def.signal
    local default_route = def.default_route

    -- The signal that can block exit signal of the passing loop
    local after_signal = def.after_signal
    local after_route = def.after_default_route

    if event.approach and not event.has_entered then
        local train = get_train()
        local this_train_id = train:get_id()

        if passing_loop_last_processed and passing_loop_last_processed == this_train_id then -- luacheck: ignore
            return
        end
        passing_loop_last_processed = this_train_id -- luacheck: ignore

        if def.custom_set_route then
            local route = def.custom_set_route(train)
            if route then
                interrupt(0, {
                    passing_loop_set_route = true,
                    route = route,
                })
                return
            end
        end

        local this_train_max_speed = train:get_max_speed()
        local this_train_length = train:train_length_meters()

        local found_train_section = false
        local that_train = false
        for _, section in ipairs(checked_sections) do
            local section_occupancy = section_occupancy(section)
            local train_in_section = section_occupancy[1] -- Normally only one train per section

            if train_in_section and found_train_section then
                that_train = get_train(train_in_section)
                break
            elseif train_in_section == this_train_id then
                found_train_section = true
            end
        end

        if not that_train then
            interrupt(0, {
                passing_loop_set_route = true,
                route = default_route,
            })
            return
        end

        local that_train_max_speed = that_train:get_max_speed()
        if this_train_max_speed - that_train_max_speed > speed_difference then
            -- We are faster
            interrupt(0, {
                passing_loop_set_route = true,
                route = default_route,
            })
            return
        end

        -- They are faster, we should wait

        -- Would that faster train intentionally go into the passing loop?
        -- Do not block the loop in such cases
        local that_train_route = def.custom_set_route and def.custom_set_route(that_train) or nil
        if that_train_route then
            passing_loop_defs[that_train_route] = nil
        end

        for pl_name, pl_def in pairs(passing_loop_defs) do
            if pl_def.max_tl and this_train_length > pl_def.max_tl then -- luacheck: ignore
                -- Too long to fit in this passing loop
            elseif can_set_route(signal, pl_name) then
                interrupt(0, {
                    passing_loop_set_route = true,
                    set_after_route = true,
                    route = pl_name,
                })
                return
            end
        end

        -- No passing loop available, go to default
        interrupt(0, {
            passing_loop_set_route = true,
            route = default_route,
        })
        return
    elseif event.msg and event.msg.passing_loop_set_route then
        set_route(signal, event.msg.route)
        if event.msg.set_after_route and after_signal and after_route then
            set_route(after_signal, after_route)
        end
    end
end
