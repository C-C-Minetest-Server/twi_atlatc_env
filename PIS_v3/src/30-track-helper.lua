assert(is_loading)

function F.deregister_train_above(ignore_atc_arrow)
    if not event.train or not (atc_arrow or ignore_atc_arrow) then return end

    return F.register_train_event({
        type = "deregister_train",
        atc_id = atc_id,
    })
end
