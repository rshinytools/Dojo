"""Juniper's bronze practice bell outside the Grand Dojo arena."""


def build_quick_play_bell(parent, location, *, item, part, prop, sign, wood, metal, slate):
    """Place a compact station facing the plaza, with no collision or added lights."""
    x, floor, z = location
    model = item(parent, "Model", "bell")
    prop(model, "token", "ModelStreamingMode", 1)

    cedar, bronze, enamel = "78403A", "BD8645", "533B46"

    def piece(name, dx, height, dz, size, tint, material, **options):
        node = part(model, name, (x + dx, floor + height, z + dz), size,
                    tint, material=material, collide=False, **options)
        prop(node, "bool", "CastShadow", False)
        return node

    piece("Slate base", 0, .18, 0, (4.50, .36, 1.78), "776672", slate)
    piece("Bronze base trim", 0, .40, 0, (4.22, .10, 1.52), bronze, metal)
    for side in (-1, 1):
        dx = side * 1.80
        piece("Bell mount cedar upright", dx, 2.10, 0, (.40, 3.44, .50), cedar, wood)
        piece("Bell mount bronze shoe", dx, .51, 0, (.54, .26, .62), bronze, metal)
        piece("Bell mount bronze clasp", dx, 3.14, 0, (.48, .14, .55), bronze, metal)
    piece("Curved mount crossbeam", 0, 3.87, 0, (4.45, .29, .74), cedar, wood)
    piece("Crossbeam golden edge", 0, 4.03, 0, (4.56, .09, .77), bronze, metal)
    piece("Bell hanger", 0, 3.35, 0, (.21, .84, .20), bronze, metal)
    # Roblox cylinders extend along local X, so turn that axis upward.
    piece("Bronze bell crown", 0, 2.97, 0, (.30, 1.22, 1.22), "D49D51", metal, shape=2, roll=90)
    piece("Bronze bell body", 0, 2.51, 0, (.67, 1.53, 1.53), bronze, metal, shape=2, roll=90)
    piece("Bronze bell opening", 0, 2.15, 0, (.16, 1.87, 1.87), "E0AD56", metal, shape=2, roll=90)
    piece("Bell clapper", 0, 2.01, 0, (.21, .21, .21), "64505A", metal, shape=0)
    sign(model, "JUNIPER’S BELL", x, floor + 1.33, z + .48, 3.49, .62,
         tint=enamel, wayfinding=True)

    anchor = piece("Start", 0, 1.99, .92, (.20, .20, .20), bronze, metal, transparency=1)
    prompt = item(anchor, "ProximityPrompt", "QuickPlayPrompt")
    prop(prompt, "string", "ActionText", "Play timing drill")
    prop(prompt, "string", "ObjectText", "Juniper’s Bell")
    prop(prompt, "float", "MaxActivationDistance", 6)
    prop(prompt, "bool", "RequiresLineOfSight", False)
    return model
