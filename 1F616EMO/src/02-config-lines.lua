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

F.lines = {}

-- Origin Metro

F.lines["U1"] = {
    -- RC L-U1
    -- was: Spawn Subway Line 1
    -- was: Spawn Metro: Islands Line
    rc = "L-U1",
    code = "ISL",
    name = "Origin Metro: Islands Line",
    textline_name = "Islands Line",
    short_name = "Islands",
    W = "SPN",
    E = "ACP",
    through_E = "CEN",

    -- Shared with CEN
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point, line_id if different
        { "SPN", "3", true,  "U1" },
        { "ISN", "1", false, "U1" },
        { "FRI", "1", false, "U1" },
        { "SCL", "1", false, "U1" },
        { "ACP", "1", true,  "CEN" },
        { "SCL", "2", false, "U1" },
        { "FRI", "2", false, "U1" },
        { "ISN", "2", false, "U1" },
    }),
}

F.lines["S1"] = {
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
}

F.lines["SPN-CW"] = {
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

    departure_time_adjustment = 2,

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "SPN", "1" },
        { "SPS", "1" },
        { "ALF", "1" },
        { "NLU", "1" },
        { "MOF", "1" },
        { "YTP", "1" },
        { "HLY", "1" },
    }),
}

F.lines["SPN-ACW"] = {
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

    departure_time_adjustment = 2,

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "SPN", "2" },
        { "HLY", "2" },
        { "YTP", "2" },
        { "MOF", "2" },
        { "NLU", "2" },
        { "ALF", "2" },
        { "SPS", "2" },
    }),
}

-- SmushyVille Metro

F.lines["CSL"] = {
    rc = "L-CSL",
    name = "SmushyVille Metro: Castle Line",
    textline_name = "Castle Line",
    short_name = "Castle",
    E = "SVE",
    W = "SAE",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "SVE", "1", true },
        { "SDS", "1" },
        { "SHV", "1" },
        { "SAG", "1" },
        { "SAE", "1", true },
        { "SAG", "2" },
        { "SHV", "2" },
        { "SDS", "4" },
    }),
}

F.lines["CEN"] = {
    rc = "L-U1",
    name = "Acacia Plains Railway: Central Line",
    textline_name = "Central Line",
    short_name = "Central",
    through_W = "U1",
    E = F.lines["U1"].E,
    W = F.lines["U1"].W,

    adjacent_stations = F.lines["U1"].adjacent_stations,
}

F.lines["OAI"] = {
    rc = "L-OAI",
    name = "Acacia Plains Railway: Oasis Line",
    textline_name = "Oasis Line",
    short_name = "Oasis",
    N = "ACP",
    S = "OAI",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "ACP", "2", true },
        { "OLV", "1" },
        { "OAI", "2", true },
        { "OLV", "2" },
    }),
}

-- Grape Hills Metro

F.lines["GRH1"] = {
    rc = "L-GRH1",
    name = "Grape Hills Line 1",
    textline_name = "Grape Hills 1",
    short_name = "GRH1",

    N = "SNL",
    S = "VFT",

    background_color = "#5555FF",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "SNL", "2", true },
        { "SHI", "4" },
        { "GRH", "4" },
        { "CCB", "1" },
        { "CED", "1" },
        { "PIA", "1" },
        { "VFT", "1", true },
        { "PIA", "2" },
        { "CED", "2" },
        { "CCB", "4" },
        { "GRH", "1" },
        { "SHI", "1" },
    }),
}

F.lines["GRH1E"] = {
    rc = "L-GRH1E",
    code = "GRH1",
    name = "Grape Hills Line 1",
    textline_name = "Grape Hills 1",
    short_name = "GRH1",

    N = "SNL",
    S = "eOTH",

    background_color = "#5555FF",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "SNL",  "2", true },
        { "SHI",  "4" },
        { "GRH",  "4" },
        { "CCB",  "1" },
        { "CED",  "1" },
        { "PIA",  "1" },
        { "VFT",  "1" },
        { "eOTH", "3", true },
        { "VFT",  "2" },
        { "PIA",  "2" },
        { "CED",  "2" },
        { "CCB",  "4" },
        { "GRH",  "1" },
        { "SHI",  "1" },
    }),
}

F.lines["GRH1"].adjacent_stations["VFT:2"] = F.lines["GRH1"].adjacent_stations["VFT:1"]
F.lines["GRH1"].adjacent_stations["eOTH:3"] = {}
F.lines["GRH1"].adjacent_stations["eOTH:3"][#F.lines["GRH1"].adjacent_stations["eOTH:3"] + 1] = { "VFT", "2" }
for _, entry in ipairs(F.lines["GRH1"].adjacent_stations["VFT:1"]) do
    F.lines["GRH1"].adjacent_stations["eOTH:3"][#F.lines["GRH1"].adjacent_stations["eOTH:3"] + 1] = entry
end

F.lines["GRH1E-R-VFT"] = {
    rc = "L-GRH1E-R-VFT",
    code = "GRH1",
    name = "Grape Hills Line 1",
    textline_name = "Grape Hills 1",
    short_name = "GRH1",

    N = "SNL",
    S = "eOTH",

    background_color = "#5555FF",

    adjacent_stations ={
        ["VFT:1"] = F.lines["GRH1E"].adjacent_stations["VFT:2"],
    },
}

F.lines["GRH2"] = {
    rc = "L-GRH2",
    name = "Grape Hills Line 2",
    textline_name = "Grape Hills 2",
    short_name = "GRH2",

    W = "DUI",
    E = "KIH",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "DUI", "1", true },
        { "GRO", "2" },
        { "SCC", "2" },
        { "GRH", "3" },
        { "SHI", "2" },
        { "KIH", "2", true },
        { "SHI", "3" },
        { "GRH", "2" },
        { "SCC", "1" },
        { "GRO", "1" },
    }),
}

F.lines["GRH3"] = {
    rc = "L-GRH3",
    name = "Grape Hills Line 3",
    textline_name = "Grape Hills 3",
    short_name = "GRH3",
}

F.lines["GRH4"] = {
    rc = "L-GRH4",
    name = "Grape Hills Line 4GRH4",
    textline_name = "Grape Hills 4GRH4",
    short_name = "GRH4",
}

-- Nordstetten Trams (Display only)

F.lines["NO1"] = {
    line = "NO1",
    code = "NO-LRT1",
    name = "Nordstetten LRT: Line 1",
    textline_name = "Nordstetten LRT 1",
    short_name = "LRT 1",
    N = "NO-ISN",
    S = "HAI",
}

F.lines["NO2"] = {
    line = "NO2",
    code = "NO-LRT2",
    name = "Nordstetten LRT: Line 2",
    textline_name = "Nordstetten LRT 2",
    short_name = "LRT 2",
    N = "NO-ISN",
    S = "NO-WS",
}

-- Express

F.lines["NX"] = {
    rc = "L-NX",
    name = "Newcomers Express",
    short_name = "Newcomers",
    W = "BAJ",
    E = "eGRO",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eGRO", "8", true },
        { "BAJ",  "2A", true },
    }),
}

F.lines["OEX"] = {
    rc = "L-OEX",
    name = "Origin Express",
    short_name = "Origin",
    W = "eGRO",
    E = "HR-NEN",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eGRO", "3", true },
        { "eYTP", "3" },
        { "HR-NEN", "2", true },
        { "eYTP", "4" },
    }),
}

-- Intercity / S-Bahn

F.lines["SPN-S1"] = {
    rc = "L-SPN-S1",
    code = "S1",
    name = "Origin S-Bahn Line 1",
    N = "NO-T",
    S = "eOAI",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "NO-T", "3", true }, -- 103 in y5nw's system
        { "eYTP", "5" },
        { "HR-eCIG", "2" },
        { "OVV", "4" },
        { "eOAI", "4", true },
        { "OVV", "1" },
        { "HR-eCIG", "1" },
        { "eYTP", "6" },
    }),
}

F.lines["SVL-CW"] = {
    rc = "L-SVL-CW",
    code = "SVL",
    name = "SmushyVille Loop",
    textline_name = "SmushyVille Loop",
    short_name = "SmushyVille",
    default_dir = "CW",
    custom_dir_abbr = "CW",
    custom_term_desc = "Clockwise Loop",
    custom_term_desc_textline = "Clockwise Loop",
    custom_term_desc_short = "Clockwise",

    departure_time_adjustment = 10,

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eYTP", "1" },
        { "eSVE", "1" },
        { "SAG", "4" },
        { "eOTH", "1" },
        { "eSPH", "1" },
        -- { "ABM", "1" },
    }),
}

F.lines["SVL-ACW"] = {
    rc = "L-SVL-ACW",
    code = "SVL",
    name = "SmushyVille Loop",
    textline_name = "SmushyVille Loop",
    short_name = "SmushyVille",
    default_dir = "ACW",
    custom_dir_abbr = "ACW",
    custom_term_desc = "Anti-clockwise Loop",
    custom_term_desc_textline = "Anti-clockwise Loop",
    custom_term_desc_short = "Anti-clockw.",

    departure_time_adjustment = 10,

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eYTP", "2" },
        -- { "ABM", "2" },
        { "eSPH", "2" },
        { "eOTH", "2" },
        { "SAG", "6" },
        { "eSVE", "2" },
    }),
}

F.lines["S21"] = {
    rc = "L-S21",
    code = "S21",
    name = "S-Bahn Line 21",
    W = "APL",
    E = "eGRO",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eGRO", "8", true },
        { "MOT", "2" },
        { "BAJ", "2B" },
        { "APL", "2", true },
        { "BAJ", "1B" },
        { "MOT", "1" },
    }),
}

-- Technically on subway trains but belongs to national railway
F.lines["RXB-SVE"] = {
    rc = "L-RXB-SVE",
    code = "RXB",
    name = "RelaxingBasin Shuttle",
    short_name = "RelaxingBasin",
    N = "SVE",
    S = "RXB",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "SVE", "2", true },
        { "RXB",  "1", true },
    }),
}

-- HelenasaurusRex's Polislink

F.lines["HR-LUC-LRT1"] = {
    rc = "L-HR-LUC-LRT1",
    code = "LRT1",
    name = "Luciopoli Polislink: Line 1",
    textline_name = "Polislink Line 1",
    short_name = "Polislink 1",
    N = "HR-CIG",
    S = "HR-SLU",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "HR-CIG", "1", true },
        { "HR-LUC", "L2" },
        { "HR-SLU", "2", true },
        { "HR-LUC", "L1" },
    }),
}

-- Vedu_0825's services

F.lines["VD-VFT1-CW"] = {
    rc = "L-VD-VFT1-CW",
    code = "VFT1",
    name = "Fenced Town Subway",
    short_name = "Subway",
    default_dir = "CW",
    custom_dir_abbr = "CW",
    custom_term_desc = "Clockwise Loop",
    custom_term_desc_textline = "Clockwise Loop",
    custom_term_desc_short = "Clockwise",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "VD-VFT", "1" },
        { "VD-CLI", "1" },
        { "VD-DIC", "1" },
        { "VD-CAF", "1" },
    }),
}

-- Display only
F.lines["SPN"] = {
    -- was: Spawn Metro: Spawn Line
    code = "SPN",
    name = "Origin Metro: Origin Line",
    textline_name = "Origin Line",
    short_name = "Origin",

    adjacent_stations = merge_key_tables({
        F.lines["SPN-CW"].adjacent_stations,
        F.lines["SPN-ACW"].adjacent_stations,
    }),
}

F.lines["SVL"] = {
    code = "SVL",
    name = "SmushyVille Loop",
    textline_name = "SmushyVille Loop",
    short_name = "SmushyVille",

    adjacent_stations = merge_key_tables({
        F.lines["SVL-CW"].adjacent_stations,
        F.lines["SVL-ACW"].adjacent_stations,
    }),
}

-- Carts (Display only)

F.lines["ALFC"] = {
    code = "ALFC",
    name = "Alcantaramark's Carts",
}

F.lines["RXIC"] = {
    code = "RXIC",
    name = "RelaxingIsland Carts",
}

-- Manually routed trains

F.lines["---"] = {
    name = "Manually Routed Train",
    short_name = "Manual",
    textline_name = "Manual",
}

-- Deprecated / unused

F.lines["S1-SPN"] = {
    -- RC L-S1-SPN
    -- was: S1 (towards Spawn Island)
    rc = "L-S1-SPN",
    code = "SPN",
    name = "Spawn Metro: Spawn Line",
    textline_name = "Spawn Line",
    short_name = "Spawn",
    N = "MOF",
    S = "NLU",
}

F.lines["eCEN"] = {
    rc = "L-eCEN",
    name = "Spawn-Acacia Plains Central Express",
    textline_name = "Central Express",
    short_name = "SPN-ACP",
    W = "SPN",
    E = "ACP",
}

F.lines["eNO-SV"] = {
    rc = "L-eNO-SV",
    name = "Nordstetten-SmushyVille High-Speed",
    textline_name = "NO-SV High-Speed",
    shortname = "NO-SV HSR",
    E = "NO-T",
    W = "SAG",
}

F.lines["VFT2"] = {
    rc = "L-VFT2",
    code = "VFT",
    name = "Fenced Town Shuttle",
    short_name = "Fenced Town",
    N = "VFT",
    S = "eYTP",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eYTP", "4", true },
        { "VFT",  "2", true },
    }),
}

F.lines["E1"] = {
    rc = "L-E1",
    name = "1F616EMO Express 1",
    E = "NO-T",
    W = "SAG",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "NO-T", "3", true }, -- 103 in y5nw's system
        { "eYTP", "1" },
        { "eSVE", "1" },
        { "SAG",  "4", true },
        { "eSVE", "2" },
        { "eYTP", "2" },
    }),
}

F.lines["LUC"] = {
    rc = "L-LUC",
    code = "E2",
    name = "1F616EMO Express 2",
    N = "eGRH",
    S = "HR-NEN",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eGRH",   "3", true },
        { "eSPH",   "1" },
        { "eYTP",   "5" },
        { "HR-LUC", "1" },
        { "HR-NEN", "1", true },
        { "HR-LUC", "6" },
        { "eYTP",   "6" },
        { "eSPH",   "2" },
    }),
}

F.lines["E4"] = {
    rc = "L-E4",
    name = "1F616EMO Express 4",
    E = "eOAI",
    W = "eGRO",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eGRO", "3", true },
        { "eOTH", "2" },
        { "SAG",  "5" },
        { "NLU", "3" },
        { "HR-eCIG", "2" },
        { "OVV", "4" },
        { "eOAI", "4", true },
        { "OVV", "1" },
        { "HR-eCIG", "1" },
        { "NLU", "4" },
        { "SAG",  "3" },
        { "eOTH", "1" },
    }),
}

F.lines["E3"] = {
    rc = "L-E3",
    name = "1F616EMO Express 3",
    E = "eOAI",
    W = "HR-NEN",
}

F.lines["VD-VFT1"] = {
    code = "VFT1",
    name = "Fenced Town Subway",
    short_name = "Subway",
}

F.lines["VFT"] = {
    rc = "L-VFT",
    name = "Fenced Town Shuttle",
    short_name = "Fenced Town",
    N = "eGRH",
    S = "VFT",

    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eGRH", "4", true },
        { "eSPH", "1" }, -- physically reversed but logically didn't
        { "VFT",  "2", true },
        { "eSPH", "2" }, -- physically reversed but logically didn't
    }),
}

F.lines["RXB"] = {
    rc = "L-RXB",
    name = "RelaxingBasin Shuttle",
    short_name = "RelaxingBasin",
    N = "eYTP",
    S = "RXB",

    show_complementary_station = true,
    adjacent_stations = construct_adjacent_stations({
        -- station, track, reverse point
        { "eYTP", "3", true },
        { "RXB",  "1", true },
    }),
}

-- Ferry
F.lines["FR-SPN-CHF"] = {
    rc = "L-FR-SPN-CHF",
    name = "1F616EMO Ferry: Origin-Chizuru's Farm",
    textline_name = "Origin-Chizuru's Farm",
    custom_dir_abbr = "~",
    custom_term_desc = "Ferry Loop",
    custom_term_desc_textline = "Loop",
    custom_term_desc_short = "Loop",
}
