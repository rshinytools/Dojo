"""Fighter Select board at the east edge of Festival Plaza."""

from math import cos, radians, sin


def build_fighter_select_station(city, plaza, *, item, prop, part, sign, cedar, slate, metal):
    x, z, yaw = 9.65, 54.3, -58
    angle = radians(yaw)
    c, s = cos(angle), sin(angle)
    kiosk = item(plaza, "Model", "Fighter Select Board")
    prop(kiosk, "token", "ModelStreamingMode", 1)

    def point(across, y, front=0):
        return x + c * across + s * front, y, z - s * across + c * front

    def piece(name, across, y, front, size, tint, material=None, collide=False):
        properties = {"yaw": yaw, "collide": collide}
        if material is not None:
            properties["material"] = material
        return part(kiosk, name, point(across, y, front), size, tint, **properties)

    for side in (-1, 1):
        across = side * 1.98
        piece("Basalt pillar foot", across, .32, 0, (.65, .35, .70), "7C6B77", slate, True)
        piece("Fighter board upright", across, 1.51, 0, (.31, 2.10, .38), "754931", cedar, True)
        piece("Fighter board clasp", across, 2.01, .205, (.31, .15, .055), "CA9B58", metal)
    piece("Lacquered fighter plaque", 0, 2.21, 0, (3.85, 1.41, .37), "334D4E", cedar, True)
    for level in (1.52, 2.91):
        piece("Brass plaque edging", 0, level, .035, (4.17, .104, .50), "C49B61", metal)
    piece("Cedar ridge cap", 0, 3.01, 0, (4.32, .145, .52), "81543B", cedar)

    lettering = sign(kiosk, "FIGHTER SELECT", *point(0, 2.42, .02), 3.62, .55, yaw,
                     "334D4E", face_only=True, single_line=True)
    prop(lettering.find("Item"), "float", "MaxDistance", 68)
    for across, tint in zip((-1.02, -.34, .34, 1.02), ("B99153", "74A9B9", "839A71", "BC7055")):
        piece("Fighter marker", across, 1.93, .194, (.37, .35, .054), tint, metal)

    anchor = part(city, "Fighter Select Station", point(0, 1.82, .55), (.4, .4, .4),
                  "FFFFFF", collide=False, transparency=1)
    prompt = item(anchor, "ProximityPrompt", "SwitchFighterPrompt")
    prop(prompt, "string", "ActionText", "Switch fighter")
    prop(prompt, "string", "ObjectText", "Fighter Select")
    prop(prompt, "float", "MaxActivationDistance", 8)
    prop(prompt, "bool", "RequiresLineOfSight", False)
