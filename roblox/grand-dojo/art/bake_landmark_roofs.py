"""Bake the authored Roblox roof parts into one textured mesh per landmark."""

from collections import defaultdict
from dataclasses import dataclass
from math import cos, pi, radians, sin, tau
from pathlib import Path
from tempfile import TemporaryDirectory
from xml.etree import ElementTree
import json

import bpy
import numpy as np
from mathutils import Matrix, Vector


ART = Path(__file__).resolve().parent
PLACE = ART.parent / "Beast_Dojo_Grand_Dojo.rbxlx"
OUTPUT = ART / "landmark-roofs"
LANDMARKS = {
    "Grand Dojo ring canopy": "Fighting_Ring_Roof",
    "Crowned gallery": "Trophy_Hall_Roofs",
    "Lantern district tower": "Lantern_Tower_Roofs",
}
PART_NAMES = {
    "Swept tile panel", "Glazed barrel tile", "Indigo eave tile end",
    "Eave copper edging", "Upturned bronze finial", "Raised ridge coping",
    "Gilded ridge finial", "Brass ridge binding", "Brass ridge shoe",
}

BOX_VERTICES = tuple((x, y, z) for z in (-.5, .5) for y in (-.5, .5) for x in (-.5, .5))
BOX_FACES = ((0, 2, 3, 1), (4, 5, 7, 6), (0, 1, 5, 4), (2, 6, 7, 3), (0, 4, 6, 2), (1, 3, 7, 5))


@dataclass
class RoofPart:
    name: str
    center: Vector
    size: Vector
    axes: Matrix
    color: tuple[float, float, float, float]
    cylinder: bool

    def point(self, coordinates):
        scaled = Vector(tuple(value * scale for value, scale in zip(coordinates, self.size)))
        return self.center + self.axes @ scaled


def name(node):
    return node.findtext("Properties/string[@name='Name']")


def vector(properties, path):
    return Vector(tuple(float(properties.findtext(f"{path}/{axis}")) for axis in "XYZ"))


def linear_srgb(channel):
    return channel / 12.92 if channel <= .04045 else ((channel + .055) / 1.055) ** 2.4


def read_parts(model):
    parts = []
    for node in model.findall("Item[@class='Part']"):
        if name(node) not in PART_NAMES:
            continue
        properties = node.find("Properties")
        frame = properties.find("CoordinateFrame[@name='CFrame']")
        axes = Matrix(tuple(tuple(float(frame.findtext(f"R{row}{col}")) for col in range(3)) for row in range(3)))
        packed_color = int(properties.findtext("Color3uint8[@name='Color3uint8']"))
        color = tuple(linear_srgb(((packed_color >> shift) & 255) / 255) for shift in (16, 8, 0))
        if properties.findtext("bool[@name='CanCollide']") != "false":
            raise ValueError(f"{name(node)} on {name(model)} is a collider")
        parts.append(RoofPart(name(node), vector(properties, "CoordinateFrame[@name='CFrame']"),
                              vector(properties, "Vector3[@name='size']"), axes, (*color, 1),
                              properties.findtext("token[@name='shape']") == "2"))
    if not parts:
        raise ValueError(f"No roof geometry in {name(model)}")
    return parts


def lower_detail(parts):
    rows = defaultdict(list)
    opaque_outline = []
    for part in parts:
        if part.cylinder:
            rows[part.name, round(part.center.z, 3)].append(part)
        else:
            opaque_outline.append(part)
    for row in rows.values():
        ordered = sorted(row, key=lambda part: part.center.x)
        opaque_outline.extend(part for index, part in enumerate(ordered)
                              if index % 3 == 0 or index == len(ordered) - 1)
    return opaque_outline


def cylinder_polygons(profile):
    size = len(profile)
    vertices = tuple((x, y, z) for x in (-.5, .5) for y, z in profile)
    side = [(i, (i+1) % size, (i+1) % size + size, i + size) for i in range(size)]
    return vertices, [*side, tuple(reversed(range(size))), tuple(range(size, 2*size))]


def primitive(part, lod):
    if not part.cylinder:
        return BOX_VERTICES, BOX_FACES, 0
    if part.name == "Glazed barrel tile":
        # The recessed bottom closes the profile and sits inside the clay panel.
        steps = 5 if lod else 7
        angles = tuple(-pi/9 + index * (pi+2*pi/9) / (steps-1) for index in range(steps))
    else:
        steps = 6 if lod else 8
        angles = tuple(tau * index / steps for index in range(steps))
    profile = tuple((.5*sin(angle), .5*cos(angle)) for angle in angles)
    vertices, faces = cylinder_polygons(profile)
    return vertices, faces, steps - int(part.name == "Glazed barrel tile")


def bounds(parts):
    points = [part.point(point) for part in parts for point in primitive(part, False)[0]]
    low = Vector(tuple(min(point[axis] for point in points) for axis in range(3)))
    high = Vector(tuple(max(point[axis] for point in points) for axis in range(3)))
    return (low + high) / 2, high - low


def make_mesh(label, parts, pivot, lod):
    points, faces, colors, smooth = [], [], [], []
    for part in parts:
        vertices, polygons, smooth_sides = primitive(part, lod)
        offset = len(points)
        for corner in vertices:
            x, y, z = part.point(corner) - pivot
            points.append((x, -z, y))
        for index, polygon in enumerate(polygons):
            faces.append(tuple(offset+i for i in polygon))
            colors.append(part.color)
            smooth.append(index < smooth_sides)

    mesh = bpy.data.meshes.new(label)
    mesh.from_pydata(points, [], faces)
    mesh.update()
    paint = mesh.color_attributes.new(name="Roof color", domain="CORNER", type="FLOAT_COLOR")
    for polygon, tint, rounded in zip(mesh.polygons, colors, smooth):
        polygon.use_smooth = rounded
        for index in polygon.loop_indices:
            paint.data[index].color = tint
    model = bpy.data.objects.new(label, mesh)
    bpy.context.scene.collection.objects.link(model)
    model.select_set(True)
    bpy.context.view_layer.objects.active = model
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.uv.smart_project(angle_limit=radians(68), island_margin=.0022, area_weight=.23)
    bpy.ops.object.mode_set(mode="OBJECT")
    return model


def bake_pixels(material, size, kind, **options):
    tree = material.node_tree
    target = tree.nodes.new("ShaderNodeTexImage")
    image = bpy.data.images.new(kind, size, size, alpha=False, float_buffer=True)
    target.image = image
    tree.nodes.active = target
    bpy.ops.object.bake(type=kind, margin=3, margin_type="EXTEND", **options)
    array = np.empty(size*size*4, dtype=np.float32)
    image.pixels.foreach_get(array)
    tree.nodes.remove(target)
    bpy.data.images.remove(image)
    return array.reshape((size, size, 4))


def roof_paint(model):
    material = bpy.data.materials.new("Native roof pigments")
    material.use_nodes = True
    model.data.materials.append(material)
    tree = material.node_tree
    pigment = tree.nodes.new("ShaderNodeVertexColor")
    pigment.layer_name = "Roof color"
    grain = tree.nodes.new("ShaderNodeTexNoise")
    grain.inputs["Scale"].default_value = 8.5
    grain.inputs["Detail"].default_value = 3
    position = tree.nodes.new("ShaderNodeTexCoord")
    tree.links.new(position.outputs["Object"], grain.inputs["Vector"])
    shades = tree.nodes.new("ShaderNodeValToRGB")
    shades.color_ramp.elements[0].color = (.78, .80, .84, 1)
    shades.color_ramp.elements[1].color = (1, 1, 1, 1)
    tree.links.new(grain.outputs["Fac"], shades.inputs["Fac"])
    glaze = tree.nodes.new("ShaderNodeMixRGB")
    glaze.blend_type = "MULTIPLY"
    glaze.inputs[0].default_value = 1
    tree.links.new(pigment.outputs["Color"], glaze.inputs[1])
    tree.links.new(shades.outputs["Color"], glaze.inputs[2])
    tree.links.new(glaze.outputs["Color"], tree.nodes.get("Principled BSDF").inputs["Base Color"])
    return material


def export(parts, pivot, label, *, lod):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 18
    scene.render.threads_mode = "FIXED"
    scene.render.threads = 8
    scene.view_settings.view_transform = "Standard"
    model = make_mesh(label, parts, pivot, lod)
    size = 512 if lod else 1024
    pigment = roof_paint(model)
    color = bake_pixels(pigment, size, "DIFFUSE", pass_filter={"COLOR"})
    ao = np.clip(bake_pixels(pigment, size, "AO")[:, :, :1], 0, 1)
    color[:, :, :3] *= .79 + .21 * ao
    color[:, :, :3] += (1 - ao) * color[:, :, :3] * np.array([.12, .047, .01])
    color[:, :, 3] = 1

    with TemporaryDirectory() as folder:
        atlas = bpy.data.images.new(label + " color", size, size, alpha=False, float_buffer=True)
        atlas.pixels.foreach_set(color.ravel())
        atlas_file = Path(folder) / (label + ".png")
        atlas.save_render(str(atlas_file), scene=scene)
        atlas = bpy.data.images.load(str(atlas_file))
        atlas.pack()
        material = bpy.data.materials.new("Baked roof clay and brass")
        material.use_nodes = True
        tree = material.node_tree
        shader = tree.nodes.get("Principled BSDF")
        shader.inputs["Roughness"].default_value = .67
        texture = tree.nodes.new("ShaderNodeTexImage")
        texture.image = atlas
        tree.links.new(texture.outputs["Color"], shader.inputs["Base Color"])
        model.data.materials.clear()
        model.data.materials.append(material)
        model.data.color_attributes.remove(model.data.color_attributes["Roof color"])
        model.data.calc_loop_triangles()
        triangles = len(model.data.loop_triangles)
        if triangles > 20_000:
            raise ValueError(f"{label} exceeds Roblox's triangle limit: {triangles}")
        bpy.ops.export_scene.gltf(filepath=str(OUTPUT / (label + ".glb")), export_format="GLB",
                                  use_selection=True)
    return {"file": label + ".glb", "triangles": triangles, "atlasPixels": size}


def main():
    root = ElementTree.parse(PLACE).getroot()
    models = {label: node for node in root.iter("Item") if (label := name(node)) in LANDMARKS}
    OUTPUT.mkdir(exist_ok=True)
    manifest = {}
    for label, filename in LANDMARKS.items():
        parts = read_parts(models[label])
        pivot, size = bounds(parts)
        manifest[filename] = {
            "sourceModel": label,
            "nativeRoofParts": len(parts),
            "pivotStuds": [round(value, 6) for value in pivot],
            "detailedSizeStuds": [round(value, 6) for value in size],
            "detail": export(parts, pivot, filename, lod=False),
            "lowerDetail": export(lower_detail(parts), pivot, filename + "_LOD1", lod=True),
        }
    (OUTPUT / "placement.json").write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    main()
