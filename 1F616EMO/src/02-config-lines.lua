local function construct_adjacent_stations(list)
    local station_to_following_stations = {}
    for i, station in ipairs(list) do
        local following_stations = {}
        local j = i
        repeat
            j = j + 1
            if j > #list then
                j = 1
            end
            following_stations[#following_stations + 1] = list[j]
        until j == i
        station_to_following_stations[station[1] .. ":" .. station[2]] = following_stations
    end
    return station_to_following_stations
end

F.lines = {
    ["U1"] = {
        -- RC L-U1
        -- was: Spawn Subway Line 1
        -- was: Spawn Metro: Islands Line
        rc = "L-U1",
        code = "ISL",
        name = "Origin Metro: Islands Line",
        textline_name = "Islands Line",
        short_name = "Islands",
        W = "SPN",
        through_E = "CEN",
    },
    ["S1"] = {
        -- RC L-S1
        -- was: S1
        -- was: Spawn Metro: Eastern Line
        rc = "L-S1",
        code = "ERL",
        background_color = "#74fa74",
        color = "#002b36",
        name = "Origin Metro: Eastern Line",
        textline_name = "Eastern Line",
        short_name = "Eastern",
        N = "HAI",
        S = "OVV",
    },
    ["SPN-CW"] = {
        -- Spawn Line (Clockwise)
        -- was: Spawn Metro: Spawn Line
        rc = "L-SPN-CW",
        code = "SPN",
        name = "Origin Metro: Origin Loop",
        textline_name = "Origin Line",
        short_name = "Origin",
        default_dir = "CW",
        custom_dir_abbr = "CW",
        custom_term_desc = "Clockwise Loop",
        custom_term_desc_textline = "Clockwise Loop",
        custom_term_desc_short = "Clockwise",

        adjacent_stations = construct_adjacent_stations({
            -- station, track, reverse point
            {"SPN", "1"},
            {"SPS", "1"},
            {"ALF", "1"},
            {"NLU", "1"},
            {"MOF", "1"},
            {"YTP", "1"},
            {"HLY", "1"},
        }),
    },
    ["SPN-ACW"] = {
        -- Spawn Line (Anti clockwise)
        -- was: Spawn Metro: Spawn Line
        rc = "L-SPN-ACW",
        code = "SPN",
        name = "Origin Metro: Origin Loop",
        textline_name = "Origin Line",
        short_name = "Origin",
        default_dir = "ACW",
        custom_dir_abbr = "ACW",
        custom_term_desc = "Anti-clockwise Loop",
        custom_term_desc_textline = "Anti-clockwise Loop",
        custom_term_desc_short = "Anti-clockw.",

        adjacent_stations = construct_adjacent_stations({
            -- station, track, reverse point
            {"SPN", "2"},
            {"HLY", "2"},
            {"YTP", "2"},
            {"MOF", "2"},
            {"NLU", "2"},
            {"ALF", "2"},
            {"SPS", "2"},
        }),
    },

    ["CSL"] = {
        rc = "L-CSL",
        name = "SmushyVille Metro: Castle Line",
        textline_name = "Castle Line",
        short_name = "Castle",
        E = "SVE",
        W = "SAE",
    },

    ["CEN"] = {
        rc = "L-U1",
        name = "Acacia Plains Railway: Central Line",
        textline_name = "Central Line",
        short_name = "Central",
        through_W = "U1",
        E = "ACP",
    },
    ["OAI"] = {
        rc = "L-OAI",
        name = "Acacia Plains Railway: Oasis Line",
        textline_name = "Oasis Line",
        short_name = "Oasis",
        N = "ACP",
        S = "OAI",
    },

    ["GRH1"] = {
        rc = "L-GRH1",
        name = "Grape Hills Line 1",
        textline_name = "Grape Hills 1",
        short_name = "GRH1",
    },
    ["GRH2"] = {
        rc = "L-GRH2",
        name = "Grape Hills Line 2",
        textline_name = "Grape Hills 2",
        short_name = "GRH2",

        W = "DUI",
        E = "KIH",

        adjacent_stations = construct_adjacent_stations({
            -- station, track, reverse point
            {"DUI", "1", true},
            {"GRO", "2"},
            {"SCC", "2"},
            {"GRH", "3"},
            {"SHI", "2"},
            {"KIH", "2", true},
            {"SHI", "3"},
            {"GRH", "2"},
            {"SCC", "1"},
            {"GRO", "1"},
        }),
    },
    ["GRH3"] = {
        rc = "L-GRH3",
        name = "Grape Hills Line 3",
        textline_name = "Grape Hills 3",
        short_name = "GRH3",
    },

    ["eCEN"] = {
        rc = "L-eCEN",
        name = "Spawn-Acacia Plains Central Express",
        textline_name = "Central Express",
        short_name = "SPN-ACP",
        W = "SPN",
        E = "ACP",
    },

    ["NO1"] = {
        line = "NO1",
        code = "NO-LRT1",
        name = "Nordstetten LRT: Line 1",
        textline_name = "Nordstetten LRT 1",
        short_name = "LRT 1",
        N = "NO-ISN",
        S = "HAI",
    },
    ["NO2"] = {
        line = "NO2",
        code = "NO-LRT2",
        name = "Nordstetten LRT: Line 2",
        textline_name = "Nordstetten LRT 2",
        short_name = "LRT 2",
        N = "NO-ISN",
        S = "NO-WS",
    },

    ["E1"] = {
        rc = "L-E1",
        name = "1F616EMO Express 1",
        E = "NO-T",
        W = "SAG",

        adjacent_stations = construct_adjacent_stations({
            -- station, track, reverse point
            {"NO-T", "3", true}, -- 103 in y5nw's system
            {"eYTP", "1"},
            {"eSVE", "1"},
            {"SAG", "4", true},
            {"eSVE", "2"},
            {"eYTP", "2"},
        }),
    },
    ["LUC"] = {
        rc = "L-LUC",
        code = "E2",
        name = "1F616EMO Express 2",
        N = "eGRH",
        S = "HR-NEN",

        adjacent_stations = construct_adjacent_stations({
            -- station, track, reverse point
            {"eGRH", "3", true},
            {"eSPH", "1"},
            {"eYTP", "5"},
            {"HR-LUC", "1"},
            {"HR-NEN", "1", true},
            {"HR-LUC", "6"},
            {"eYTP", "6"},
            {"eSPH", "2"},
        }),
    },
    ["E3"] = {
        rc = "L-E3",
        name = "1F616EMO Express 3",
        E = "eOAI",
        W = "HR-NEN",
    },

    ["eNO-SV"] = {
        rc = "L-eNO-SV",
        name = "Nordstetten-SmushyVille High-Speed",
        textline_name = "NO-SV High-Speed",
        shortname = "NO-SV HSR",
        E = "NO-T",
        W = "SAG",
    },

    ["RXB"] = {
        rc = "L-RXB",
        name = "RelaxingBasin Shuttle",
        short_name = "RelaxingBasin",
        N = "eYTP",
        S = "RXB",
    },

    ["VFT"] = {
        rc = "L-VFT",
        name = "Fenced Town Shuttle",
        short_name = "Fenced Town",
        N = "eGRH",
        S = "VFT",

        adjacent_stations = construct_adjacent_stations({
            -- station, track, reverse point
            {"eGRH", "4", true},
            {"eSPH", "1"}, -- physically reversed but logically didn't
            {"VFT", "2", true},
            {"eSPH", "2"}, -- physically reversed but logically didn't
        }),
    },

    -- Display only
    ["SPN"] = {
        -- was: Spawn Metro: Spawn Line
        code = "SPN",
        name = "Origin Metro: Origin Line",
        textline_name = "Origin Line",
        short_name = "Origin",
    },

    -- Deprecated / unused
    ["S1-SPN"] = {
        -- RC L-S1-SPN
        -- was: S1 (towards Spawn Island)
        rc = "L-S1-SPN",
        code = "SPN",
        name = "Spawn Metro: Spawn Line",
        textline_name = "Spawn Line",
        short_name = "Spawn",
        N = "MOF",
        S = "NLU",
    },

    -- Ferry
    ["FR-SPN-CHF"] = {
        rc = "L-FR-SPN-CHF",
        name = "1F616EMO Ferry: Origin-Chizuru's Farm",
        textline_name = "Origin-Chizuru's Farm",
        custom_dir_abbr = "~",
        custom_term_desc = "Ferry Loop",
        custom_term_desc_textline = "Loop",
        custom_term_desc_short = "Loop",
    },
}
