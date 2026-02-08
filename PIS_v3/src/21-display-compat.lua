assert(is_loading)

F.get_textline_display = F.get_pis_single_line
F.get_express_station_display_lines = F.get_pis_multi_line
F.set_textline_minimal = F.get_pis_compat

function F.show_lr(def, texts)
    digiline_send(def.left_disp or "l", table.concat(texts, "\n"))
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%26s", y))
    end
    digiline_send(def.right_disp or "r", table.concat(rtexts, "\n"))
end

function F.show_textline(_, texts)
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%27s", y))
    end
    display(table.concat(texts, "\n"), table.concat(rtexts, "\n"))
end

function F.show_textline_r(_, texts)
    local rtexts = {}
    for _, y in ipairs(texts) do
        table.insert(rtexts, string.format("%27s", y))
    end
    display(table.concat(rtexts, "\n"), table.concat(texts, "\n"))
end

F.set_textline = function(def)
    local texts = F.get_pis_single_line(def)
    local show_func = def.show_func or F.show_lr
    show_func(def, texts)
end
