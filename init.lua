minetest.register_privilege("secret", "Wouldn't you like to know?")
minetest.register_privilege("hidden_one", {description = "Can hide from players.", give_to_singleplayer=false})

local default_sneak_mode = "old" -- change this to "new" if you want new movement.

-- Admin Curses

-- prevents player from jumping
local function hobble(user, target)
	local player = minetest.get_player_by_name(target)
	player:get_meta():set_string("hobbled", "true")
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
local default_slow = 0.3

local function slowmo(name, target, speed)
	local player = minetest.get_player_by_name(target)
	player:get_meta():set_string("slowed", speed)
	player:set_physics_override({speed = speed})
end

minetest.register_chatcommand("slowmo", {
	params = "<person> <speed>",
	privs = {secret = true},
	description = "Reduce player movement speed.",

	func = function(name, params)
		local target, speed = params:match("^(%S+)%s*([%d.]*)$")
		if target == nil or target == "" then
			return false, "You must enter a player name, optionally followed by speed."
		end

		local player = minetest.get_player_by_name(target)
		if player == nil then
			return false, "Player does not exist."
		end

		if speed == nil or speed == "" or
				tonumber(speed) > 1.0 or tonumber(speed) < 0.1 then
			speed = default_slow
		end

		slowmo(name, target, speed)
		minetest.chat_send_player(target, "Cursed by an admin! You feel sloooooow! " ..
			"(Speed set to ".. speed ..")")
		minetest.chat_send_player(name, "Curse successful! "..target.."'s speed set to "..speed)
	end
})

-- prevent player from changing speed/direction and jumping
local function freeze(name, target)
	local player = minetest.get_player_by_name(target)
	player:get_meta():set_string("frozen", "true")
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
	player:get_meta():set_string("lost", "true")
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

-- lower light levels for player
local function blind(name,target)
	local player = minetest.get_player_by_name(target)
	player:get_meta():set_string("blind", "true")
	player:override_day_night_ratio(0.05)
end

minetest.register_chatcommand("blind", {
	params = "<person>",
	privs = {secret=true},
	description = "Place player in eternal night time.",
	func = function(name, target)
		local player = minetest.get_player_by_name(target)
		if player == nil then
			return false, "Player does not exist."
		end
		blind(name,target)
		minetest.chat_send_player(target, "Cursed by an admin! Eternal night time!")
		minetest.chat_send_player(name, "Curse successful!")
	end
})


-- trigger curse effects when player joins
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if player:get_meta():get_string("hobbled") == "true" then
		hobble(name,name)
	end
	local slowed = player:get_meta():get_string("slowed")
	if slowed then
		slowmo(name,name, tonumber(slowed))
	end
	if player:get_meta():get_string("frozen") == "true" then
		freeze(name,name)
	end
	if player:get_meta():get_string("lost") == "true" then
		getlost(name,name)
	end
	if player:get_meta():get_string("blind") == "true" then
		blind(name,name)
	end
	-- set sneak mode if unassigned
	if player:get_meta():get_string("sneak_mode") == nil then
		player:get_meta():set_string("sneak_mode", default_sneak_mode)
	end
	-- set movement physics based on sneak_mode
	if player:get_meta():get_string("sneak_mode") == "old" then
		player:set_physics_override({new_move = false, sneak_glitch = true, sneak = true})
	elseif player:get_meta():get_string("sneak_mode") == "new" then
		player:set_physics_override({new_move = true, sneak_glitch = false, sneak = true})
	elseif player:get_meta():get_string("sneak_mode") == "none" then
		player:set_physics_override({sneak = false})
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
		player:get_meta():set_string("hobbled", "")
		player:get_meta():set_string("slowed", "")
		player:get_meta():set_string("frozen", "")
		player:get_meta():set_string("lost", "")
		player:get_meta():set_string("blind", "")
		player:set_physics_override({jump = 1, speed = 1, sneak = true})
		player:hud_set_flags({minimap = true})
		player:override_day_night_ratio(nil)
		minetest.chat_send_player(target, "The curse is lifted. You have been set free!")
		minetest.chat_send_player(name, "The curse is lifted.")
	end
})

-- set sneak mode
local function sneak_mode(player, mode)
	player:get_meta():set_string("sneak_mode", mode)
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
		if not target then --and not reason then
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


-- check player status
minetest.register_chatcommand("curses",{
	params = "<person>",
	privs = {secret = true},
	description = "Check player status.",
	func = function(user_name, target_name)
		local player = minetest.get_player_by_name(target_name)
		if player == nil then
			return false, "Player does not exist or is not logged in."
		end
		local result = "Status for player "..target_name..": "
		local status_list = {"hobbled", "slowed", "frozen", "lost", "blind", "caged"}
		for i, status in ipairs(status_list) do
			if player:get_meta():get_string(status_list[i]) == "true" then
				result = result..status_list[i].." "
			end
		end
		if player:get_meta():get("slowed") and player:get_meta():get_string("slowed") ~= "" then
			result = result.."slowed("..player:get_meta():get_string("slowed")..")"
		end
		minetest.chat_send_player(user_name, result.." Sneak mode: "..player:get_meta():get_string("sneak_mode"))
		return
	end
})


-- Cage Commands

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
		if target:get_meta():get_string("caged") == "true" then
			return false, "This player is already caged."
		end
		-- get cage position from config or return
		local cagepos = minetest.setting_get_pos("cage_coordinate")
		if not cagepos then
			return false, "No cage set..."
		end
		-- save then remove all privs other than shout
		local target_privs = minetest.privs_to_string(minetest.get_player_privs(target_name))
		target:get_meta():set_string("caged_privs", target_privs)
		minetest.chat_send_player(warden_name, target:get_meta():get_string("caged_privs"))
		minetest.set_player_privs(target_name,{shout = true})
		target:get_meta():set_string("caged", "true")
		sneak_mode(target, "none")
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
		if target:get_meta():get_string("caged") ~= "true" then
			return false, "This player is not caged."
		end
		-- get release position from config or return
		local releasepos = minetest.setting_get_pos("release_coordinate")
		if not releasepos then
			return false, "No release point set..."
		end
		-- restore privs and release
		local original_privs = minetest.string_to_privs(target:get_meta():get_string("caged_privs"))
		minetest.set_player_privs(target_name, original_privs)
		target:get_meta():set_string("caged_privs", nil)
		sneak_mode(target, default_sneak_mode)
		target:get_meta():set_string("caged", "")
		target:setpos(releasepos)
	end
})



-- Other Commands

-- hide player model and nametag (only works in 0.4.14 and above)
vanished_players = {}

minetest.register_chatcommand("vanish", {
	params = "<optional player>",
	description = "Make yourself or suppilied user invisible",
	privs = {hidden_one = true},
	func = function(caller, param)
        local user
        if not param or param == "" then
			user = caller
        else
            if not minetest.get_player_by_name(param) then
                minetest.chat_send_player(caller, param .. " is not a valid player")
                return
            else
                user = param
            end
		end

		local prop
		local player = minetest.get_player_by_name(user)
		vanished_players[user] = not vanished_players[user]
		if vanished_players[user] then
			prop = {
				visual_size = {x = 0, y = 0},
				selectionbox = {-0.01, -0.01, -0.01, 0.01, 0.01, 0.01},
				show_on_minimap = false,
				makes_footstep_sound = false,
			}
			player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
            minetest.chat_send_player(user, "you are now vanished")
		else
			-- default player size.
			prop = {
				visual_size = {x = 1, y = 1},
				selectionbox = {-0.35, 0, -0.35, 0.35, 2, 0.35},
				show_on_minimap = true,
				makes_footstep_sound = true,
			}
			player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
            minetest.chat_send_player(user, "you are now un vanished")
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

