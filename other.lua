local default_sneak_mode = "old" -- change this to "new" if you want new movement.

-- trigger curse effects when player joins
minetest.register_on_joinplayer(function(player)

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
	func = function(name, param)
		local player = minetest.get_player_by_name(param)
		if not player then return false, "Player does not exist." end

		for key, effect in pairs(catcommands.effects) do
			catcommands.effects[key]("", player, false, false, {})
		end

		minetest.chat_send_player(param, "The curse is lifted. You have been set free!")
		return true, "The curses on " .. param .. " are lifted."
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