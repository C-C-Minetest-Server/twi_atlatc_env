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
