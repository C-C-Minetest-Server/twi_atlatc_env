-- Generate static cache

F.textline_advertisments_by_group = {}

for name, def in pairs(F.textline_advertisments) do
    for group, bool in pairs(def.groups or {}) do
        if bool then
            F.textline_advertisments_by_group[group] = F.textline_advertisments_by_group[group] or {}
            F.textline_advertisments_by_group[group][#F.textline_advertisments_by_group[group] + 1] = name
        end
    end
end

F.concat_index = function(i, tbs)
    local table_index = 1
    while tbs[table_index] ~= nil and i > #tbs[table_index] do
        i = i - #tbs[table_index]
        table_index = table_index + 1
    end
    return tbs[table_index][i]
end

F.random_from_tables = function(tbs)
    local length = 0
    for _, tb in ipairs(tbs) do
        length = length + #tb
    end
    if length == 0 then return nil end
    local random_index = math.random(1, length)
    return F.concat_index(random_index, tbs)
end

F.get_textline_advertisment_by_groups = function(groups)
    local tbs = {}
    for _, group in ipairs(groups) do
        tbs[#tbs+1] = F.textline_advertisments_by_group[group]
    end
    return F.random_from_tables(tbs)
end