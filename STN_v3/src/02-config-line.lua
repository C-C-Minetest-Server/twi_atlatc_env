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

    -- Linked list of current station -> next station
    stations = {
        -- stn_id:track_id:point_id
        ["M27-SOL:1:E1"] = {
            delay = 30,
            reverse = true,

            next = "eGRO:6:S1",
            dir = "W",
        },

        ["eGRO:6:S1"] = {
            depint = "00;00;06;00",
            depoff = "00;00;00;00",

            delay = 30,

            next = "BAJ:2B:W1",
            dir = "W",
        },

        ["BAJ:2B:W1"] = {
            delay = 30,

            next = "eEAN:3:W1",
            dir = "W",
        },

        ["eEAN:3:W1"] = {
            delay = 30,
            reverse = true,

            next = "BAJ:1A:E1",
            dir = "E",
        },

        ["BAJ:1A:E1"] = {
            delay = 30,

            next = "eGRO:7:N1",
            dir = "E",
        },

        ["eGRO:7:N1"] = {
            delay = 30,

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

F.stn_v3_lines["OEX"] = {
    rc = "L-OEX",
    code = "OEX",
    name = {
        "Origin Express",
        "Origin Exp.",
        "Origin",
    },

    termini = {
        W = "eGRO",
        E = "HR-NEN",
    },

    stations = {
        ["eGRO:3:N1"] = {
            depint = "00;00;06;00",
            depoff = "00;00;01;00",

            delay = 10,
            reverse = true,

            next = "eYTP:3:S1",
            dir = "E",
        },
        ["eYTP:3:S1"] = {
            delay = 30,
            next = "HR-NEN:2:S1",
            dir = "E",
        },
        ["HR-NEN:2:S1"] = {
            delay = 30,
            next = "eYTP:4:N1",
            reverse = true,
            dir = "W",
        },
        ["eYTP:4:N1"] = {
            delay = 30,
            next = "eGRO:3:N1",
            dir = "W",
        },
    },
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

    stations = {
        ["eGRO:1:N1"] = {
            delay = 30,
            reverse = true,

            next = "BLE:2:S1",
            dir = "S",
        },
        ["BLE:2:S1"] = {
            depint = "00;00;06;00",
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
    code = "LIB",

    name = {
        "Libreland Shuttle",
        "Libreland",
    },
    termini = {
        W = "eLIB",
        E = "BAJ",
    },

    stations = {
        ["BAJ:2B:E1"] = {
            delay = 30,
            reverse = true,
            next = "eLIB:2:N1",
            dir = "W",
        },
        ["eLIB:2:N1"] = {
            depint = "00;00;06;00",
            depoff = "00;00;00;00",
            delay = 10,
            reverse = true,
            next = "BAJ:2B:E1",
            dir = "E",
        },
    }
}

-- (As of now) display only
F.stn_v3_lines["SPN"] = {
    code = "SPN",
    name = {
        "Origin Subway: Origin Line",
        "Origin Line",
        "Origin",
    },
}

F.stn_v3_lines["SPN-S1"] = {
    code = "S1",
    name = {
        "Originsphere S-Bahn: Line 1",
        "Origin S-Bahn: Line 1",
        "S-Bahn Line 1",
        "S1",
    },
}

F.stn_v3_lines["SVL"] = {
    code = "SVL",
    name = {
        "Originsphere S-Bahn: SmushyVille Loop",
        "Origin S-Bahn: SmushyVille Loop",
        "SmushyVille Loop",
        "SmushyVille",
    },
}
