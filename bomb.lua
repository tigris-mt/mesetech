-- A unique explosive, similiar to a drill but fires in all six directions at once.
morebombs.register("mesetech:bomb", {
    description = "Active Mese Bomb",
    tiles = {"mesetech_bomb.png"},
    sounds = default.node_sound_metal_defaults(),
    groups = {cracky = 2},
    paramtype2 = "facedir",
    action = function(pos, def)
        for _,dir in ipairs({
            {x = 1, y = 0, z = 0},
            {x = -1, y = 0, z = 0},
            {x = 0, y = 1, z = 0},
            {x = 0, y = -1, z = 0},
            {x = 0, y = 0, z = 1},
            {x = 0, y = 0, z = -1},

        }) do
            morebombs.drill(pos, 6, dir)
        end
    end,
})

minetest.register_craft{
    output = "mesetech:bomb",
    recipe = {
        {"morebombs:thunderfist", "", "morebombs:thunderfist"},
        {"", "mesetech:active_mese_3", ""},
        {"morebombs:thunderfist", "", "morebombs:thunderfist"},
    },
}
