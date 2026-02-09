assert(is_loading)

function F.checkpoint(name)
    if not event.train or not atc_arrow then return end

    if not name then
        name = atc_pos.x .. ":" .. atc_pos.y .. ":" .. atc_pos.z
    end

    name = "!CHK:" .. tostring(name)
    F.register_train_on_checkpont(atc_id, name)
end

function F.external_interrupt_checkpoint_handler()
    if event.punch then
        print("F.external_interrupt_checkpoint_handler up and running: (" ..
            atc_pos.x .. "," .. atc_pos.y .. "," .. atc_pos.z .. ")")
        return
    end

    if not event.ext_int then return end
    if type(event.message) ~= "table" then return end

    local atc_id, name = event.message.atc_id, event.message.name
    F.register_train_on_checkpont(atc_id, "!CHK:" .. name)
end
