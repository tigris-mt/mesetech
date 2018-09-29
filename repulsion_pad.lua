minetest.register_node("mesetech:repulsion_pad", {
    description = "Oscillating Repulsion Pad",
    tiles = {"mesetech_repulsion_pad.png"},
    groups = {cracky = 1, oddly_breakable_by_hand = 3, fall_damage_add_percent = -100, bouncy = 120},
})

minetest.register_node("mesetech:repulsion_pad_off", {
    description = "Active Repulsion Pad (you hacker you!)",
    tiles = {"mesetech_repulsion_pad_off.png"},
    drop = "mesetech:repulsion_pad",
    groups = {oddly_breakable_by_hand = 1, fall_damage_add_percent = -100, bouncy = 40, not_in_creative_inventory = 1},
})

minetest.register_abm{
    nodenames = {"mesetech:repulsion_pad"},
    chance = 2,
    interval = 5,
    action = function(pos)
        minetest.swap_node(pos, {name = "mesetech:repulsion_pad_off"})
    end,
}

minetest.register_abm{
    nodenames = {"mesetech:repulsion_pad_off"},
    chance = 2,
    interval = 1,
    action = function(pos)
        minetest.swap_node(pos, {name = "mesetech:repulsion_pad"})
    end,
}

minetest.register_craft{
    output = "mesetech:repulsion_pad",
    recipe = {
        {"technic:fine_gold_wire", "technic:fine_silver_wire", "technic:fine_gold_wire"},
        {"technic:carbon_steel_ingot", "mesetech:active_mese_2", "technic:carbon_steel_ingot"},
        {"technic:carbon_steel_ingot", "mesetech:active_mese_2", "technic:carbon_steel_ingot"},
    },
}
