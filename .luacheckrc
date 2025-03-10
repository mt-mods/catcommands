unused_args = false
allow_defined_top = true
exclude_files = {".luacheckrc"}

globals = {
    "minetest",

    --mod created
    "catcommands", "map",
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",

    --depends
    "irc",
}