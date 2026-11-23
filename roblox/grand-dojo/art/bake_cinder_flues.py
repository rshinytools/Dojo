"""Bake the three authored Cinder flues with compact color and occlusion atlases."""

import argparse
import json
from math import cos, radians, sin, tau
from pathlib import Path
from tempfile import TemporaryDirectory
from xml.etree import ElementTree

import bpy
import numpy as np
from mathutils import Matrix, Vector

from bake_landmark_roofs import (
    BOX_FACES, BOX_VERTICES, RoofPart, bake_pixels, cylinder_polygons,
    linear_srgb, name, vector,
)


ART = Path(__file__).resolve().parent
PLACE = ART.parent / "Beast_Dojo_Grand_Dojo.rbxlx"
OUTPUT = ART / "cinder-flues"
PAINT = "Kiln paint"
FLUE = "Cinder kiln flue"
VENT = "Amber vent inlay"


def read_part(node):
    properties = node.find("Properties")
    frame = properties.find("CoordinateFrame[@name='CFrame']")
    axes = Matrix(tuple(tuple(float(frame.findtext(f"R{row}{col}")) for col in range(3)) for row in range(3)))
    pigment = int(properties.findtext("Color3uint8[@name='Color3uint8']"))
    color = tuple(linear_srgb(((pigment >> channel) & 255) / 255) for channel in (16, 8, 0))
    if properties.findtext("bool[@name='CanCollide']") != "false":
        raise ValueError(f"Flue contains a collider: {name(node)}")
    return RoofPart(name(node), vector(properties, "CoordinateFrame[@name='CFrame']"),
                    vector(properties, "Vector3[@name='size']"), axes, (*color, 1),
                    properties.findtext("token[@name='shape']") == "2")


def split_wedge_face(first, second, axis):
    # Both authored right wedges meet at the triangle's high corner.
    a, other = (part.point((0, .5, .5)) for part in (first, second))
    if first.name != second.name or first.color != second.color or (a - other).length > .0002:
        raise ValueError(f"Mismatched triangle wedges near {tuple(a)}")
    b, c = (part.point((0, -.5, -.5)) for part in (first, second))
    if first.name == "Copper rim cap":
        outward = Vector((0, 1, 0))
    else:
        center = (a + b + c) / 3 - axis
        outward = Vector((center.x, 0, center.z))
    return (a, b, c) if (b - a).cross(c - a).dot(outward) > 0 else (a, c, b)


def faces_for(nodes, *, lod):
    wedges = [read_part(node) for node in nodes if node.get("class") == "WedgePart"]
    parts = [read_part(node) for node in nodes if node.get("class") == "Part" and name(node) != VENT]
    axis = next(part.center for part in parts if part.name == "Recessed flue throat")
    for first, second in zip(wedges[::2], wedges[1::2], strict=True):
        yield split_wedge_face(first, second, axis), first.color

    collars = [part for part in parts if part.name == "Hammered copper collar"]
    if lod:
        crown = max(collars, key=lambda part: part.center.y)
        parts = [part for part in parts if part.name == "Recessed flue throat"] + [crown]
    for part in parts:
        if part.cylinder:
            count = 8 if lod else 12
            profile = [(.5 * sin(i * tau / count), .5 * cos(i * tau / count)) for i in range(count)]
            vertices, faces = cylinder_polygons(profile)
        else:
            vertices, faces = BOX_VERTICES, BOX_FACES
        for face in faces:
            yield tuple(part.point(vertices[index]) for index in face), part.color


def bounds(faces):
    axes = zip(*(point for face, _ in faces for point in face))
    low, high = zip(*((min(axis), max(axis)) for axis in axes))
    return Vector(low), Vector(high)


def make_mesh(label, faces, pivot):
    points, polygons = [], []
    for face, _ in faces:
        start = len(points)
        for point in face:
            x, y, z = point - pivot
            points.append((x, -z, y))
        polygons.append(tuple(range(start, len(points))))
    mesh = bpy.data.meshes.new(label)
    mesh.from_pydata(points, [], polygons)
    mesh.update()
    paint = mesh.color_attributes.new(name=PAINT, type="FLOAT_COLOR", domain="CORNER")
    for polygon, (_, color) in zip(mesh.polygons, faces, strict=True):
        for index in polygon.loop_indices:
            paint.data[index].color = color

    obj = bpy.data.objects.new(label, mesh)
    bpy.context.scene.collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=.0002)
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.uv.smart_project(angle_limit=radians(65), island_margin=.009, area_weight=.28)
    bpy.ops.object.mode_set(mode="OBJECT")
    return obj


def kiln_paint(mesh):
    material = bpy.data.materials.new("Fired brick and copper bake source")
    material.use_nodes = True
    mesh.materials.append(material)
    tree = material.node_tree
    pigment = tree.nodes.new("ShaderNodeVertexColor")
    pigment.layer_name = PAINT
    position = tree.nodes.new("ShaderNodeTexCoord")
    grain = tree.nodes.new("ShaderNodeTexNoise")
    grain.inputs["Scale"].default_value = 5.8
    grain.inputs["Detail"].default_value = 3.2
    tree.links.new(position.outputs["Object"], grain.inputs["Vector"])
    shades = tree.nodes.new("ShaderNodeValToRGB")
    shades.color_ramp.elements[0].color = (.69, .62, .59, 1)
    shades.color_ramp.elements[1].color = (1.14, 1.08, 1.02, 1)
    tree.links.new(grain.outputs["Fac"], shades.inputs["Fac"])
    mixed = tree.nodes.new("ShaderNodeMixRGB")
    mixed.blend_type = "MULTIPLY"
    mixed.inputs["Fac"].default_value = .43
    tree.links.new(pigment.outputs["Color"], mixed.inputs[1])
    tree.links.new(shades.outputs["Color"], mixed.inputs[2])
    tree.links.new(mixed.outputs["Color"], tree.nodes.get("Principled BSDF").inputs["Base Color"])
    return material


def export(label, faces, pivot, size):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 20
    scene.render.threads_mode = "FIXED"
    scene.render.threads = 8
    scene.view_settings.view_transform = "Standard"
    obj = make_mesh(label, faces, pivot)
    material = kiln_paint(obj.data)
    color = bake_pixels(material, size, "DIFFUSE", pass_filter={"COLOR"})
    ao = np.clip(bake_pixels(material, size, "AO")[:, :, :1], 0, 1)
    color[:, :, :3] *= .72 + .28 * ao
    color[:, :, :3] += (1 - ao) * color[:, :, :3] * np.array([.10, .051, .023])
    color[:, :, 3] = 1

    filename = label + ".glb"
    with TemporaryDirectory() as staging:
        image = bpy.data.images.new(label + " atlas", size, size, alpha=False, float_buffer=True)
        image.pixels.foreach_set(color.ravel())
        image_file = str(Path(staging) / (label + ".png"))
        image.save_render(image_file, scene=scene)
        image = bpy.data.images.load(image_file)
        image.pack()
        baked = bpy.data.materials.new("Baked Cinder flues")
        baked.use_nodes = True
        tree = baked.node_tree
        texture = tree.nodes.new("ShaderNodeTexImage")
        texture.image = image
        shader = tree.nodes.get("Principled BSDF")
        shader.inputs["Roughness"].default_value = .76
        tree.links.new(texture.outputs["Color"], shader.inputs["Base Color"])
        obj.data.materials.clear()
        obj.data.materials.append(baked)
        obj.data.color_attributes.remove(obj.data.color_attributes[PAINT])
        obj.data.calc_loop_triangles()
        triangles = len(obj.data.loop_triangles)
        bpy.ops.export_scene.gltf(filepath=str(OUTPUT / filename), export_format="GLB", use_selection=True)

    low, high = bounds(faces)
    return {"file": filename, "triangles": triangles, "atlasPixels": size,
            "sizeStuds": rounded(high - low), "centerStuds": rounded((low + high) / 2)}


def rounded(values):
    return [round(value, 6) for value in values]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("place", nargs="?", type=Path, default=PLACE)
    place = ElementTree.parse(parser.parse_args().place).getroot()
    groups = [group.findall("Item") for group in place.iter("Item") if name(group) == FLUE]
    if len(groups) != 3:
        raise ValueError(f"Expected three authored flues, found {len(groups)}")
    details = [face for group in groups for face in faces_for(group, lod=False)]
    lower = [face for group in groups for face in faces_for(group, lod=True)]
    low, high = bounds(details)
    pivot = (low + high) / 2
    OUTPUT.mkdir(exist_ok=True)
    metadata = {
        "sourceModel": "Copper kilns",
        "replaceSubmodelsNamed": FLUE,
        "keepNativePartsNamed": VENT,
        "nativeVents": sum(name(node) == VENT for group in groups for node in group),
        "pivotStuds": rounded(pivot),
        "detail": export("Cinder_Kiln_Flues", details, pivot, 1024),
        "lowerDetail": export("Cinder_Kiln_Flues_LOD1", lower, pivot, 512),
    }
    (OUTPUT / "placement.json").write_text(json.dumps(metadata, indent=2) + "\n")


if __name__ == "__main__":
    main()
