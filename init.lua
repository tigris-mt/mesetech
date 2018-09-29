mesetech = {
    max_level = 3,
    mese = "default:mese_crystal",
    next = {},
}

mesetech.next[mesetech.mese] = "mesetech:active_mese_1"

local function include(p)
    dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/" .. p)
end

-- Register Active Mese
for level=1,mesetech.max_level do
    if level ~= mesetech.max_level then
        mesetech.next["mesetech:active_mese_" .. level] = "mesetech:active_mese_" .. (level + 1)
    end
    minetest.register_craftitem("mesetech:active_mese_" .. level, {
        description = "Level " .. level .. " Active Mese",
        inventory_image = "mesetech_tube.png^mesetech_" .. level .. ".png",
        groups = {active_mese = level},
    })
end

minetest.register_craftitem("mesetech:tube", {
    description = "Empty Suppression Tube",
    inventory_image = "mesetech_tube.png",
})

-- The tube is where the initial crafting cost is, besides the actual mese. Don't want it too expensive, so one composite plate should work to keep the pressure.
minetest.register_craft{
    output = "mesetech:tube",
    recipe = {
        {"default:obsidian_glass", "", "default:obsidian_glass"},
        {"default:obsidian_glass", "", "default:obsidian_glass"},
        {"default:obsidian_glass", "technic:composite_plate", "default:obsidian_glass"},
    },
}

include("activator.lua")

if minetest.settings:get_bool("mesetech_enable_bombs", true) and minetest.get_modpath("morebombs") then
    include("bomb.lua")
end

if minetest.settings:get_bool("mesetech_enable_anchors", true) and minetest.get_modpath("tigris_base") then
    include("anchor.lua")
end
