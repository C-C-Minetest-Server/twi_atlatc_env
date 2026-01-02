assert(is_loading)

F.garbage_cleaner = function()
    local now = os.time()
    local sec_in_minute = now % 20

    -- Pick advertisement
    if sec_in_minute < 7 then
        if F.show_advertisement == 0 then
            repeat
                F.show_advertisement = math.random(1, #F.pis_advertisements)
            until F.show_advertisement ~= F.last_advertisement or #F.pis_advertisements == 1
        end
    elseif F.show_advertisement ~= 0 then
        F.last_advertisement = F.show_advertisement
        F.show_advertisement = 0
    end
end
