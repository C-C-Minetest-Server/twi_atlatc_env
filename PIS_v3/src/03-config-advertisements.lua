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

    -- Deprecation of MultiCraft
    -- Expire: After deprecation of MC clients
    {
        "!!  MULTICRAFT CLIENTS  !!",
        "!!  DEPRECATED IN MAY   !!",
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

    -- WFC fire mourning 2
    {
        ">> WANG FUK COURT FIRE  <<",
        ">> IS MAN-MADE DISASTER <<",
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

F.marquee_advertisements = {
    --[[ TEMPOARAY ADS GOES HERE ]] --

    -- Deprecation of MultiCraft
    -- Expire: After deprecation of MC clients
    {
        "MultiCraft clients will not be able to connect in May.",
    },

    --[[ RAILWAY SERVICE NOTICES ]] --

    {
        "Running trains are deadly. Stand behind the yellow lines.",
    },

    -- WFC fire mourning
    {
        "We mourn the loss in the Wang Fuk Court fire."
    },

    {
        "Join our Discord server: discord.gg/bFhZuwQxDX",
    },

    {
        "Any suggestions? Run /report",
    },

    {
        "You should use newcomers plots within 14 days after buying it.",
    },

    {
        "Hate nighttime? Use /day command to make it day.",
    },

    {
        "Want your ads here? /mail 1F616EMO",
    },
}
