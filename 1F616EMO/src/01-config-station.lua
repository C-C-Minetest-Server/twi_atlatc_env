assert(is_loading)

-- Dictionary of arrays/string
-- arrays: list of names, from long to short
-- system will pick the best suiting name for the context
-- string: if there are no alternatives, same as { string }
F.station_names = {
    -- Origin Metro
    FRI = {
        "Furina Island",
        "Furina Isl.",
    },
    SPN = {
        "Origin Island",
        "Origin Isl.",
        "Origin",
    },
    HLY = {
        "Lianyi Road",
        "Lianyi Rd.",
    },
    SCL = "Scorchland",
    ISN = {
        "Origin North",
        "Origin N.",
    },
    SPS = {
        "Origin South",
        "Origin S.",
    },
    ALF = {
        "Alcantaramark's Factory",
        "Alcantaramark's",
    },
    RXF = {
        "RelaxingFarm",
        "RelaxFarm",
        "Rx Farm",
    },
    HAI = "Have Idea",
    NLU = {
        "North Luciopoli",
        "Luciopoli N.",
    },
    YTP = {
        "Yantian Road",
        "Yantian Rd.",
    },
    MOF = {
        "Mountain Foot",
        "Mt. Foot",
    },
    OVV = {
        "Oval Valley",
        "Oval Vly.",
    },

    -- Acacia Plains Metro
    ACP = {
        "Acacia Plains",
        "Acacia Plns.",
    },
    OLV = "Oliville",
    OAI = "Oasis",

    -- SmushyVille Metro
    SVE = {
        "dloke's Hill",
        "dloke's",
    },
    SDS = {
        "South Downtown",
        "S. Downtown",
    },
    SHV = "ShroomVille",
    SAG = {
        "Sandy Grove",
        "Sandy Grv.",
    },
    SAE = {
        "Sandy Edge",
        "Sandy Edg.",
    },

    -- Grape Hills Metro
    GRH = {
        "Grape Hills",
        "Grape Hls.",
    },
    SHI = "Shino",
    SCC = {
        "Scattered Cliff",
        "Scat. Cliff",
    },
    GRO = "Groma",
    KIH = "Kitkahood",
    DUI = {
        "Duck Island",
        "Duck Isl.",
    },
    VFT = {
        "Fenced Town",
        "Fenced Twn.",
    },
    SNL = {
        "Snake Lakes",
        "Snake Lks.",
    },
    CCB = {
        "Coco Beach",
        "Coco Bch.",
    },
    CED = {
        "Centric Desert",
        "Centric Dst.",
    },
    PIA = "Piaskowiec",


    -- Intercity stations
    eYTP = {
        "Yantian Road",
        "Yantian Rd.",
    },
    eSVE = {
        "Eastern SmushyVille",
        "SmushyVille E.",
    },
    eOAI = {
        "Oasis Main",
        "Oasis",
    },
    eGRH = {
        "Grape Hills",
        "Grape Hls.",
    },
    eGRO = "Groma",
    eSPH = "Spagetihood",
    eOTH = "Otterhood",
    MOT = {
        "Mount Turkey",
        "Mt. Turkey",
    },
    BAJ = {
        "Basandra Junction",
        "Basandra Jct.",
    },
    WOM = "Woodman",
    RXB = {
        "RelaxingBasin",
        "RelaxBasin",
        "Rx Basin",
    },
    APL = {
        "Apple Lake",
        "Apple Lk.",
    },
    eLIB = "Libreland",
    eEAN = "Eagle Nest",


    -- Nordstetten
    ["NO-NE"] = {
        "Eulerstraße",
        "Eulerstr.",
    },
    ["NO-IN"] = {
        "Industriestraße",
        "Industriestr.",
    },
    ["NO-WS"] = {
        "Wörther Straße",
        "Wörther Str.",
    },
    ["NO-WO"] = {
        "Offenburger Straße",
        "Offenburger Str.",
    },
    ["NO-ISL"] = "Apfelbühl",
    ["NO-T"] = {
        "Nordstetten Hauptbahnof",
        "Nordstetten Hbf.",
        "Nordstetten",
    },
    ["NO-HA"] = "Hagenauer Platz",


    -- HelenasaurusRex
    ["HR-LUC"] = {
        "Luciopoli Central",
        "Luciopoli Ctl.",
        "Luciopoli",
    },
    ["HR-CIG"] = {
        "Citrus Grove",
        "Citrus Grv.",
    },
    ["HR-eCIG"] = {
        "Citrus Grove",
        "Citrus Grv.",
    },
    ["HR-SLU"] = {
        "South Luciopoli",
        "Luciopoli S.",
    },
    ["HR-NEN"] = {
        "New Normandy Central",
        "New Normandy Ctl.",
        "New Normandy",
    },


    -- Vedu_0825
    ["VD-VFT"] = {
        "Train Station",
        "Train Stn.",
    },
    ["VD-CLI"] = "Cliff",
    ["VD-DIC"] = {
        "Digtron Complex",
        "Digtron Cmplx.",
    },
    ["VD-CAF"] = {
        "Cactus Farm",
        "Cactus Frm.",
    },


    -- Maverick2797
    ["M27-QUO"] = "Quoralla",
    ["M27-CFB"] = "Cliffy Beach",
    ["M27-SOL"] = "Solandar",


    -- 1F616EMO Ferry
    ["FR-SPN"] = "Origin",
    ["FR-RXF"] = {
        "RelaxingFarm",
        "RelaxFarm",
        "Rx Farm",
    },
    ["FR-CHF"] = {
        "Chizuru's Farm",
        "Chizuru's Frm.",
    },


    -- Emergency Stations / Platforms
    ["EMER-SHV"] = {
        "ShroomVille (Backup Platform)",
        "ShroomVille (Backup)",
        "ShroomVille",
    },


    -- Special
    ["XX-UNK"] = {
        "Unknown Station",
        "Unknown Stn.",
        "Unknown",
        "???",
    }
}

F.pseudo_station_names = {
    ["CW"] = {
        "Clockwise Loop",
        "Clockwise",
        "Clockw.",
        "Clockw",
    },
    ["ACW"] = {
        "Anti-Clockwise Loop",
        "Anti-Clockwise",
        "Anti-Clockw.",
        "Anticlockw.",
        "Anticlockw",
    },

    ["FR-LOOP"] = {
        "Ferry Loop",
        "Loop",
    },
}

F.station_interchange = {
    SPN = { "SPN", "U1", },
    ISN = { "S1", "U1", },
    FRI = { "U1", "RXIC", },
    SPS = { "S1", "SPN", },
    HAI = { "S1", "NO1", "RXIC", },
    ALF = { "SPN", "ALFC", },
    YTP = { "SPN", "SPN-S1", "SVL", "OEX", },
    ACP = { "CEN", "OAI", },
    OVV = { "S1", "SPN-S1", },
    VFT = { "GRH1", "VD-VFT1" },
    GRH = { "GRH1", "GRH2",  },
    SHI = { "GRH1", "GRH2" },
    GRO = { "GRH2", "S21", "NX", "OEX", },
    OAI = { "OAI", "SPN-S1", },
    SVE = { "CSL", "SVL", "RXB-SVE", },
    SAG = { "CSL", "SVL", },
    eOTH = { "GRH1", "SVL", },
    BAJ = { "S21", "LIB-BAJ", "NX" },
    eEAN = { "S21", "NX" },

    ["NO-WS"] = { "NO1", "NO2", "SPN-S1", },

    ["HR-CIG"] = { "HR-LUC-LRT1", "SPN-S1" },
}
F.station_interchange.eYTP = F.station_interchange.YTP
F.station_interchange.eSVE = F.station_interchange.SVE
F.station_interchange.eGRH = F.station_interchange.GRH
F.station_interchange.eGRO = F.station_interchange.GRO
F.station_interchange.eOAI = F.station_interchange.OAI
F.station_interchange["HR-eCIG"] = F.station_interchange["HR-CIG"]
F.station_interchange["NO-T"] = F.station_interchange["NO-WS"]
F.station_interchange["VD-VFT"] = F.station_interchange.VFT

F.interchange_line_alias = {
    ["SPN-CW"] = "SPN",
    ["SPN-ACW"] = "SPN",
    ["GRH1E"] = "GRH1",
    ["VF-VFT1-CW"] = "VF-VFT1",
    ["SVL-CW"] = "SVL",
    ["SVL-ACW"] = "SVL",
}

F.complementary_station = {
    ["HR-eCIG"] = {
        { "HR-LUC", "HR-LUC-LRT1" },
    },
    ["HR-LUC"] = {
        { "HR-eCIG", "HR-LUC-LRT1" },
    },

    ["eGRH"] = {
        { "eGRO", "GRH2" },
    },
    ["eGRO"] = {
        { "eGRH", "GRH2" },
    },
}