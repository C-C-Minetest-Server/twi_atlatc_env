F.stations = {
    -- 1F616EMO Railway
    FRI = "Furina Island",
    SPN = "Origin Island",
    HLY = "Lianyi Road",
    SCL = "Scorchland",
    ISN = "Origin North",
    SPS = "Origin South",
    ALF = "Alcantaramark's Factory",
    RXF = "RelaxingFarm",
    HAI = "Have Idea",
    NLU = "North Luciopoli",
    YTP = "Yantian Road",
    eYTP = "Yantian Road",
    SVE = "dloke's Hill",
    eSVE = "Eastern SmushyVille",
    SDS = "South Downtown",
    RXB = "RelaxingBasin",
    SHV = "ShroomVille",
    SAG = "Sandy Grove",
    SAE = "Sandy Edge",
    ACP = "Acacia Plains",
    OLV = "Oliville",
    OAI = "Oasis",
    eOAI = "Oasis Main",
    MOF = "Mountain Foot",
    WOM = "Woodman",
    OVV = "Oval Valley",
    GRH = "Grape Hills",
    eGRH = "Grape Hills",
    SHI = "Shino",
    SCC = "Scattered Cliff",
    GRO = "Grand Groma",
    eGRO = "Groma",
    KIH = "Kitkahood",
    DUI = "Duck Island",
    eSPH = "Spagetihood",
    VFT = "Fenced Town",
    SNL = "Snake Lakes",
    CCB = "Coco Beach",
    CED = "Centric Desert",
    PIA = "Piaskowiec",
    eOTH = "Otterhood",
    MOT = "Mount Turkey",
    BAJ = "Basandra Junction",

    -- Emergency Stations / Platforms
    ["EMER-SHV"] = "ShroomVille (Backup Platform)",

    -- Nordstetten
    ["NO-NE"] = "Eulerstraße",
    ["NO-IN"] = "Industriestraße",
    ["NO-WS"] = "Wörther Straße",
    ["NO-WO"] = "Offenburger Straße",
    ["NO-ISL"] = "Apfelbühl",
    ["NO-T"] = "Nordstetten Hauptbahnof",
    ["NO-HA"] = "Hagenauer Platz",

    -- HelenasaurusRex
    ["HR-LUC"] = "Luciopoli Central",
    ["HR-CIG"] = "Citrus Grove",
    ["HR-eCIG"] = "Citrus Grove",
    ["HR-SLU"] = "South Luciopoli",
    ["HR-NEN"] = "New Normandy Central",

    -- Vedu_0825
    ["VD-VFT"] = "Train Station",
    ["VD-CLI"] = "Cliff",
    ["VD-DIC"] = "Digtron Complex",
    ["VD-CAF"] = "Cactus Farm",

    -- 1F616EMO Ferry
    ["FR-SPN"] = "Origin",
    ["FR-RXF"] = "RelaxingFarm",
    ["FR-CHF"] = "Chizuru's Farm",
}

F.stations_short = {
    HLY = "Lianyi Rd.",
    ISN = "Spawn N.",
    SPS = "Spawn S.",
    ALF = "Alcantaramark's",
    NLU = "N. Luciopoli",
    YTP = "Yantian Rd.",
    SCC = "Sca. Cliff",
    RXB = "RelaxBasin",
    BAJ = "Basandra Jct.",

    eYTP = "Yantian Rd.",
    eSVE = "E. SmushyVille",

    ["EMER-SHV"] = "ShroomVille",

    ["NO-NE"] = "Eulerstr.",
    ["NO-IN"] = "Industriestr.",
    ["NO-WS"] = "Wörther Str.",
    ["NO-WO"] = "Offenburger Str.",
    ["NO-T"] = "Nordstetten Hbf.",

    ["HR-LUC"] = "Luciopoli",
    ["HR-NEN"] = "N. Normandy",
}

-- Usually the name of the city
F.station_express = {
    -- eYTP = "Spawn",
    eSVE = "SmushyVille E.",
    eOAI = "Oasis",
    eGRH = "Grape Hills",

    ["NO-T"] = "Nordstetten",

    ["HR-LUC"] = "Luciopoli",
    ["HR-NEN"] = "New Normandy",
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
    GRO = { "GRH2", "NX", "OEX", },
    OAI = { "OAI", "SPN-S1", },
    SVE = { "CSL", "SVL", },
    SAG = { "CSL", "SVL", },
    eOTH = { "GRH1", "SVL", },

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

F.interchange_line_alias = {
    ["SPN-CW"] = "SPN",
    ["SPN-ACW"] = "SPN",
    ["GRH1E"] = "GRH1",
    ["VD-VFT1-CW"] = "VF-VFT1",
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