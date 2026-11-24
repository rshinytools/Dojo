"""Build Reedguard's original segmented visual shell and render a Blender art preview."""

import argparse
import json
from math import cos, pi, sin
from pathlib import Path
import sys

import bpy
from mathutils import Matrix, Vector


OUT = Path(__file__).resolve().parent
# One Blender unit represents one stud in the art handoff. Check the importer.
PIVOTS = {
    "Torso": (0, 0, 2.132),
    "Head": (0, 0, 3.075),
    "Right Arm": (0.82, 0, 2.706),
    "Left Arm": (-0.82, 0, 2.706),
    "Right Leg": (0.4674, 0, 1.394),
    "Left Leg": (-0.4674, 0, 1.394),
    "Tail": (0, 0.369, 1.599),
}
GROUPS = {name: [] for name in PIVOTS}
CHAMFER = ((-.69, -1), (.69, -1), (1, -.66), (1, .66),
           (.69, 1), (-.69, 1), (-1, .66), (-1, -.66))


def linear(channel):
    return channel / 12.92 if channel <= .04045 else ((channel + .055) / 1.055) ** 2.4


def srgb(channel):
    return 12.92 * channel if channel <= .0031308 else 1.055 * channel ** (1 / 2.4) - .055


def material(name, hex_value, roughness=.8, grain=None, metallic=0):
    mat = bpy.data.materials.new(name)
    color = tuple(linear(int(hex_value[i:i + 2], 16) / 255) for i in (0, 2, 4))
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if grain:
        nodes = mat.node_tree.nodes
        noise = nodes.new("ShaderNodeTexNoise")
        noise.inputs["Scale"].default_value = grain
        noise.inputs["Detail"].default_value = 2
        bump = nodes.new("ShaderNodeBump")
        bump.inputs["Strength"].default_value = .19
        bump.inputs["Distance"].default_value = .018
        mat.node_tree.links.new(noise.outputs["Fac"], bump.inputs["Height"])
        mat.node_tree.links.new(bump.outputs["Normal"], shader.inputs["Normal"])
    return mat


def mesh(group, name, vertices, faces, surf, *, bevel=0):
    data = bpy.data.meshes.new(name)
    data.from_pydata(vertices, [], faces)
    data.update()
    model = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(model)
    model.data.materials.append(surf)
    if group:
        GROUPS[group].append(model)
    if bevel:
        edge = model.modifiers.new("Softened edges", "BEVEL")
        edge.width, edge.segments = bevel, 2 if group == "Head" and bevel >= .02 else 1
        edge.limit_method = "ANGLE"
        edge.angle_limit = .35
        edge.harden_normals = True
    return model


def connect_rings(group, name, rings, surf, bevel=0):
    length = len(rings[0])
    vertices = [vertex for ring in rings for vertex in ring]
    faces = [tuple(reversed(range(length)))]
    for index in range(len(rings) - 1):
        offset = index * length
        for side in range(length):
            nxt = (side + 1) % length
            faces.append((offset + side, offset + nxt, offset + length + nxt, offset + length + side))
    faces.append(tuple(range(len(vertices) - length, len(vertices))))
    return mesh(group, name, vertices, faces, surf, bevel=bevel)


def loft(group, name, sections, surf, bevel=.02):
    """Sections run from the bottom up, with chamfered cross-sections."""
    rings = [[(x + u * w, y + v * d, z) for u, v in CHAMFER]
             for z, x, y, w, d in sections]
    return connect_rings(group, name, rings, surf, bevel)


def rounded_box(group, name, position, size, surf, bevel=.035, rotation=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=position)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(surf)
    if bevel:
        edge = obj.modifiers.new("Softened edges", "BEVEL")
        edge.width, edge.segments = bevel, 2 if group == "Head" and bevel >= .02 else 1
        edge.harden_normals = True
    if rotation:
        obj.rotation_euler = rotation
    if group:
        GROUPS[group].append(obj)
    return obj


def tube(group, name, path, radii, surf, *, sides=8, aspect=1):
    """Use parallel edge rings to avoid the primitive seams of a segmented tail."""
    rings = []
    points = [Vector(point) for point in path]
    for i, (point, radius) in enumerate(zip(points, radii)):
        forward = (points[min(i + 1, len(points) - 1)] - points[max(i - 1, 0)]).normalized()
        right = forward.cross(Vector((1, 0, 0)))
        if right.length < .08:
            right = forward.cross(Vector((0, 0, 1)))
        right.normalize()
        across = forward.cross(right)
        rings.append([tuple(point + radius * (cos(2 * pi * j / sides) * right +
                                               aspect * sin(2 * pi * j / sides) * across))
                      for j in range(sides)])
    return connect_rings(group, name, rings, surf)


def plate(group, name, outline, surf, thickness=.025, bevel=.009):
    outline = [Vector(point) for point in outline]
    n = (outline[1] - outline[0]).cross(outline[2] - outline[0]).normalized()
    front = [tuple(v) for v in outline]
    back = [tuple(v - n * thickness) for v in outline]
    return connect_rings(group, name, [back, front], surf, bevel)


def ellipse(group, name, center, scale, surf):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(surf)
    GROUPS[group].append(obj)
    return obj


def make_fighter():
    gold = material("Kangaroo ochre", "D19948", .77, 95)
    lit = material("Sunlit cheek and toes", "EDBE76", .77, 95)
    cream = material("Muzzle and throat sand", "EFC999", .76, 82)
    ear = material("Warm ear lining", "C97D66", .83)
    ear_deep = material("Ear lining fold", "A3574C", .87)
    dark = material("Warm ink", "291C21", .62)
    white = material("Eye ivory", "FFF0D4", .55)
    iris = material("Copper iris", "733D23", .47)
    white_glint = material("Painted eye glint", "FFF9EC", .35)
    wrap = material("Crimson padded cloth", "82303A", .88, 145)
    wrap_colors = [material("Dyed red weave " + str(i + 1), h, .89, 140)
                   for i, h in enumerate(("9D4046", "AC5050", "A04448", "B55755"))]
    stitch = material("Warm cloth edge thread", "D17663", .89, 165)
    walnut = material("Dark walnut tunic", "403039", .88, 115)
    walnut_lit = material("Tunic folded leather", "563840", .88, 112)
    leather = material("Reed brace leather backing", "795031", .84, 120)
    reeds = [material("Cured festival reed " + str(i + 1), col, .79, 98)
             for i, col in enumerate(("CA9756", "E4B46D", "B57E42"))]
    brass = material("Antique gold piping", "D9A65B", .52, metallic=.24)

    loft("Torso", "Tapered chest", [(1.55, 0, .02, .54, .345), (1.82, 0, .026, .60, .37),
         (2.32, 0, .04, .73, .445), (2.66, 0, .05, .76, .398),
         (2.85, 0, .07, .56, .335), (2.99, 0, .09, .33, .255)], gold, .045)
    loft("Torso", "Sand chest plane", [(1.78, 0, -.332, .30, .025), (2.10, 0, -.366, .39, .068),
         (2.52, 0, -.347, .44, .075), (2.73, 0, -.272, .34, .105),
         (2.88, 0, -.187, .18, .088)], cream, .017)
    loft("Torso", "Dark training overskirt", [(1.08, 0, .015, .68, .405),
         (1.34, 0, .00, .70, .435), (1.62, 0, -.006, .58, .375),
         (1.77, 0, 0, .575, .368)], walnut, .027)
    for z, breadth, depth, surf in ((1.63, .636, .430, wrap), (1.71, .634, .434, wrap_colors[0]),
                                       (1.785, .611, .413, wrap_colors[2])):
        loft("Torso", "Layered waist sash", [(z - .04, 0, 0, breadth, depth),
             (z + .04, 0, 0, breadth, depth)], surf, .014)
    rounded_box("Torso", "Sash knot", (-.22, -.409, 1.70), (.265, .248, .159), wrap_colors[1],
                .03, (0, .15, .12))
    for side in (-1, 1):
        x = .31 * side
        front = [(x - .27, -.443, 1.67), (x - .22, -.513, .96),
                 (x + .13, -.535, .83), (x + .20, -.495, 1.19),
                 (x + .23, -.446, 1.67)]
        plate("Torso", "Split festival tabard", front, wrap_colors[(side + 1) // 2], .055, .012)
        piping = [tuple(Vector(point) + Vector((0, -.018, 0))) for point in front[:4]]
        tube("Torso", "Gold tabard binding", piping, [.019] * 4, brass, sides=5)
        # Three unequal reed blades repeat the project's original shoulder motif.
        for j in range(3):
            root = Vector((x - .019, -.536, 1.09))
            stem = Vector((x + (j - 1) * .105, -.520, 1.31 + .05 * (j == 1)))
            middle = (root + stem) / 2
            plate("Torso", "Reed-blade embroidery", [tuple(root), tuple(middle - Vector((.035, 0, 0))),
                    tuple(stem), tuple(middle + Vector((.029, 0, -.018)))], brass, .007, .002)
        rounded_box("Torso", "Overskirt hip fold", (side * .58, -.02, 1.29),
                    (.220, .69, .4), walnut_lit, .044, (0, side * .20, 0))

    for back in (False, True):
        signs = 1 if back else -1
        path = [Vector((-.49 + 1.05 * i / 16, signs * (.323 + .10 * sin(pi * i / 16)), 1.94 + .91 * i / 16))
                for i in range(17)]
        cross = Vector((-.64, 0, .77)).normalized()
        tube("Torso", "Continuous brace leather", path, [.108] * len(path), leather, sides=6, aspect=1.26)
        for j in range(5):
            stripe = [p + cross * ((j - 2) * .043) + Vector((0, signs * .073, 0)) for p in path]
            tube("Torso", "Longitudinal woven reed", stripe, [.025] * len(stripe), reeds[j % 3], sides=5)
        for i in range(1, 16):
            across = [path[i] + cross * (.109 - j * .0545) +
                      Vector((0, signs * (.079 + .029 * (j % 2 == i % 2)), 0)) for j in range(5)]
            tube("Torso", "Over-under reed stitch", across, [.016] * 5, reeds[(i + 1) % 3], sides=5)
    for i in range(6):
        x = .43 + .07 * i
        tube("Torso", "Shoulder guard rib",
             [(x, -.26, 2.84), (x, -.17, 2.98), (x, .014, 3.015),
              (x, .167, 2.97), (x, .275, 2.83)], [.041, .048, .049, .042, .031], reeds[i % 3], sides=6)

    loft("Head", "Angular kangaroo skull", [(2.88, 0, .11, .275, .255), (3.03, 0, .053, .39, .31),
         (3.23, 0, .042, .49, .358), (3.50, 0, .08, .488, .335),
         (3.67, 0, .13, .37, .29), (3.74, 0, .135, .263, .207)], gold, .025)
    snout_sections = ((-.288, .33, 3.135, .182), (-.465, .309, 3.113, .169),
                      (-.70, .237, 3.105, .123), (-.825, .143, 3.096, .088))
    connect_rings("Head", "Sculpted sand muzzle",
                  [[(u * width, depth, height + v * tall) for u, v in CHAMFER]
                   for depth, width, height, tall in snout_sections], cream, .023)
    loft("Head", "Defined jaw", [(2.937, 0, -.372, .205, .195),
         (2.989, 0, -.419, .257, .285), (3.093, 0, -.464, .292, .298)], lit, .024)
    # Nose tapers to a soft point with nostril shadows instead of a flat black rectangle.
    connect_rings("Head", "Graphite nose",
                  [[(u * width, depth, 3.168 + v * height) for u, v in CHAMFER]
                   for depth, width, height in ((-.740, .153, .085), (-.845, .151, .071), (-.891, .096, .048))],
                  dark, .014)
    for side in (-1, 1):
        tube("Head", "Natural mouth corner", [(side * .047, -.831, 3.044), (side * .145, -.787, 3.024),
             (side * .228, -.701, 3.029), (side * .282, -.586, 3.072)],
             [.012, .012, .012, .008], iris, sides=5)
        eye_outline = [(.090, -.320, 3.445), (.366, -.302, 3.522), (.473, -.207, 3.426),
                       (.358, -.304, 3.322), (.150, -.351, 3.323)]
        def side_outline(outline):
            points = [(side * x, y, z) for x, y, z in outline]
            return points if side == 1 else list(reversed(points))
        plate("Head", "Outboard eye socket", side_outline(eye_outline), dark, .047, .019)
        white_outline = [(.135, -.341, 3.429), (.352, -.321, 3.482), (.426, -.267, 3.421),
                         (.341, -.328, 3.351), (.166, -.365, 3.350)]
        plate("Head", "Tapered eye white", side_outline(white_outline), white, .026, .012)
        ellipse("Head", "Copper fighting eye", (side * .273, -.363, 3.414), (.072, .016, .058), iris)
        ellipse("Head", "Pupil", (side * .259, -.377, 3.418), (.038, .012, .05), dark)
        ellipse("Head", "Catchlight", (side * .241, -.389, 3.447), (.013, .006, .013), white_glint)
        brow = [(.092, -.353, 3.482), (.320, -.329, 3.570), (.463, -.240, 3.548),
                (.386, -.302, 3.497), (.154, -.360, 3.460)]
        plate("Head", "Expressive swept brow", side_outline(brow), dark, .040, .016)
        cheek = [(.263, -.306, 3.267), (.422, -.207, 3.367), (.472, -.126, 3.240),
                 (.371, -.210, 3.138), (.267, -.294, 3.143)]
        plate("Head", "Golden cheek break", side_outline(cheek), lit, .025, .014)

    for side, tip_z, tip_x in ((1, 4.93, .66), (-1, 4.65, .94)):
        base_x = side * .24
        profile = ((.15, 3.59), (.16, 3.99), (tip_x * .73, tip_z - .24), (tip_x, tip_z),
                   (tip_x * 1.09, tip_z - .23), (.57 if side == 1 else .72, 4.06), (.29, 3.58))
        if side < 0:
            profile = tuple(reversed(profile))

        def ear_face(x, z, offset=0):
            return (side * x, .055 + .10 * (z - 3.59) + .05 * x + offset, z)

        outline = [ear_face(x, z) for x, z in profile]
        back = [ear_face(x, z, .105) for x, z in profile]
        connect_rings("Head", "Asymmetric angular ear", [outline, back], gold, .021)
        # Both ear liners sit on the modeled front plane, including when viewed from the ring side.
        mid_x, mid_z = .35 if side == 1 else .43, 4.09
        inner_profile = [(mid_x + (x - mid_x) * .73, mid_z + (z - mid_z) * .76)
                         for x, z in profile]
        inner = [ear_face(x, z, -.019) for x, z in inner_profile]
        backing = [ear_face(x, z, .003) for x, z in inner_profile]
        connect_rings("Head", "Recessed ear lining", [inner, backing], ear, .01)
        tube("Head", "Ear lining center fold",
             [ear_face(.277, 3.80, -.027), ear_face(tip_x * .67, tip_z - .33, -.027),
              ear_face(tip_x * .76, tip_z - .24, -.025)],
             [.016, .010, .003], ear_deep, sides=5)
        if side < 0:
            tube("Head", "Short ear woven tie", [(-.448, .014, 3.974), (-.323, -.015, 4.017),
                 (-.203, .049, 4.018)], [.025, .032, .022], reeds[0], sides=6)

    for side, arm, leg in ((1, "Right Arm", "Right Leg"), (-1, "Left Arm", "Left Leg")):
        x = side * .99
        loft(arm, "Defined upper arm", [(2.01, x + side * .05, -.02, .232, .236),
             (2.22, x + side * .11, .053, .262, .276), (2.51, x + side * .075, .050, .283, .301),
             (2.77, x, .034, .276, .281), (2.875, x - side * .066, .017, .197, .188)], gold, .035)
        loft(arm, "Forearm taper", [(1.71, x + side * .079, -.258, .213, .212),
             (1.92, x + side * .074, -.178, .232, .222), (2.16, x + side * .06, -.081, .241, .247)], lit, .027)
        loft(arm, "Padded square fist", [(1.43, x + side * .049, -.401, .240, .283),
             (1.52, x + side * .065, -.396, .333, .35), (1.86, x + side * .081, -.337, .321, .303),
             (2.01, x + side * .073, -.244, .228, .227)], wrap, .048)
        for i, surf in enumerate(wrap_colors):
            z = 1.556 + .108 * i
            width = (.318, .330, .324, .297)[i]
            y = -.401 + .044 * i
            depth = (.350, .335, .320, .289)[i]
            loft(arm, "Overlapping knuckle band", [(z - .05, x + side * .073, y, width, depth),
                 (z + .051, x + side * .080, y - .02, width - .002, depth + .004)], surf, .022)
            tube(arm, "Raised knuckle seam", [(x - width * .53, y - depth - .004, z + .04),
                 (x, y - depth - .008, z + .044), (x + width * .66, y - depth, z + .031)],
                 [.007, .007, .006], stitch, sides=5)
        rounded_box(arm, "Fist thumb fold", (x - side * .222, -.436, 1.675),
                    (.236, .418, .29), wrap_colors[0], .054, (0, side * .31, .08))

        x = side * .431
        loft(leg, "Strong tapered hind leg", [(.15, x, -.03, .191, .218),
             (.37, x + side * .023, .074, .219, .232), (.64, x + side * .045, .153, .266, .263),
             (.90, x + side * .069, .145, .318, .317), (1.12, x + side * .047, .095, .348, .347),
             (1.49, x, .024, .326, .308)], gold, .028)
        loft(leg, "Kangaroo runner foot", [(.0, x, -.229, .331, .556),
             (.098, x, -.244, .335, .569), (.18, x, -.171, .303, .475),
             (.28, x, -.038, .234, .351)], gold, .018)
        for toe in (-1, 0, 1):
            rounded_box(leg, "Defined sand toe", (x + toe * .184, -.657 + abs(toe) * .028, .098),
                        (.166, .234, .154), lit if toe == 0 else cream, .027)
        loft(leg, "Ankle cloth", [(.273, x, .019, .220, .229), (.415, x, .070, .237, .229)],
             wrap_colors[0], .016)
        loft(leg, "Ankle cloth overlap", [(.341, x, .052, .233, .240), (.383, x, .053, .240, .235)],
             wrap_colors[3], .009)

    tube("Tail", "Single sweeping kangaroo tail",
         [(0, .255, 1.60), (.038, .630, 1.36), (.091, .994, 1.004), (.157, 1.434, .674),
          (.247, 1.885, .502), (.348, 2.270, .465), (.414, 2.602, .518),
          (.425, 2.838, .644), (.412, 2.977, .805)],
         [.278, .290, .259, .213, .168, .121, .083, .047, .014], gold, sides=10, aspect=.95)


def merge_groups():
    for group, parts in GROUPS.items():
        bpy.ops.object.select_all(action="DESELECT")
        for obj in parts:
            obj.select_set(True)
            bpy.context.view_layer.objects.active = obj
            for mod in list(obj.modifiers):
                bpy.ops.object.modifier_apply(modifier=mod.name)
        bpy.context.view_layer.objects.active = parts[0]
        if len(parts) > 1:
            bpy.ops.object.join()
        obj = bpy.context.object
        bpy.context.scene.cursor.location = PIVOTS[group]
        bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
        obj.name = group.replace(" ", "_") + "_Shell"
        obj.data.name = obj.name
        obj["rig_group"] = group
        GROUPS[group] = [obj]


def bake_import_atlas():
    """Flatten the runtime look into one small embedded base-color atlas."""
    bodies = [parts[0] for parts in GROUPS.values()]
    colors = list(dict.fromkeys(mat for obj in bodies for mat in obj.data.materials))
    tile = 64
    per_row = 8
    width = per_row * tile
    # Square power-of-two storage avoids a format conversion at import.
    pixels = [1.0] * (4 * width * width)
    for index, source in enumerate(colors):
        ox = (index % per_row) * tile
        oy = (index // per_row) * tile
        red, green, blue, _ = source.diffuse_color
        for y in range(tile):
            for x in range(tile):
                strain = ((x * 19 + y * 43 + (x*y) * 67) % 61) / 61
                grain = .885 + .11 * strain + .045 * sin(x * .68 + y * .81)
                i = ((oy + y) * width + ox + x) * 4
                pixels[i:i + 4] = [min(1.0, max(0.0, srgb(value * grain)))
                                   for value in (red, green, blue)] + [1.0]
    image = bpy.data.images.new("Reedguard embedded color atlas", width, width, alpha=False)
    image.pixels.foreach_set(pixels)
    image.update()
    image.pack()

    atlas = bpy.data.materials.new("Reedguard shell atlas")
    atlas.use_nodes = True
    shader = atlas.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Roughness"].default_value = .82
    paint = atlas.node_tree.nodes.new("ShaderNodeTexImage")
    paint.image = image
    atlas.node_tree.links.new(paint.outputs["Color"], shader.inputs["Base Color"])

    preview_slots = []
    for obj in bodies:
        data = obj.data
        saved = list(data.materials)
        slots = [face.material_index for face in data.polygons]
        preview_slots.append((obj, saved, slots))
        while data.uv_layers:
            data.uv_layers.remove(data.uv_layers[0])
        uvs = data.uv_layers.new(name="ImportColorAtlas")
        uvs.active_render = True
        data.uv_layers.active = uvs
        # Sample useful space inside one painted tile. Padding prevents color bleed between materials.
        for face in data.polygons:
            material_index = colors.index(saved[face.material_index])
            tx, ty = material_index % per_row, material_index // per_row
            axis = max(range(3), key=lambda n: abs(face.normal[n]))
            plane = [n for n in range(3) if n != axis]
            for loop_index in face.loop_indices:
                coordinate = data.vertices[data.loops[loop_index].vertex_index].co
                u, v = (min(.855, max(.145, .5 + coordinate[n] * .17)) for n in plane)
                uvs.data[loop_index].uv = ((tx + u) / per_row, (ty + v) / per_row)
        data.materials.clear()
        data.materials.append(atlas)
    return preview_slots


def restore_preview_materials(snapshots):
    for obj, materials, indices in snapshots:
        obj.data.materials.clear()
        for source in materials:
            obj.data.materials.append(source)
        for face, index in zip(obj.data.polygons, indices):
            face.material_index = index


def mirror_to_runtime_axes():
    """Make glTF face -Z while preserving Blender X as the Roblox side."""
    mirror = Matrix.Diagonal((1.0, -1.0, 1.0, 1.0))
    for parts in GROUPS.values():
        obj = parts[0]
        obj.data.transform(mirror)
        obj.data.flip_normals()
        obj.location.y *= -1
        obj.data.update()
    bpy.context.view_layer.update()


def model_report():
    meshes = {}
    visual_height = 0.0
    for group, parts in GROUPS.items():
        obj = parts[0]
        obj.data.calc_loop_triangles()
        bounds = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
        lo = [round(min(v[i] for v in bounds), 4) for i in range(3)]
        hi = [round(max(v[i] for v in bounds), 4) for i in range(3)]
        visual_height = max(visual_height, hi[2])
        meshes[group] = {"node": obj.name, "triangles": len(obj.data.loop_triangles),
                         "blender_pivot_xyz": list(PIVOTS[group]),
                         "gltf_pivot_xyz": [PIVOTS[group][i] for i in (0, 2, 1)],
                         "blender_bounds_min_xyz": lo, "blender_bounds_max_xyz": hi}
    return {"art_height": visual_height, "triangles": sum(m["triangles"] for m in meshes.values()),
            "blender_axes": "Z up, forward -Y.", "gltf_axes": "Y up, forward -Z.",
            "atlas": "One embedded 512 × 512 PNG on TEXCOORD_0.", "groups": meshes}


def art_pose():
    pose = {
        "Head": (0, .075, -.10), "Torso": (0, -.04, .024),
        "Right Arm": (-1.47, -.17, -.13), "Left Arm": (-1.16, .11, .115),
        "Right Leg": (.04, -.115, -.12), "Left Leg": (-.09, .13, .07), "Tail": (0, .02, -.16),
    }
    for group, angles in pose.items():
        GROUPS[group][0].rotation_euler = angles


def aim(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat("-Z", "Y").to_euler()


def area(name, point, target, power, size, rgb):
    data = bpy.data.lights.new(name, "AREA")
    data.energy, data.shape, data.size, data.color = power, "DISK", size, rgb
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.location = point
    aim(obj, target)


def preview(args):
    scene = bpy.context.scene
    art_pose()
    platform = material("Dojo mat slate", "453A4B", .9)
    border = material("Muted ring edge", "BF8764", .81)
    floor = material("Studio backdrop plum", "292332", .93)
    rounded_box(None, "Backdrop", (0, 0, -.16), (200, 200, .11), floor, .03)
    rounded_box(None, "Rounded sparring mat", (0, .56, -.113), (6.96, 6.72, .17), platform, .19)
    for x in (-2.92, 2.92):
        rounded_box(None, "Mat marked edge", (x, .53, -.027), (.025, 5.64, .008), border, .005)
    for y in (-2.28, 3.34):
        rounded_box(None, "Mat marked edge", (0, y, -.027), (5.84, .025, .008), border, .005)
    data = bpy.data.cameras.new("Three-quarter preview")
    camera = bpy.data.objects.new("Three-quarter preview", data)
    bpy.context.collection.objects.link(camera)
    camera.location = (7.35, -10.6, 5.23)
    aim(camera, (0, .41, 2.40))
    data.type, data.ortho_scale = "ORTHO", 6.43
    scene.camera = camera
    area("Warm lantern key", (1.5, -5, 6.1), (0, .1, 2.4), 720, 4.2, (1, .77, .53))
    area("Cool city fill", (-3.1, -1.2, 4.1), (0, 0, 2.2), 450, 4.7, (.64, .77, 1))
    area("Golden eave rim", (-1.1, 3.8, 5.9), (0, .35, 2.9), 1080, 3.5, (1, .60, .33))
    scene.world = bpy.data.worlds.new('Plum room ambience')
    scene.world.color = (.17, .14, .18)
    scene.render.engine = "CYCLES"
    scene.cycles.samples, scene.cycles.use_denoising = (12 if args.quick else 36), True
    scene.render.resolution_x, scene.render.resolution_y = (560, 589) if args.quick else (900, 946)
    scene.render.resolution_percentage = 100
    scene.view_settings.view_transform = "AgX"
    scene.view_settings.look = "AgX - Medium High Contrast"
    scene.render.image_settings.file_format = "JPEG"
    scene.render.image_settings.quality = 93
    scene.render.filepath = str(OUT / "Reedguard_Guard_Offline_Blender.jpg")
    bpy.ops.render.render(write_still=True)
    if args.save_blend:
        bpy.context.preferences.filepaths.save_version = 0
        scene.render.filepath = "//Reedguard_Guard_Offline_Blender.jpg"
        bpy.ops.wm.save_as_mainfile(filepath=str(OUT / "Reedguard_Festival_Preview.blend"), compress=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--quick", action="store_true")
    parser.add_argument("--skip-render", action="store_true")
    parser.add_argument("--save-blend", action="store_true", help="save the editable guard-pose preview scene")
    args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:])
    bpy.ops.wm.read_factory_settings(use_empty=True)
    make_fighter()
    merge_groups()
    bpy.ops.object.select_all(action="SELECT")
    snapshots = bake_import_atlas()
    mirror_to_runtime_axes()
    bpy.ops.export_scene.gltf(filepath=str(OUT / "Reedguard_Festival_Shell.glb"), export_format="GLB",
                              use_selection=True, export_extras=True, export_yup=True,
                              export_animations=False, export_apply=True)
    mirror_to_runtime_axes()
    restore_preview_materials(snapshots)
    report = model_report()
    (OUT / "rig-bindings.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"height": report["art_height"], "triangles": report["triangles"]}), flush=True)
    if not args.skip_render:
        preview(args)


if __name__ == "__main__":
    main()
