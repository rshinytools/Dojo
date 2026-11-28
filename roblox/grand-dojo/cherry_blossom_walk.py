"""Garden Lookout's blossom path and sunset terrace."""

from math import cos, radians, sin


def build_cherry_blossom_walk(parent, *, item, prop, part, beam, sign, route, lantern,
                             tree, guard, source, cedar, slate, stone):
    walk = item(parent, "Model", "Cherry Blossom Walk")
    prop(walk, "token", "ModelStreamingMode", 1)
    floor = 2.42
    upper = 6.10

    route(walk, "Garden Lookout connection", ((-77.3, floor, 45.85), (-84.9, floor, 45.85)),
          4.2, "BA9991", surface=stone, railings=False, join_overlap=.13)
    part(walk, "Blossom entry landing", (-85.2, floor-.27, 49.2), (4.2, .54, 11.2),
         "BA9991", material=stone)
    route(walk, "Step-free blossom path", ((-85.8, floor, 46.7), (-98.1, upper, 46.7)),
          4.8, "B99791", surface=stone, railings=False, join_overlap=.22)
    for index in range(10):
        top = floor + (upper-floor)*(index+1)/10
        part(walk, "Optional blossom stair", (-87.65-index*1.16, top-.24, 52.0),
             (1.27, .48, 4.1), "AA8990", material=stone)
        part(walk, "Warm stone stair nose", (-87.1-index*1.16, top-.072, 52.0),
             (.10, .12, 4.04), "CFADA2", material=stone, collide=False)

    part(walk, "Sunset terrace", (-103.45, upper-.26, 49.65), (11.95, .52, 11.3),
         "BC9C94", material=stone)
    for x, z, width, depth, top in ((-84.95, 49.25, 3.7, 10.3, floor-.27),
                                       (-91.6, 46.7, 3.3, 4.4, 3.40),
                                       (-92.5, 52.0, 3.8, 3.7, 3.50),
                                       (-103.45, 49.65, 11.55, 10.9, upper-.42)):
        part(walk, "Terrace dressed stone base", (x, (top-.55)/2, z),
             (width, top+.55, depth), "786776", material=slate)

    def rail(a, b):
        guard(walk, "Blossom walk safety rail", a, b, height=2.45)
        for height in (.43, 1.13):
            beam(walk, "Cedar rail", (a[0], a[1]+height, a[2]),
                 (b[0], b[1]+height, b[2]), .19, "8D503E")
        for index in range(3):
            t = index / 2
            x, y, z = (p+(q-p)*t for p, q in zip(a, b))
            part(walk, "Cedar newel", (x, y+.61, z), (.34, 1.22, .34),
                 "784438", material=cedar, collide=False)
            part(walk, "Newel cap", (x, y+1.25, z), (.43, .12, .43),
                 "AD7651", material=cedar, collide=False)

    for a, b in (
        ((-81, floor, 44.0), (-86.85, floor, 44.0)),
        ((-81, floor, 47.85), (-83.2, floor, 47.85)),
        ((-83.35, floor, 47.85), (-83.35, floor, 54.55)),
        ((-83.35, floor, 54.55), (-87.0, floor, 54.55)),
        ((-86.8, floor, 44.35), (-98.0, upper, 44.35)),
        ((-86.8, floor, 49.0), (-98.0, upper, 49.0)),
        ((-87.0, floor, 54.0), (-98.0, upper, 54.0)),
        ((-98.0, upper, 44.15), (-103.5, upper, 44.15)),
        ((-103.5, upper, 44.15), (-109.2, upper, 44.15)),
        ((-109.2, upper, 44.15), (-109.2, upper, 55.0)),
        ((-109.2, upper, 55.0), (-103.5, upper, 55.0)),
        ((-103.5, upper, 55.0), (-98.0, upper, 55.0)),
    ):
        rail(a, b)

    # Keep scenery away from the route and frame the city from the seat.
    for x, z, base, scale, yaw, height in (
        (-83.5, 40.4, .2, 1.16, 70, .83),
        (-91.2, 39.2, .0, 1.65, 28, .75),
        (-93.2, 57.5, .0, 1.45, 140, .88),
        (-106.9, 57.6, 2.5, 1.30, 208, 1.10),
        (-111.4, 47.5, 3.8, 1.24, 250, 1.22),
        (-106.6, 38.8, .0, 1.25, 315, .92),
    ):
        part(walk, "Planted blossom shelf", (x, base-.45, z), (3.8, .9, 3.8),
             "877480", material=slate)
        tree(walk, x, z, True, scale, yaw, base, height_scale=height, compact=True)

    seasonal = item(walk, "Folder", "Seasonal blossom clusters")
    for x, y, z, width, tint in (
        (-83.8, 6.6, 42.0, 3.9, "E08BAC"), (-86.0, 7.4, 41.6, 4.0, "ECAAAC"),
        (-91.7, 7.3, 39.6, 4.6, "EC9DBB"), (-94.2, 7.58, 39.1, 3.2, "D77CA6"),
        (-94.2, 7.95, 55.9, 4.1, "EA9CB6"), (-96.0, 8.90, 56.1, 4.0, "E588B0"),
        (-109.3, 12.0, 56.1, 4.7, "E99CBE"), (-109.9, 15.1, 47.0, 3.5, "E798B6"),
    ):
        cluster = part(seasonal, "Seasonal blossom", (x, y, z), (width, width*.48, width*.82),
                       tint, shape=0, collide=False, transparency=1)
        prop(cluster, "bool", "CastShadow", False)

    for x, y, z in ((-81.1, floor, 44.0), (-86.7, floor, 54.3), (-92.5, 4.4, 44.35),
                    (-97.7, upper, 54.25), (-102.3, upper, 44.25), (-108.2, upper, 54.55)):
        part(walk, "Slate lantern plinth", (x, y+.34, z), (.72, .68, .72), "83717B",
             material=slate, collide=False)
        lantern(walk, x, y+1.06, z, .48, light=False)

    x, z = -81.8, 48.25
    part(walk, "Blossom plaque post", (x, floor+1.22, z), (.30, 2.44, .30), "764139",
         material=cedar, collide=False)
    sign(walk, "CHERRY BLOSSOM WALK", x, floor+2.46, z, 4.65, .89,
         yaw=68, tint="843D4E", wayfinding=True)

    # Face northeast toward the city and sky saddle, with space to walk behind.
    x, z = -103.6, 48.8
    yaw = -42
    seat = part(walk, "Sunset Bench", (x, upper+.67, z), (4.20, .23, 1.20), "975A43",
                material=cedar, yaw=yaw, class_name="Seat")
    angle = radians(yaw)
    for offset in (-1.48, 1.48):
        bx, bz = x+offset*cos(angle), z-offset*sin(angle)
        part(walk, "Bench leg", (bx, upper+.32, bz), (.26, .65, 1.02), "754537",
             material=cedar, yaw=yaw)
    for height in (1.10, 1.39):
        part(walk, "Bench back", (x+.62*sin(angle), upper+height, z+.62*cos(angle)),
             (4.20, .23, .15), "A56549", material=cedar, yaw=yaw)
    prompt = item(seat, "ProximityPrompt", "SitAtSunset")
    prop(prompt, "string", "ActionText", "Sit")
    prop(prompt, "string", "ObjectText", "Sunset Bench")
    prop(prompt, "float", "MaxActivationDistance", 6)
    prop(prompt, "bool", "RequiresLineOfSight", False)
    script = item(seat, "Script", "SunsetBench")
    prop(script, "ProtectedString", "Source", source)
