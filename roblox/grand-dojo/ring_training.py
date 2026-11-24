"""Small native mentor stations for the four-ring progression path."""
from math import cos, radians, sin


TRAINING_ART = {
    "lantern-timing": (
        "LANTERN TIMING", "305C53", "B89150", ("9DDCA9", "EEAB64", "71CFC4"), 0,
    ),
    "kiln-rhythm": (
        "KILN RHYTHM", "70473F", "C08753", ("F1BD77", "F08959", "DEB367"), 2,
    ),
    "wind-signals": (
        "WIND COURT SIGNALS", "3C596E", "9BABAB", ("A0D7EA", "9BADE9", "D5D2ED"), 1,
    ),
}


def build_ring_training(parent, placements, *, item, part, prop, sign, wood, slate, metal, neon):
    """Mount stations at the supplied public route floor positions and yaw."""
    if set(placements) != set(TRAINING_ART):
        raise ValueError("every mentor station must have one public placement")
    training = item(parent, "Folder", "Ring Training")
    for drill_id, (title, enamel, trim, accents, shape) in TRAINING_ART.items():
        station = item(training, "Model", drill_id)
        prop(station, "token", "ModelStreamingMode", 1)
        x, y, z, yaw = placements[drill_id]
        sine, cosine = sin(radians(yaw)), cos(radians(yaw))

        def at(dx, dy, dz):
            return x + dx * cosine + dz * sine, y + dy, z - dx * sine + dz * cosine

        def piece(name, dx, dy, dz, size, tint, material, **options):
            obj = part(station, name, at(dx, dy, dz), size, tint, yaw=yaw,
                       material=material, collide=False, **options)
            prop(obj, "bool", "CastShadow", False)
            return obj

        def anchor(name, action, label, dx):
            host = piece(name, dx, 2.35, .23, (.2, .2, .2), trim, metal, transparency=1)
            prompt = item(host, "ProximityPrompt", "TrainingPrompt")
            prop(prompt, "string", "ActionText", action)
            prop(prompt, "string", "ObjectText", label)
            prop(prompt, "float", "HoldDuration", .20)
            prop(prompt, "float", "MaxActivationDistance", 4.3)
            prop(prompt, "bool", "RequiresLineOfSight", False)
            return prompt

        for dx in (-9.02, -5.98):
            piece("Mentor sign pedestal", dx, .17, 0, (.55, .34, .6), "655D60", slate)
            piece("Mentor sign cedar support", dx, 1.17, 0, (.23, 2.1, .28), enamel, wood)
            piece("Mentor sign gold finial", dx, 2.55, 0, (.31, .24, .31), trim, metal)
        sign(station, title, *at(-7.5, 2.37, .13), 4.17, .61, yaw=yaw, tint=enamel)
        sign(station, "+40 FIGHTER XP", *at(-7.5, 1.87, .12), 3.71, .36, yaw=yaw, tint=enamel)
        anchor("Start", "Begin drill", title, -7.5)

        for index, (dx, accent) in enumerate(zip((-2.5, 2.5, 7.5), accents), start=1):
            piece("Slate cue base", dx, .15, 0, (1.37, .30, 1.12), "62595C", slate)
            piece("Painted cue stem", dx, .74, 0, (.28, .96, .28), enamel, wood)
            piece("Rounded cue collar", dx, 1.24, 0, (.57, .13, .55), trim, metal)
            piece("Lit cue", dx, 1.57, 0, (.68, .53, .56), accent, neon, shape=shape)
            piece("Cue metal cap", dx, 1.88, 0, (.65, .10, .61), trim, metal)
            sign(station, str(index), *at(dx, 1.03, .20), .64, .41, yaw=yaw, tint=enamel)
            anchor(str(index), "Activate cue", f"Cue {index}", dx)
    return training
