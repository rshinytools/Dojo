"""Build open wall shoulders around the existing district arrival gates."""

from math import atan2, cos, degrees, hypot, radians, sin


# The two junction-side piers stop at the existing gate columns. A wing at
# either of those columns would sit between a cross-town road and its square.
DISTRICTS = {
    "Tideharbor Coast": ("748C8B", "A1AE9D", "35727A", "35595C", 7.5, (8.15, 8.65)),
    "Cinder Terraces": ("A06E62", "C18B67", "9B4E39", "77413A", 8.15, (8.35, 0)),
    "Skywalk Peaks": ("817B99", "B2A6B8", "635C88", "4E4D73", 7.8, (4.6, 3.55)),
    "Frostglass Gardens": ("8B9BAA", "B4C0C5", "548296", "446B80", 7.2, (0, 8.25)),
    "Lantern Circuit": ("87718E", "B198A8", "805278", "543961", 7.6, (8.15, 8.8)),
}

# At Skywalk two roads enter across the front of the old gate. Step the walls
# behind each turn. At Frostglass the radial road approaches diagonally.
WING_OFFSETS = {
    ("Skywalk Peaks", -1): (0, -7.0),
    ("Skywalk Peaks", 1): (0, 3.9),
    ("Frostglass Gardens", 1): (2.5, 0),
}


def build_district_gateway(town, name, center, yaw, *, item, prop, part,
                           festival_lantern, garden_prop, slate, wood):
    stone, coping, panel, frame, height, lengths = DISTRICTS[name]
    x, y, z = center
    span = 15 if yaw else 18
    if yaw:
        x += -27 if yaw > 0 else 27
    else:
        z += 25
    facing = -yaw
    c, s = cos(radians(facing)), sin(radians(facing))

    boundary = item(town, "Model", "Arrival gate boundary walls")
    prop(boundary, "token", "ModelStreamingMode", 1)
    prop(boundary, "token", "LevelOfDetail", 4)
    for side, length in zip((-1, 1), lengths):
        wing = item(boundary, "Folder", "Left wall shoulder" if side < 0 else "Right wall shoulder")
        outboard, setback = WING_OFFSETS.get((name, side), (0, 0))
        root = span/2+.86+outboard

        def point(across, height, fore):
            fore += setback
            return x+across*c+fore*s, y+height, z-across*s+fore*c

        def trim(parent, label, at, size, tint, *, material=slate, pitch=0, roll=0):
            detail = part(parent, label, point(*at), size, tint, yaw=facing, pitch=pitch, roll=roll,
                          material=material, collide=False)
            prop(detail, "bool", "CastShadow", False)

        if length:
            mid = side*(root+length/2)
            end = side*(root+length-.52)
            part(wing, "Dressed stone wall", point(mid, 2.6, 0), (length, 5.25, 1.38),
                 stone, yaw=facing, material=slate)
            trim(wing, "Wall foot course", (mid, .33, .04), (length, .66, 1.89), coping)
            trim(wing, "Lower projecting stone course", (mid, 1.13, .05), (length, .19, 1.54), coping)
            trim(wing, "Wall crown stone", (mid, 5.22, 0), (length+.26, .35, 1.72), coping)
            panels = max(2, round(length/2))
            for outward in (-1, 1):
                trim(wing, "Cedar wall face", (mid, 3.46, outward*.74), (length-.24, 2.54, .11),
                     panel, material=wood)
                for i in range(1, panels):
                    position = side*(root+length*i/panels)
                    trim(wing, "Cedar wall panel seam", (position, 3.46, outward*.81),
                         (.12, 2.58, .09), frame, material=wood)
                trim(wing, "Cedar wall belt", (mid, 2.14, outward*.86),
                     (length-.12, .19, .13), frame, material=wood)
                trim(wing, "Cedar wall cornice", (mid, 4.77, outward*.86),
                     (length-.12, .17, .13), frame, material=wood)
            for face in (-1, 1):
                slope = degrees(atan2(.47, 1.19))
                trim(wing, "Tiled wall cap", (mid, 5.61, face*.55),
                     (length+.5, .25, hypot(1.19, .47)), "45527E", pitch=face*slope)
                trim(wing, "Indigo wall eave", (mid, 5.40, face*1.12),
                     (length+.36, .22, .28), "566998")
            trim(wing, "Indigo wall ridge", (mid, 5.91, 0), (length+.42, .28, .46), "303D69")
            part(wing, "Stone wall end pier", point(end, 2.87, 0), (1.16, 5.81, 1.57),
                 stone, yaw=facing, material=slate)
            trim(wing, "Dressed pier foot", (end, .45, .04), (1.53, .9, 1.95), coping)
            trim(wing, "Cedar pier casing", (end, 5.66, 0), (1.26, 2.04, 1.66),
                 frame, material=wood)
            trim(wing, "Gold pier rail", (end, 6.47, 0), (1.39, .13, 1.78), "CF9D62")
            # Keep the Mistline shoulder's planting away from its turn into town.
            garden_side = -1 if name == "Skywalk Peaks" and side < 0 else 1
            trim(wing, "Gate garden ledge", (end, .19, garden_side*1.30), (2.14, .35, 1.24), coping)
            garden_prop(wing, "meadowGrass", point(end-.17*side, .39, garden_side*1.39), .16, facing+37)
            garden_prop(wing, "mossFlowers", point(end+.30*side, .39, garden_side*1.48), .12, facing-23)
        else:
            end = side*span/2
            # Dress existing junction columns above the walking envelope.
            trim(wing, "Junction jamb coping", (end, 5.64, 0), (1.65,.23,1.59), coping)
            trim(wing, "Junction jamb foil", (end, 6.47, .81), (1.23,.13,.11), "CF9D62")

        trim(wing, "Cedar tower plate", (end, 6.75, 0), (2.04, .36, 2.14), frame, material=wood)
        for face in (-1, 1):
            roof_rise = height-6.71
            slope = degrees(atan2(roof_rise, 1.34))
            trim(wing, "Swept pier roof", (end, 6.71+roof_rise*.50, face*.60),
                 (2.43, .28, hypot(1.34, roof_rise)), "415683", pitch=face*slope)
            trim(wing, "Pier eave tile", (end, 6.84, face*1.25), (2.59, .20, .35), "61769C")
        trim(wing, "Pier ridge", (end, height+.11, 0), (2.37, .24, .40), "37466E")
        for tip in (-1, 1):
            trim(wing, "Pier brass finial", (end+tip*1.14, height+.2, 0),
                 (.48, .18, .33), "DAAB71", roll=tip*36)
        if length:
            trim(wing, "Sconce support", (end, 5.27, 1.03), (.38,.19,.62), frame, material=wood)
            festival_lantern(wing, *point(end, 4.66, 1.32), .51, light=False)
