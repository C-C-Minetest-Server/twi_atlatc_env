-- namespace for system-related codes
F.system = {}

-- Best neighbour to travel to if you want to reach a destination
-- curr_system -> (destination -> neighbor system)
F.system.best_neighbour = {
    -- Eastern Spawn System
    -- Covers: Have Idea to North Luciopoli upper tracks
    SPN_E = {
        SPN_I = "YTP",
        YTP = "YTP",
        NO = "YTP",
        SV_S = "YTP",
        SV_C = "YTP",
        RXB = "YTP",
        ACP_C = "YTP",
        ACP_O = "YTP",
        ACP_S = "YTP",
        ELK_NN = "YTP",
    },

    -- Spawn Islands System
    -- Covers: Yantian Rd. subway tracks to Scorchland
    SPN_I = {
        SPN_E = "YTP",
        YTP = "YTP",
        NO = "YTP",
        SV_S = "YTP",
        SV_C = "YTP",
        RXB = "YTP",
        ACP_C = "ACP_C",
        ACP_O = "ACP_C",
        ACP_S = "ACP_C",
        ELK_NN = "YTP",
    },

    -- Yantian Road-Luciopoli System
    -- Covers: Yantian Rd. Express tracks to North Luciopoli lower tracks
    -- Future extension: Luciopoli Main, Northern diverging point
    YTP = {
        SPN_E = "SPN_E",
        SPN_I = "SPN_I",
        NO = "SPN_E",
        SV_S = "SV_S",
        SV_C = "SV_S",
        RXB = "SV_S",
        ACP_C = "ACP_S",
        ACP_O = "ACP_S",
        ACP_S = "ACP_S",
        ELK_NN = "ELK_NN",
    },

    -- Nordstetten System
    -- Covers: All tracks within Nordstetten
    -- Future extension: West of Apfelbühl til diverging point
    NO = {
        SPN_E = "SPN_E",
        SPN_I = "SPN_E",
        YTP = "SPN_E",
        SV_S = "SPN_E",
        SV_C = "SPN_E",
        RXB = "YTP",
        ACP_C = "YTP",
        ACP_O = "YTP",
        ACP_S = "YTP",
        ELK_NN = "YTP",
    },

    -- Southern SmushyVille System
    -- Covers: Eastern SmushyVille Express tracks
    -- Future extension: All express tracks south of SV
    SV_S = {
        SPN_E = "YTP",
        SPN_I = "YTP",
        YTP = "YTP",
        NO = "YTP",
        SV_C = "SV_C",
        RXB = "RXB",
        ACP_C = "YTP",
        ACP_O = "YTP",
        ACP_S = "YTP",
        ELK_NN = "YTP",
    },

    -- Central SmushyVille System
    -- Covers: Downtown Line, ShroomVille Line
    SV_C = {
        SPN_E = "SV_S",
        SPN_I = "SV_S",
        YTP = "SV_S",
        NO = "SV_S",
        SV_S = "SV_S",
        RXB = "SV_S",
        ACP_C = "SV_S",
        ACP_O = "SV_S",
        ACP_S = "SV_S",
        ELK_NN = "SV_S",
    },

    -- RelaxingBasin Branch Line
    RXB = {
        SPN_E = "SV_S",
        SPN_I = "SV_S",
        YTP = "SV_S",
        NO = "SV_S",
        SV_C = "SV_S",
        SV_S = "SV_S",
        ACP_C = "SV_S",
        ACP_O = "SV_S",
        ACP_S = "SV_S",
        ELK_NN = "SV_S",
    },

    -- Acacia Plains Central Line
    ACP_C = {
        SPN_E = "ACP_O",
        SPN_I = "SPN_I",
        YTP = "ACP_O",
        NO = "ACP_O",
        SV_C = "ACP_O",
        SV_S = "ACP_O",
        RXB = "ACP_O",
        ACP_O = "ACP_O",
        ACP_S = "ACP_O",
        ELK_NN = "ACP_O",
    },

    -- Acacia Plains Oasis Line
    ACP_O = {
        SPN_E = "ACP_S",
        SPN_I = "ACP_C",
        YTP = "ACP_S",
        NO = "ACP_S",
        SV_C = "ACP_S",
        SV_S = "ACP_S",
        RXB = "ACP_S",
        ACP_C = "ACP_C",
        ACP_S = "ACP_S",
        ELK_NN = "ACP_S",
    },

    -- Acacia Plains South
    ACP_S = {
        SPN_E = "YTP",
        SPN_I = "ACP_O",
        YTP = "YTP",
        NO = "YTP",
        SV_C = "YTP",
        SV_S = "YTP",
        RXB = "YTP",
        ACP_C = "ACP_O",
        ACP_O = "ACP_O",
        ELK_NN = "YTP",
    },

    -- Elementalcraft Industrial Line (New Normandy)
    ELK_NN = {
        SPN_E = "YTP",
        SPN_I = "YTP",
        YTP = "YTP",
        NO = "YTP",
        SV_C = "YTP",
        SV_S = "YTP",
        RXB = "YTP",
        ACP_C = "YTP",
        ACP_O = "YTP",
        ACP_S = "YTP",
    }
}

function F.find_and_set_route(curr_system)
    -- If the system is undefined, raise an error
    local curr_system_neighbours = F.system.best_neighbour[curr_system]
    if not curr_system_neighbours then
        error("Attempt to access undefined system " .. curr_system)
    end

    local rc_list = F.get_rc_list()

    -- Clean up SN-* (System Neighbour)
    local i = 1
    while i <= #rc_list do
        if string.sub(rc_list[i], 1, 3) == "SN-" then
            table.remove(rc_list, i)
        else
            i = i + 1
        end
    end

    local curr_index = table_indexof(rc_list, "S-" .. curr_system)
    if curr_index ~= -1 then
        -- If we are already in our destination, remove the RC and don't do anything
        table.remove(rc_list, curr_index)
    else
        -- Otherwise, lookup for our destination
        -- If there are multiple S-* RCs, behaviour is undefined
        for _, this_rc in ipairs(rc_list) do
            if string.sub(this_rc, 1, 2) == "S-" then
                local dest_system = string.sub(this_rc, 3)
                local neighbour_system = curr_system_neighbours[dest_system]
                if neighbour_system then
                    table.insert(rc_list, "SN-" .. neighbour_system)
                    break
                end
            end
        end
    end

    set_rc(table.concat(rc_list, " "))
end