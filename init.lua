catcommands = {}
local modpath = minetest.get_modpath("catcommands")

minetest.register_privilege("secret", "Wouldn't you like to know?")
minetest.register_privilege("hidden_one", {description = "Can hide from players.", give_to_singleplayer=false})

dofile(modpath .. "/api.lua")
dofile(modpath .. "/monkey_patching.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/other.lua")

catcommands.init = true