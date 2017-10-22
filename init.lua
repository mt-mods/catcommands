minetest.register_privilege("secret", "Wouldn't you like to know?")
minetest.register_privilege("hidden_one", {description = "Can hide from players.", give_to_singleplayer=false})


-- Admin Curses

-- prevents player from jumping
local function hobble(user, target)
	local player = minetest.get_player_by_name(target)
	player:set_attribute("hobbled", "true")
	player:set_physics_override({jump = 0})
end

minetest.register_chatcommand("hobble", {
	params = "<person>",
	privs = {secret=true},
	description = "Prevent player jumping.",
	func = function(name, target)
		local player = minetest.get_player_by_name(target)
		if player == nil then
			return false, "Player does not exist."
		end
		hobble(name, target)
		minetest.chat_send_player(target, "Cursed by an admin! No more jumping!")
		minetest.chat_send_player(name, "Curse successful!")
	end
})

-- reduces player movement speed
local function slowmo(name, target)
	local player = minetest.get_player_by_name(target)
	player:set_attribute("slowed", "true")
	player:set_physics_override({speed = 0.3})
end

minetest.register_chatcommand("slowmo", {
	params = "<person>",
	privs = {secret=true},
	description = "Reduce player movement speed.",
	func = function(name, target)
		local player = minetest.get_player_by_name(target)
		if player == nil then
			return false, "Player does not exist."
		end
		slowmo(name,target)
		minetest.chat_send_player(target, "Cursed by an admin! You feel sloooooow!")
		minetest.chat_send_player(name, "Curse successful!")
	end
})

-- prevent player from changing speed/direction and jumping
local function freeze(name, target)
	local player = minetest.get_player_by_name(target)
	player:set_attribute("frozen", "true")
	player:set_physics_override({jump = 0, speed = 0})
end

minetest.register_chatcommand("freeze", {
	params = "<person>",
	privs = {secret=true},
	description = "Prevent player movement.",
	func = function(name, target)
		local player = minetest.get_player_by_name(target)
		if player == nil then
			return false, "Player does not exist."
		end
		freeze(name, target)
		minetest.chat_send_player(target, "Cursed by an admin! You are now frozen!")
		minetest.chat_send_player(name, "Curse successful!")
	end
})

-- disables minimap for player
local function getlost(name,target)
	local player = minetest.get_player_by_name(target)
	player:set_attribute("lost", "true")
	player:hud_set_flags({minimap = false})
end

minetest.register_chatcommand("getlost", {
	params = "<person>",
	privs = {secret=true},
	description = "Prevent player from using the minimap.",
	func = function(name, target)
		local player = minetest.get_player_by_name(target)
		if player == nil then
			return false, "Player does not exist."
		end
		getlost(name,target)
		minetest.chat_send_player(target, "Cursed by an admin! You will get lost now!")
		minetest.chat_send_player(name, "Curse successful!")
	end
})


-- trigger curse effects when player joins
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if player:get_attribute("hobbled") == "true" then
		hobble(name,name)
	end
	if player:get_attribute("slowed") == "true" then
		slowmo(name,name)
	end
	if player:get_attribute("unglitched") == "true" then
		noglitch(name,name)
	end
	if player:get_attribute("frozen") == "true" then
		freeze(name,name)
	end
	if player:get_attribute("lost") == "true" then
		getlost(name,name)
	end
	if player:get_attribute("sneak_mode") == "old" then
		player:set_physics_override({new_move = false, sneak_glitch = true})
	elseif player:get_attribute("sneak_mode") == "new" then
		player:set_physics_override({new_move = true, sneak_glitch = false})
	end	
end)

-- reset player physics
minetest.register_chatcommand("setfree",{
	params = "<person>",
	privs = {secret=true},
	description = "Reset player movement.",
	func = function(name, target)
		local player = minetest.get_player_by_name(target)
		if player == nil then 
			return false, "Player does not exist."
		end
		player:set_attribute("hobbled", "")
		player:set_attribute("slowed", "")
		player:set_attribute("unglitched", "")
		player:set_attribute("frozen", "")
		player:set_attribute("lost", "")
		player:set_physics_override({jump = 1, speed = 1, sneak = true})
		player:hud_set_flags({minimap = true})
		minetest.chat_send_player(target, "The curse is lifted. You have been set free!")
		minetest.chat_send_player(name, "The curse is lifted.")
	end
})

-- set sneak mode
local function sneak_mode(player, mode)
	player:set_attribute("sneak_mode", mode)
	if mode == "old" then
		player:set_physics_override({new_move = false, sneak_glitch = true, sneak = true})
	elseif mode == "new" then
		player:set_physics_override({new_move = true, sneak_glitch = false, sneak = true})
	elseif mode == "none" then
		player:set_physics_override({sneak = false})
	end
end

minetest.register_chatcommand("set_sneak",{
	params = "<player> <old | new | none>",
	privs = {secret = true},
	description = "Set sneak mode for player.",
	func = function(name, params)
		local target, mode = params:match("(%S+)%s+(.+)")
		if not target and not reason then
			return false, "Must include player name and sneak mode."
		end
		local player = minetest.get_player_by_name(target)
		if not player then 
			return false, "Player does not exist."
		end
		if not mode or (mode ~= "old" and mode ~= "new" and mode ~= "none") then
			return false, "Set a mode: old, new or none."
		end
		sneak_mode(player, mode)
	end
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
	params = "<person>",
	privs = {secret=true},
	description = "Put a player in the cage.",
	func = function(warden_name, target_name)
		-- prevent self-caging
		if warden_name == target_name then
			return false, "You can't cage yourself."
		end
		-- get target player or return
		local target = minetest.get_player_by_name(target_name)
		if not target then
			return false, "Player does not exist."
		end
		-- return if already caged
		if target:get_attribute("caged") == "true" then
			return false, "This player is already caged."
		end
		-- get cage position from config or return
		local cagepos = minetest.setting_get_pos("cage_coordinate")
		if not cagepos then
			return false, "No cage set..."
		end
		-- add current target privs to table and save to file
		local privs = minetest.get_player_privs(target_name)
		priv_table[target_name] = privs
		table_save()
		-- remove all privs but shout and add caged and unglitched
		minetest.set_player_privs(target_name,{shout = true})
		target:set_attribute("caged", "true")
		sneak_mode(target, "none")
		-- move target to cage location
		target:setpos(cagepos)
	end
})

-- free a player from the cage
minetest.register_chatcommand("uncage", {
	params = "<person>",
	privs = {secret=true},
	description = "Free a player from the cage.",
	func = function(warden_name, target_name)
		-- get target player or return
		local target = minetest.get_player_by_name(target_name)
		if not target then
			return false, "Player does not exist."
		end
		-- return if not caged
		if target:get_attribute("caged") ~= "true" then
			return false, "This player is not caged."
		end
		-- get release position from config or return
		local releasepos = minetest.setting_get_pos("release_coordinate")
		if not releasepos then
			return false, "No release point set..."
		end
		-- get target's original privs from table and restore them
		local original_privs = priv_table[target_name]
		minetest.set_player_privs(target_name,original_privs)
		-- remove entry for target from table and save to file
		priv_table[target_name] = nil
		table_save()
		-- restore sneak and move target to release point
		local mode = "old" -- TODO: need to check conf here
		sneak_mode(target, mode)
		target:set_attribute("caged", "")
		target:setpos(releasepos)
	end
})

-- list caged players
minetest.register_chatcommand("list_caged", {
	params = "",
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
	params = "",
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
	params = "<text>",
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

