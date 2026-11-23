"""Native geometry for the Frostglass Gardens reflector activity."""

from math import hypot


FLOOR = 14.027
STATIONS = (
    ("Source", -217.0, -178.60),
    ("Lens1", -213.45, -178.60),
    ("Lens2", -207.55, -175.65),
    ("Lens3", -201.65, -178.60),
    ("Receiver", -198.10, -178.60),
)
HEADINGS = ((1, 0), (1, .5), (1, -.5))
TARGETS = (2, 3, 1)
INITIAL_HEADINGS = (1, 1, 3)
HEADING_NAMES = ("East", "Southeast", "Northeast")
SLATE = 800
METAL = 1088
GLASS = 1568
NEON = 288
RAY_Y = FLOOR + 1.83


def build_frostglass_reflectors(town, *, item, prop, part, beam, sign, vector, color):
    puzzle = item(town, "Model", "Frostglass Reflectors")
    prop(puzzle, "token", "ModelStreamingMode", 1)

    def matte(parent, name, position, size, tint, **kwargs):
        obj = part(parent, name, position, size, tint, collide=False, **kwargs)
        prop(obj, "bool", "CastShadow", False)
        return obj

    def prompt(hub, action, label):
        interact = item(hub, "ProximityPrompt", "Interact")
        prop(interact, "string", "ActionText", action)
        prop(interact, "string", "ObjectText", label)
        prop(interact, "float", "MaxActivationDistance", 5.4)
        prop(interact, "float", "HoldDuration", .16)
        prop(interact, "bool", "RequiresLineOfSight", False)

    def caption(hub, name, text, size, lift):
        gui = item(hub, "BillboardGui", "Caption")
        vector(gui, "UDim2", "Size", ("XS", "XO", "YS", "YO"), size)
        vector(gui, "Vector3", "StudsOffsetWorldSpace", ("X", "Y", "Z"), (0, lift, 0))
        prop(gui, "float", "MaxDistance", 22)
        prop(gui, "float", "LightInfluence", 0)
        label = item(gui, "TextLabel", name)
        vector(label, "UDim2", "Size", ("XS", "XO", "YS", "YO"), (1, 0, 1, 0))
        color(label, "BackgroundColor3", "203740")
        prop(label, "float", "BackgroundTransparency", .12)
        color(label, "TextColor3", "F1F5EB")
        prop(label, "bool", "TextScaled", True)
        prop(label, "bool", "TextWrapped", True)
        prop(label, "token", "Font", 4)
        prop(label, "string", "Text", text)
        return label

    def ray(parent, name, start, finish):
        light = item(parent, "Beam", name)
        for field, target in (("Attachment0", start), ("Attachment1", finish)):
            prop(light, "Ref", field, target.get("referent"))
        prop(light, "bool", "Enabled", False)
        prop(light, "bool", "FaceCamera", True)
        prop(light, "float", "Width0", .135)
        prop(light, "float", "Width1", .107)
        prop(light, "float", "LightEmission", .24)
        prop(light, "float", "LightInfluence", 0)
        prop(light, "ColorSequence", "Color", "0 .91 .78 .48 0 1 .95 .85 .64 0 ")
        return light

    title_x = -207.6
    matte(puzzle, "Reflector wayfinding post", (-193.4, FLOOR + .97, -158.8),
          (.28, 1.94, .29), "76858E", material=SLATE)
    sign(puzzle, "REFLECTORS  ←", -193.4, FLOOR + 2.05, -158.65, 3.94, .69, tint="34525D")
    matte(puzzle, "Reflector trail plaque stem", (title_x, FLOOR + .8, -181.21),
          (.28, 1.6, .33), "76858E", material=SLATE)
    sign(puzzle, "FROSTGLASS REFLECTORS", title_x, FLOOR + 1.98, -180.99, 6.2, .8, tint="34525D")
    sign(puzzle, "Turn lenses to guide light from the source to the receiver.",
         title_x, FLOOR + 1.14, -180.93, 6.3, .68, tint="486773")

    models, anchors = [], []
    for index, (name, x, z) in enumerate(STATIONS):
        station = item(puzzle, "Model", name)
        models.append(station)
        matte(station, "Pale slate socket", (x, FLOOR + .10, z), (1.83, .21, 1.76),
              "A6B8C2", material=SLATE)
        matte(station, "Beveled brass bearing", (x, FLOOR + .26, z), (.57, 1.15, 1.15),
              "A49270", shape=2, roll=90, material=METAL)
        matte(station, "Lens column", (x, FLOOR + .99, z), (.61, 1.17, .61),
              "486875", material=SLATE)
        matte(station, "Lens collar", (x, FLOOR + 1.51, z), (.85, .14, .83),
              "B7A578", material=METAL)
        pigment = "E4CD96" if index == 0 else "8FBCCC"
        hub = matte(station, "Hub", (x, RAY_Y, z), (.59, .77, .67), pigment,
                    shape=0, material=GLASS)
        anchors.append(item(hub, "Attachment", "RayAnchor"))
        if index == 0:
            prompt(hub, "Reset lenses", "Frostglass source")
            caption(hub, "Status", "Source • Session clears 0", (0, 158, 0, 41), 1.14)
        elif index == len(STATIONS) - 1:
            caption(hub, "Status", "Receiver • Awaiting light", (0, 142, 0, 40), 1.14)
        else:
            prompt(hub, "Turn lens", f"Reflector {index}")
            heading = HEADING_NAMES[INITIAL_HEADINGS[index - 1] - 1]
            caption(hub, "Status", f"Lens {index} • {heading}", (0, 134, 0, 39), 1.14)

    ray(models[0], "InputRay", anchors[0], anchors[1])
    for index, (_, x, z) in enumerate(STATIONS[1:-1], start=1):
        station = models[index]
        for heading, (dx, dz) in enumerate(HEADINGS, start=1):
            length = hypot(dx, dz)
            ux, uz = dx / length, dz / length
            direction = item(station, "Model", f"Direction{heading}")

            def needle_point(distance, offset=0):
                return x + ux * distance - uz * offset, RAY_Y + .15, z + uz * distance + ux * offset

            for start, finish in ((needle_point(.40), needle_point(1.19)),
                                  (needle_point(.92, .16), needle_point(1.19)),
                                  (needle_point(.92, -.16), needle_point(1.19))):
                marker = beam(direction, "Pointer", start, finish, .072, "E8C784")
                prop(marker, "bool", "CastShadow", False)
                if heading != INITIAL_HEADINGS[index - 1]:
                    marker.find("Properties/float[@name='Transparency']").text = "1"

            if heading == TARGETS[index - 1]:
                finish_anchor = anchors[index + 1]
            else:
                endpoint = matte(direction, "Ray end", (x + 2.53 * ux, RAY_Y, z + 2.53 * uz),
                                 (.06, .06, .06), "82C2D6", transparency=1)
                finish_anchor = item(endpoint, "Attachment", "RayAnchor")
            ray(direction, "OutputRay", anchors[index], finish_anchor)

    return puzzle
