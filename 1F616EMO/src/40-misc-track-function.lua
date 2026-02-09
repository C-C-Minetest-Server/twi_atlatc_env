assert(is_loading)

F.rev = function(speed, func)
    __approach_callback_mode = 1

    if func then
        if not func() then return end
    end

    if event.approach and not event.has_entered then
        atc_set_ars_disable(true)
        atc_set_lzb_tsr(2)
    elseif event.train and atc_arrow then
        speed = speed or "M"
        atc_send("B0WRA1S" .. speed)
    end
end

F.pre_signal = function(_dep_curr_system)
    __approach_callback_mode = 1

    if not event.approach or event.has_entered then return end

    local rc = F.get_rc_safe()
    if rc == "" then return end

    if F.has_rc("A0", rc) then
        atc_set_ars_disable(true)
    elseif F.has_rc("A1", rc) then
        atc_set_ars_disable(false)
    end
end

F.set_route_if_all_can = function(defs)
    for _, def in ipairs(defs) do
        if not can_set_route(def[1], def[2]) then return end
    end
    for _, def in ipairs(defs) do
        set_route(def[1], def[2])
    end
    return true
end

F.checkpoint = function(checkpoint_id)
    if event.train and atc_arrow and atc_id then
        if not checkpoint_id then
            if atc_pos then
                checkpoint_id = "POS:" .. atc_pos.x .. ":" .. atc_pos.y .. ":" .. atc_pos.z .. ""
            else
                return
            end
        end
        F.register_train_on_checkpoint(checkpoint_id, atc_id)
    end

    -- Hook onto PIS_v3 so to avoid track replacements
    interrupt_pos("STN_v3_chkpt_int", {
        atc_id = atc_id,
        name = checkpoint_id or (atc_pos.x .. ":" .. atc_pos.y .. ":" .. atc_pos.z),
    })
end

F.approach_alarm_start = function(track_id)
    __approach_callback_mode = 1

    if not event.approach or event.has_entered then return end

    F.activate_approach_alarm(track_id, atc_id)
end

F.approach_alarm_end = function(track_id)
    if not event.train or not atc_arrow then return end
    F.deactivate_approach_alarm(track_id)
end

-- on LuaATC Luacontrollers
F.controller_alarm_detect = function(watches, frequency)
    local port = {}
    frequency = frequency or 0.4

    if event.msg == "start" then
        local activated = false
        for _, watch in ipairs(watches) do
            if F.get_activated_approach_alarm(watch) then
                activated = true
                break
            end
        end

        if activated then
            port.a = true
            port.b = true
            port.c = true
            port.d = true
            set_mesecon_outputs(port)
            digiline_send("debug", "act")

            interrupt(frequency / 2, "end")
        else
            interrupt(1, "start")
            digiline_send("debug", "loop")
        end
    elseif event.msg == "end" then
        port.a = false
        port.b = false
        port.c = false
        port.d = false
        set_mesecon_outputs(port)

        interrupt(frequency / 2, "start")
        digiline_send("debug", "loop")
    else
        interrupt_safe(0, "start")
    end
end
