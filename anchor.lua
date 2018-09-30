local cooldown = {}

local function fire(name, user, speed)
    local c = cooldown[user:get_player_name()] or 0
    if minetest.get_gametime() - c < 1 then
        return false
    end

    tigris.create_projectile(name .. "_p", {
        pos = vector.add(user:getpos(), vector.new(0, user:get_properties().eye_height or 1.625, 0)),
        velocity = vector.multiply(user:get_look_dir(), speed),
        gravity = 1,
        owner = user:get_player_name(),
        owner_object = user,
    })

    cooldown[user:get_player_name()] = minetest.get_gametime()
    return true
end

local function r(name, d)
    local function fail(self)
        -- Maybe alert the user in a better way?
        minetest.chat_send_player(self._owner, "You feel a slight tug, but nothing happens.")
    end

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
                fail(self)
            end
            return true
        end,

        on_timeout = fail,
    })

    minetest.register_craftitem(name, {
        description = d.description,
        inventory_image = d.image,

        on_use = function(itemstack, user)
            if fire(name, user, d.speed) then
                itemstack:take_item()
            end
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

-- Terrible when thrown.
r("mesetech:anchor_ammo", {
    description = "Spatial Dislocator-Anchor Ammunition",
    image = "mesetech_tube.png^mesetech_anchor_ammo.png",
    hp = 4,
    speed = 6,
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

minetest.register_craft{
    output = "mesetech:anchor_ammo 2",
    recipe = {
        {"technic:stainless_steel_ingot", "mesetech:anchor_super", "technic:stainless_steel_ingot"},
        {"technic:fine_gold_wire", "mesetech:active_mese_3", "technic:fine_gold_wire"},
    },
}

-- Energy-expensive, but speed means very fast escape.
local gun = {
    max = 600 * 1000,
    shots = 6,
    delay = 1,
}
gun.per = gun.max / gun.shots

technic.register_power_tool("mesetech:anchor_gun", gun.max)
minetest.register_tool("mesetech:anchor_gun", {
    description = "Spatial Dislocator-Anchor Gun",
    inventory_image = "mesetech_gun.png",
    range = 0,

    wear_represents = "technic_RE_charge",
    on_refill = technic.refill_RE_charge,

    on_use = function(itemstack, user)
        local meta = minetest.deserialize(itemstack:get_metadata()) or {}
        -- Handle charge.
        if not meta.charge then
            return
        end
        if meta.charge < gun.per then
            return
        end
        local removed = user:get_inventory():remove_item("main", ItemStack("mesetech:anchor_ammo"))
        if not removed or removed:get_count() < 1 then
            return
        end
        if not fire("mesetech:anchor_ammo", user, 40) then
            return
        end
        meta.charge = meta.charge - gun.per
        technic.set_RE_wear(itemstack, meta.charge, gun.max)
        itemstack:set_metadata(minetest.serialize(meta))
        return itemstack
    end,
})
minetest.register_craft{
    output = "mesetech:anchor_gun",
    recipe = {
        {"mesetech:active_mese_3", "technic:brass_ingot", "technic:brass_ingot"},
        {"", "mesetech:active_mese_3", "technic:blue_energy_crystal"},
        {"", "", "technic:stainless_steel_ingot"},
    },
}
