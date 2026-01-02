assert(is_loading)

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

F.pis_advertisements = {
    -- Exactly 26 bytes lone, and two lines

    --[[ TEMPOARAY ADS GOES HERE ]] --

    -- TEMPORARY: Gathering idea for annual WFC fire mourning
    -- Scheduled removal: 2026-01-01
    {
        ">> IDEAS ON WFC ANNUAL  <<",
        ">> MOURNING: /feedback  <<"
    },

    -- TEMPORARY: Marry christmas and new year greetings
    -- Scheduled removal: 2025-01-08
    {
        ">> MERRY CHRISTMAS  AND <<",
        ">>   A HAPPY NEW YEAR   <<"
    },

    --[[ RAILWAY SERVICE NOTICES ]] --

    -- Stay behind yellow line
    F.yellow_line_warning,

    --[[ OFFICIAL ADS ]] --

    -- WFC fire mourning
    -- Kept forever
    -- TODO: Proper weighting system to use during annual mourning
    {
        ">> WE MOURN THE LOSS OF <<",
        ">> WANG FUK COURT FIRE  <<"
    },

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
