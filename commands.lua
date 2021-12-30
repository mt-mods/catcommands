--effects
minetest.register_chatcommand("hobble", {
	params = "<person>",
	privs = {secret=true},
	description = "Prevent player jumping.",
	func = function(name, param)
		local target = minetest.get_player_by_name(param)
		if not target then
			return false, "Target does not exist."
		end
		catcommands.effects.hobble("", target, true, true)
		return true, "Curse successful!"
	end
})

minetest.register_chatcommand("slowmo", {
	params = "<person> <speed>",
	privs = {secret = true},
	description = "Reduce player movement speed.",

	func = function(name, param)
        --verify input
        if param == "" then return false, "You must enter a player name, optionally followed by speed." end
        local split = param:split(" ")
        local target = minetest.get_player_by_name(split[1])
        if not target then return false, "please enter a online player" end
        if split[2] and not tonumber(split[2]) then return false, "please enter a valid number" end

		catcommands.effects.slowmo("", target, true, true, {kv = split[2]})
		return true, "Curse successful! " .. split[1] .. "'s speed set to " .. (split[2] or 0.3)
	end
})

minetest.register_chatcommand("freeze", {
	params = "<person>",
	privs = {secret=true},
	description = "Prevent player movement.",
	func = function(name, param)
		local target = minetest.get_player_by_name(param)
		if not target then
			return false, "Target does not exist."
		end
		catcommands.effects.freeze("", target, true, true)
		return true, "Curse successful!"
	end
})

minetest.register_chatcommand("getlost", {
	params = "<person>",
	privs = {secret=true},
	description = "Prevent player from using the minimap.",
	func = function(name, param)
		local target = minetest.get_player_by_name(param)
		if not target then
			return false, "Target does not exist."
		end
		catcommands.effects.getlost("", target, true, true)
		return true, "Curse successful!"
	end
})

minetest.register_chatcommand("blind", {
	params = "<person>",
	privs = {secret=true},
	description = "Place player in eternal night time.",
	func = function(name, param)
		local target = minetest.get_player_by_name(param)
		if not target then
			return false, "Target does not exist."
		end
		catcommands.effects.blind("", target, true, true)
		return true, "Curse successful!"
	end
})

--utility
minetest.register_chatcommand("proclaim", {
	params = "<text>",
	description = "Sends text to all players",
	privs = {server = true},
	func = function (user, param)
		if not param or param == "" then return end
        catcommands.utility.proclaim(param)
	end
})

minetest.register_chatcommand("curses",{
	params = "<person>",
	privs = {secret = true},
	description = "Check player status.",
	func = function(name, param)
		local target = minetest.get_player_by_name(param)
		if not target then return false, "Player does not exist or is not logged in." end
		local result = "Enabled curses for player " .. param .. ": "

		for effect, _ in pairs(catcommands.effects) do
			if target:get_meta():get(effect) then
				result = result .. effect .. " "
			end
		end

        return true, result
	end
})








