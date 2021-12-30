catcommands.effects = {}
catcommands.utility = {}

--[[
    all effect api commands should take the following input format
    (user, target, notify)
    @user player obj calling the function
    @target player obj the function should manipulate
    @notify boolean if the api call should notify the target of the applied function
    @status boolean if to enable or disable effect
    @data table to pass data through
        @data.kv default value of the stored player meta
--]]

function catcommands.effects.hobble(user, target, notify, status, data)
    local message
    if status then
        target:get_meta():set_string("hobble", "true")
        target:set_physics_override({jump = 0})
        message = "Cursed by an admin! No more jumping!"
    else
        target:get_meta():set_string("hobble", "")
        target:set_physics_override({jump = 1})
        message = "you can jump now"
    end

    if notify then
        minetest.chat_send_player(target:get_player_name(), message)
    end
end

function catcommands.effects.slowmo(user, target, notify, status, data)
    local message
    data = data or {}
    if data.kv then data.kv = tonumber(data.kv) else data.kv = 0.3 end
    if status then
        target:get_meta():set_string("slowmo", data.kv)
        target:set_physics_override({speed = data.kv})
        message = "hold your horses there buddy, you have been slowed down"
    else
        target:get_meta():set_string("slowmo", "")
        target:set_physics_override({speed = 1})
        message = "off to the races, you have been freed"
    end

    if notify then
        minetest.chat_send_player(target:get_player_name(), message)
    end
end

function catcommands.effects.freeze(user, target, notify, status, data)
    local message
    if status then
        target:get_meta():set_string("freeze", "true")
        target:set_physics_override({jump = 0, speed = 0})
        message = "Cursed by an admin! You are now frozen!"
    else
        target:get_meta():set_string("freeze", "")
        target:set_physics_override({jump = 1, speed = 1})
        message = "you are unfrozen now"
    end

    if notify then
        minetest.chat_send_player(target:get_player_name(), message)
    end
end

function catcommands.effects.getlost(user, target, notify, status, data)
    local message
    if status and target:hud_get_flags().minimap == false then return end
    if status then
        target:get_meta():set_string("getlost", "true")
        target:hud_set_flags({minimap = false})
        message = "Cursed by an admin! You will get lost now!"
    else
        target:get_meta():set_string("getlost", "")
        target:hud_set_flags({minimap = true})
        message = "you can view the map now"
    end

    if notify then
        minetest.chat_send_player(target:get_player_name(), message)
    end
end

function catcommands.effects.blind(user, target, notify, status, data)
    local message
    if status then
        target:get_meta():set_string("blind", "true")
        target:override_day_night_ratio(0.05)
        message = "Cursed by an admin! Eternal night time!"
    else
        target:get_meta():set_string("blind", "")
        target:override_day_night_ratio(nil)
        message = "you can now see again"
    end

    if notify then
        minetest.chat_send_player(target:get_player_name(), message)
    end
end

--apply affects on join
minetest.register_on_joinplayer(function(target)
    for key, api in pairs(catcommands.effects) do
        if target:get_meta():get(key) then
            catcommands.effects[key]("", target, false, true, {kv = target:get_meta():get(key)})
        end
    end
end)

--utility
function catcommands.utility.proclaim(message)
    if not message or message == "" then return end

    minetest.chat_send_all(message)
	if minetest.get_modpath("irc") and irc.connected and irc.config.send_join_part then
		irc:say(message)
	end
end