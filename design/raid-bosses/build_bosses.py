"""Author and export the two Beast Dojo raid boss redesigns in Blender 4.5."""

import argparse
import json
from math import cos, pi, sin
from pathlib import Path
import sys

import bpy
import bmesh
from mathutils import Vector


def point(xyz):
    x, y, z = xyz
    return Vector((x, -z, y))


def product_color(code):
    def linear(channel):
        return channel / 12.92 if channel < .04045 else ((channel + .055) / 1.055) ** 2.4
    return tuple(linear(int(code[i:i + 2], 16) / 255) for i in (0, 2, 4)) + (1,)


def material(name, tint, metallic=0, roughness=.46, glow=0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = product_color(tint)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = mat.diffuse_color
    shader.inputs["Metallic"].default_value = metallic
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Emission Color"].default_value = mat.diffuse_color
    shader.inputs["Emission Strength"].default_value = glow
    return mat


def finish(name, mat, group, bevel=0):
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    if bevel:
        edge = obj.modifiers.new("Fitted edge bevel", "BEVEL")
        edge.width, edge.segments = bevel, 2
        bpy.ops.object.modifier_apply(modifier=edge.name)
    world = obj.matrix_world.copy()
    obj.parent = group
    obj.matrix_world = world
    return obj


def hinge(name, pivot, parent=None):
    obj = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(obj)
    obj.parent = parent
    obj.matrix_world.translation = point(pivot)
    obj.location = (parent.matrix_world.inverted() @ point(pivot)) if parent else point(pivot)
    bpy.context.view_layer.update()
    return obj


def box(name, at, size, mat, group, bevel=.055, yaw=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=point(at))
    obj = bpy.context.object
    obj.scale = (size[0], size[2], size[1])
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.rotation_euler.z = yaw
    bpy.context.view_layer.update()
    return finish(name, mat, group, bevel)


def lens(name, at, size, mat, group, subdiv=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdiv, radius=1, location=point(at))
    bpy.context.object.scale = (size[0] / 2, size[2] / 2, size[1] / 2)
    bpy.context.view_layer.update()
    return finish(name, mat, group)


def axle(name, start, end, radius, mat, group, tip=None, sides=12, bevel=.035):
    a, b = point(start), point(end)
    bpy.ops.mesh.primitive_cone_add(vertices=sides, radius1=radius, radius2=radius if tip is None else tip,
                                   depth=(b - a).length, location=(a + b) * .5)
    bpy.context.object.rotation_euler = (b - a).to_track_quat("Z", "Y").to_euler()
    bpy.context.view_layer.update()
    return finish(name, mat, group, bevel)


def solid(name, bottom, top, mat, group):
    size = len(bottom)
    data = bpy.data.meshes.new(name)
    data.from_pydata([point(v) for v in bottom + top], [], [tuple(reversed(range(size))),
        tuple(range(size, size * 2)), *((i, (i + 1) % size, (i + 1) % size + size, i + size) for i in range(size))])
    mesh = bmesh.new()
    mesh.from_mesh(data)
    bmesh.ops.recalc_face_normals(mesh, faces=list(mesh.faces))
    mesh.to_mesh(data)
    mesh.free()
    obj = bpy.data.objects.new(name, data)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(mat)
    obj.parent = group
    obj.matrix_parent_inverse = group.matrix_world.inverted()
    return obj


def kilnback():
    rig = hinge("Animated Body", (0, 0, 0))
    bronze = material("Kiln bronze", "92603F", .72, .35)
    gold = material("Hammered gold", "DA9B55", .67, .31)
    iron = material("Dark fired iron", "343033", .62, .43)
    jade = material("Kiln glaze", "2F6A63", .28, .31)
    ember = material("Ember glass", "FF862E", .16, .28, 2.2)
    cyan = material("Exposed furnace", "70F5D9", .17, .29, 2.7)
    tiles = [material("Layered glaze " + str(i), shade, .17, .34)
             for i, shade in enumerate(("DBBB8D", "CBA479", "DACAAC", "C5B7A0"))]
    lens("Armored furnace vessel", (0, 2.5, -.35), (9.7, 4.85, 9.5), jade, rig)
    lens("Cast chassis", (0, 1.68, -.27), (9.08, 2.6, 9.34), iron, rig)
    axle("Crown octagonal rim", (0, 4.66, -.36), (0, 5.06, -.36), 2.28, bronze, rig, sides=8)
    axle("Crown jade inlay", (0, 5.06, -.36), (0, 5.20, -.36), 1.94, jade, rig, sides=8)
    axle("Boiler crown", (0, 5.17, -.36), (0, 5.52, -.36), .89, gold, rig, tip=.72, sides=10)
    for index in range(8):
        theta = index * pi / 4

        def polar(u, y, radius):
            return u * cos(theta) + radius * sin(theta), y, -.30 - u * sin(theta) + radius * cos(theta)

        plate = hinge(f"Shell Plate {index + 1}", polar(0, 4.17, 2.88), rig)
        outline = [(-.86, 4.66, 1.54), (.86, 4.66, 1.54), (1.74, 3.86, 3.94),
                   (1.47, 3.32, 4.94), (-1.47, 3.32, 4.94), (-1.74, 3.86, 3.94)]
        solid("Forged segment backing", [polar(x * 1.06, y - .28, z) for x, y, z in outline],
              [polar(x * 1.06, y - .05, z) for x, y, z in outline], bronze, plate)
        solid("Chamfered ceramic plate", [polar(x, y - .03, z) for x, y, z in outline],
              [polar(x * .95, y + .20, 2.85 + (z - 2.85) * .95) for x, y, z in outline], tiles[index % 4], plate)
        for u in (-.76, .76):
            axle("Pinned ceramic fastener", polar(u, 3.77, 4.28), polar(u, 3.94, 4.30), .15, gold, plate,
                 tip=.12, sides=8)
        axle("Glaze seam accent", polar(0, 4.57, 2.39), polar(0, 3.96, 4.01), .052, gold, plate, sides=6)
    for side in (-1, 1):
        for back in (-1, 1):
            x, z = side * 3.80, back * 3.06
            leg = hinge(f"Leg {1 + (side + 1) + (back + 1) // 2}", (x, 1.4, z), rig)
            axle("Shoulder hinge", (x - .24, 1.69, z), (x + .24, 1.69, z), .61, gold, leg)
            axle("Sloped plated shin", (x, 1.60, z), (x + side * .86, .54, z + back * .78), .49,
                 bronze, leg, tip=.65, sides=6, bevel=.085)
            box("Toe guard", (x + side * .84, .37, z + back * .91), (1.70, .72, 1.66), bronze, leg, .13)
            for toe in (-.43, .43):
                box("Ivory ceramic claw", (x + side * .84 + toe, .24, z + back * 1.58),
                    (.38, .43, .61), tiles[2], leg, .075)
            box("Knee copper panel", (x + side * 1.10, 1.07, z + back * .42),
                (.21, .55, .69), gold, leg, .05)
        word = "Left" if side < 0 else "Right"
        bellows = hinge("Bellows " + word, (side * 4.75, 2.1, -.55), rig)
        for fold in range(4):
            x = side * (4.53 + fold * .32)
            box("Copper bellows fold", (x, 1.94, -.72), (.25, 1.56 - fold * .07, 1.95 - fold * .11),
                bronze if fold % 2 else gold, bellows, .08)
        box("Vent Glow", (side * 5.70, 1.94, -.72), (.11, .93, 1.15), ember, bellows)
        for gap in (-.3, 0, .3):
            box("Cast vent grille", (side * 5.77, 1.94, -.72 + gap), (.10, 1.03, .09), iron, bellows, .018)
        shutter = hinge("Core Shutter " + word, (side * .67, 2.67, 5.55), rig)
        box("Sliding ceramic furnace shield", (side * .93, 2.70, 5.71), (.48, 1.42, .32), bronze, shutter, .10)
    axle("Front furnace bezel", (0, 2.68, 4.88), (0, 2.68, 5.63), 1.28, bronze, rig, sides=16)
    axle("Core Glow", (0, 2.68, 5.63), (0, 2.68, 5.81), .91, cyan, rig, sides=20)
    for index in range(12):
        a = index * pi / 6
        axle("Core retaining stud", (1.12 * sin(a), 2.68 + 1.12 * cos(a), 5.61),
             (1.12 * sin(a), 2.68 + 1.12 * cos(a), 5.73), .10, gold, rig, sides=8)
    head = hinge("Head", (0, 1.66, 4.69), rig)
    axle("Articulated neck mount", (0,1.57,4.52), (0,1.46,6.21), .61, bronze, head, tip=.72, sides=10)
    lens("Jade tortoise brow", (0, 1.42, 6.18), (2.12, 1.38, 1.98), jade, head)
    lens("Ceramic jaw", (0, 1.10, 6.63), (1.62, .59, 1.28), tiles[0], head)
    for side in (-1, 1):
        box("Armored brow", (side * .68, 1.79, 6.74), (.66, .31, .42), bronze, head, .08, yaw=side * .43)
        box(f"Eye {side}", (side * .69, 1.63, 6.92), (.40, .15, .10), ember, head, .03, yaw=side * .43)
    return rig


def feather(name, start, end, width, depth, primary, trim, group):
    a, b = Vector(start), Vector(end)
    span = b - a
    width_axis = Vector((-span.z, 0, span.x)).normalized() * width
    rows = ((0,.48), (.31,1), (.70,.84), (1,.03))

    # Split into straight bands so no GLB face tessellation crosses the taper.
    for i, ((f0, w0), (f1, w1)) in enumerate(zip(rows, rows[1:])):
        strip = [a + span * f0 - width_axis * w0 / 2, a + span * f0 + width_axis * w0 / 2,
                 a + span * f1 + width_axis * w1 / 2, a + span * f1 - width_axis * w1 / 2]
        solid(name + f" {i + 1}", [tuple(p) for p in strip],
              [tuple(p + Vector((0, depth, 0))) for p in strip], primary if i < 2 else trim, group)
    axle("Raised gilded quill", tuple(a + span * .17 + Vector((0, depth, 0))),
         tuple(a + span * .72 + Vector((0, depth, 0))), .027, trim, group, tip=.010, sides=5, bevel=0)


def phoenix():
    rig = hinge("Animated Body", (0, 3.64, .12))
    burgundy = material("Oxblood flight plates", "572437", .27, .40)
    red = material("Vermilion enamel plumage", "A43438", .22, .34)
    copper = material("Copper coverts", "DF6940", .42, .32)
    gold = material("Sunburst brass", "F5AF4B", .58, .30)
    pale = material("Sun gold enamel", "FFDB84", .23, .35)
    iris = material("Amber iris", "FBA93E", .16, .34, .75)
    heart = material("Sunheart", "FFF29B", .09, .32, 3.8)
    lens("Sculpted breast", (0, 3.17, .55), (4.35, 4.54, 4.20), red, rig)
    lens("Gorget plumage", (0, 5.04, .82), (2.80, 3.54, 2.74), copper, rig)
    lens("Tapered back", (0, 3.86, -1.03), (3.53, 2.66, 3.65), burgundy, rig)
    lens("Sharp brow and head", (0, 6.37, 1.42), (3.02, 2.03, 2.35), red, rig)
    solid("Hooked sun gold beak", [(-.80,5.27,2.39),(.80,5.27,2.39),(.29,4.90,3.97),(-.29,4.90,3.97)],
          [(-.65,5.91,2.44),(.65,5.91,2.44),(.28,5.37,3.91),(-.28,5.37,3.91)], gold, rig)
    lens("Lower beak", (0,5.09,2.97), (1.19,.31,1.43), pale, rig)
    axle("Sunheart Rim", (0, 2.59, 2.42), (0, 2.59, 2.90), 1.14, gold, rig, sides=20)
    axle("Sunheart", (0, 2.59, 2.91), (0, 2.59, 3.12), .89, heart, rig, sides=20)
    lens("Sunheart Spark", (0, 2.59, 3.13), (.62,.62,.17), heart, rig, 1)
    for index in range(12):
        a = index * pi / 6
        axle("Sunray clasp", (1.0*sin(a), 2.59+1.0*cos(a), 2.97),
             (1.29*sin(a),2.59+1.29*cos(a),2.80),.095,pale,rig,tip=.042,sides=5,bevel=0)
    crown = hinge("Crown Fan", (0, 6.80, .67), rig)
    tail = hinge("Tail Fan", (0, 2.74, -1.31), rig)
    for i in range(-2, 3):
        feather("Crown blade", (i*.22, 6.83, .81), (i*.59, 8.19-abs(i)*.28, -1.98+abs(i)*.32),
                .61, .15, gold if i == 0 else copper, pale, crown)
    for i in range(-3, 4):
        feather("Tail blade", (i*.31, 2.73, -1.61), (i*1.52, 2.12+abs(i)*.31, -10.62+abs(i)*.63),
                1.11, .16, red if i % 2 else copper, gold, tail)
    for side, word in ((-1, "Left"), (1, "Right")):
        lens(word + " eye mask", (side * 1.19, 6.04, 2.18), (1.08, .96, .91), pale, rig, 1)
        box(word + " eye surround", (side * 1.26, 6.12, 2.46), (.80, .43, .19), burgundy, rig, .065,
            yaw=side * .51)
        lens(word + " iris", (side * 1.28, 6.12, 2.59), (.27,.22,.13), iris, rig, 1)
        box(word + " pupil", (side * 1.22, 6.12, 2.66), (.066,.17,.052), burgundy, rig, .012)
        solid(word + " swept brow",
              [(side*.51,6.21,2.49),(side*1.62,6.51,2.16),(side*1.49,6.63,2.09),(side*.64,6.41,2.38)],
              [(side*.51,6.34,2.57),(side*1.64,6.66,2.26),(side*1.51,6.76,2.12),(side*.65,6.51,2.46)],
              gold, rig)
        plate = hinge(word + " Heart Plate", (side * .94, 2.60, 3.05), rig)
        lens("Overlapping chest armor", (side * .91, 2.64, 3.16), (.61,1.94,.40), burgundy, plate, 1)
        box("Chest armor gold spine", (side * .98, 2.64, 3.35), (.10,1.27,.08), gold, plate, .03)
        talon = hinge(word + " Talon", (side * 1.24, 1.92, .37), rig)
        axle("Talon shank", (side * 1.24, 1.95, .25), (side * 1.23, 1.04, .62), .28, gold, talon,
             tip=.19, sides=7)
        for toe in (-1, 0, 1):
            x = side * 1.23 + toe * .28
            axle("Talon digit", (side * 1.23,.99,.60), (x,.91,1.36), .118,gold,talon, tip=.077,sides=7)
            axle("Talon tip", (x,.91,1.36), (x+toe*.10,.80,1.67),.092,pale,talon,tip=.015,sides=6)
        wing = hinge(word + " Wing", (side * 1.62, 4.12, -.11), rig)
        outer = hinge("Outer Wing", (side * 5.65, 4.04, -1.04), wing)
        axle("Armored leading edge", (side*1.45,4.12,.26), (side*5.81,4.54,-1.05),
             .62,red,wing,tip=.43,sides=6,bevel=.10)
        for i in range(6):
            feather("Layered wing covert", (side*(2.02+i*.63),4.18+i*.07,.31-i*.24),
                    (side*(3.03+i*.75),3.63+i*.09,-4.36-i*.31),1.12,.19,
                    red if i % 2 else copper, gold, wing)
        axle("Gilded outer wing rail", (side*5.45,4.57,-1.04), (side*10.41,5.36,-2.47),
             .40, gold, outer, tip=.19, sides=6, bevel=.065)
        for i in range(8):
            feather("Primary wing blade", (side*(5.51+i*.56),4.37+i*.16,-.65-i*.24),
                    (side*(9.91+i*.54),3.58+i*.24,-5.99+i*.31),1.12,.25,
                    burgundy if i < 3 else red, copper if i < 3 else gold, outer)
    return rig


def setup_preview(rig, boss_name):
    # Preview floor and lights are saved in Blender and excluded from Roblox export.
    stone = material("Exhibition basalt", "3A363E", .18, .55)
    brass = material("Inlaid brass", "9C6032", .66, .42)
    phoenix_preview = boss_name == "Solar_Phoenix"
    floor = hinge("Preview floor", (0, 0, 0))
    box("Shadow floor", (0, -.67, 0), (200, .22, 200), stone, floor)
    radius = 9.1 if phoenix_preview else 7.7
    axle("Basalt plinth", (0,-.58,0), (0,-.05,0), radius, stone, floor, sides=16, bevel=.13)
    axle("Inset ring band", (0,-.08,0), (0,-.03,0), radius*.94, brass, floor, sides=32, bevel=.01)
    axle("Dark top", (0,-.04,0), (0,0,0), radius*.91, stone, floor, sides=32, bevel=.006)
    scene = bpy.context.scene
    scene.world = bpy.data.worlds.new("Raid render world")
    scene.world.use_nodes = True
    scene.world.node_tree.nodes["Background"].inputs["Color"].default_value = (.15,.11,.15,1)
    scene.world.node_tree.nodes["Background"].inputs["Strength"].default_value = .32

    def light(name, at, watts, shade, size, target):
        datablock = bpy.data.lights.new(name,"AREA")
        datablock.energy, datablock.color, datablock.shape = watts, shade, "DISK"
        datablock.size = size
        light_object = bpy.data.objects.new(name,datablock)
        scene.collection.objects.link(light_object)
        light_object.location = point(at)
        light_object.rotation_euler = (point(target) - light_object.location).to_track_quat("-Z","Y").to_euler()

    light("Amber key", (-7,13,9), 2500, (1,.63,.37), 9, (0,3,0))
    light("Soft opposite fill", (9,9,7), 2150, (.42,.64,1), 10, (0,3,0))
    light("Gold silhouette rim", (0,10,-9), 2800, (1,.43,.26), 8, (0,3,0))
    camera = bpy.data.objects.new("Three-quarter model camera", bpy.data.cameras.new("Raid show view"))
    scene.collection.objects.link(camera)
    camera.location = point((10,8.8,24) if phoenix_preview else (13,8.7,21))
    target = point((0,3.35,-.8) if phoenix_preview else (0,2.55,.45))
    camera.rotation_euler = (target - camera.location).to_track_quat("-Z","Y").to_euler()
    camera.data.type, camera.data.ortho_scale = "ORTHO", 29.4 if phoenix_preview else 17.7
    scene.camera = camera
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 36
    scene.use_nodes = True
    tree = scene.node_tree
    bloom = tree.nodes.new("CompositorNodeGlare")
    bloom.glare_type = "FOG_GLOW"
    bloom.inputs["Threshold"].default_value = 1.45
    layers = next(node for node in tree.nodes if node.type == "R_LAYERS")
    output = next(node for node in tree.nodes if node.type == "COMPOSITE")
    tree.links.new(layers.outputs["Image"], bloom.inputs["Image"])
    tree.links.new(bloom.outputs["Image"], output.inputs["Image"])
    scene.cycles.use_denoising = True
    scene.render.resolution_x, scene.render.resolution_y = 1440, 1080
    scene.render.image_settings.file_format = "PNG"
    scene.view_settings.view_transform = "AgX"


def compact_meshes(rig):
    animated = {"Core Glow", "Vent Glow", "Eye -1", "Eye 1", "Sunheart", "Sunheart Rim",
                "Sunheart Spark", "Left iris", "Right iris"}
    for group in (rig, *(obj for obj in rig.children_recursive if obj.type == "EMPTY")):
        meshes = [obj for obj in group.children if obj.type == "MESH" and
                  not any(obj.name == name or obj.name.startswith(name + ".") for name in animated)]
        if not meshes:
            continue
        bpy.ops.object.select_all(action="DESELECT")
        for obj in meshes:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = meshes[0]
        if len(meshes) > 1:
            bpy.ops.object.join()
        bpy.context.object.name = group.name + " Geometry"
        # Roblox import coordinates use the bounding-box center for the visual
        # piece. The parent hinge retains the authored animation origin.
        bpy.ops.object.origin_set(type="ORIGIN_GEOMETRY", center="BOUNDS")


def export(builder, name, output, preview):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    rig = builder()
    bpy.context.view_layer.update()
    setup_preview(rig, name)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.ops.wm.save_as_mainfile(filepath=str(output / f"{name}.blend"))

    compact_meshes(rig)
    objects = [rig, *rig.children_recursive]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.export_scene.gltf(filepath=str(output / f"{name}.glb"), export_format="GLB", use_selection=True,
                              export_apply=True, export_animations=False)
    details = []
    for obj in (o for o in objects if o.type == "EMPTY"):
        triangles = sum(sum(len(face.vertices) - 2 for face in mesh.data.polygons)
                        for mesh in obj.children if mesh.type == "MESH")
        pivot = obj.matrix_world.translation
        details.append({"group": obj.name, "parent": obj.parent.name if obj.parent else None,
                        "pivot": [round(value, 4) for value in (pivot.x, pivot.z, -pivot.y)], "triangles": triangles})
    total = sum(group["triangles"] for group in details)
    count = sum(obj.type == "MESH" for obj in objects)
    assert 0 < total < 20000 and count <= 27, (total, count)
    (output / f"{name}.json").write_text(json.dumps({"triangles": total, "meshes": count, "groups": details}, indent=2) + "\n")
    if name == "Solar_Phoenix":
        # The editable and game exports retain their rest pivots.
        for side, word in ((-1, "Left"), (1, "Right")):
            wing = next(child for child in rig.children if child.name == word + " Wing")
            wing.rotation_euler.y = -side * .38
            wing.rotation_euler.x = -.20
            outer = next(child for child in wing.children if child.type == "EMPTY")
            outer.rotation_euler.y = -side * .20
        next(child for child in rig.children if child.name == "Tail Fan").rotation_euler.x = .31
    bpy.context.scene.render.filepath = str(preview / f"{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"{name}: {len(details)} animation groups, {count} meshes, {total} triangles", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--previews", type=Path, required=True)
    parser.add_argument("--boss", choices=("kilnback", "phoenix", "both"), default="both")
    args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else None)
    args.out.mkdir(parents=True, exist_ok=True)
    args.previews.mkdir(parents=True, exist_ok=True)
    for key, name, builder in (("kilnback", "Kilnback_Custodian", kilnback), ("phoenix", "Solar_Phoenix", phoenix)):
        if args.boss in (key, "both"):
            export(builder, name, args.out.resolve(), args.previews.resolve())


if __name__ == "__main__":
    main()
