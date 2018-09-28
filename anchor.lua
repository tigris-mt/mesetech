local cooldown = {}

local function r(name, d)
    tigris.register_projectile(name .. "_p", {
        texture = d.image,
        load_map = true,
        on_node_hit = function(self, pos)
            if self._owner and self._owner_object and self._last_passable then
                if minetest.get_player_by_name(self._owner) then
                    self._owner_object:setpos(self._last_passable)
                    self._owner_object:set_hp(self._owner_object:get_hp() - d.hp)
                end
            else
                -- Maybe alert the user in a better way?
                minetest.chat_send_player(self._owner, "You feel a slight tug, but nothing happens.")
            end
            return true
        end,
    })

    minetest.register_craftitem(name, {
        description = d.description,
        inventory_image = d.image,

        on_use = function(itemstack, user)
            local c = cooldown[user:get_player_name()] or 0
            if minetest.get_gametime() - c < 1 then
                return itemstack
            end

            tigris.create_projectile(name .. "_p", {
                pos = vector.add(user:getpos(), vector.new(0, user:get_properties().eye_height or 1.625, 0)),
                velocity = vector.multiply(user:get_look_dir(), d.speed),
                gravity = 1,
                owner = user:get_player_name(),
                owner_object = user,
            })

            cooldown[user:get_player_name()] = minetest.get_gametime()
            itemstack:take_item()
            return itemstack
        end,
    })
end

r("mesetech:anchor", {
    description = "Spatial Dislocator-Anchor",
    image = "mesetech_tube.png^mesetech_anchor.png",
    hp = 3,
    speed = 12,
})

r("mesetech:anchor_super", {
    description = "Super Spatial Dislocator-Anchor",
    image = "mesetech_tube.png^mesetech_anchor_super.png",
    hp = 4,
    speed = 20,
})

minetest.register_craft{
    output = "mesetech:anchor 3",
    recipe = {
        {"homedecor:plastic_sheeting", "mesetech:active_mese_1", "homedecor:plastic_sheeting"},
        {"homedecor:plastic_sheeting", "mesetech:active_mese_1", "homedecor:plastic_sheeting"},
        {"homedecor:plastic_sheeting", "mesetech:active_mese_1", "homedecor:plastic_sheeting"},
    },
}

minetest.register_craft{
    output = "mesetech:anchor_super 2",
    recipe = {
        {"technic:fine_silver_wire", "mesetech:anchor", "technic:fine_silver_wire"},
        {"technic:fine_silver_wire", "mesetech:active_mese_2", "technic:fine_silver_wire"},
    },
}
