F.cache_function = function(period, get_key, func)
    local caches = {}
    local last_clear = os.time()

    return function(...)
        local now = os.time()
        if last_clear + period <= now then
            for k in pairs(caches) do
                caches[k] = nil
            end
        end

        local cache_key = get_key(...)
        if cache_key == nil then
            return nil
        end
        if caches[cache_key] then
            return unpack(caches[cache_key])
        end

        caches[cache_key] = {func(...)}
        return unpack(caches[cache_key])
    end
end
