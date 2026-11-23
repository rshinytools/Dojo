"""Skywalk's Cloudbreak Wind Trial and its native interaction points."""

from math import atan2, degrees, hypot


START = (59.5, 25.095, -263.8)
START_DECK_CENTER = (56.15, 25.095, -263.8)
START_DECK_SIZE = (13.3, 11.5)

# Positions are flat top centers. Separate landings keep the route off the skybridge.
LANDINGS = (
    (68.50, 26.25, -263.0, 4.80, 5.20),
    (78.25, 27.65, -267.0, 5.10, 4.80),
    (87.90, 29.25, -262.6, 5.10, 5.50),
    (97.70, 30.78, -266.7, 5.40, 5.10),
    (99.90, 31.42, -275.05, 4.80, 5.20),
    (107.80, 32.30, -268.0, 9.80, 8.40),
    (106.00, 33.80, -277.7, 4.90, 5.10),
    (114.80, 35.40, -276.0, 5.00, 5.00),
    (121.30, 36.95, -281.2, 4.90, 5.10),
    (111.80, 38.60, -285.2, 4.80, 5.00),
    (111.00, 39.90, -293.4, 4.65, 5.10),
    (120.10, 41.20, -292.0, 5.50, 5.30),
    (129.10, 42.65, -292.8, 4.60, 4.80),
    (126.00, 44.15, -301.2, 5.00, 5.10),
    (117.80, 45.60, -301.7, 4.75, 4.90),
    (120.60, 47.10, -310.0, 5.00, 5.10),
    (130.00, 49.90, -315.2, 8.20, 7.50),
    (136.40, 51.22, -309.0, 4.80, 4.90),
    (138.40, 52.65, -319.4, 4.80, 5.10),
    (128.70, 54.20, -322.5, 4.80, 5.05),
    (134.20, 55.80, -328.0, 4.80, 5.10),
    (142.40, 58.70, -335.7, 5.00, 5.60),
    (142.40, 59.50, -342.3, 4.60, 4.25),
    (146.50, 62.00, -350.1, 20.0, 10.2),
)
MILESTONES = (3, 6, 12, 17, 22, 24)
RECOVERIES = (6, 17)


def build_cloudbreak_course(parent, *, item, prop, asset, part, beam, sign, festival_lantern,
                            slate, limestone, wood, metal, neon):
    course = item(parent, "Model", "Cloudbreak Wind Trial")
    prop(course, "token", "ModelStreamingMode", 1)
    prop(course, "token", "LevelOfDetail", 4)
    platforms = item(course, "Folder", "Platforms")
    art = item(course, "Folder", "Trail markers and summit bell")
    cedar = "8A493E"
    brass = "C59E62"
    jade = "4F8383"
    chalk = "AAA0AE"

    def marker(name, point):
        return part(course, name, point, (.2, .2, .2), "FFF1D6", collide=False, transparency=1)

    def prompt(name, point, action, caption, radius):
        anchor = marker(name + " Anchor", point)
        handle = item(anchor, "ProximityPrompt", name)
        prop(handle, "string", "ActionText", action)
        prop(handle, "string", "ObjectText", caption)
        prop(handle, "float", "MaxActivationDistance", radius)
        prop(handle, "bool", "RequiresLineOfSight", False)
        return anchor

    def trim(name, point, size, tint, material, **options):
        detail = part(art, name, point, size, tint, material=material, collide=False, **options)
        prop(detail, "bool", "CastShadow", False)

    sx, sy, sz = START_DECK_CENTER
    dw, dd = START_DECK_SIZE
    part(course, "Cloudbreak start deck", (sx, sy - .37, sz), (dw, .74, dd), chalk, material=slate)
    marker("Start", START)
    for side in (-1, 1):
        edge = sz + side * 5.66
        beam(course, "Launch deck boundary rail", (49.8, sy + 1.10, edge),
             (62.45, sy + 1.10, edge), .26, jade, collide=True)
        for px in (50.3, 62.20):
            trim("Launch deck rail post", (px, sy + .61, edge), (.36, 1.26, .44), cedar, wood)
        trim("Cloudbreak cedar threshold pillar", (50.4, sy + 3.14, edge),
             (.74, 6.18, .75), cedar, wood)
        festival_lantern(art, 50.24, sy + 5.07, edge - side * .62, .52, light=False)
    beam(art, "Cloudbreak lintel timber", (50.4, sy + 6.32, sz - 6.09),
         (50.4, sy + 6.32, sz + 6.09), .58, cedar)
    beam(art, "Cloudbreak upper gold edging", (50.02, sy + 6.64, sz - 6.26),
         (50.02, sy + 6.64, sz + 6.26), .13, brass)
    sign(art, "CLOUDBREAK WIND TRIAL", 49.98, sy + 5.92, sz, 10.1, 1.23, -90, "465776")
    sign(art, "PRACTICE", 55.0, sy + 2.18, sz - 3.55, 3.55, .66, -90, jade)
    sign(art, "EXPERT", 55.0, sy + 2.18, sz + 3.55, 3.36, .66, -90, "67517A")
    prompt("PracticePrompt", (55.15, sy + 1.39, sz - 3.59), "Start practice", "Cloudbreak Wind Trial", 4.1)
    prompt("ExpertPrompt", (55.15, sy + 1.39, sz + 3.59), "Start timed Expert", "Cloudbreak Wind Trial", 4.1)
    trim("Jade launch inlay", (START[0], sy + .027, sz), (.06, 4.8, 4.8), jade,
         limestone, shape=2, roll=90)
    for side in (-1, 1):
        beam(art, "Cloudbreak launch arrow", (61.73, sy + .053, sz),
             (60.85, sy + .053, sz + side * .54), .08, brass)

    # Air streaks under the first moving slab show its sideways travel.
    for ribbon, (offset, height, tint) in enumerate(((-1.72, 29.40, "93C1C9"), (1.75, 29.02, "76A9BB"))):
        wind_x = LANDINGS[3][0] + offset
        path = tuple((wind_x + dx, height + dy, LANDINGS[3][2] + dz) for dx, dy, dz in (
            (.35, -.18, 4.58), (.02, -.04, 2.39), (-.12, .10, -.03),
            (.18, .23, -2.21), (.54, .33, -4.83),
        ))
        for a, b in zip(path, path[1:]):
            streak = beam(art, "Wind streak below the slab", a, b, .085 - .023 * ribbon, tint)
            prop(streak, "bool", "CastShadow", False)

    for i, (x, y, z, width, depth) in enumerate(LANDINGS, 1):
        summit = i == len(LANDINGS)
        thickness = .86 if summit or i in RECOVERIES else .66
        tint = "B8A5A5" if summit else "826C82" if i in RECOVERIES else ("71868C", "807E94", "908496")[i % 3]
        if i == 4:
            tint = "4F8791"
        part(platforms, f"{i:02d}", (x, y - thickness / 2, z), (width, thickness, depth), tint, material=slate)
        if i == 4:
            # This slab is translated by the server as one piece.
            continue
        for side in (-1, 1):
            trim("Gold landing edge bracket", (x + side * (width / 2 - .22), y + .02, z),
                 (.34, .085, min(1.67, depth - .42)), brass, metal)
        if i in MILESTONES:
            trim("Reached stage jade inlay", (x, y + .027, z), (.052, 1.49, 1.49), jade,
                 limestone, shape=2, roll=90)
        if not summit:
            next_x, _, next_z = LANDINGS[i][:3]
            dx, dz = next_x - x, next_z - z
            length = hypot(dx, dz)
            tip = (x + dx / length * 1.10, y + .052, z + dz / length * 1.10)
            for side in (-1, 1):
                tail = (tip[0] - dx / length * .48 + dz / length * side * .32, tip[1],
                        tip[2] - dz / length * .48 - dx / length * side * .32)
                beam(art, "Next jump direction inlay", tip, tail, .062, "E8C98B")

        if i not in RECOVERIES:
            continue
        station_x = x - width / 2 + 1.04
        station_z = z + depth / 2 - 1.05
        trim("Slate recovery lantern pedestal", (station_x, y + .58, station_z),
             (1.22, 1.16, 1.22), "706781", slate)
        trim("Recovery pedestal brass cap", (station_x, y + 1.22, station_z),
             (1.32, .16, 1.32), brass, metal)
        festival_lantern(art, station_x, y + 1.59, station_z, .62, light=False, tint="FFC57F")
        sign(art, "RECOVERY 1" if i == RECOVERIES[0] else "RECOVERY 2", station_x,
             y + 2.55, station_z + .63, 2.12, .46, 0, "665176")

    bx, by, bz = 146.5, 62.0, -352.65
    for side in (-1, 1):
        trim("Summit bell frame pillar", (bx + side * 2.69, by + 2.94, bz),
             (.61, 5.90, .62), cedar, wood)
        trim("Bell pillar slate shoe", (bx + side * 2.69, by + .30, bz),
             (1.02, .60, 1.03), chalk, slate)
        beam(art, "Bell frame gold brace", (bx + side * 2.62, by + 4.24, bz),
             (bx + side * 1.60, by + 5.8, bz), .17, brass)
    trim("Bell frame lintel", (bx, by + 5.89, bz), (6.48, .50, .68), cedar, wood)
    for lift, height, diameter, tint in ((4.30, .48, 1.41, "A87C4F"), (3.60, .92, 1.78, "BF9762"),
                                         (2.87, .62, 2.25, "9F743F"), (2.46, .27, 2.66, "CB9C60")):
        trim("Summit bronze bell band", (bx, by + lift, bz), (height, diameter, diameter), tint,
             metal, shape=2, roll=90)
    beam(art, "Bell suspension", (bx, by + 4.52, bz), (bx, by + 5.61, bz), .19, brass)
    trim("Bell hanging plaque", (bx, by + 3.47, bz + .92), (.30, .68, .046), "C9A170", metal)
    trim("Bell clapper glint", (bx, by + 2.29, bz), (.22, .20, .24), "E5BE77", neon)
    bell = prompt("BellPrompt", (bx, by + 2.17, bz + .33), "Ring the Bell", "Cloudbreak summit", 4.9)
    tone = item(bell, "Sound", "Summit Bell Chime")
    asset(tone, "SoundId", "rbxassetid://158050602")
    prop(tone, "float", "Volume", .43)
    prop(tone, "float", "PlaybackSpeed", .73)
    prop(tone, "float", "RollOffMaxDistance", 39)
    prompt("ReturnPrompt", (153.55, by + 1.46, -349.65), "Return to Skywalk", "Cloudbreak summit", 4.2)
    return course
