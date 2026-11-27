"""Three compact activity stations beside existing routes."""

from quick_play_bell_scenery import build_quick_play_bell
from quick_play_rush_scenery import build_quick_play_rush


def build_quick_play(city, *, item, part, prop, sign, wood, slate, metal, neon):
    stations = item(city, "Folder", "Festival Quick Play")
    shared = dict(item=item, part=part, prop=prop, sign=sign, wood=wood, metal=metal, slate=slate)
    build_quick_play_bell(stations, (28, .15, 33), **shared)
    build_quick_play_rush(stations, (-26.8, .15, 44.8), **shared, neon=neon, yaw=16)

    x, y, z = 58.65, 8.85, -51.62
    rescue = item(stations, "Model", "rescue")
    prop(rescue, "token", "ModelStreamingMode", 1)

    def piece(name, dx, dy, dz, size, color, material, **options):
        node = part(rescue, name, (x + dx, y + dy, z + dz), size, color,
                    material=material, collide=False, **options)
        prop(node, "bool", "CastShadow", False)
        return node

    for side in (-1, 1):
        piece("Dock slate foot", side * 1.47, .18, 0, (.65, .36, .65), "777281", slate)
        piece("Dock cedar pier", side * 1.47, 1.10, 0, (.26, 1.76, .38), "64494C", wood)
    piece("Teal rescue counter", 0, 1.91, 0, (3.68, .26, .98), "315B61", wood)
    piece("Bronze counter edge", 0, 2.07, .01, (3.74, .09, 1.03), "C29561", metal)
    piece("Lantern perch", .97, 2.24, .15, (.55, .30, .45), "775455", wood)
    piece("Rescued lantern", .97, 2.59, .15, (.47, .47, .47), "FFBD75", neon, shape=0)
    for row, height in enumerate((2.20, 2.33, 2.46)):
        piece("Painted wave", -.57 + row * .10, height, .22, (1.11, .08, .18), "60999E", metal, roll=-8)
    sign(rescue, "REEDFALL RESCUE", x, y + 1.56, z + .29, 3.53, .58,
         tint="315B61", wayfinding=True)
    anchor = piece("Start", 0, 1.55, .80, (.20, .20, .20), "C29561", metal, transparency=1)
    prompt = item(anchor, "ProximityPrompt", "QuickPlayPrompt")
    prop(prompt, "string", "ActionText", "Play lantern rescue")
    prop(prompt, "string", "ObjectText", "Reedfall Rescue")
    prop(prompt, "float", "MaxActivationDistance", 6)
    prop(prompt, "bool", "RequiresLineOfSight", False)
