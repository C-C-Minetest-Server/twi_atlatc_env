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

    -- TEMPORARY: Gathering idea for annual WFC fire mourning
    -- Scheduled removal: 2026-01-01
    {
        ">> IDEAS ON WFC ANNUAL <<",
        ">> MOURNING: /feedback <<"
    },

    -- TEMPORARY: Mourn those died in Taiwan knife attack
    -- Scheduled removal: 2025-12-27
    {
        ">> MOURN THOSE DIED IN <<",
        ">> TAIWAN KNIFE ATTACK <<"
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

    -- Want your ad here?
    {
        ">> WANT YOUR ADS HERE?  <<",
        ">>    /mail 1F616EMO    <<"
    },
}
