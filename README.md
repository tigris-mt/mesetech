# MeseTech

## Dependencies
* Default (Minetest Game) for Mese
* [Technic](https://github.com/minetest-mods/technic) for Technology

## Optional Dependencies
* [Pipeworks](https://github.com/minetest-mods/pipeworks) for Tubes
* [Tigris Base](https://github.com/tigris-mt/tigris_base) for Projectiles
* [MoreBombs](https://github.com/tigris-mt/morebombs) for Explosions

## Settings
* `mesetech_enable_bombs = <bool>`
* `mesetech_enable_anchors = <bool>`

## Activator Setup
* To the back of the activator must be lava.
* To the front of the activator must be empty space.
* Above and below the empty space must be Container Magnets.
* Two nodes to the front of the activator must be an Active Mese Receiver.

Upon insertion of mese (either crystals or active mese level 1-2), the activator and magnets will begin particle manifestation. With enough technic power, the activator will begin enhancing the mese contained within and passing the result to the receiver.

## Anchors
To use the Spatial Dislocator-Anchors, simply throw them. You will be teleported to the landing site. Beware! You will lose a small amount of health.
