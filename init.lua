minetest.register_privilege("secret", "Wouldn't you like to know?")
minetest.register_privilege("frozen", {description = "Unable to move.", give_to_singleplayer=false})
minetest.register_privilege("hobbled", {description = "Unable to jump.", give_to_singleplayer=false})
minetest.register_privilege("slowed", {description = "Slow moving.", give_to_singleplayer=false})
minetest.register_privilege("unglitched", {description = "Not very glitchy...", give_to_singleplayer=false})
minetest.register_privilege("lost", {description = "Not allowed to use minimap.", give_to_singleplayer=false})
minetest.register_privilege("caged", {description = "Not going anywhere...", give_to_singleplayer=false})
minetest.register_privilege("hidden_one", {description = "Can hide from players.", give_to_singleplayer=false})



-- Admin Curses

-- prevents player from jumping
local function hobble(user, target)
    -- return if player is admin
    local admin_name  = minetest.setting_get ("name")
    if target == admin_name then
        return
    end
    -- apply curse
    local player = minetest.get_player_by_name(target)
    local privs = minetest.get_player_privs(target)
    privs.hobbled = true
    minetest.set_player_privs(target,privs)
    player:set_physics_override({jump = 0})
end

minetest.register_chatcommand("hobble", {
    targets = "<person>",
    privs = {secret=true},
    description = "Prevent player jumping.",
    func = function(name, target)
        local player = minetest.get_player_by_name(target)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        hobble(name, target)
        minetest.chat_send_player(target, "Cursed by an admin! No more jumping!")
        minetest.chat_send_player(name, "Curse successful!")
    end
})

-- reduces player movement speed
local function slowmo(name, target)
    -- return if player is admin
    local admin_name  = minetest.setting_get ("name")
    if target == admin_name then
        return
    end
    -- apply curse
    local player = minetest.get_player_by_name(target)
    local privs = minetest.get_player_privs(target)
    privs.slowed = true
    minetest.set_player_privs(target, privs)
    player:set_physics_override({speed = 0.3})
end

minetest.register_chatcommand("slowmo", {
    targets = "<person>",
    privs = {secret=true},
    description = "Reduce player movement speed.",
    func = function(name, target)
        local player = minetest.get_player_by_name(target)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist") 
            return
        end
        slowmo(name,target)
        minetest.chat_send_player(target, "Cursed by an admin! You feel sloooooow!")
        minetest.chat_send_player(name, "Curse successful!")
    end
})

-- disable sneak glitch for the player
local function noglitch(name, target)
    -- return if player is admin
    local admin_name  = minetest.setting_get ("name")
    if target == admin_name then
        return
    end
    -- apply curse
    local player = minetest.get_player_by_name(target)
    local privs = minetest.get_player_privs(target)
    privs.unglitched = true
    minetest.set_player_privs(target, privs)
    player:set_physics_override({sneak = false})
end

minetest.register_chatcommand("noglitch", {
    targets = "<person>",
    privs = {secret=true},
    description = "Disable sneak glitch for a player.",
    func = function(name, target)
        local player = minetest.get_player_by_name(target)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        noglitch(name, target)
        minetest.chat_send_player(target, "Cursed by an admin! You feel less glitchy...")
        minetest.chat_send_player(name, "Curse successful!")
    end
})

-- prevent player from changing speed/direction and jumping
local function freeze(name, target)
    -- return if player is admin
    local admin_name  = minetest.setting_get ("name")
    if target == admin_name then
        return
    end
    -- apply curse
    local player = minetest.get_player_by_name(target)
    local privs = minetest.get_player_privs(target)
    privs.frozen = true
    minetest.set_player_privs(target, privs)
    player:set_physics_override({jump = 0, speed = 0})
end

minetest.register_chatcommand("freeze", {
    targets = "<person>",
    privs = {secret=true},
    description = "Prevent player movement.",
    func = function(name, target)
        local player = minetest.get_player_by_name(target)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        freeze(name, target)
        minetest.chat_send_player(target, "Cursed by an admin! You are now frozen!")
        minetest.chat_send_player(name, "Curse successful!")
    end
})

-- disables minimap for player
local function getlost(name,target)
    -- return if player is admin
    local admin_name  = minetest.setting_get ("name")
    if target == admin_name then
        return
    end
    -- apply curse
    local player = minetest.get_player_by_name(target)
    local privs = minetest.get_player_privs(target)
    privs.lost = true
    minetest.set_player_privs(target, privs)
    player:hud_set_flags({minimap = false})
end

minetest.register_chatcommand("getlost", {
    targets = "<person>",
    privs = {secret=true},
    description = "Prevent player from using the minimap.",
    func = function(name, target)
        local player = minetest.get_player_by_name(target)
        if player == nil then
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        getlost(name,target)
        minetest.chat_send_player(target, "Cursed by an admin! You will get lost now!")
        minetest.chat_send_player(name, "Curse successful!")
    end
})


-- trigger curse effects when player joins
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
    if minetest.get_player_privs(name).lost then
        player:hud_set_flags({minimap = false})
    end
end)

-- reset player physics
minetest.register_chatcommand("setfree",{
    targets = "<person>",
    privs = {secret=true},
    description = "Reset player movement.",
    func = function(name, target)
        local player = minetest.get_player_by_name(target)
        if player == nil then 
            minetest.chat_send_player(name,"Player does not exist")
            return
        end
        local privs = minetest.get_player_privs(target)
        privs.frozen = nil
        privs.hobbled = nil
        privs.slowed = nil
        privs.unglitched = nil
        privs.lost = nil
        minetest.set_player_privs(target, privs)
        player:set_physics_override({jump = 1, speed = 1, sneak = true})
        player:hud_set_flags({minimap = true})
        minetest.chat_send_player(target, "The curse is lifted. You have been set free!")
        minetest.chat_send_player(name, "The curse is lifted.")
    end,
})



-- Cage Commands

local priv_table = {}

-- save table to file
local function table_save()
    local data = priv_table
    local f, err = io.open(minetest.get_worldpath() .. "/curse_priv_table.txt", "w")
    if err then
        return err
    end
    f:write(minetest.serialize(data))
    f:close()
end

-- read saved file
local function table_read()
    local f, err = io.open(minetest.get_worldpath() .. "/curse_priv_table.txt", "r")
    local data = minetest.deserialize(f:read("*a"))
    f:close()
    return data
end

minetest.after(3.0, function()
    local f, err = io.open(minetest.get_worldpath() .. "/curse_priv_table.txt", "r")
    if err then
        table_save()
    else
        priv_table = table_read()
    end
end)

minetest.register_on_shutdown(function()
    table_save()
end)


-- put a player in the cage
minetest.register_chatcommand("cage", {
    targets = "<person>",
    privs = {secret=true},
    description = "Put a player in the cage.",
    func = function(warden_name, target_name)
        --prevent self-caging
        if warden_name == target_name then
            minetest.chat_send_player(warden_name,"You can't cage yourself")
            return
        end
        -- get target player or return
        local target = minetest.get_player_by_name(target_name)
        if not target then
            minetest.chat_send_player(warden_name,"Player does not exist")
            return
        end
        -- get target player's privs or return
        local privs = minetest.get_player_privs(target_name)
        if privs.caged == true then
            minetest.chat_send_player(warden_name,"This player is already caged")
            return
        end
        -- get cage position from config or return
        local cagepos = minetest.setting_get_pos("cage_coordinate")
        if not cagepos then
            minetest.chat_send_player(warden_name, "No cage set...")
            return
        end
        -- add current target privs to table and save to file
        priv_table[target_name] = privs
        table_save()
        -- remove all privs but shout and add caged and unglitched
        minetest.set_player_privs(target_name,{shout = true, caged = true})
        noglitch(warden_name, target_name)
        -- move target to cage location
        target:setpos(cagepos)
    end
})

-- free a player from the cage
minetest.register_chatcommand("uncage", {
    targets = "<person>",
    privs = {secret=true},
    description = "Free a player from the cage.",
    func = function(warden_name, target_name)
        -- get target player or return
        local target = minetest.get_player_by_name(target_name)
        if not target then
            minetest.chat_send_player(warden_name,"Player does not exist")
            return
        end
        -- get target player's privs or return
        local privs = minetest.get_player_privs(target_name)
        if privs.caged ~= true then
            minetest.chat_send_player(warden_name,"This player is not caged")
            return
        end
        -- get release position from config or return
        local releasepos = minetest.setting_get_pos("release_coordinate")
        if not releasepos then
            minetest.chat_send_player(warden_name, "No release point set...")
            return
        end
        -- get target's original privs from table and restore them
        local original_privs = priv_table[target_name]
        minetest.set_player_privs(target_name,original_privs)
        -- remove entry for target from table and save to file
        priv_table[target_name] = nil
        table_save()
        -- restore sneak and move target to release point
        target:set_physics_override({sneak = true})
        target:setpos(releasepos)
    end
})

-- list caged players
minetest.register_chatcommand("list_caged", {
    targets = "",
    description = "List all caged players.",
    privs = {server = true},
    func = function (_, _)
        local players = ""
        for player, _ in pairs(priv_table) do
            players = players .. player .. ", "
        end
        return true, "Currently caged players: " .. players
    end
})



-- Other Commands

-- hide player model and nametag (only works in 0.4.14 and above)
vanished_players = {}

minetest.register_chatcommand("vanish", {
    targets = "",
    description = "Make user invisible",
    privs = {hidden_one = true},
    func = function(user)
        local prop
        local player = minetest.get_player_by_name(user)
        vanished_players[user] = not vanished_players[user]
        if vanished_players[user] then
            prop = {visual_size = {x = 0, y = 0},
            collisionbox = {0,0,0,0,0,0}}
            player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
        else
            -- default player size.
            prop = {visual_size = {x = 1, y = 1},
            collisionbox = {-0.35, -1, -0.35, 0.35, 1, 0.35}}
            player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
        end
        player:set_properties(prop)
    end
})

-- announcements
minetest.register_chatcommand("proclaim", {
    targets = "<text>",
    description = "Sends text to all players",
    privs = {server = true},
    func = function (user, text)
        if not text
        or text == "" then
            return
        end
        minetest.chat_send_all(text)
        if minetest.get_modpath("irc") then 
            if irc.connected and irc.config.send_join_part then
                irc:say(text)
            end
        end
    end
})

