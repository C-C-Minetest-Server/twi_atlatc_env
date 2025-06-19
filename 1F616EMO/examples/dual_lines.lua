F.stn_v2({
    here     = "eSPH",
    track    = "1",
    door_dir = "R",
}, {
    ["LUC"] = {
        dir            = "S",
        rev_dir        = "N",
        delay          = 15,
        reverse        = false,
        next           = "eYTP",
        rev_next       = "eGRH",
        next_track     = "5",
        next_time      = nil,
        rev_next_track = "3",
        rev_next_time  = nil,
    },
    ["VFT"] = {
        rev_dir    = "S",
        reverse    = true,
        next       = "VFT",
        next_track = "2",
        next_time  = nil,
        delay      = 10,
    },
})
