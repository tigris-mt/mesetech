local pipes = minetest.get_modpath("pipeworks")

minetest.register_node("mesetech:magnet", {
    description = "Container Magnet",
    tiles = {"default_steel_block.png^technic_fine_copper_wire.png"},
    groups = {cracky = 1},
})

minetest.register_craft{
    output = "mesetech:magnet",
    recipe = {
        {"default:steel_ingot", "technic:copper_coil", "default:steel_ingot"},
        {"default:steel_ingot", "technic:red_energy_crystal", "default:steel_ingot"},
        {"default:steel_ingot", "technic:copper_coil", "default:steel_ingot"},
    },
}

minetest.register_node("mesetech:receiver", {
    description = "Active Mese Receiver",
    tiles = {"mesetech_receiver.png"},
    groups = {cracky = 1, tubedevice = 1},

    on_construct = function(pos, node)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_size("main", 4)
        meta:set_string("formspec", "size[8,5] list[current_name;main;2,0;4,1] list[current_player;main;0,1;8,4] listring[context;main] listring[current_player;main]")
    end,

    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos);
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        return ((minetest.get_item_group(stack:get_name(), "active_mese") or 0) ~= 0 and not minetest.is_protected(pos, player:get_player_name())) and stack:get_count() or 0
    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        return (not minetest.is_protected(pos, player:get_player_name())) and stack:get_count() or 0
    end,

    tube = {
        input_inventory = "main",
        connect_sides = {left=1, right=1, front=1, back=1, bottom=1},
    },

    after_place_node = pipes and pipeworks.after_place,
    after_dig_node = pipes and pipeworks.after_dig,
})

minetest.register_craft{
    output = "mesetech:receiver",
    recipe = {
        {"technic:composite_plate", "default:obsidian", "technic:composite_plate"},
        {"default:mese", "", "homedecor:plastic_sheeting"},
        {"technic:composite_plate", "default:obsidian", "technic:composite_plate"},
    },
}

minetest.register_node("mesetech:particles", {
    description = "Particles (you hacker you!)",
    tiles = {{
        name = "mesetech_particles.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 0.5,
        },
    }},
    selection_box = {type = "fixed", fixed = {0,0,0,0,0,0}},
    walkable = false,
    groups = {not_in_creative_inventory = 1},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    drop = "",
    diggable = false,
    buildable_to = true,
    can_dig = function()
        return false
    end,
    on_blast = function()
    end,
})

if minetest.get_modpath("mesecons_mvps") then
    mesecon.register_mvps_stopper("mesetech:particles")
end

local function r(d)
    local class = {
        lc = d.class:lower(),
        uc = d.class:upper(),
    }
    local _name = "mesetech:activator_" .. class.lc
    local names = {
        inactive = _name,
        active = _name .. "_active",
    }
    local desc = class.uc .. " Mese Activator L" .. d.level

    local tiles = {
        "mesetech_activator.png" .. (pipes and "^pipeworks_tube_connection_metallic.png"),
        "mesetech_activator.png",
        "mesetech_activator.png",
        "mesetech_activator.png",
        "mesetech_activator.png",
        "mesetech_activator_front.png",
    }
    for i,t in ipairs(tiles) do
        tiles[i] = tiles[i] .. "^mesetech_activator_" .. class.lc .. ".png"
    end
    local active_tiles = table.copy(tiles)
    for i,t in ipairs(active_tiles) do
        active_tiles[i] = active_tiles[i] .. "^mesetech_activator_active.png"
    end

    local function get_orientation(pos, node)
        local ndir = minetest.facedir_to_dir(node.param2)
        local dir = vector.multiply(ndir, -1)
        local ret = {}
        ret.front = vector.add(pos, dir)
        ret.back = vector.add(pos, ndir)
        ret.e1 = vector.add(ret.front, vector.new(0, 1, 0))
        ret.e2 = vector.add(ret.front, vector.new(0, 1, 0))
        ret.target = vector.add(ret.front, dir)
        local function check(pos, type, type2)
            VoxelManip():read_from_map(pos, pos)
            local n = minetest.get_node(pos).name
            return n == type or n == type2
        end
        for _,d in pairs{
            {ret.front, "air", "mesetech:particles"},
            {ret.back, "default:lava_flowing", "default:lava_source"},
            {ret.e1, "mesetech:magnet"},
            {ret.e2, "mesetech:magnet"},
            {ret.target, "mesetech:receiver"},
        } do
            if not check(d[1], d[2], d[3]) then
                return false
            end
        end
        return ret
    end

    for _,active in ipairs{true, false} do
        local cname = active and names.active or names.inactive
        minetest.register_node(cname, {
            description = desc,
            tiles = active and active_tiles or tiles,
            drop = names.inactive,
            groups = {cracky = 1, level = 2, technic_machine = 1, ["technic_" .. class.lc] = 1, not_in_creative_inventory = (active and 1 or 0), tubedevice = 1, tubedevice_receiver = 1},
            paramtype2 = "facedir",
            technic_disabled_machine_name = names.inactive,

            on_construct = function(pos)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                inv:set_size("main", 1)
                inv:set_size("tubes", 1)
                meta:set_string("formspec", "size[8,5] list[current_name;main;0,0;1,1] label[1,0;Mese] label[5.75,0;Empty Tubes] list[current_name;tubes;7,0;1,1] list[current_player;main;0,1;8,4] listring[current_player;main] listring[context;main] listring[current_player;main] listring[context;tubes] listring[current_player;main]")
                meta:set_string("infotext", desc .. " Unpowered")
                meta:set_int(class.uc .. "_EU_demand", d.demand)
            end,

            on_destruct = function(pos)
                local front = vector.multiply(minetest.facedir_to_dir(minetest.get_node(pos).param2), -1)
                VoxelManip():read_from_map(front, front)
                if minetest.get_node(front).name == "mesetech:particles" then
                    minetest.remove_node(front)
                end
            end,

            can_dig = function(pos, player)
                local meta = minetest.get_meta(pos);
                local inv = meta:get_inventory()
                return inv:is_empty("main") and inv:is_empty("tubes")
            end,

            allow_metadata_inventory_put = function(pos, listname, index, stack, player)
                local group = (minetest.get_item_group(stack:get_name(), "active_mese") or 0)
                local active_ok = group > 0 and group < d.level
                local mese = stack:get_name() == mesetech.mese
                local tube = stack:get_name() == "mesetech:tube"
                return ((listname == "main" and (active_ok or mese)) or (listname == "tubes" and tube) and not minetest.is_protected(pos, player:get_player_name())) and stack:get_count() or 0
            end,

            allow_metadata_inventory_move = function()
                return 0
            end,

            allow_metadata_inventory_take = function(pos, listname, index, stack, player)
                return (not minetest.is_protected(pos, player:get_player_name())) and stack:get_count() or 0
            end,

            tube = {
                insert_object = function(pos, node, stack, direction)
                    local meta = minetest.get_meta(pos)
                    local inv = meta:get_inventory()
                    return inv:add_item((stack:get_name() == "mesetech:tube") and "tubes" or "main", stack)
                end,
                can_insert = function(pos, node, stack, direction)
                    if direction.x ~= 0 or direction.z ~=0 or direction.y ~= -1 then
                        return false
                    end
                    local meta = minetest.get_meta(pos)
                    local inv = meta:get_inventory()
                    local group = (minetest.get_item_group(stack:get_name(), "active_mese") or 0)
                    local active_ok = group > 0 and group < d.level
                    local mese = stack:get_name() == mesetech.mese
                    local tube = stack:get_name() == "mesetech:tube"
                    if tube then
                        return inv:room_for_item("tubes", stack)
                    elseif active_ok or mese then
                        return inv:room_for_item("main", stack)
                    end
                    return false
                end,
                input_inventory = "main",
                connect_sides = {top = 1},
            },

            after_place_node = pipes and pipeworks.after_place,
            after_dig_node = pipes and pipeworks.after_dig,

            technic_run = function(pos, node)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                local function remove_item(listname)
                    local old = inv:get_list(listname)
                    old[1]:take_item()
                    inv:set_list(listname, old)
                end

                local eu = {
                    input = meta:get_int(class.uc .. "_EU_input"),
                    demand = meta:get_int(class.uc .. "_EU_demand"),
                }

                local function demand(n)
                    meta:set_int(class.uc .. "_EU_demand", n)
                end

                local orientation = get_orientation(pos, node)
                if not orientation then
                    meta:set_string("infotext", desc .. " Incorrect Setup")
                    meta:set_int("time", 0)
                    demand(0)
                    technic.swap_node(pos, names.inactive)
                    if minetest.get_node(orientation.front).game == "mesetech:particles" then
                        minetest.remove_node(orientation.front)
                    end
                    return
                end

                local powered = eu.input >= eu.demand
                if powered then
                    meta:set_int("time", meta:get_int("time") + d.speed * 100)
                end

                while true do
                    local target = minetest.get_meta(orientation.target):get_inventory()
                    local subject = inv:get_list("main")[1]:get_name()
                    local raw = subject == mesetech.mese
                    if inv:get_list("main")[1]:get_count() < 1 or (inv:get_list("tubes")[1]:get_count() < 1 and raw) or not target:room_for_item("main", ItemStack(mesetech.next[subject])) then
                        meta:set_string("infotext", desc .. " Idle")
                        meta:set_int("time", 0)
                        demand(0)
                        technic.swap_node(pos, names.inactive)
                        minetest.remove_node(orientation.front)
                        return
                    end
                    minetest.set_node(orientation.front, {name = "mesetech:particles"})
                    technic.swap_node(pos, names.active)
                    meta:set_string("infotext", desc .. " Active")
                    local isp = (minetest.get_item_group(subject, "active_mese") or 0) + 3
                    if meta:get_int("time") < isp * 100 then
                        if not powered then
                            technic.swap_node(pos, names.inactive)
                            meta:set_string("infotext", desc .. " Unpowered")
                        end
                        return
                    end
                    demand(d.demand)
                    meta:set_int("time", meta:get_int("time") - isp * 100)
                    target:add_item("main", ItemStack(mesetech.next[subject]))
                    remove_item("main")
                    if raw then
                        remove_item("tubes")
                    end
                end
            end,
        })

        technic.register_machine(class.uc, cname, technic.receiver)
    end

    minetest.register_craft{
       output = names.inactive,
       recipe = d.recipe,
    }
end

r{
    class = "lv",
    level = 1,
    demand = 7 * 1000,
    speed = 1,
    recipe = {
        {"default:mese_crystal", "default:obsidian", "default:mese_crystal"},
        {"technic:fine_copper_wire", "technic:electric_furnace", "technic:fine_copper_wire"},
        {"technic:lv_transformer", "technic:control_logic_unit", "technic:lv_transformer"},
    },
}

r{
    class = "mv",
    level = 2,
    demand = 150 * 1000,
    speed = 2,
    recipe = {
        {"technic:concrete", "technic:mv_cable", "technic:concrete"},
        {"technic:fine_silver_wire", "mesetech:activator_lv", "technic:fine_silver_wire"},
        {"technic:concrete", "technic:mv_transformer", "technic:concrete"},
    },
}

r{
    class = "hv",
    level = 3,
    demand = 700 * 1000,
    speed = 3,
    recipe = {
        {"technic:blast_resistant_concrete", "technic:hv_cable", "technic:blast_resistant_concrete"},
        {"technic:fine_gold_wire", "mesetech:activator_mv", "technic:fine_gold_wire"},
        {"technic:blast_resistant_concrete", "technic:hv_transformer", "technic:blast_resistant_concrete"},
    },
}
