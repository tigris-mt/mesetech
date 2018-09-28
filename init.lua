mesetech = {}

-- Register Active Mese
for level=1,3 do
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

if minetest.get_modpath("morebombs") then
    tigris.include("bomb.lua")
end
