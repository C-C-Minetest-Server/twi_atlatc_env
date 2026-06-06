assert(is_loading)

F.stn_v3_lines = {}

-- Grape Hills Subway

F.stn_v3_lines["GRH4"] = {
    rc = "L-GRH4",
    code = "GRH4",
    name = {
        "Grape Hills Line 4",
        "Grape Hills 4",
        "GRH Line 4",
        "GRH4",
    },
    termini = {
        N = "WEW",
        S = "GRO",
    },

    stations = {
        ["WEW:1:W1"] = {
            delay = 10,
            reverse = true,
            next = "GRO:4:S1",
            dir = "S",

            on_leave_rc = "B-GRO-T4S K-STN-CLEAR-ROUTE",
        },
        ["GRO:4:S1"] = {
            delay = 10,
            reverse = true,
            next = "WEW:1:W1",
            dir = "N",

            on_leave_rc = "B-WEW-T1W K-STN-CLEAR-ROUTE",
        },
    },
}

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
        E = "MAP",
    },

    -- Linked list of current station -> next station
    stations = {
        -- stn_id:track_id:point_id
        ["MAP:2:W1"] = {
            depint = "00;00;06;00",
            depoff = "00;00;02;00",

            delay = 10,
            reverse = true,

            next = "eGRO:6:S1",
            dir = "W",
        },

        ["eGRO:6:S1"] = {

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

            next = "MAP:2:W1",
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
            kick = true,

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

F.stn_v3_lines["CCP-CCB"] = {
    rc = "L-CCP-CCB",
    code = "CCP",
    name = {
        "Coco Beach Pier Shuttle",
        "Coco Pier Shuttle",
        "Coco Beach Pier",
        "Coco Pier",
    },
    termini = {
        N = "CCB",
        S = "CCP",
    },

    stations = {
        ["CCB:2:N1"] = {
            delay = 10,
            reverse = true,
            next = "CCP:1:S1",
            dir = "S",
        },
        ["CCP:1:S1"] = {
            depint = "00;00;06;00",
            depoff = "00;00;00;00",
            delay = 10,
            reverse = true,
            next = "CCB:2:N1",
            dir = "N",
        },
    },
}

-- Originsphere S-Bahn

F.stn_v3_lines["SPN-S2"] = {
    rc = "L-SPN-S2",
    code = "S2",
    name = {
        "Originsphere S-Bahn: Line 2",
        "Origin S-Bahn: Line 2",
        "S-Bahn Line 2",
        "S2",
    },
    termini = {
        N = "DEP",
        S = "HR-NEN",
    },

    stations = {
        ["DEP:2:N1"] ={
            depint = "00;00;02;30",
            depoff = "00;00;00;00",
            delay = 5,
            reverse = true,
            next = "eYTP:5:S2",
            dir = "S",
            on_leave_rc = "J-YTP-NO-YTP B-eYTP-T5S K-STN-CLEAR-ROUTE",
        },
        ["eYTP:5:S2"] = {
            delay = 15,
            next = "HR-LUC:1:S1",
            dir = "S",
            on_leave_rc = "B-HR-LUC-T1S K-STN-CLEAR-ROUTE",
        },
        ["HR-LUC:1:S1"] = {
            delay = 15,
            next = "HR-NEN:1:S1",
            dir = "S",
            on_leave_rc = "B-HR-NEN-T1S K-STN-CLEAR-ROUTE"
        },
        ["HR-NEN:1:S1"] = {
            delay = 15,
            reverse = true,
            next = "HR-LUC:6:N1",
            dir = "N",
            on_leave_rc = "B-HR-LUC-T6N K-STN-CLEAR-ROUTE",
        },
        ["HR-LUC:6:N1"] = {
            delay = 15,
            next = "eYTP:6:N1",
            dir = "N",
            on_leave_rc = "B-eYTP-T6N K-STN-CLEAR-ROUTE",
        },
        ["eYTP:6:N1"] = {
            delay = 15,
            next = "DEP:2:N1",
            dir = "N",
            on_leave_rc = "J-YTP-NO-DEP B-DEP-T2N K-STN-CLEAR-ROUTE",
        },
    }
}

-- Grape Hills S-Bahn
F.stn_v3_lines["S22"] = {
    rc = "L-S22",
    code = "S22",
    name = {
        "S-Bahn Line 22",
        "S22",
    },
    termini = {
        N = "MAP",
        S = "SNE",
    },

    stations = {
        ["SNE:1:W1"] = {
            delay = 15,
            reverse = true,
            next = "eOTH:1:N2",
            dir = "N",
            on_leave_rc = "J-SV_S-WL-WL B-eOTH-T1N K-STN-CLEAR-ROUTE",
        },
        ["eOTH:1:N2"] = {
            delay = 15,
            next = "eGRO:8:N2",
            dir = "N",
            on_leave_rc = "J-SV_N-WL-GRH J-SV_N-GRO-GRO B-eGRO-T8N K-STN-CLEAR-ROUTE",
        },
        ["eGRO:8:N2"] = {
            delay = 15,
            next = "LIV:2:W1",
            dir = "N",
            on_leave_rc = "J-GRO-LIV-LIV B-LIV-T2W K-STN-CLEAR-ROUTE",
        },
        ["LIV:2:W1"] = {
            delay = 15,
            next = "MAP:4:W1",
            dir = "N",
            on_leave_rc = "B-MAP-T4W K-STN-CLEAR-ROUTE",
        },
        ["MAP:4:W1"] = {
            delay = 15,
            next = "LIV:1:E1",
            reverse = true,
            dir = "S",
            on_leave_rc = "B-LIV-T1E K-STN-CLEAR-ROUTE",
        },
        ["LIV:1:E1"] = {
            delay = 15,
            next = "eGRO:5:N2",
            dir = "S",
            on_leave_rc = "J-LIV-GRO-GRO B-eGRO-T5S K-STN-CLEAR-ROUTE",
        },
        ["eGRO:5:N2"] = {
            delay = 15,
            next = "eOTH:2:S1",
            dir = "S",
            on_leave_rc = "J-SV_N-GRO-GRO J-SV_N-WL-WL B-eOTH-T2S K-STN-CLEAR-ROUTE",
        },
        ["eOTH:2:S1"] = {
            delay = 15,
            next = "SNE:1:W1",
            dir = "S",
            on_leave_rc = "J-SV_S-WL-WOM B-SNE-T1W K-STN-CLEAR-ROUTE",
        },
    }
}

-- Maverick2797 Railway
F.stn_v3_lines["M27-XSS"] = {
    rc = "L-XSS",
    code = "XSS",
    name = {
        "Cross-Server Sleeper",
        "X-Server Sleeper",
        "XS Sleeper",
        "XSS",
    },
    termini = {
        ACW = "M27-VER",
        CW = "M27-SOL",
    },

    stations = {
        ["M27-VER:1:N2"] = {
            depint = "00;00;05;30",
            depoff = "00;00;00;00",
            delay = 60,
            reverse = true,
            next = "eYTP:3:S2",
            dir = "CW",
            on_leave_rc = "J-YTP-NO-YTP J-YTP-YTP_N-YTP B-eYTP-T3S K-STN-CLEAR-ROUTE",
        },
        ["eYTP:3:S2"] = {
            delay = 10,
            next = "SAG:3:W2",
            dir = "CW",
            on_leave_rc = "J-YTP-YTP_S-SV_S B-SAG-T3W K-STN-CLEAR-ROUTE",
        },
        ["SAG:3:W2"] = {
            delay = 10,
            next = "eGRO:7:N2",
            dir = "CW",
            on_leave_rc = "J-SV_S-WL-WL J-SV_N-WL-GRH J-SV_N-GRO-GRO B-eGRO-T7N K-STN-CLEAR-ROUTE",
        },
        ["eGRO:7:N2"] = {
            delay = 10,
            next = "M27-SOL:2:E2",
            dir = "CW",
            on_leave_rc = "B-M27-SOL-T2E K-STN-CLEAR-ROUTE",
        },
        ["M27-SOL:2:E2"] = {
            depint = "00;00;05;30",
            depoff = "00;00;02;45",
            delay = 60,
            reverse = false, -- marked as false explicitly to show train doesn't reverse at terminus unlike most other stations
            next = "eGRO:6:S2",
            dir = "ACW",
            on_leave_rc = "B-eGRO-T6S K-STN-CLEAR-ROUTE",
        },
        ["eGRO:6:S2"] = {
            delay = 10,
            next = "SAG:5:E2",
            dir = "ACW",
            on_leave_rc = "J-SV_N-GRO-GRH J-SV_N-WL-WL J-SV_S-WL-SAG B-SAG-T5E K-STN-CLEAR-ROUTE",
        },
        ["SAG:5:E2"] = {
            delay = 10,
            next = "eYTP:4:N2",
            dir = "ACW",
            on_leave_rc = "J-YTP-YTP_S-YTP B-eYTP-T4N K-STN-CLEAR-ROUTE",
        },
        ["eYTP:4:N2"] = {
            delay = 10,
            next = "M27-VER:1:N2",
            dir = "ACW",
            on_leave_rc = "J-YTP-YTP_N-NO J-YTP-NO-DEP B-M27-VER-T1N K-STN-CLEAR-ROUTE",
        },
    }
}

-- Ferry lines
F.stn_v3_lines["FR-PLL-SNE"] = {
    rc = "L-FR-PLL-SNE",
    code = "PLL",
    name = {
        "Snezhnaya-PL Land Ferry",
        "PL Land Ferry",
        "PL Land",
    },
    termini = {
        N = "FR-SNE",
        S = "FR-PLL",
    },

    stations = {
        ["FR-SNE:1:e1"] = {
            delay = 60,
            reverse = true,
            next = "FR-PLL:1:S1",
            dir = "S",
        },
        ["FR-PLL:1:S1"] = {
            delay = 60,
            next = "FR-SNE:1:e1",
            dir = "N",
        },
    }
}

F.stn_v3_lines["FR-SLV-LIB"] = {
    rc = "L-FR-SLV-LIB",
    code = "SLV",
    name = {
        "Smallville-Libreland Ferry",
        "Smallville Ferry",
        "Smallville",
    },
    termini = {
        N = "FR-SLV",
        S = "FR-LIB",
    },

    stations = {
        ["FR-LIB:1:e1"] = {
            delay = 60,
            next = "FR-SLV:1:E1",
            dir = "N",
            reverse = true,
        },
        ["FR-SLV:1:E1"] = {
            delay = 60,
            next = "FR-LIB:1:e1",
            dir = "S",
        },
    },
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
