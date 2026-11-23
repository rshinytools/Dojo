"""Layered orchard banks on the valley side of the Lantern Circuit road."""

from lanternwood_ridge import ridge_facets
from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Near toe, lower bank, middle bench and high orchard edge. The aft skirt
# settles into the existing Lanternwood foothill behind the planted shoulder.
_SECTIONS = (
    (-173.3, 39.4, -4.9, -4.35, -3.90),
    (-169.2, 38.4, -.80, 2.20, 6.15),
    (-164.8, 37.0, .75, 3.95, 7.90),
    (-159.7, 36.5, 1.42, 4.87, 8.83),
    (-154.4, 37.4, 1.09, 4.11, 7.32),
    (-148.8, 36.4, .12, 3.67, 6.72),
    (-143.1, 36.6, .15, 2.86, 4.98),
    (-137.8, 37.6, -.94, 2.03, 4.22),
    (-132.5, 37.5, -2.29, -.25, 2.45),
    (-128.1, 38.7, -4.95, -4.42, -3.70),
)

_STONE = (
    ("796E78", "81717D", "8B7A84"),
    ("95848C", "8A7C88", "A28B93"),
    ("948494", "9A8997", "8F8290"),
)
_TURF = ("73805C", "7F8D60", "85916B", "76815E")


def _contours():
    rows = []
    for index, (x, z, low, mid, high) in enumerate(_SECTIONS):
        bend = (-.38, .41, -.14, .25)[index % 4]
        rows.append((
            (x, -5.48, z),
            (x + bend, low, z + 2.42),
            (x - bend * .65, low + .23, z + 6.21 + bend),
            (x + bend * .45, mid, z + 8.42 + bend),
            (x - bend, mid + .19, z + 12.43),
            (x + bend * .7, high, z + 15.35 + bend),
            (x + bend * 1.1, high - .04, z + 17.82),
            (x, -5.69, z + 22.46 + bend),
        ))
    return rows


def build_orchard_road_terraces(landscape, *, item, prop, part, triangle,
                                garden_prop, showcase_tree, rock, grass, cedar,
                                rock_variant, variant_field):
    """Seat short stone faces and living orchard benches below the road."""
    orchard = item(landscape, "Model", "Lantern orchard road terraces")
    prop(orchard, "token", "ModelStreamingMode", 1)
    prop(orchard, "token", "LevelOfDetail", 4)
    surfaces = []
    rows = _contours()
    for strip in range(len(rows[0]) - 1):
        planted = strip in (2, 4, 6)
        palette = _TURF if planted else _STONE[min(strip // 2, len(_STONE) - 1)]
        for index, (a, b) in enumerate(zip(rows, rows[1:])):
            quad = a[strip], b[strip], a[strip + 1], b[strip + 1]
            one, two, three, four = quad
            faces = ((one, two, four), (one, four, three)) if index % 2 else (
                (one, two, three), (two, four, three))
            for face in faces:
                surfaces.append(face)
                before = len(orchard)
                triangle(orchard, *face, palette[index % len(palette)],
                         name="Orchard bench groundcover" if planted else "Orchard bank split slate",
                         thickness=.17, material=grass if planted else rock, collide=False, shadow=False)
                if not planted:
                    for slab in list(orchard)[before:]:
                        prop(slab, "string", variant_field, rock_variant)

    existing = [face for face, _, _ in ridge_facets()]

    def floor(x, z):
        # Old rock meets the new bank at the western and uphill seams.
        return ridge_surface_height(surfaces + existing, x, z)

    def cedar_part(group, name, position, size, tint, **orientation):
        piece = part(group, name, position, size, tint,
                     material=cedar if name.endswith("trunk") else grass,
                     collide=False, **orientation)
        prop(piece, "bool", "CastShadow", False)

    planting = item(orchard, "Folder", "Terraced orchard grove")
    for x, z, scale, shade in (
        (-168.6, 46.1, .69, 6), (-164.8, 49.2, .64, 0),
        (-160.4, 46.8, .78, 3), (-153.5, 46.8, .65, 4),
        (-148.6, 51.1, .74, 6), (-142.3, 47.6, .63, 1),
        (-136.8, 45.2, .57, 3),
    ):
        hillside_cedar(cedar_part, planting, x, floor(x, z) - .21, z, scale, shade)
    for x, z, pink, scale, yaw in (
        (-162.3, 42.7, True, .70, 53),
        (-152.2, 41.4, False, .75, 142),
        (-142.9, 42.4, True, .57, 237),
    ):
        showcase_tree(planting, x, z, pink, scale, yaw, floor(x, z) - .16, compact=True)

    for index, (x, z) in enumerate((
        (-167.8, 40.8), (-164.7, 41.3), (-160.8, 40.1), (-157.5, 41.1),
        (-154.7, 43.4), (-150.2, 41.2), (-147.0, 42.4), (-144.2, 44.4),
        (-140.5, 42.1), (-137.7, 42.4), (-134.2, 43.0),
    )):
        garden_prop(planting, "bankRock", (x, floor(x, z) - .08, z),
                    .15 + index % 3 * .035, 31 + index * 39, "A39697")
        px, pz = x + .48, z + .52
        key, scale, tint = (
            ("grassBlade", .36, "D3B57D"), ("mossFlowers", .18, "D8A8C3"),
            ("meadowCover", .17, "8D9A68"), ("meadowFlowers", .33, "DAB38B"),
        )[index % 4]
        garden_prop(planting, key, (px, floor(px, pz) - .035, pz), scale, 16 + index * 31, tint)
    for piece in planting.iter("Item"):
        shadow = piece.find("Properties/bool[@name='CastShadow']")
        if shadow is not None:
            shadow.text = "false"
