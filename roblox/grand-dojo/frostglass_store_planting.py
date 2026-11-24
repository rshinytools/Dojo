"""Screened Creator Store winter foliage for Frostglass Gardens."""

from math import hypot

from south_valley_backdrop import ridge_surface_height


# Station along the final Lantern road span, roadside toe, bank depth and
# crown height relative to the pavement. The two shoulders break at different
# heights, leaving the gate and its sign visible in the space between them.
_APPROACH_BANKS = (
    ((.29, 9.1, 7.8, -3.1), (.40, 8.8, 10.4, .12),
     (.55, 8.65, 10.8, 1.60), (.68, 8.8, 11.1, 1.05),
     (.80, 9.02, 9.7, -.33), (.85, 9.2, 7.2, -2.9)),
    ((.34, 9.1, 7.2, -3.0), (.46, 8.85, 8.8, -.94),
     (.62, 8.7, 9.6, .48), (.76, 8.88, 8.8, -.45),
     (.90, 9.12, 6.8, -2.6)),
)
_ROCK_TONES = ("777588", "817E90", "89869B", "9692A4", "A29CAD")
_SNOW_TONES = ("C9CCDC", "D4D8E5", "C3CBDA", "DDE0EA")


def _planting(parent, label, *, item, prop, part, vector, asset):
    planting = item(parent, "Model", label)
    prop(planting, "token", "ModelStreamingMode", 1)

    def mesh(name, x, z, yaw, size, mesh_size, mesh_id, texture_id, floor, *, double_sided=False):
        decoration = part(planting, name, (x, floor + size[1] / 2 - .035, z), size,
                          "A3A2A5", yaw=yaw, material=256, collide=False, class_name="MeshPart")
        vector(decoration, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        prop(decoration, "bool", "DoubleSided", double_sided)
        prop(decoration, "bool", "CastShadow", False)
        prop(decoration, "token", "RenderFidelity", 0)
        asset(decoration, "MeshContent", f"rbxassetid://{mesh_id}")
        asset(decoration, "TextureContent", f"rbxassetid://{texture_id}")
        return decoration

    # Striatp's Small Snowy Pine Tree, Creator Store 76188132698241.
    pine_size = (9.574310, 15.486298, 9.574753)
    def pine(name, x, z, yaw, scale, floor):
        tree = mesh(name, x, z, yaw,
                    tuple(axis * scale for axis in pine_size), pine_size, 6436440031, 6341718741,
                    floor, double_sided=True)
        material = item(tree, "SurfaceAppearance", "Creator Store snowy pine material")
        prop(material, "token", "AlphaMode", 1)
        asset(material, "ColorMapContent", "rbxassetid://6901062953")

    return pine, mesh


def build_frostglass_store_planting(town, *, item, prop, part, vector, asset):
    pine, mesh = _planting(town, "Frostglass winter planting", item=item, prop=prop, part=part,
                           vector=vector, asset=asset)
    floor = 14.027
    for x, z, yaw, scale in ((-216.27, -194.15, 18, .33), (-162.19, -204.20, 53, .37),
                             (-210.21, -204.84, 87, .42)):
        pine("Snow-dusted courtyard pine", x, z, yaw, scale, floor)

    # akmadman7273's Snow Bush, Creator Store 1163700582.
    bush_size = (6.442000, 4.138090, 6.317780)
    for x, z, yaw, scale in ((-198.80, -158.65, 35, .25), (-177.82, -154.29, 64, .21),
                             (-163.66, -204.53, 102, .24)):
        mesh("Frosted garden shrub", x, z, yaw, tuple(axis * scale for axis in bush_size),
             bush_size, 742756209, 1093033181, floor)


def build_frostglass_approach_planting(roads, *, item, prop, part, vector, asset, triangle,
                                      garden_prop, rock, snow, rock_variant, variant_field):
    pine, _ = _planting(roads, "Frostglass approach pines", item=item, prop=prop, part=part,
                        vector=vector, asset=asset)
    # Ground heights measured against native Terrain in Studio Play.
    for x, z, yaw, scale, floor in (
        (-219, -123, 18, .41, 7.40),
        (-217, -134, 77, .49, 8.25),
        (-214, -142, 44, .34, 10.73),
        (-199, -119, 32, .33, 7.99),
        (-193, -130, 63, .40, 9.80),
        (-191, -138, 81, .50, 10.54),
    ):
        pine("Snow-dusted roadside pine", x, z, yaw, scale, floor)

    for side, sections, pines in (
        (1, _APPROACH_BANKS[0], ((.43, 14.55, 30, .53), (.70, 15.06, 77, .66))),
        (-1, _APPROACH_BANKS[1], ((.55, 13.62, 41, .55), (.76, 13.48, 112, .60))),
    ):
        _build_approach_bank(roads, side, sections, pines, item=item, prop=prop, part=part,
                             vector=vector, asset=asset, triangle=triangle, garden_prop=garden_prop,
                             rock=rock, snow=snow, rock_variant=rock_variant, variant_field=variant_field)


def _build_approach_bank(roads, side, sections, pines, *, item, prop, part, vector, asset, triangle,
                         garden_prop, rock, snow, rock_variant, variant_field):
    bank = item(roads, "Model", "Frostglass west snow ledges" if side == 1 else "Frostglass east snow ledges")
    prop(bank, "token", "ModelStreamingMode", 1)
    prop(bank, "token", "LevelOfDetail", 4)
    length = hypot(14, 41)

    def point(station, offset, height):
        return (-216 + 14 * station - 41 / length * offset * side, height,
                -108 - 41 * station - 14 / length * offset * side)

    # The inner slope shows stone faces and a caught stripe of snow. The
    # broad crest holds the pines, with the rear face buried into the bank.
    contours = []
    for across, rise in ((0, 0), (.15, .53), (.30, .67), (.39, .92), (.66, 1), (1, 0)):
        row = []
        for index, (station, toe, depth, crown) in enumerate(sections):
            pavement = 10 + 4 * station
            shift = across * (1 - across) * (.019 if index % 2 else -.018)
            row.append(point(station + shift, toe + depth * across,
                             pavement - 5.55 + (crown + 5.55) * rise))
        contours.append(row)
    faces = []

    def facet(points, covered, index):
        faces.append(points)
        before = len(bank)
        colors = _SNOW_TONES if covered else _ROCK_TONES
        triangle(bank, *points, colors[index % len(colors)],
                 name="Drifted snow cap" if covered else "Stratified Frostglass stone",
                 material=snow if covered else rock, thickness=.13, shadow=False, collide=False)
        if not covered:
            for piece in bank[before:]:
                prop(piece, "string", variant_field, rock_variant)

    for band, (inner, outer) in enumerate(zip(contours, contours[1:])):
        for index, (a, b, c, d) in enumerate(zip(inner, inner[1:], outer, outer[1:])):
            covered = band == 3 or (band == 1 and index % 3 != 1)
            facet((a, b, c), covered, index + band)
            facet((b, d, c), covered, index + band + 1)
    for end in (0, -1):
        toe = contours[0][end]
        for band, (inner, outer) in enumerate(zip(contours[1:], contours[2:])):
            facet((toe, inner[end], outer[end]), False, band + 1)

    pine, _ = _planting(bank, "Snow ledge trees", item=item, prop=prop, part=part, vector=vector, asset=asset)
    for station, offset, yaw, scale in pines:
        x, _, z = point(station, offset, 0)
        ground = ridge_surface_height(faces, x, z)
        pine("Snow ledge pine", x, z, yaw, scale, ground)
        for kind, along, across, size, tint in (
            ("bankRock", .022, -.75, .26, "9690A5"),
            ("meadowCover", -.025, .85, .19, "C0CDC2"),
            ("grassBlade", .011, 1.32, .27, "BBC3B0"),
        ):
            x, _, z = point(station + along, offset + across, 0)
            height = ridge_surface_height(faces, x, z)
            before = len(bank)
            garden_prop(bank, kind, (x, height - .08, z), size, yaw + 22, tint)
            for piece in bank[before:]:
                shadow = piece.find("Properties/bool[@name='CastShadow']")
                if shadow is not None:
                    shadow.text = "false"
