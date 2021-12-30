if minetest.get_modpath("map") then
    local old_update = map.update_hud_flags

    function map.update_hud_flags(player)
        if player:get_meta():get_string("getlost") then
            return
        else
            return old_update(player)
        end
    end
end