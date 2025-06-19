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
        custom_dir_abbr = "CW",
        custom_term_desc = "Clockwise Loop",
        custom_term_desc_textline = "Clockwise Loop",
        custom_term_desc_short = "Clockwise",
    },
    ["SPN-ACW"] = {
        -- Spawn Line (Anti clockwise)
        -- was: Spawn Metro: Spawn Line
        rc = "L-SPN-ACW",
        code = "SPN",
        name = "Origin Metro: Origin Loop",
        textline_name = "Origin Line",
        short_name = "Origin",
        custom_dir_abbr = "ACW",
        custom_term_desc = "Anti-clockwise Loop",
        custom_term_desc_textline = "Anti-clockwise Loop",
        custom_term_desc_short = "Anti-clockw.",
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
    },
    ["LUC"] = {
        rc = "L-LUC",
        code = "E2",
        name = "1F616EMO Express 2",
        N = "eGRH",
        S = "HR-NEN",
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
        name = " Fenced Town Shuttle",
        short_name = "Fenced Town",
        N = "eGRH",
        S = "VFT",
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
