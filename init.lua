minetest.register_privilege("secret", "Wouldn't you like to know?")
minetest.register_privilege("frozen", {description = "Unable to move.", give_to_singleplayer=false})
minetest.register_privilege("hobbled", {description = "Unable to jump.", give_to_singleplayer=false})
minetest.register_privilege("slowed", {description = "Slow moving.", give_to_singleplayer=false})
minetest.register_privilege("unglitched", {description = "Not very glitchy...", give_to_singleplayer=false})


--prevents player from changing speed/direction and jumping.
local function freeze(name, param)
    local player = minetest.get_player_by_name(param)
    local privs=minetest.get_player_privs(param)
    privs.frozen=true
    minetest.set_player_privs(param,privs)
    player:set_physics_override({jump = 0, speed = 0})
end

minetest.register_chatcommand("freeze", {
    params = "<person>",
    privs = {secret=true},
    description = "Prevent player movement.",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        freeze(name, param)
        minetest.chat_send_player(param, "Cursed by an admin! You are now frozen!")
        minetest.chat_send_player(name, "Curse successful!")
    end
})

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if minetest.get_player_privs(name).frozen then
        freeze(name,name)
    end
end)

--prevents player from jumping.
local function hobble(name, param)
    local player = minetest.get_player_by_name(param)
    local privs=minetest.get_player_privs(param)
    privs.hobbled=true
    minetest.set_player_privs(param,privs)
    player:set_physics_override({jump = 0})
end

minetest.register_chatcommand("hobble", {
    params = "<person>",
    privs = {secret=true},
    description = "Prevent player jumping.",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        hobble(name,param)
        minetest.chat_send_player(param, "Cursed by an admin! No more jumping!")
        minetest.chat_send_player(name, "Curse successful!")
    end
})

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if minetest.get_player_privs(name).hobbled then
        hobble(name,name)
    end
end)

--reduces player movement speed
local function slowmo(name, param)
        local player = minetest.get_player_by_name(param)
        local privs=minetest.get_player_privs(param)
        privs.slowed=true
        minetest.set_player_privs(param,privs)
        player:set_physics_override({speed = 0.3})
end

minetest.register_chatcommand("slowmo", {
    params = "<person>",
    privs = {secret=true},
    description = "Reduce player movement speed.",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist") 
            return
        end
        slowmo(name,param)
        minetest.chat_send_player(param, "Cursed by an admin! You feel sloooooow!")
        minetest.chat_send_player(name, "Curse successful!")
    end
})

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if minetest.get_player_privs(name).slowed then
        slowmo(name,name)
    end
end)

--disable sneak glitch for the player.
local function noglitch(name, param)
        local player = minetest.get_player_by_name(param)
        local privs=minetest.get_player_privs(param)
        privs.unglitched=true
        minetest.set_player_privs(param,privs)
        player:set_physics_override({sneak = false})
end

minetest.register_chatcommand("noglitch", {
    params = "<person>",
    privs = {secret=true},
    description = "Disable sneak glitch for a player.",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        noglitch(name, param)
        minetest.chat_send_player(param, "Cursed by an admin! You feel less glitchy...")
        minetest.chat_send_player(name, "Curse successful!")
    end
})

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if minetest.get_player_privs(name).unglitched then
        noglitch(name,name)
    end
end)

--reset player physics.
minetest.register_chatcommand("setfree",{
    params = "<person>",
    privs = {secret=true},
    description = "Reset player movement.",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if player == nil then 
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        local privs=minetest.get_player_privs(param)
        privs.frozen=nil
        privs.hobbled=nil
        privs.slowed=nil
        privs.unglitched=nil
        minetest.set_player_privs(param,privs)
        player:set_physics_override({jump = 1, speed = 1, sneak = true})
        minetest.chat_send_player(param, "The curse is lifted. You have been set free!")
        minetest.chat_send_player(param, "The curse is lifted.")
    end,
})
