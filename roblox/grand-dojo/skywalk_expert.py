"""Native geometry for the optional Wind-bridge expert course."""

from math import atan2, cos, degrees, hypot, sin


COURTYARD_Y = 25.095
COURSE_POINTS = (
    (60, COURTYARD_Y, -263.8),
    (70, 27.05, -263.8),
    (79.5, 29.05, -269.8),
    (90, 31.06, -264.7),
    (96, 31.06, -277),
    (86, 29.35, -283.5),
    (75, 27.62, -279.6),
    (60, COURTYARD_Y, -281.2),
)
BRIDGE_WIDTHS = (4.2, 3.55, 2.95, 2.7, 2.8, 3.15, 3.7)
SLATE, WOOD, NEON, FABRIC = 800, 528, 288, 1312
INDIGO, VIOLET, GOLD = "505B85", "665E82", "D8AC63"
DECK = "A58880"
LANDING_EDGE = 62.8
CHECKPOINT_RADIUS = 3.15
NET_Y = COURTYARD_Y - 5.8
NET_COLOR = "66859A"


def bridge_endpoints(index, a, b):
    """Keep the sloped deck flush with each flat, circular checkpoint."""
    dx, dz = b[0] - a[0], b[2] - a[2]
    length = hypot(dx, dz)
    ux, uz = dx / length, dz / length
    inset_a = (LANDING_EDGE - a[0]) / ux if index == 1 else CHECKPOINT_RADIUS
    inset_b = (b[0] - LANDING_EDGE) / ux if index == len(BRIDGE_WIDTHS) else CHECKPOINT_RADIUS
    return ((a[0] + inset_a * ux, a[1], a[2] + inset_a * uz),
            (b[0] - inset_b * ux, b[1], b[2] - inset_b * uz))


def build_skywalk_expert(parent, *, item, part, prop, sign, beam):
    """Attach the Wind-bridge spur to the east side of the Skywalk courtyard."""
    model = item(parent, "Model", "Skywalk Expert Course")
    prop(model, "token", "ModelStreamingMode", 1)
    prop(model, "token", "LevelOfDetail", 4)
    checkpoints = item(model, "Folder", "Checkpoints")
    recovery = item(model, "Folder", "Recovery Stations")

    def marker(parent, label, xyz):
        return part(parent, label, xyz, (.2, .2, .2), GOLD, collide=False, transparency=1)

    def prompt(parent, name, xyz, action, object_text, radius):
        anchor = marker(parent, name + " Anchor", xyz)
        handle = item(anchor, "ProximityPrompt", name)
        prop(handle, "string", "ActionText", action)
        prop(handle, "string", "ObjectText", object_text)
        prop(handle, "float", "MaxActivationDistance", radius)
        prop(handle, "bool", "RequiresLineOfSight", False)

    def span(label, a, b, width, thickness, tint, *, material, casts_shadow=True):
        dx, dy, dz = (v - u for u, v in zip(a, b))
        ground = hypot(dx, dz)
        slope = atan2(dy, ground)
        center = (
            (a[0] + b[0]) / 2 + dx / ground * sin(slope) * thickness / 2,
            (a[1] + b[1]) / 2 - cos(slope) * thickness / 2,
            (a[2] + b[2]) / 2 + dz / ground * sin(slope) * thickness / 2,
        )
        piece = part(model, label, center, (width, thickness, hypot(ground, dy) + .82),
                     tint, yaw=degrees(atan2(dx, dz)), pitch=-degrees(slope),
                     material=material)
        if not casts_shadow:
            prop(piece, "bool", "CastShadow", False)

    def guard(a, b):
        for lift in (.56, 1.35):
            beam(model, "Cedar guardrail", (a[0], a[1] + lift, a[2]),
                 (b[0], b[1] + lift, b[2]), .22, INDIGO, collide=True)
        for x, y, z in (a, b):
            part(model, "Cedar rail post", (x, y + .69, z), (.36, 1.38, .36),
                 INDIGO, material=WOOD, collide=False)
            part(model, "Rail post cap", (x, y + 1.41, z), (.44, .14, .44),
                 GOLD, material=SLATE, collide=False)

    def landing(name, center_z, rail_gap):
        top = COURTYARD_Y
        part(model, name, (56.15, top - .33, center_z), (13.3, .66, 11.5),
             DECK, material=SLATE)
        for side in (-1, 1):
            near_z = center_z + side * 5.50
            guard((49.65, top, near_z), (62.65, top, near_z))
            guard((62.65, top, center_z + side * rail_gap), (62.65, top, near_z))
        for z in (center_z - 4.3, center_z + 4.3):
            part(model, "Slate landing pier", (57.5, top - 9.22, z), (2.45, 17.78, 2.55),
                 "857A8E", material=SLATE, collide=False)
            part(model, "Landing bearing", (57.5, top - .82, z), (3.16, .43, 3.06),
                 "B1A2AD", material=SLATE, collide=False)

    landing("Trial start landing", COURSE_POINTS[0][2], 2.58)
    landing("Courtyard return landing", COURSE_POINTS[-1][2], 2.72)
    marker(model, "Start", COURSE_POINTS[0])
    for z in (-268.95, -258.65):
        part(model, "Trial gate cedar post", (50.2, COURTYARD_Y + 3.60, z),
             (.39, 7.20, .39), INDIGO, material=WOOD, collide=False)
    sign(model, "WIND-BRIDGE TRIAL", 50.2, COURTYARD_Y + 6.85, -263.8, 10.25, 1.12,
         -90, INDIGO)
    sign(model, "STAY ON THE BEAMS · 24 SECONDS", 50.2, COURTYARD_Y + 5.86, -263.8,
         9.95, .64, -90, VIOLET)
    sign(model, "PRACTICE", 57.50, COURTYARD_Y + 2.52, -267.40, 3.8, .66, -90, INDIGO)
    sign(model, "EXPERT", 57.50, COURTYARD_Y + 2.52, -260.2, 3.7, .66, -90, VIOLET)
    prompt(model, "PracticePrompt", (56.4, COURTYARD_Y + 1.44, -267.4),
           "Start practice", "Wind-bridge trial", 4.8)
    prompt(model, "ExpertPrompt", (56.4, COURTYARD_Y + 1.44, -260.2),
           "Start expert", "24-second Wind-bridge trial", 4.8)
    for tip in (-.48, .48):
        beam(model, "Wind course direction inlay", (61.31, COURTYARD_Y + .04, -263.8),
             (60.48, COURTYARD_Y + .04, -263.8 + tip), .078, GOLD)
    for z in (-285.75, -276.65):
        part(model, "Courtyard gate cedar post", (50.2, COURTYARD_Y + 2.95, z),
             (.32, 5.9, .32), INDIGO, material=WOOD, collide=False)
    sign(model, "SKYWALK COURTYARD", 50.2, COURTYARD_Y + 5.8, -281.2,
         8.4, .97, 90, INDIGO)

    for index, (a, b, width) in enumerate(zip(COURSE_POINTS, COURSE_POINTS[1:], BRIDGE_WIDTHS), 1):
        ramp_a, ramp_b = bridge_endpoints(index, a, b)
        span("Wind-bridge timber beam", ramp_a, ramp_b, width, .51,
             ("A88A83", "A58C8A", "A39699")[(index - 1) % 3], material=WOOD)
        net_level = NET_Y - .014 * index
        lower_a = (a[0], net_level, a[2])
        lower_b = (b[0], net_level, b[2])
        span("Woven catch net", lower_a, lower_b, 8.6, .22, NET_COLOR,
             material=FABRIC, casts_shadow=False)
        dx, dz = b[0] - a[0], b[2] - a[2]
        length = hypot(dx, dz)
        for t in (.18, .36, .54, .72, .9):
            x, z = a[0] + t * dx, a[2] + t * dz
            offset_x, offset_z = dz / length * 3.93, -dx / length * 3.93
            beam(model, "Catch net cross tie",
                 (x - offset_x, net_level + .027, z - offset_z),
                 (x + offset_x, net_level + .027, z + offset_z), .066, "A4B4BB")
        for side in (-1, 1):
            offset_x, offset_z = side * dz / length, -side * dx / length
            for t in (.25, .75):
                x = ramp_a[0] + t * (ramp_b[0] - ramp_a[0]) + offset_x * (width + .16) / 2
                z = ramp_a[2] + t * (ramp_b[2] - ramp_a[2]) + offset_z * (width + .16) / 2
                y = ramp_a[1] + t * (ramp_b[1] - ramp_a[1])
                part(model, "Brass beam binding", (x, y - .12, z), (.22, .24, .22),
                     GOLD, material=SLATE, collide=False)

    for index, (x, y, z) in enumerate(COURSE_POINTS[1:], 1):
        marker(checkpoints, str(index), (x, y, z))
        if index == len(COURSE_POINTS) - 1:
            continue
        diameter = CHECKPOINT_RADIUS * 2
        part(model, "Slate checkpoint landing", (x, y - .36, z), (.72, diameter, diameter),
             "9E8E9F", material=SLATE, shape=2, roll=90)
        part(model, "Brass checkpoint inlay", (x, y + .035, z), (2.08, .07, 2.08),
             GOLD, material=NEON, collide=False)
        part(model, "Rock needle support", (x, y - 9.27, z), (2.74, 17.83, 2.74),
             "897D90", yaw=index * 21, material=SLATE, collide=False)
        part(model, "Slate checkpoint corbel", (x, y - .79, z), (4.1, .65, 4.1),
             "AEA0AF", yaw=index * 11, material=SLATE, collide=False)
        prev_x, _, prev_z = COURSE_POINTS[index - 1]
        in_dx, in_dz = x - prev_x, z - prev_z
        norm = hypot(in_dx, in_dz)
        px, pz = x + in_dz / norm * 2.28, z - in_dx / norm * 2.28
        part(model, "Numbered waypost", (px, y + .9, pz), (.22, 1.77, .22),
             INDIGO, material=WOOD, collide=False)
        sign(model, f"{index:02d}", px, y + 1.88, pz, 1.16, .66,
             degrees(atan2(-in_dx, -in_dz)), INDIGO)
        part(model, "Catch net landing", (x, NET_Y - .115, z), (9.3, .23, 9.3),
             "778D9D", material=FABRIC)
        prompt(recovery, "RecoveryPrompt", (x, NET_Y + 1.15, z),
               "Return to start", "Caught by the net", 6)

    for index in (0, len(COURSE_POINTS) - 1):
        x, _, z = COURSE_POINTS[index]
        part(model, "Catch net end landing", (x, NET_Y - .115, z), (8.7, .23, 9.1),
             "778D9D", material=FABRIC)
        prompt(recovery, "RecoveryPrompt", (x, NET_Y + 1.15, z),
               "Return to start", "Caught by the net", 6)
