--[[
Symbol convention:
!!: Warnings
>>: Information
]]

F.yellow_line_warning = {
    "!!  TRAINS ARE DEADLY   !!",
    "!! STAY IN YELLOW LINE  !!"
}

F.WFC_mourning = {
    ">> WE MOURN THE LOSS OF <<",
    ">> WANG FUK COURT FIRE  <<"
}

F.pis_advertisements = {
    -- Exactly 26 bytes lone, and two lines

    -- Stay behind yellow line
    F.yellow_line_warning,

    -- Should br copied to occupy 1/3 of the ads in annual mourning
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
}
