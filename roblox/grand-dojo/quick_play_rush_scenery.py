"""A compact Lantern Rush start counter for the lantern arcade."""

from math import cos, radians, sin


def build_quick_play_rush(parent, location, *, item, part, prop, sign, wood, metal, slate, neon, yaw=0):
    """Build a three-lantern signpost. Its art never intersects player navigation."""
    x, floor, z = location
    cosine, sine = cos(radians(yaw)), sin(radians(yaw))
    model = item(parent, "Model", "rush")
    prop(model, "token", "ModelStreamingMode", 1)
    cedar, brass, indigo = "813F30", "BD824B", "454465"

    def position(across, lift, ahead):
        return x + across * cosine + ahead * sine, floor + lift, z - across * sine + ahead * cosine

    def piece(name, across, lift, ahead, size, tint, material, **options):
        node = part(model, name, position(across, lift, ahead), size, tint,
                    material=material, yaw=yaw, collide=False, **options)
        prop(node, "bool", "CastShadow", False)
        return node

    piece("Cedar lintel", 0, 3.63, 0, (4.58, .44, .56), cedar, wood)
    piece("Indigo coping", 0, 3.91, .02, (4.76, .17, .81), indigo, wood)
    piece("Brass face trim", 0, 3.74, .30, (4.46, .08, .08), brass, metal)
    for side in (-1, 1):
        across = side * 1.97
        piece("Cedar support", across, 1.87, 0, (.36, 3.49, .44), cedar, wood)
        piece("Slate shoe", across, .18, 0, (.69, .36, .73), "716977", slate)
        piece("Brass post cuff", across, .48, 0, (.5, .15, .55), brass, metal)
    for across, tint in ((-1.13, "FFB976"), (0, "6BF1CA"), (1.13, "FFB976")):
        piece("Lantern suspension", across, 3.30, .13, (.09, .35, .09), brass, metal)
        piece("Lantern shade", across, 2.87, .13, (.52, .59, .52), tint, neon, shape=0)
        for height in (2.58, 3.15):
            piece("Lantern collar", across, height, .13, (.42, .085, .42), brass, metal)
    sign(model, "LANTERN RUSH", *position(0, 1.94, .25), 3.55, .77,
         yaw=yaw, tint="5B384B", wayfinding=True)

    anchor = piece("Start", 0, 1.63, .79, (.20, .20, .20), brass, metal, transparency=1)
    prompt = item(anchor, "ProximityPrompt", "QuickPlayPrompt")
    prop(prompt, "string", "ActionText", "Start lane race")
    prop(prompt, "string", "ObjectText", "Lantern Rush")
    prop(prompt, "float", "MaxActivationDistance", 6)
    prop(prompt, "bool", "RequiresLineOfSight", False)
    return model
