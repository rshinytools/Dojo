"""Staggered clay shelves beyond the north rail of Copper Kiln Walk."""

from math import cos, pi, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Desert Rocks Pack, sshhhh6408, Creator Store 10730751733. Detached Studio
# inspection found these individual MeshParts had no children or texture IDs.
# InitialSize uses the unscaled MeshSize, independent of the store placements.
STORE_STONES = {
    "Cube.005": (10730695008, (590.528748, 129.243088, 391.128632)),
    "Cube.008": (10730695083, (812.263611, 381.683350, 592.743652)),
    "Cube.010": (10730695055, (873.843933, 225.131348, 571.961670)),
}

SHELVES = (
    # Center, radii, crown, planted ribs. The north rail remains in the foreground.
    ((180.4, -263.35), (15.3, 12.9), 20.8,
     ((175.9, -258.5, .78), (182.5, -260.4, .92), (177.0, -267.2, .65))),
    ((200.4, -242.7), (16.0, 11.5), 15.8,
     ((196.3, -238.55, .73), (201.4, -237.8, .86), (204.1, -245.5, .74))),
    ((215.2, -217.4), (12.4, 10.2), 10.4,
     ((210.25, -216.0, .69), (215.25, -221.6, .79), (219.3, -219.75, .60))),
)
CLAY = (("977264", "A77B69", "9D7468"), ("AB806B", "B08570", "A37B67"),
        ("B68D70", "AA8269", "BB9378"), ("AA846C", "B68C74", "A5806D"))


def build_cinder_ravine_terraces(town, *, item, prop, part, triangle, vector, asset,
                                garden_prop, stone, grass, cedar, stone_variant, variant_field):
    terraces = item(town, "Model", "Cinder ravine clay terraces")
    prop(terraces, "token", "ModelStreamingMode", 1)
    prop(terraces, "token", "LevelOfDetail", 4)

    def tree_part(parent, name, point, size, tint, **rotation):
        material = cedar if name.endswith("trunk") else grass
        piece = part(parent, name, point, size, tint, material=material, collide=False, **rotation)
        prop(piece, "bool", "CastShadow", False)

    for shelf_index, ((x, z), (width, depth), crown, trees) in enumerate(SHELVES):
        shelf = item(terraces, "Model", ("Upper clay fan", "Middle potter's shoulder", "Lower glazed aprons")[shelf_index])
        rock = item(shelf, "Folder", "Silted sandstone banks")
        faces = []

        def draw(face, name, tint, material):
            faces.append(face)
            first = len(rock)
            triangle(rock, *face, tint, name=name, material=material, thickness=.22, shadow=False)
            if material == stone:
                for wedge in rock[first:]:
                    prop(wedge, "string", variant_field, stone_variant)

        rings = []
        for band, (radius, lift) in enumerate(((1.0,-4.9), (.90,crown*.24), (.76,crown*.58),
                                               (.65,crown*.75), (.54,crown*.91))):
            points = []
            for j in range(12):
                angle = j * pi / 6 + .19 * shelf_index
                scallop = 1 + .105 * sin(j * 1.73 + shelf_index) - .06 * cos(j * 2.17)
                px = x + cos(angle) * width * radius * scallop + (1 - radius) * 3.3
                pz = z + sin(angle) * depth * radius * scallop - (1 - radius) * 1.8
                height = lift + (.95 + band * .12) * sin(j * .93 + shelf_index)
                points.append((px,height,pz))
            rings.append(points)

        for band, (lower, upper) in enumerate(zip(rings, rings[1:])):
            for j, a in enumerate(lower):
                next_vertex = (j + 1) % len(lower)
                pigment = CLAY[band][(j // 2 + shelf_index) % 3]
                draw((a, lower[next_vertex], upper[j]), "Weathered clay bank", pigment, stone)
                draw((upper[j], lower[next_vertex], upper[next_vertex]), "Weathered clay bank", pigment, stone)
        for j, a in enumerate(rings[-1]):
            material = grass if j in (1, 2, 3, 7, 8, 9) else stone
            tint = ("81845D", "86916C", "7E875E")[j % 3] if material == grass else CLAY[-1][j % 3]
            draw((a, rings[-1][(j + 1) % 12], (x + 2.4, crown, z - 1.2)), "Planted clay crown", tint, material)

        def root(px, pz):
            return px, ridge_surface_height(faces, px, pz), pz

        planting = item(shelf, "Folder", "Dry-slope planting")
        for j, (px, pz, scale) in enumerate(trees):
            rx, ry, rz = root(px, pz)
            hillside_cedar(tree_part, planting, rx, ry - .18, rz, scale, j + shelf_index * 3)
            garden_prop(planting, "meadowCover", root(px + .51,pz + .50), .24, 21 + j*27, "9B9F6D")
            garden_prop(planting, "mossFlowers", root(px - .38,pz - .56), .16, 31 + j*27, "C49B84")
        for j, (dx, dz) in enumerate(((-.59,.41),(-.49,-.28),(.28,.60),(.55,-.17))):
            garden_prop(planting, "meadowGrass", root(x + width*dx,z + depth*dz),
                        .20, 79 + j*41, "ACA268")

    # These skirt pieces are sunk into the authored banks and selectively tinted
    # to match the terracotta architecture. No intact store model is inserted.
    for label, key, position, size, yaw, tint in (
        ("Broken upper buttress", "Cube.008", (178.35, 6.58, -259.5), (21.2, 16.8, 12.8), 26, "A47765"),
        ("Potter's clay shelf", "Cube.005", (194.24, 6.43, -240.7), (23.4, 13.8, 15.6), -32, "AA806C"),
        ("Layered middle foot", "Cube.010", (204.75, 4.08, -237.25), (17.3, 9.45, 12.1), 50, "A67D69"),
        ("Low clay apron", "Cube.010", (214.0, 3.10, -213.3), (18.7, 10.4, 12.7), 41, "9C7767"),
    ):
        identifier, mesh_size = STORE_STONES[key]
        piece = part(terraces, label, position, size, tint, yaw=yaw, material=stone,
                     collide=False, class_name="MeshPart")
        prop(piece, "bool", "CastShadow", False)
        prop(piece, "token", "RenderFidelity", 0)
        prop(piece, "string", variant_field, stone_variant)
        vector(piece, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        asset(piece, "MeshContent", f"rbxassetid://{identifier}")
