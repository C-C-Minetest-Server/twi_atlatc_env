--[[
Symbol convention:
!!: Warnings
>>: Information
]]

F.yellow_line_warning = {
    "!!  TRAINS ARE DEADLY   !!",
    "!! STAY IN YELLOW LINE  !!"
}

F.approach_warning = {
    "!!  TRAIN APPROACHING   !!",
    "!! STAY IN YELLOW LINE  !!"
}

F.WFC_mourning = {
    ">> WE MOURN THE LOSS OF <<",
    ">> WANG FUK COURT FIRE  <<"
}

F.pis_advertisements = {
    -- Exactly 26 bytes lone, and two lines

    --[[ TEMPOARAY ADS GOES HERE ]]--

    -- TEMPORARY: Honor to Ho Wai-Ho
    -- Fireman passed away in Tai Po Fire
    -- Full-honor funeral: 2025-12-19
    -- Scheduled removal: 2025-12-21
    {
        ">>  FULL HONOR TO LATE  <<",
        ">>  FIREMAN  HO WAI-HO  <<"
    },

    -- TEMPORARY: Gathering idea for annual WFC fire mourning
    -- Scheduled removal: 2026-01-01
    {
        ">> IDEAS ON WFC ANNUAL <<",
        ">> MOURNING: /feedback <<"
    },

    --[[ RAILWAY SERVICE NOTICES ]]--

    -- Stay behind yellow line
    F.yellow_line_warning,

    --[[ OFFICIAL ADS ]]--

    -- Should be copied to occupy 1/3 of the ads in annual mourning
    F.WFC_mourning,

    -- Join Discord server
    {
        ">>   JOIN OUR DISCORD   <<",
        ">>    bit.ly/3XWaKCO    <<"
    },

    -- Give suggestions via /report
    {
        ">>  HAVE SUGGESTIONS?   <<",
        ">>   USE /report CMD    <<"
    },

    -- Use newcomers plots within 14 days
    {
        ">>  USE NEWCOMERS PLOTS <<",
        ">>    WITHIN 14 DAYS    <<"
    },

    -- /day
    {
        ">>   HATE NIGHTTIME?    <<",
        ">>     USE /day CMD     <<"
    },
}
