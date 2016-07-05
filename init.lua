minetest.register_privilege("secret", "Wouldn't you like to know?")
minetest.register_privilege("frozen", {description = "Unable to move.", give_to_singleplayer=false})
minetest.register_privilege("hobbled", {description = "Unable to jump.", give_to_singleplayer=false})
minetest.register_privilege("slowed", {description = "Slow moving.", give_to_singleplayer=false})
minetest.register_privilege("unglitched", {description = "Not very glitchy...", give_to_singleplayer=false})
minetest.register_privilege("hidden_one", {description = "Can hide from players.", give_to_singleplayer=false})


--Admin Curses

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

--reduces player movement speed
local function slowmo(name, param)
    local player = minetest.get_player_by_name(param)
    local privs = minetest.get_player_privs(param)
    privs.slowed = true
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

--trigger curse effects when player joins
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if minetest.get_player_privs(name).hobbled then
        hobble(name,name)
    end
    if minetest.get_player_privs(name).slowed then
        slowmo(name,name)
    end
    if minetest.get_player_privs(name).unglitched then
        noglitch(name,name)
    end
    if minetest.get_player_privs(name).frozen then
        freeze(name,name)
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



--Cage Commands

--put a player in the cage
minetest.register_chatcommand("cage", {
    params = "<person>",
    privs = {secret=true},
    description = "Put a player in the cage.",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        local privs = minetest.get_player_privs(param)
        privs.interact=nil
        privs.spawn=nil
        privs.home=nil
        privs.fly=nil
        privs.fast=nil
        minetest.set_player_privs(param,privs)
        noglitch(name, param)
        local cagepos = minetest.setting_get_pos("cage_coordinate")
        if not cagepos then
            minetest.chat_send_player(name, "No cage set...")
            return false
        end
        player:setpos(cagepos)
    end
})

--free a player from the cage
minetest.register_chatcommand("uncage", {
    params = "<person>",
    privs = {secret=true},
    description = "Free a player from the cage.",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        local privs = minetest.get_player_privs(param)
        privs.interact=true
        privs.spawn=true
        privs.home=true
        privs.fly=true
        privs.fast=true
        privs.unglitched=nil
        minetest.set_player_privs(param,privs)
        player:set_physics_override({sneak = true})
        local spawnpos = minetest.setting_get_pos("static_spawnpoint")
        if not spawnpos then
            minetest.chat_send_player(name, "No spawn point set...")
            return false
        end
        player:setpos(spawnpos)
    end
})



--Other Commands

--hide player model and nametag (only works in 0.4.14 and above)
vanished_players = {}

minetest.register_chatcommand("vanish", {
    params = "",
    description = "Make user invisible",
    privs = {hidden_one = true},
    func = function(name, param)
        local prop
        local player = minetest.get_player_by_name(name)
        vanished_players[name] = not vanished_players[name]
        if vanished_players[name] then
            prop = {visual_size = {x = 0, y = 0},
            collisionbox = {0,0,0,0,0,0}}
            player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
        else
            -- default player size
            prop = {visual_size = {x = 1, y = 1},
            collisionbox = {-0.35, -1, -0.35, 0.35, 1, 0.35}}
            player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
        end
        player:set_properties(prop)
    end
})

--announcements (only works in 0.4.14 and above)
minetest.register_chatcommand("say", {
    params = "<text>",
    description = "Sends text to all players",
    privs = {server = true},
    func = function (name, param)
        if not param
        or param == "" then
            return
        end
        minetest.chat_send_all(param)
    end
})
