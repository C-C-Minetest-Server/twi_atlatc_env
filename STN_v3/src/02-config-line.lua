assert(is_loading)

F.stn_v3_lines = {}

--[[
eGRO-related lines:
NX: 3 trains, interval 6 minutes, offset 1 minute
S21: 6 trains, interval 3 minutes for double the time of NX, offset 0 minutes
OEX: 2 trains, interval 6 minutes, offset 0 minutes
BLE-GRO: 1 train, interval 6 minutes, offset 2 minutes
]]

F.stn_v3_lines["NX"] = {
    -- Train matching
    rc = "L-NX",

    -- PIS display parameters
    code = "NX",
    name = {
        "Newcomers Express",
        "Newcomers",
    },
    termini = {
        W = "eEAN",
        E = "M27-SOL",
    },

    base_depint = "00;00;06;00", -- Full journey: 00;18;00 with 3 trains
    base_depoff = "-00;00;04;00",

    -- Linked list of current station -> next station
    stations = {
        -- stn_id:track_id:point_id
        ["M27-SOL:1:E1"] = {
            -- Schedule information
            depoff = "00;00;00;00",

            -- Scheduled stops: Minimum door waiting time (default: 5)
            delay = 10,
            reverse = true,

            next = "eGRO:6:S1",
            dir = "W",
        },

        ["eGRO:6:S1"] = {
            -- Schedule information
            depoff = "00;00;05;00",

            -- Scheduled stops: Minimum door waiting time (default: 5)
            delay = 15,

            next = "BAJ:2B:W1",
            dir = "W",
        },

        ["BAJ:2B:W1"] = {
            -- Schedule information
            depoff = "00;00;07;00",

            -- Scheduled stops: Minimum door waiting time (default: 5)
            delay = 10,

            next = "eEAN:2:W1",
            dir = "W",
        },

        ["eEAN:2:W1"] = {
            -- Schedule information
            depoff = "00;00;09;00",

            -- Scheduled stops: Minimum door waiting time (default: 5)
            delay = 10,
            reverse = true,

            next = "BAJ:1A:E1",
            dir = "E",
        },

        ["BAJ:1A:E1"] = {
            -- Schedule information
            depoff = "00;00;11;00",

            -- Scheduled stops: Minimum door waiting time (default: 5)
            delay = 10,

            next = "eGRO:7:N1",
            dir = "E",
        },

        ["eGRO:7:N1"] = {
            -- Schedule information
            depoff = "00;00;13;00",

            -- Scheduled stops: Minimum door waiting time (default: 5)
            delay = 15,

            next = "M27-SOL:1:E1",
            dir = "E",
        },
    },

    --[[
    Experiment results:
    M27-SOL -> GRO: 03;30 (leave some more room to tolerate M27-QUO delays)
    eGRO -> BAJ: 01;38 (may race with LIB-BAJ, so leave at least 30s room)
    BAJ -> eEAN: 01;25

    full trip: 15;19
    ]]
}

F.stn_v3_lines["BLE"] = {
    rc = "L-BLE",

    code = "BLE",
    name = {
        "Bledarhood Shuttle",
        "Bleadrhood",
    },
    termini = {
        N = "eGRO",
        S = "BLE",
    },

    base_depint = "00;00;06;00",
    base_depoff = "00;00;02;00",

    stations = {
        ["eGRO:1:N1"] = {
            depoff = "00;00;00;00",

            delay = 10,
            reverse = true,

            next = "BLE:2:S1",
            dir = "S",
        },
        ["BLE:2:S1"] = {
            depoff = "00;00;04;30",

            delay = 10,
            reverse = true,

            next = "eGRO:1:N1",
            dir = "N",
        },
    }
}

F.stn_v3_lines["LIB-BAJ"] = {
    rc = "L-LIB-BAJ",

    name = {
        "Libreland Shuttle",
        "Libreland",
    },
    termini = {
        W = "eLIB",
        E = "BAJ",
    },

    base_depint = "00;00;06;00",
    base_depoff = "00;00;08;00",

    stations = {
        ["BAJ:2B:E1"] = {
            depoff = "00;00;01;00",
            delay = 10,
            reverse = true,
            next = "eLIB:2:N1",
            dir = "W",
        },
        ["eLIB:2:N1"] = {
            depoff = "00;00;04;45",
            delay = 10,
            reverse = true,
            next = "BAJ:2B:E1",
            dir = "E",
        },
    }
}
