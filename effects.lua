minetest.register_craftitem("mesetech:infuser", {
    description = "Empty Personal Infuser",
    inventory_image = "mesetech_infuser.png",
})

minetest.register_craft{
    output = "mesetech:infuser 4",
    recipe = {
        {"homedecor:plastic_sheeting", "technic:rubber", "homedecor:plastic_sheeting"},
        {"homedecor:plastic_sheeting", "mesetech:active_mese_1", "homedecor:plastic_sheeting"},
        {"", "technic:stainless_steel_ingot", ""},
    },
}

playereffects.register_effect_type("mesetech:infused", "Infusion Limit", minetest.registered_items["mesetech:infuser"].inventory_image, {"mesetech:infused"}, function() end, function() end)

function mesetech.register_infuser(name, d)
    minetest.register_craftitem(name, {
        description = d.description,
        inventory_image = "mesetech_infuser_filled.png^(mesetech_infuser_filling.png^[colorize:" .. d.color .. ":255)",
        on_use = function(itemstack, user)
            if playereffects.has_effect_type(user:get_player_name(), "mesetech:infused") then
                return itemstack
            end
            if d.apply(user) then
                playereffects.apply_effect_type("mesetech:infused", 15, user)
                itemstack:take_item()
            end
            return itemstack
        end,
    })
end

mesetech.register_infuser("mesetech:infuser_antigravity", {
    description = "Antigravity Infuser",
    color = "#F00",
    apply = function(user)
        playereffects.apply_effect_type("mesetech:antigravity", math.random(0,1) + 5, user)
        return true
    end,
})

playereffects.register_effect_type("mesetech:antigravity", "Antigravity", minetest.registered_items["mesetech:infuser_antigravity"].inventory_image, {"mesetech:antigravity"},
    function(player)
        player_monoids.gravity:add_change(player, 0.2, "mesetech:antigravity")
    end,
    function(effect, player)
        player_monoids.gravity:del_change(player, "mesetech:antigravity")
    end)

minetest.register_craft{
    output = "mesetech:infuser_antigravity",
    recipe = {
        {"mesetech:infuser"},
        {"mesetech:active_mese_1"},
        {"dye:red"},
    },
}

mesetech.register_infuser("mesetech:infuser_hp", {
    description = "Vitality Infuser",
    color = "#00F",
    apply = function(user)
        playereffects.apply_effect_type("mesetech:regen", math.random(0, 1) + 3, user)
        return true
    end,
})

playereffects.register_effect_type("mesetech:regen", "Regeneration", "heart.png", {"mesetech:regen"},
    function(player)
        player:set_hp(player:get_hp() + 2)
    end,
    nil, nil, nil, 1)

minetest.register_craft{
    output = "mesetech:infuser_hp",
    recipe = {
        {"mesetech:infuser"},
        {"mesetech:active_mese_2"},
        {"dye:blue"},
    },
}
