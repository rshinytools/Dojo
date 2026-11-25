"""Native district courts, signed approaches and stable Bot Spar entry markers."""

from math import atan2, cos, degrees, hypot, pi, sin


CINDER_CENTER = (226.0, 16.15, -185.40)
CLOUD_TOP_CENTER = (54.5, 28.95, -316.70)
GALLEON_CENTER = (293.0, 6.34, 63.10)
GILT = "D0A468"
BONE = "EFE1BF"
PLAYER_STAND_HEIGHT = 2.1326  # Settled root height of the shared R6 carrier.


def _named(parent, name):
    return next(node for node in parent.findall("Item")
                if node.findtext("Properties/string[@name='Name']") == name)


def _set(node, kind, name, value):
    props = node.find("Properties")
    field = props.find(f"{kind}[@name='{name}']")
    field.text = str(value)


def _translate(parent, dx, dy, dz):
    for frame in parent.iter("CoordinateFrame"):
        for coordinate, change in zip("XYZ", (dx, dy, dz)):
            axis = frame.find(coordinate)
            axis.text = f"{float(axis.text) + change:.7g}"


def _loop(cx, y, cz, rx, rz, sides, phase=0.0):
    return [(cx + rx * cos(phase + i * 2 * pi / sides), y,
             cz + rz * sin(phase + i * 2 * pi / sides)) for i in range(sides)]


class _RingArt:
    def __init__(self, item, prop, part, beam, triangle, sign, route,
                 swept_roof, festival_lantern, slate, wood, fabric, metal, neon):
        self.item, self.prop, self.part = item, prop, part
        self.beam, self.triangle, self.sign, self.route = beam, triangle, sign, route
        self.swept_roof, self.lantern = swept_roof, festival_lantern
        self.slate, self.wood, self.fabric, self.metal, self.neon = slate, wood, fabric, metal, neon

    def model(self, parent, name):
        model = self.item(parent, "Model", name)
        self.prop(model, "token", "ModelStreamingMode", 1)
        return model

    def detail(self, parent, name, xyz, size, tint, material, **rotation):
        obj = self.part(parent, name, xyz, size, tint, material=material, collide=False, **rotation)
        self.prop(obj, "bool", "CastShadow", False)
        return obj

    def line(self, parent, name, a, b, size, tint, **collision):
        obj = self.beam(parent, name, a, b, size, tint, **collision)
        self.prop(obj, "bool", "CastShadow", False)
        return obj

    def plaquette(self, parent, xyz, title, yaw, tint, *, width=9.0):
        x, y, z = xyz
        self.detail(parent, "Wayfinding post", (x, y + 1.49, z), (.32, 2.98, .32), "70504C", self.wood)
        self.detail(parent, "Wayfinding plinth", (x, y + .13, z), (.68, .26, .68), "827483", self.slate)
        self.sign(parent, title, x, y + 3.10, z, width, 1.05, yaw, tint, single_line=True)

    def marker(self, parent, name, xyz, yaw=0, size=(.24, .24, .24)):
        return self.part(parent, name, xyz, size, BONE, yaw=yaw, collide=False, transparency=1)

    def sparring(self, court, bot, level, *, gate, bounds, player, opponent, returning, existing=False):
        corner = _named(court, "Bot Spar Corner") if existing else self.model(court, "Bot Spar Corner")
        if existing:
            prompt = _named(_named(corner, "Sparring Gate"), "SparPrompt")
        else:
            center, size = bounds
            self.marker(corner, "Sparring Bounds", center, size=size)
            gate_part = self.marker(corner, "Sparring Gate", gate)
            prompt = self.item(gate_part, "ProximityPrompt", "SparPrompt")
        for key, value in (("ActionText", "Bot Spar"), ("ObjectText", f"{bot} · Level {level}")):
            if existing:
                _set(prompt, "string", key, value)
            else:
                self.prop(prompt, "string", key, value)
        if not existing:
            self.prop(prompt, "float", "MaxActivationDistance", 7)
            self.prop(prompt, "bool", "RequiresLineOfSight", False)
        for name, (xyz, yaw) in (("Player Spawn", player), ("Bot Spawn", opponent), ("Safe Return", returning)):
            self.marker(corner, name, xyz, yaw)
        return corner

    def outlined_floor(self, parent, center, radius, tint):
        x, y, z = center
        face = _loop(x, y - .15, z, radius, radius, 8, pi / 8)
        for index, a in enumerate(face):
            b = face[(index + 1) % len(face)]
            self.triangle(parent, (x, y - .15, z), a, b, tint,
                          name="Collidable octagonal stone mat", thickness=.30, material=self.slate,
                          shadow=False, collide=True)
        return [(a, y, c) for a, _, c in face]

    def handrail(self, parent, a, b, tint):
        for height, thickness in ((.53, .18), (1.28, .22)):
            self.line(parent, "Court safety rail", (a[0], a[1] + height, a[2]),
                      (b[0], b[1] + height, b[2]), thickness, tint, collide=True)

    def platform_path(self, parent, name, points, width, surface_tint, rail_tint, *, material):
        self.route(parent, name, points, width, surface_tint, surface=material,
                   stone_footings=False, join_overlap=.32, railings=False)
        for side in (-1, 1):
            outline = []
            for index, (x, y, z) in enumerate(points):
                prev, next_ = points[max(0, index - 1)], points[min(index + 1, len(points) - 1)]
                dx, dz = next_[0] - prev[0], next_[2] - prev[2]
                w = side * (width / 2 - .24) / hypot(dx, dz)
                outline.append((x + dz * w, y, z - dx * w))
            for index, (a, b) in enumerate(zip(outline, outline[1:])):
                self.handrail(parent, a, b, rail_tint)
                self.detail(parent, "Bridge metal-capped timber post", (a[0], a[1] + .65, a[2]),
                            (.36, 1.34, .36), rail_tint, self.wood)
                if index % 2 == 0:
                    self.detail(parent, "Gilt bridge post cap", (a[0], a[1] + 1.35, a[2]),
                                (.43, .16, .43), GILT, self.metal)


def _grand_dojo(court, art, y, dx):
    style = art.model(court, "Juniper jade and brass")
    x, z = 24.8 + dx, 14.18
    # Keep Juniper's new plate on the existing small board instead of raising a new marquee.
    art.sign(style, "JUNIPER TORTOISE", x, y + 1.47, z + .03, 4.91, .44, 0, "34544C",
             face_only=True, single_line=True)
    for inset in (-2.14, 2.14):
        art.detail(style, "Jade board clasp", (x + inset, y + 2.13, z + .19), (.25, 1.00, .13),
                   GILT, art.metal)
    # The low shell motif uses Juniper's copper-trimmed six scutes and the bronze outline of a canal ripple.
    cx, cz = 27.5 + dx, -4.72
    for radius, tone in ((3.02, "9F8D58"), (2.63, "547765")):
        loop = _loop(cx, y + .047, cz, radius, radius * .72, 12, pi / 12)
        for i, a in enumerate(loop):
            art.line(style, "Copper canal ripple inlay", a, loop[(i + 1) % len(loop)], .075, tone)
    for cx_shift, cz_shift, tint in ((0, 0, "769073"), (-.84, -.53, "4D6D5F"), (.84, -.53, "5A7C6B"),
                                     (-.84, .55, "5A7C6B"), (.84, .55, "4D6D5F"), (0, 1.09, "769073")):
        art.detail(style, "Jade shell scute stitch", (cx + cx_shift, y + .041, cz + cz_shift),
                   (.76, .025, .60), tint, art.fabric, yaw=45)
    art.sparring(court, "Juniper Tortoise", 1, gate=None, bounds=None, existing=True,
                 player=((cx, y + PLAYER_STAND_HEIGHT, 10.5), 0), opponent=((cx, y, -2.2), 180),
                 returning=((28.5 + dx, y + 2.22, 14.4), 0))


def _open_glaze_east_rail(terrace, start, end):
    # Shorten just the east span of the existing Glaze Terrace. Its stairs and
    # walkway keep their original clearance and guardrails.
    for obj in list(terrace.findall("Item")):
        props = obj.find("Properties")
        name = props.findtext("string[@name='Name']")
        frame = props.find("CoordinateFrame[@name='CFrame']")
        size = props.find("Vector3[@name='size']")
        if frame is None or size is None or abs(float(frame.findtext("X")) - 202.01) > .012:
            continue
        z = float(frame.findtext("Z"))
        depth = float(size.findtext("Z"))
        if name == "Glaze cedar guardrail" and depth > 17:
            far = z + depth / 2
            frame.find("Z").text = f"{(far + end) / 2:.7g}"
            size.find("Z").text = f"{far - end:.7g}"
        elif name in ("Glaze railing newel", "Glaze copper newel cap") and start < z < end:
            terrace.remove(obj)


def _cinder(town, terrace, art):
    ring = art.model(town, "Cinder Terraces Ring")
    cx, y, cz = CINDER_CENTER
    clay, fired, basalt, ember = "9F5A49", "744647", "5E474F", "F6B160"
    art.plaquette(town, (164.4, 10.027, -186.2), "CINDER RING VIA GLAZE TERRACE  →", 0, "795045", width=10.7)
    art.plaquette(ring, (199.35, 15.80, -186.9), "CINDER TERRACES RING  →", 0, "795045")
    approach = ((201.76, 15.80, cz), (207.6, 15.99, cz), (213.55, y, cz))
    _open_glaze_east_rail(terrace, cz - 3.29, cz + 3.29)
    art.platform_path(ring, "Cinder kilnstone bridge", approach, 6.55, "AD8874", "925C54", material=art.slate)
    art.detail(ring, "Counterfort below kilnstone bridge", (207.1, 12.4, cz), (5.7, 7.0, 5.75),
               "886B69", art.slate)
    foot = art.outlined_floor(ring, CINDER_CENTER, 14.0, "AA7966")
    art.detail(ring, "Weathered clay octagon plinth", (cx, y - 1.54, cz), (23.4, 3.0, 23.4),
               basalt, art.slate)
    art.detail(ring, "Potter's basalt buttress", (cx, y - 5.4, cz), (20.0, 7.84, 19.4),
               "7A6061", art.slate)
    for index, a in enumerate(foot):
        b = foot[(index + 1) % len(foot)]
        art.line(ring, "Octagon bronze edge trim", (a[0], y - .21, a[2]),
                 (b[0], y - .21, b[2]), .26, "A67452")
        art.detail(ring, "Cinder rim pier", (a[0] * .98 + cx * .02, y + .66, a[2] * .98 + cz * .02),
                   (.48, 1.31, .48), fired, art.slate)
        if index == 3:
            art.handrail(ring, a, (a[0], y, cz + 3.18), fired)
            art.handrail(ring, (b[0], y, cz - 3.18), b, fired)
        else:
            art.handrail(ring, a, b, fired)
    for side in (-1, 1):
        z = cz + side * 7.6
        for xshift in (-.62, 0, .62):
            art.detail(ring, "Inactive kiln vent inlay", (cx + xshift, y + .018, z),
                       (.37, .025, 1.14), basalt, art.metal)
        art.detail(ring, "Orange porcelain warning stitch", (cx, y + .021, z + .76 * side),
                   (2.15, .025, .15), "DA965C", art.fabric)
    # Fired clay columns, black copper shoulders and ivory tusks reflect Bracken's armor.
    back_x = cx + 11.6
    for side in (-1, 1):
        z = cz + side * 5.8
        art.detail(ring, "Kiln pillar basalt shoe", (back_x, y + .24, z), (1.34, .48, 1.42), basalt, art.slate)
        art.detail(ring, "Bracken fired clay pillar", (back_x, y + 2.55, z), (.88, 4.85, .94), clay, art.slate)
        art.detail(ring, "Copper collar", (back_x, y + 4.43, z), (1.09, .28, 1.15), GILT, art.metal)
        art.detail(ring, "Bracken purple hanging pennant", (back_x - .55, y + 3.21, z * .99 + cz * .01),
                   (.12, 2.70, 1.10), "69465F", art.fabric)
        for k in range(3):
            art.detail(ring, "Fired armor plaque", (back_x - .64, y + 3.85 - k * .57, z),
                       (.16, .34, .76 - k * .08), ("C18569", "BE745A", "AB614E")[k], art.slate)
        points = [(back_x - .48, y + h, cz + side * dz) for h, dz in
                  ((4.65, 5.72), (4.31, 4.88), (4.29, 4.20), (4.63, 3.82))]
        for a, b, width in zip(points, points[1:], (.36, .28, .18)):
            art.line(ring, "Bracken ivory tusk crest", a, b, width, BONE)
    art.detail(ring, "Kiln crest red beam", (back_x, y + 5.06, cz), (1.20, .62, 13.35),
               fired, art.wood)
    art.detail(ring, "Copper kiln crest ridge", (back_x, y + 5.51, cz), (1.41, .22, 12.89),
               GILT, art.metal)
    art.detail(ring, "Resting forge embers", (back_x - .63, y + 4.10, cz), (.09, .27, 2.82),
               ember, art.neon)
    art.sign(ring, "BRACKEN BOAR", back_x - .70, y + 3.35, cz, 8.9, 1.01, -90, fired, single_line=True)
    art.detail(ring, "Octagon entry copper cap", (212.93, y + 7.32, cz),
               (.76, .38, 9.11), GILT, art.metal)
    art.sign(ring, "CINDER TERRACES RING", 212.48, y + 6.91, cz, 9.6, 1.11, -90, fired, single_line=True)
    art.sign(ring, "BRACKEN BOAR   ·   LEVEL 3", 212.61, y + 5.99, cz, 8.5, .58, -90, "714943", single_line=True)
    for z in (cz - 3.64, cz + 3.64):
        art.detail(ring, "Octagon entry pier", (212.95, y + 3.52, z), (.86, 7.03, .90), clay, art.slate)
        art.detail(ring, "Octagon entry amber lamp", (212.39, y + 2.31, z),
                   (.19, .78, .47), "FFCC8A", art.neon)
    art.sparring(ring, "Bracken Boar", 3, gate=(212.48, y + 1.61, cz),
                 bounds=((cx, y + 3, cz), (18.0, 6, 18.0)), player=((cx - 5.6, y + PLAYER_STAND_HEIGHT, cz), -90),
                 opponent=((cx + 5.3, y, cz), 90), returning=((210.3, 18.29, cz), -90))


def _cloud_top(town, art):
    ring = art.model(town, "Cloud-Top Temple")
    cx, y, cz = CLOUD_TOP_CENTER
    blue, dusk, white, gold = "526188", "4F4B6A", "BFBCCE", "E3BE80"
    art.plaquette(town, (31.6, 25.027, -255.4), "CLOUD-TOP TEMPLE  →", 0, dusk, width=7.2)
    art.plaquette(ring, (47.95, 25.09, -270.9), "CLOUD-TOP TEMPLE  ↑", 0, dusk, width=7.2)
    # Offset the first span away from Wind Court's eastern wall and decorative rock shoulders.
    approach = ((49.25, 25.067, -270.65), (49.98, 25.19, -280.62),
                (54.5, 26.65, -294.70), (54.5, 28.19, -300.45))
    art.platform_path(ring, "Cloud-Top lower wind bridge", approach, 5.9, "A79AAF", blue, material=art.slate)
    art.part(ring, "Cloud-Top landing porch", (cx, 28.19 - .34, -301.63),
             (9.0, .68, 4.66), "A79AAF", material=art.slate)
    for side in (-1, 1):
        edge = cx + side * 4.29
        art.handrail(ring, (edge, 28.19, -299.45), (edge, 28.19, -303.84), blue)
        art.handrail(ring, (cx + side * 2.79, 28.19, -299.45), (edge, 28.19, -299.45), blue)
        art.handrail(ring, (cx + side * 3.29, 28.19, -303.84), (edge, 28.19, -303.84), blue)
    art.platform_path(ring, "Cloud-Top upper wind bridge", ((cx, 28.19, -303.7), (cx, y, -306.0)),
                      6.9, "B4A9BA", blue, material=art.wood)
    art.part(ring, "Cloud-Top temple mat", (cx, y - .26, cz),
             (25.1, .52, 23.2), "AAA9BA", material=art.slate)
    art.detail(ring, "Skyward slate foundation", (cx, y - 1.15, cz), (23.95, 1.9, 21.95), "7F728E", art.slate)
    for dx, dz, w, h, depth in ((-7, -5.3, 9.6, 13.2, 11.1), (5.4, 4.2, 11.0, 16.2, 10.2),
                                  (.25, -1, 9.2, 19.7, 8.8)):
        art.detail(ring, "Tapered cloud footing", (cx + dx, y - 2 - h / 2, cz + dz), (w, h, depth),
                   "807088", art.slate, pitch=5, roll=11 if dx > 0 else -8, class_name="WedgePart")
    north, south, west, east = cz - 11.23, cz + 11.23, cx - 12.17, cx + 12.17
    for a, b in (((west, y, north), (east, y, north)), ((west, y, north), (west, y, south)),
                 ((east, y, north), (east, y, south)), ((west, y, south), (cx - 3.32, y, south)),
                 ((east, y, south), (cx + 3.32, y, south))):
        art.handrail(ring, a, b, blue)
        art.line(ring, "Pale linen deck binding", (a[0], y + .028, a[2]), (b[0], y + .028, b[2]),
                 .088, white)
    for s in (-1, 1):
        x = cx + s * 7.5
        for start, end in ((-7.7, -3.5), (-2.5, 2.5), (3.5, 7.7)):
            art.line(ring, "Lavender wind-current inlay", (x, y + .032, cz + start),
                     (x + s * .70, y + .032, cz + end), .068, "686789")
    # Lavender courier pennants, paired upright ears and a three-chime silhouette.
    gate_z = -305.56
    for side in (-1, 1):
        x = cx + side * 3.83
        art.detail(ring, "Temple gate slate foot", (x, y + .24, gate_z),
                   (1.05, .52, 1.15), dusk, art.slate)
        art.detail(ring, "Lynx chime gate cedar upright", (x, y + 3.69, gate_z),
                   (.65, 7.37, .66), blue, art.wood)
        art.detail(ring, "Lynx ear finial", (x + side * .22, y + 8.03, gate_z + .08),
                   (.58, 1.42, .55), "797FA8", art.wood, roll=side * -19, class_name="WedgePart")
        art.detail(ring, "Lynx ear gold cut", (x + side * .29, y + 8.16, gate_z + .35),
                   (.19, .64, .06), gold, art.metal, roll=side * -19)
        art.lantern(ring, x + side * .13, y + 4.18, gate_z + .40, .42, light=False, tint="E2D6E8")
    art.detail(ring, "Temple crest crossbeam", (cx, y + 7.31, gate_z),
               (8.53, .64, .72), "6B6487", art.wood)
    art.detail(ring, "Temple crest brass lip", (cx, y + 7.70, gate_z),
               (9.02, .15, .79), gold, art.metal)
    art.sign(ring, "CLOUD-TOP TEMPLE", cx, y + 7.02, gate_z + .38, 8.45, 1.08, 0, dusk, single_line=True)
    art.sign(ring, "SABLECREST LYNX   ·   LEVEL 5", cx, y + 6.09, gate_z + .41, 7.64, .61, 0,
             "595978", single_line=True)
    for a in (-1, 0, 1):
        for angle in (-1, 1):
            art.detail(ring, "Still wind chime copper casing", (cx + (9.9 + a * .43) * angle,
                        y + 3.92 - a * .18, cz - 8.69), (.67 + a * .16, .22, .22),
                       gold, art.metal, roll=90, shape=2)
        art.detail(ring, "Silver wind chime", (cx + a * .90, y + 4.87, north + 1.9),
                   (.68 + a * .14, .28, .28), "E6D5C3", art.metal, roll=90, shape=2)
    for edge_x in (cx - 10.4, cx + 10.4):
        art.detail(ring, "Courier pennant post", (edge_x, y + 2.71, north + .55),
                   (.42, 5.45, .41), blue, art.wood)
        art.detail(ring, "Courier scarf blue silk", (edge_x, y + 3.42, north + .71),
                   (1.23, 2.42, .09), "616E99", art.fabric)
        art.detail(ring, "Courier scarf silver band", (edge_x, y + 2.43, north + .77),
                   (1.25, .27, .05), white, art.fabric)
    art.line(ring, "Far chime lintel", (cx - 10.78, y + 5.34, north + .55),
             (cx + 10.78, y + 5.34, north + .55), .49, dusk)
    art.swept_roof(ring, cx, y + 5.47, north + .83, 22.4, 3.54, 1.22, fine_tiles=False)
    art.sparring(ring, "Sablecrest Lynx", 5, gate=(cx, y + 1.59, gate_z + .68),
                 bounds=((cx, y + 3, cz), (21.8, 6, 19.8)), player=((cx, y + PLAYER_STAND_HEIGHT, cz + 5.4), 0),
                 opponent=((cx, y, cz - 5.2), 180), returning=((cx, 30.41, -301.70), 180))


def _galleon(town, art):
    ship = _named(town, "Sunken Pirate Galleon")
    ring = _named(ship, "Tideharbor practice ring")
    boardwalk = _named(ship, "Galleon boardwalk")
    # The retired practice spot stays playable by the rail, outside Granite's match footprint.
    _translate(_named(ship, "Practice Target"), -2.3, -.72, 12.22)
    for parent, old, new in ((ring, "TIDEHARBOR PRACTICE RING", "GALLEON RING"),
                             (boardwalk, "GALLEON ARENA", "GALLEON RING"),
                             (boardwalk, "GALLEON ARENA  →", "GALLEON RING  →")):
        for obj in parent.iter("Item"):
            props = obj.find("Properties")
            text = props.find("string[@name='Text']")
            if text is not None and text.text == old:
                text.text = new
    cx, y, cz = GALLEON_CENTER
    navy, slate, silver = "4C6283", "697687", "B5BFC8"
    style = art.model(ring, "Granite breakwater ironwork")
    for side in (-1, 1):
        for x in (cx - 10.75, cx + 10.75):
            z = cz + side * 8.63
            art.detail(style, "Slate breakwater shoulder casing", (x, y + .48, z),
                       (1.24, .88, 1.12), slate, art.slate)
            art.detail(style, "Indigo copper corner plate", (x, y + 1.76, z),
                       (.99, .71, .94), navy, art.metal, roll=side * 9)
            art.detail(style, "Corner silver cap", (x, y + 2.14, z), (1.04, .15, .94), silver, art.metal)
        art.line(style, "Indigo tide deck binding", (cx - 10.4, y + .035, cz + side * 7.72),
                 (cx + 10.4, y + .035, cz + side * 7.72), .18, navy)
    for a, scale in ((-.55, 1.4), (0, 1.70), (.55, 1.4)):
        art.detail(style, "Breakwater joint hatch inlay", (cx + a * 2.55, y + .035, cz),
                   (scale, .027, 1.00), "9FB1BC", art.metal, yaw=45)
    x = cx + 10.78
    for k in range(3):
        art.detail(style, "Indigo bow crest plate", (x, y + 2.21 + .34 * k, cz),
                   (.24, .38, 4.12 - k * .48), ("62799B", "7F95AA", "8BA0B0")[k],
                   art.metal, pitch=k * -5)
    crest = ((x - .20, y + 3.05, cz), (x - .83, y + 3.67, cz), (x - 1.12, y + 4.28, cz))
    for a, b, width in zip(crest, crest[1:], (.52, .32)):
        art.line(style, "Granite ivory horn crest", a, b, width, BONE)
    art.sign(style, "GRANITE RHINO   ·   LEVEL 7", 280.20, y + 2.14, cz + 5.54, 7.9, .82,
             -90, navy, single_line=True)
    art.detail(style, "Galleon opponent sign post", (280.40, y + .26, cz + 5.54),
               (.40, 3.22, .40), "76564F", art.wood)
    art.sparring(ring, "Granite Rhino", 7, gate=(279.45, 7.57, cz),
                 bounds=((cx, y + 3, cz), (21.0, 6, 15.3)), player=((cx - 6.13, y + PLAYER_STAND_HEIGHT, cz), -90),
                 opponent=((cx + 6.07, y, cz), 90), returning=((275.80, 7.84, cz), 90))


def build_district_dojo_rings(ring, outer, roads, *, ring_floor, ring_offset,
                              item, prop, part, beam, triangle, sign, route, swept_roof,
                              festival_lantern, slate, wood, fabric, metal, neon):
    """Build the four themed arenas after the base districts and public roads."""
    art = _RingArt(item, prop, part, beam, triangle, sign, route, swept_roof,
                   festival_lantern, slate, wood, fabric, metal, neon)
    _grand_dojo(ring, art, ring_floor, ring_offset)
    _cinder(_named(outer, "Cinder Terraces"), _named(roads, "Glaze Terrace"), art)
    _cloud_top(_named(outer, "Skywalk Peaks"), art)
    _galleon(_named(outer, "Tideharbor Coast"), art)
