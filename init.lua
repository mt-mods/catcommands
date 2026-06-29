catcommands = {}
local modpath = core.get_modpath("catcommands")

core.register_privilege("secret", "Wouldn't you like to know?")
core.register_privilege("hidden_one", {description = "Can hide from players.", give_to_singleplayer=false})

dofile(modpath .. "/api.lua")
dofile(modpath .. "/monkey_patching.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/other.lua")

catcommands.init = true