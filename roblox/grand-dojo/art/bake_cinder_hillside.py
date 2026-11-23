"""Bake closed, single-mesh versions of the Cinder Square sandstone hillside."""

import json
from math import radians
from pathlib import Path
from tempfile import TemporaryDirectory

import bpy
import numpy as np

from bake_landmark_roofs import bake_pixels, linear_srgb
from cinder_hillside_layout import BANDS, CINDER_HILLSIDE_PIVOT, OUTLINE, hillside_faces, hillside_rings


OUTPUT = Path(__file__).resolve().parent / "cinder-hillside"
PAINT = "Cinder sandstone color"


def closed_faces(rings, bands, outline):
    yield from hillside_faces(rings, bands, outline)
    for level, reverse, color in ((bands[0], True, "A38372"), (bands[-1], False, "78595B")):
        ring = [rings[level][index] for index in outline]
        center = (0, BANDS[level][1], 0)
        for a, b in zip(ring, [*ring[1:], ring[0]]):
            yield (center, b, a) if reverse else (center, a, b), color


def make_mesh(name, bands, outline):
    indices = {}
    faces, pigments = [], []
    for corners, color in closed_faces(hillside_rings(), bands, outline):
        faces.append(tuple(indices.setdefault(point, len(indices)) for point in corners))
        pigments.append(tuple(linear_srgb(int(color[i:i+2], 16)/255) for i in (0,2,4)))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata([(x,-z,y) for x,y,z in indices], [], faces)
    mesh.update()
    paint = mesh.color_attributes.new(name=PAINT, type="FLOAT_COLOR", domain="CORNER")
    for face, tint in zip(mesh.polygons, pigments):
        for index in face.loop_indices:
            paint.data[index].color = (*tint, 1)

    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.uv.smart_project(angle_limit=radians(64), island_margin=.012, area_weight=.30)
    bpy.ops.object.mode_set(mode="OBJECT")
    return obj, tuple(indices)


def sandstone(mesh):
    material = bpy.data.materials.new("Cinder sandstone bake source")
    material.use_nodes = True
    mesh.materials.append(material)
    tree = material.node_tree
    pigment = tree.nodes.new("ShaderNodeVertexColor")
    pigment.layer_name = PAINT
    coordinates = tree.nodes.new("ShaderNodeTexCoord")
    bands = tree.nodes.new("ShaderNodeVectorMath")
    bands.operation = "MULTIPLY"
    bands.inputs[1].default_value = (.12,.14,.92)
    tree.links.new(coordinates.outputs["Object"], bands.inputs[0])
    texture = tree.nodes.new("ShaderNodeTexNoise")
    texture.inputs["Scale"].default_value = 2.8
    texture.inputs["Detail"].default_value = 3.1
    tree.links.new(bands.outputs["Vector"], texture.inputs["Vector"])
    ramp = tree.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (.59,.51,.49,1)
    ramp.color_ramp.elements[1].color = (1.19,1.11,1.04,1)
    tree.links.new(texture.outputs["Fac"], ramp.inputs["Fac"])
    grain = tree.nodes.new("ShaderNodeMixRGB")
    grain.blend_type = "MULTIPLY"
    grain.inputs["Fac"].default_value = .51
    tree.links.new(pigment.outputs["Color"], grain.inputs[1])
    tree.links.new(ramp.outputs["Color"], grain.inputs[2])
    tree.links.new(grain.outputs["Color"], tree.nodes.get("Principled BSDF").inputs["Base Color"])
    return material


def export(name, bands, outline, size):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 20
    scene.render.threads_mode = "FIXED"
    scene.render.threads = 8
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGB"
    scene.view_settings.view_transform = "Standard"
    obj, points = make_mesh(name, bands, outline)
    material = sandstone(obj.data)
    paint = bake_pixels(material, size, "DIFFUSE", pass_filter={"COLOR"})
    shade = np.clip(bake_pixels(material, size, "AO")[:, :, :1], 0, 1)
    paint[:, :, :3] *= .69 + .31 * shade
    paint[:, :, :3] += (1 - shade) * paint[:, :, :3] * np.array([.12,.057,.020])
    paint[:, :, 3] = 1

    obj.data.materials.clear()
    obj.data.color_attributes.remove(obj.data.color_attributes[PAINT])
    output = name + ".glb"
    with TemporaryDirectory() as staging:
        atlas = bpy.data.images.new(name + " color", size, size, alpha=False, float_buffer=True)
        atlas.pixels.foreach_set(paint.ravel())
        atlas_path = Path(staging) / (name + ".png")
        atlas.save_render(str(atlas_path), scene=scene)
        atlas = bpy.data.images.load(str(atlas_path))
        atlas.pack()
        material = bpy.data.materials.new("Baked Cinder sandstone")
        material.use_nodes = True
        tree = material.node_tree
        texture = tree.nodes.new("ShaderNodeTexImage")
        texture.image = atlas
        shader = tree.nodes.get("Principled BSDF")
        shader.inputs["Roughness"].default_value = .88
        tree.links.new(texture.outputs["Color"], shader.inputs["Base Color"])
        obj.data.materials.append(material)
        bpy.ops.export_scene.gltf(filepath=str(OUTPUT / output), export_format="GLB", use_selection=True)

    bounds = tuple((min(axis), max(axis)) for axis in zip(*points))
    return {
        "file": output,
        "triangles": len(obj.data.polygons),
        "atlasPixels": size,
        "sizeStuds": [round(high-low, 6) for low,high in bounds],
        "centerStuds": [round(pivot+(low+high)/2, 6)
                        for pivot,(low,high) in zip(CINDER_HILLSIDE_PIVOT,bounds)],
    }


def main():
    OUTPUT.mkdir(exist_ok=True)
    manifest = {
        "sourceModel": "Cinder sandstone hillside",
        "replacePartsNamed": "Layered Cinder sandstone",
        "pivotStuds": CINDER_HILLSIDE_PIVOT,
        "detail": export("Cinder_Square_Hillside", tuple(range(len(BANDS))), tuple(range(len(OUTLINE))), 1024),
        "lowerDetail": export("Cinder_Square_Hillside_LOD1", (0,1,3,4,6), (0,2,4,5,7,9,11,13,15,16,18,20,22), 512),
    }
    (OUTPUT / "placement.json").write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    main()
