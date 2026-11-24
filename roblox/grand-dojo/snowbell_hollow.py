"""Low visual-only slopes at the foot of Snowbell Ridge."""

from frostglass_store_planting import frostglass_winter_foliage
from south_valley_backdrop import ridge_surface_height


# Cross-sections run from the walk-facing toe, through the crowns, to the
# buried north edge. Studio sampled the basin floor at y=-3 away from the road.
_NEAR_X = (-154, -145, -136, -127, -118, -108, -98, -88, -79)
_NEAR_ROWS = (
    ((-212, -214, -213, -215, -220, -226, -232, -234, -238), (-3.5, -3.5, -3.5, -3.5, -2.5, 1.1, .1, -1.8, -3.5)),
    ((-217, -220, -220, -223, -225, -229, -234, -236, -240), (-3.5, .6, 2.6, 4.5, 5.5, 4.7, 2.7, 0, -3.5)),
    ((-220, -226, -229, -232, -230, -232, -235, -238, -243), (-3.5, 3.1, 6.1, 8.2, 10.2, 8.2, 5.7, 2.6, -3.5)),
    ((-225, -231, -235, -237, -235, -235, -237, -240, -245), (-3.5, 4.8, 8.9, 11.7, 13.7, 10.7, 7.2, 3.8, -3.5)),
    ((-232, -236, -243, -243, -243, -242, -245, -247, -248), (-3.5, 2.3, 3.9, 5.5, 6.1, 5.0, 4.9, 2.5, -3.5)),
    ((-237, -242, -249, -250, -249, -249, -252, -253, -254), (-3.6, -2.0, -1.05, -.5, -.7, -.7, -1, -2.4, -3.6)),
)
_FAR_X = (-154, -146, -136, -126, -116, -106, -96, -86, -77)
_FAR_ROWS = (
    ((-233, -239, -246, -247, -246, -246, -249, -250, -252), (-3.6, -3.4, -3.3, -2.7, -2.8, -2.8, -3.4, -3.4, -3.6)),
    ((-240, -245, -252, -254, -251, -252, -255, -257, -259), (-3.6, 0, 1.6, 3.8, 4.8, 3.6, 3.1, 1.4, -3.6)),
    ((-246, -256, -258, -260, -260, -262, -265, -266, -270), (-3.6, 3.4, 6.9, 10.8, 13.6, 11.3, 9.4, 5.3, -3.6)),
    ((-250, -263, -265, -270, -274, -275, -277, -277, -279), (-3.6, 2.1, 4.4, 7.1, 7.0, 6.7, 5.6, 2.9, -3.6)),
    ((-256, -269, -275, -280, -284, -283, -288, -286, -284), (-3.7, -3.6, -3.4, -3.4, -3.5, -3.4, -3.5, -3.7, -3.7)),
)
_SHOULDERS = (
    ("Snowbell near ravine shoulder", _NEAR_X, _NEAR_ROWS, ("toe", "slate", "drift", "brush", "trough")),
    ("Snowbell outer ravine shoulder", _FAR_X, _FAR_ROWS, ("trough", "slate", "drift", "brush")),
)


def _surface_faces(xs, rows, bands):
    contours = tuple(tuple(zip(xs, elevations, zs)) for zs, elevations in rows)
    for band, south, north in zip(bands, contours, contours[1:]):
        for index, (a, b, c, d) in enumerate(zip(south, south[1:], north, north[1:])):
            # Alternate the slant so the broad faces do not repeat in a grid.
            faces = ((a, b, d), (a, d, c)) if index % 2 else ((a, b, c), (b, d, c))
            for half, face in enumerate(faces):
                yield band, index, half, face


def snowbell_hollow_surface(x, z):
    """Return the highest authored shoulder facet at a planting coordinate."""
    faces = (face for _, xs, rows, bands in _SHOULDERS for _, _, _, face in _surface_faces(xs, rows, bands))
    return ridge_surface_height(faces, x, z)


def build_snowbell_hollow(roads, *, item, prop, part, triangle, garden_prop,
                          vector, asset, rock, snow, grass, rock_variant, variant_field):
    hollow = item(roads, "Model", "Snowbell Hollow")
    prop(hollow, "token", "ModelStreamingMode", 1)
    prop(hollow, "token", "LevelOfDetail", 4)

    palettes = {
        "toe": ("Snowbell weathered slate toe", rock, ("787485", "807B8C", "838091")),
        "slate": ("Snowbell layered slate shelf", rock, ("878294", "8E8799", "958C9D")),
        "snow": ("Snowbell broken snow drift", snow, ("BDC2D4", "CED0DE", "B6BDCF")),
        "moss": ("Snowbell moss shelf", grass, ("7F8A78", "8B9382", "808979")),
        "trough": ("Snowbell recessed slate", rock, ("716B7B", "777282", "777587")),
    }
    for name, xs, rows, bands in _SHOULDERS:
        shoulder = item(hollow, "Model", name)
        for band, index, half, face in _surface_faces(xs, rows, bands):
            if band == "drift":
                band = "snow" if index in (2, 3, 5) or (index in (1, 4, 6) and half == 1) else "slate"
            elif band == "brush":
                band = "moss" if (index + half) % 3 else "slate"
            label, material, tones = palettes[band]
            before = len(shoulder)
            triangle(shoulder, *face, tones[(index + half) % len(tones)], name=label,
                     material=material, shadow=False, collide=False, thickness=.14)
            if material == rock:
                for wedge in shoulder[before:]:
                    prop(wedge, "string", variant_field, rock_variant)

    pine, shrub = frostglass_winter_foliage(hollow, "Snowbell Hollow winter grove", item=item,
                                            prop=prop, part=part, vector=vector, asset=asset)
    for plant, name, x, z, yaw, scale in (
        (pine, "Hollow crest snow pine", -126.5, -238.0, 23, .41),
        (pine, "Hollow lee snow pine", -112.9, -237.6, 79, .31),
        (shrub, "Hollow frosted undergrowth", -124.0, -240.4, 68, .24),
        (shrub, "Hollow frosted undergrowth", -108.1, -236.9, 106, .20),
    ):
        plant(name, x, z, yaw, scale, snowbell_hollow_surface(x, z) - .11)

    bed = item(hollow, "Model", "Snowbell Hollow scree and moss")
    for key, x, z, yaw, scale in (
        ("bankRock", -128.3, -237.1, 37, .27), ("bankRock", -125.1, -238.7, 59, .20),
        ("bankRock", -114.8, -238.6, 81, .23), ("bankRock", -110.6, -235.9, 103, .17),
        ("meadowCover", -128.2, -238.7, 26, .18), ("meadowCover", -121.5, -239.3, 57, .15),
        ("grassBlade", -114.0, -239.1, 89, .19), ("grassBlade", -109.9, -237.4, 107, .15),
    ):
        before = len(bed)
        tint = "948C9E" if key == "bankRock" else "A7B29C"
        garden_prop(bed, key, (x, snowbell_hollow_surface(x, z) - .19, z), scale, yaw, tint)
        for plant in bed[before:]:
            shadow = plant.find("Properties/bool[@name='CastShadow']")
            if shadow is not None:
                shadow.text = "false"
