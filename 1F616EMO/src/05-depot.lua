F.depot = {}

-- section_occupancy(id)
F.depot.depots = {
    NLU = {
        routes = {
            ["L1-1"] = "95263736",
            ["L1-2"] = "24213087",
            ["L1-3"] = "54919762",
            ["L1-4"] = "98841043",
            ["L1-5"] = "31873260",
            ["L1-6"] = "11611898",
            ["L1-7"] = "70379279",
            ["L1-8"] = "71839304",
            ["L2-1"] = "56352529",
            ["L2-2"] = "59209119",
            ["L2-3"] = "53485278",
            ["L2-4"] = "60962623",
        },
        route_order = {
            "L1-1", "L1-2", "L1-3", "L1-4",
            "L1-5", "L1-6", "L1-7", "L1-8",
            "L2-1", "L2-2", "L2-3", "L2-4",
        },
    },
    OAI = {
        routes = {
            ["Y-OAI-T1"] = "182417",
            ["Y-OAI-T2"] = "426065",
            ["Y-OAI-T3"] = "110394",
            ["Y-OAI-T4"] = "455764",
        },
        route_order = {
            "Y-OAI-T1", "Y-OAI-T2", "Y-OAI-T3", "Y-OAI-T4",
        },
    },
}

F.depot.actions = {
    set_route = set_route,
    scan_route = function(def)
        local signal = def("signal")
        for _, route in ipairs(def("route_order")) do
            local section_occupancy_data = section_occupancy(def("routes")[route])
            if type(section_occupancy_data) == "table" and #section_occupancy_data == 0 then
                set_route(signal, route)
                return
            end
        end
    end,
}

F.depot.entry = function(depot_name, override_def)
    if event.int and event.msg and event.msg.type == "depot_entry_do" then
        local todo = event.msg
        for _, item in ipairs(todo) do
            F.depot.actions[item[1]](unpack(item[2]))
        end
        return
    end

    local def = cascade_index(override_def, F.depot.depots[depot_name])

    local do_action
    local finish = function() end

    if def("approach") == true then
        __approach_callback_mode = 1

        local todo = {}
        do_action = function(func_name, ...)
            todo[#todo + 1] = { func_name, { ... } }
        end
        finish = function()
            todo.type = "depot_entry_do"
            interrupt(0, todo)
        end
    else
        __approach_callback_mode = nil
        if event.approach then return end

        do_action = function(func_name, ...)
            F.depot.actions[func_name](...)
        end
    end

    if event.approach or (event.train and atc_arrow) then
        local rc_list = F.get_rc_list()
        if def("custom_func") then
            local route_name = def("custom_func")(rc_list)
            if route_name then
                if route_name ~= "" then
                    do_action("set_route", def("signal"), route_name)
                    finish()
                    return
                end
            end
        end
        for _, rc in ipairs(rc_list) do
            if string.sub(rc, 1, 3 + string.len(depot_name)) == ("Y-" .. depot_name .. "-") then
                local route_name = string.sub(rc, 4 + string.len(depot_name))
                do_action("set_route", def("signal"), route_name)
                finish()
                return
            end
        end

        do_action("scan_route", def)
        finish()
    end
end