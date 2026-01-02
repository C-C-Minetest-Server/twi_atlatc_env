assert(is_loading)

function F.speed_routing(signal, threshold, fast, slow)
    __approach_callback_mode = 1

    if event.approach and not event.has_entered and atc_arrow then
        local aspect = get_aspect(signal)
        if aspect_is_free(aspect) then return end

        local train = get_train()

        if train:get_ars_disable() then
            atc_set_lzb_tsr(0)
            return
        end

        local max_speed = train:get_max_speed()
        local route = max_speed >= threshold and fast or slow
        interrupt(0, {
            speed_routing = true,
            route = route,
        })
    elseif event.int and type(event.msg) == "table" and event.msg.speed_routing then
        set_route(signal, event.msg.route)
    end
end
