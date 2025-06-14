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

F.pre_signal = function(curr_system)
    __approach_callback_mode = 1

    if not event.approach or event.has_entered then return end

    local rc = F.get_rc_safe()
    if rc == "" then return end

    if F.has_rc("A0", rc) then
        atc_set_ars_disable(true)
    elseif F.has_rc("A1", rc) then
        atc_set_ars_disable(false)
    end

    if curr_system then
        F.find_and_set_route(curr_system)
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