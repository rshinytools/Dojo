"""Build and render the standalone Beast Dojo sparring bot art assets."""

import argparse
import importlib.util
import json
from math import radians
from pathlib import Path
import struct
import sys

import bpy
import bmesh
from mathutils import Matrix, Vector


SOURCE = Path(__file__).resolve().parent
PRIMITIVES = SOURCE.parent / "boxing-kangaroo/reedguard-blender/build_reedguard.py"
ROSTER = (
    ("juniper", "Juniper Tortoise", "Juniper_Tortoise", "4B7768", -20),
    ("bracken", "Bracken Boar", "Bracken_Boar", "97644E", 12),
    ("granite", "Granite Rhino", "Granite_Rhino", "576783", -13),
    ("sablecrest", "Sablecrest Lynx", "Sablecrest_Lynx", "8D647E", 18),
)
GROUPS = {"Torso", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
ATLAS_SIZE = 1024


def load_module(path):
    spec = importlib.util.spec_from_file_location(path.stem, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


p = load_module(PRIMITIVES)
REEDGUARD_PIVOTS = dict(p.PIVOTS)


def new_collection(name):
    collection = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(collection)
    return collection


def transfer(obj, collection):
    for origin in tuple(obj.users_collection):
        origin.objects.unlink(obj)
    collection.objects.link(obj)


def select(objects):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]


def build_bot(slug, title, source=SOURCE):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    p.GROUPS = {name: [] for name in (*sorted(GROUPS), "Tail")}
    p.PIVOTS = dict(REEDGUARD_PIVOTS)
    pivots = load_module(source / f"{slug}.py").build(p)
    assert GROUPS <= pivots.keys() <= GROUPS | {"Tail"}, pivots
    assert set(pivots) == {name for name, parts in p.GROUPS.items() if parts}, pivots
    # Recalculate after beveling and joining. The separate pieces keep their
    # authored surface breaks and the normal direction of closed shells.
    p.GROUPS = {name: p.GROUPS[name] for name in pivots}
    p.PIVOTS = pivots
    for parts in p.GROUPS.values():
        for obj in parts:
            if obj.type == "MESH" and len(obj.data.polygons) >= 72 and not obj.modifiers:
                for face in obj.data.polygons:
                    face.use_smooth = True
    p.merge_groups()
    collection = new_collection(title)
    objects = [parts[0] for parts in p.GROUPS.values()]
    for obj in objects:
        select([obj])
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        mesh = bmesh.new()
        mesh.from_mesh(obj.data)
        bmesh.ops.recalc_face_normals(mesh, faces=mesh.faces[:])
        mesh.to_mesh(obj.data)
        mesh.free()
        obj.data.update()
        transfer(obj, collection)
    select(objects)
    return objects


def unwrap(objects):
    select(objects)
    for obj in objects:
        for layer in tuple(obj.data.uv_layers):
            obj.data.uv_layers.remove(layer)
        obj.data.uv_layers.new(name="SparringColorAtlas")
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=radians(67), island_margin=.012, area_weight=.22)
    bpy.ops.uv.pack_islands(rotate=True, margin_method="FRACTION", margin=.004)
    bpy.ops.object.mode_set(mode="OBJECT")


def textured_export(objects, title, out):
    """Bake authored color, cavity occlusion and a warm bounce tint into one atlas."""
    unwrap(objects)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 12
    image = bpy.data.images.new(title + " baked color atlas", ATLAS_SIZE, ATLAS_SIZE, alpha=False)
    source_materials = dict.fromkeys(material for obj in objects for material in obj.data.materials)
    material_edits = []
    for material in source_materials:
        tree = material.node_tree
        shader = tree.nodes.get("Principled BSDF")
        output = next(node for node in tree.nodes if node.type == "OUTPUT_MATERIAL" and node.is_active_output)
        ao = tree.nodes.new("ShaderNodeAmbientOcclusion")
        ao.inputs["Distance"].default_value = .25
        ao.inputs["Color"].default_value = (1.0, .94, .87, 1.0)
        ao.samples = 8
        multiply = tree.nodes.new("ShaderNodeMixRGB")
        multiply.blend_type = "MULTIPLY"
        multiply.inputs[0].default_value = .27
        multiply.inputs[1].default_value = material.diffuse_color
        tree.links.new(ao.outputs["Color"], multiply.inputs[2])
        emission = tree.nodes.new("ShaderNodeEmission")
        tree.links.new(multiply.outputs["Color"], emission.inputs["Color"])
        tree.links.new(emission.outputs[0], output.inputs["Surface"])
        slot = tree.nodes.new("ShaderNodeTexImage")
        slot.image = image
        tree.nodes.active = slot
        material_edits.append((tree, output, shader, (ao, multiply, emission, slot)))
    select(objects)
    bpy.ops.object.bake(type="EMIT", margin=5, margin_type="EXTEND", use_clear=True)
    image.pack()
    for tree, output, shader, extras in material_edits:
        tree.links.new(shader.outputs[0], output.inputs["Surface"])
        for node in extras:
            tree.nodes.remove(node)

    atlas = p.material(title + " game color atlas", "FFFFFF", .79)
    nodes = atlas.node_tree.nodes
    texture = nodes.new("ShaderNodeTexImage")
    texture.image = image
    nodes.active = texture
    atlas.node_tree.links.new(texture.outputs["Color"], nodes.get("Principled BSDF").inputs["Base Color"])
    slots = []
    for obj in objects:
        mesh = obj.data
        slots.append((obj, list(mesh.materials), [face.material_index for face in mesh.polygons]))
        mesh.materials.clear()
        mesh.materials.append(atlas)
    # glTF's axis conversion maps Blender +Y to -Z. Mirror before exporting
    # so the authored -Y guard becomes -Z for the Dojo runtime convention.
    p.mirror_to_runtime_axes()
    select(objects)
    bpy.ops.export_scene.gltf(filepath=str(out), export_format="GLB", use_selection=True,
                              export_extras=True, export_yup=True, export_animations=False,
                              export_apply=True, export_materials="EXPORT")
    p.mirror_to_runtime_axes()
    p.restore_preview_materials(slots)
    return image


def read_glb(path):
    with path.open("rb") as stream:
        magic, version, size = struct.unpack("<4sII", stream.read(12))
        assert (magic, version, size) == (b"glTF", 2, path.stat().st_size), path
        length, kind = struct.unpack("<I4s", stream.read(8))
        assert kind == b"JSON", path
        return json.loads(stream.read(length))


def verify_export(path, report):
    glb = read_glb(path)
    assert len(glb["meshes"]) == len(report["groups"])
    assert len(glb["materials"]) == len(glb["images"]) == 1 and "bufferView" in glb["images"][0]
    triangles = 0
    for mesh in glb["meshes"]:
        assert len(mesh["primitives"]) == 1
        primitive = mesh["primitives"][0]
        assert primitive.get("mode", 4) == 4 and "TEXCOORD_0" in primitive["attributes"]
        count = glb["accessors"][primitive["indices"]]["count"]
        assert count % 3 == 0 and 0 < count // 3 < 20000, mesh["name"]
        triangles += count // 3
    assert triangles == report["triangles"], (triangles, report["triangles"])
    assert triangles <= 12500, triangles
    assert 4.4 <= report["art_height"] <= 5.85, report["art_height"]


def set_camera(name, position, target, frame):
    data = bpy.data.cameras.new(name)
    camera = bpy.data.objects.new(name, data)
    bpy.context.scene.collection.objects.link(camera)
    camera.location = position
    p.aim(camera, target)
    data.type = "ORTHO"
    data.ortho_scale = frame
    bpy.context.scene.camera = camera
    return camera


def platform(x, tint):
    rock = p.material("Dark warm slate", "302B3D", .87)
    inlay = p.material("Antique warm brass", "B7825A", .54, metallic=.18)
    accent = p.material("Dyed sparring mat", tint, .88, 105)
    for title, radius, depth, z, material in (
        ("Beveled ring platform", 2.10, .31, -.214, rock),
        ("Brass platform edge", 2.088, .045, -.120, inlay),
        ("Padded dojo mat", 2.012, .105, -.064, accent),
    ):
        bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=radius, depth=depth, location=(x,0,z))
        ring = bpy.context.object
        ring.name = title
        ring.data.materials.append(material)
        bevel = ring.modifiers.new("Soft lip", "BEVEL")
        bevel.width, bevel.segments = .036, 2


def studio(wide=False):
    scene = bpy.context.scene
    floor = p.material("Warm studio backdrop", "403542", .91)
    p.rounded_box(None, "Backdrop", (0,0,-.49), (200,200,.22), floor, .05)
    scene.world = bpy.data.worlds.new("Soft violet room fill")
    scene.world.use_nodes = True
    world = scene.world.node_tree.nodes.get("Background")
    world.inputs["Color"].default_value = (.25,.20,.30,1)
    world.inputs["Strength"].default_value = .34
    if wide:
        p.area("Wide warm lantern key", (1,-9,10), (0,0,2.4), 2990, 11, (1,.84,.67))
        p.area("Wide cool softbox", (-8,-5,6), (0,0,2.4), 2070, 9, (.64,.79,1))
        p.area("Wide sunrise rim", (1,5,10), (0,0,2.7), 4550, 10, (1,.61,.42))
    else:
        p.area("Warm lantern key", (2.6,-5.8,7.4), (0,0,2.4), 970, 4.6, (1,.82,.66))
        p.area("Cool front fill", (-4.2,-3.1,4.5), (0,0,2.4), 590, 4.3, (.68,.82,1))
        p.area("Warm back rim", (0,3.5,7.4), (0,0,2.6), 1150, 4.8, (1,.64,.45))
    scene.render.engine = "CYCLES"
    scene.cycles.use_denoising = True
    scene.cycles.max_bounces = 6
    scene.view_settings.view_transform = "AgX"
    scene.view_settings.look = "AgX - Medium High Contrast"
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "JPEG"
    scene.render.image_settings.quality = 94
    bpy.context.preferences.filepaths.save_version = 0


def render(file, dimensions, quick):
    scene = bpy.context.scene
    scene.cycles.samples = 10 if quick else 36
    scene.render.resolution_x, scene.render.resolution_y = dimensions
    scene.render.filepath = str(file)
    bpy.ops.render.render(write_still=True)


def save_blend(file, image_path):
    bpy.context.scene.render.filepath = "//" + image_path.name
    bpy.ops.wm.save_as_mainfile(filepath=str(file), compress=True)


def individual(spec, out, quick=False, preview_only=False, *, source=SOURCE, preview_pose=None):
    slug, title, filename, tint, _ = spec
    objects = build_bot(slug, title, source)
    if not preview_only:
        report = p.model_report()
        report["atlas"] = f"Embedded {ATLAS_SIZE} × {ATLAS_SIZE} PNG with color and cavity shading."
        report["display_name"] = title
        report["asset"] = filename + ".glb"
        report["unit"] = "1 Blender unit per intended Roblox stud"
        path = out / report["asset"]
        textured_export(objects, title, path)
        verify_export(path, report)
        (out / (filename + "_bindings.json")).write_text(json.dumps(report, indent=2) + "\n")
        print(f"{title}: {report['art_height']:.2f} units, {report['triangles']} triangles", flush=True)
    if preview_pose:
        preview_pose()
    studio()
    platform(0, tint)
    dimensions = (540, 640) if quick else (900, 1080)
    set_camera("Three-quarter guard", (6.15,-13,5.65), (0,.11,2.73), 6.65)
    image = out / (filename + "_Guard.jpg")
    render(image, dimensions, quick)
    if preview_only:
        return
    save_blend(out / (filename + ".blend"), image)
    if slug == "juniper":
        set_camera("Shell detail", (-7.6,12.1,6.6), (0,.38,2.45), 6.15)
        render(out / (filename + "_Shell.jpg"), dimensions, quick)


def lineup(out, quick=False, *, roster=ROSTER, filename="Dojo_Bot_Lineup"):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    studio(wide=True)
    for pose, x in zip(roster, (-7.25,-2.48,2.48,7.25), strict=True):
        _, title, model, tint, turn = pose
        with bpy.data.libraries.load(str(out / (model + ".blend")), link=False) as (source, destination):
            assert title in source.collections
            destination.collections = [title]
        collection = destination.collections[0]
        bpy.context.scene.collection.children.link(collection)
        rotation = Matrix.Rotation(radians(turn), 3, "Z")
        for obj in collection.objects:
            obj.location = rotation @ obj.location + Vector((x,0,0))
            obj.rotation_euler = (rotation @ obj.rotation_euler.to_matrix()).to_euler(obj.rotation_euler.order)
        platform(x, tint)
    set_camera("Lineup camera", (1,-25,7.85), (0,0,2.58), 20.8)
    image = out / (filename + ".jpg")
    render(image, (1200, 445) if quick else (1920, 710), quick)
    save_blend(out / (filename + ".blend"), image)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=SOURCE / "assets")
    parser.add_argument("--bot", choices=[entry[0] for entry in ROSTER])
    parser.add_argument("--lineup", action="store_true")
    parser.add_argument("--quick", action="store_true")
    parser.add_argument("--preview-only", action="store_true")
    args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:])
    args.output.mkdir(parents=True, exist_ok=True)
    if not args.lineup:
        for spec in ROSTER:
            if args.bot is None or spec[0] == args.bot:
                individual(spec, args.output.resolve(), args.quick, args.preview_only)
    if args.lineup or (args.bot is None and not args.preview_only):
        lineup(args.output.resolve(), args.quick)


if __name__ == "__main__":
    main()
