"""Export original garden trees with baked ambient shading using Blender and Cycles."""
from math import cos, radians, sin, tau
from pathlib import Path
import sys

import bpy
from mathutils import Vector
import numpy as np

ART = Path(__file__).resolve().parent
sys.path.insert(0, str(ART))
sys.path.insert(0, str(ART.parent))
from art.arrival_canopy_relief import arrival_canopy, arrival_canopy_faces
from arrival_hero_canopies import hero_canopy_faces, hero_canopy_lobes
from garden_tree_layout import garden_knuckles, garden_tree, rotate_garden_spray

def blender(point):
    return Vector((point[0], -point[2], point[1]))


def linear_channel(channel):
    if channel <= .04045:
        return channel / 12.92
    return ((channel + .055) / 1.055) ** 2.4


def foliage_material(pigment):
    material = bpy.data.materials.new(pigment)
    material.use_nodes = True
    nodes = material.node_tree.nodes
    links = material.node_tree.links
    surface = nodes.get("Principled BSDF")
    surface.inputs["Roughness"].default_value = .85
    base = [linear_channel(int(pigment[i:i+2], 16) / 255) for i in (0, 2, 4)]
    coord = nodes.new("ShaderNodeTexCoord")
    noise = nodes.new("ShaderNodeTexNoise")
    noise.inputs["Scale"].default_value = 8
    noise.inputs["Detail"].default_value = 3.5
    links.new(coord.outputs["Object"], noise.inputs["Vector"])
    grain = nodes.new("ShaderNodeTexVoronoi")
    grain.inputs["Scale"].default_value = 32
    links.new(coord.outputs["Object"], grain.inputs["Vector"])
    mottling = nodes.new("ShaderNodeMixRGB")
    mottling.inputs[0].default_value = .47
    links.new(noise.outputs["Fac"], mottling.inputs[1])
    links.new(grain.outputs["Distance"], mottling.inputs[2])
    tint = nodes.new("ShaderNodeValToRGB")
    for entry, factor in zip(tint.color_ramp.elements, (.68, 1.16)):
        entry.color = (*(min(value * factor, 1) for value in base), 1)
    links.new(mottling.outputs["Color"], tint.inputs["Fac"])
    links.new(tint.outputs["Color"], surface.inputs["Base Color"])
    return material


def bake(atlas_size, scene, materials, kind, pass_filter=None):
    image = bpy.data.images.new(kind, width=atlas_size, height=atlas_size, alpha=True, float_buffer=True)
    image.colorspace_settings.name = "Non-Color"
    for material in materials:
        target = material.node_tree.nodes.new("ShaderNodeTexImage")
        target.image = image
        material.node_tree.nodes.active = target
    arguments = {"type": kind, "margin": 6, "margin_type": "EXTEND"}
    if pass_filter:
        arguments["pass_filter"] = pass_filter
    bpy.ops.object.bake(**arguments)
    data = np.empty(atlas_size * atlas_size * 4, dtype=np.float32)
    image.pixels.foreach_get(data)
    return data.reshape((atlas_size, atlas_size, 4))


def export_tree(display_name, blossom, *, lod=False, relief=False, canopy_only=False, hero_canopy=False):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 24
    scene.render.threads_mode = "FIXED"
    scene.render.threads = 8

    spheres={}
    for division in (1,2):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=division, radius=1)
        prototype = bpy.context.object
        spheres[division]=(
            [vertex.co.copy() for vertex in prototype.data.vertices],
            [tuple(face.vertices) for face in prototype.data.polygons],
        )
        bpy.data.objects.remove(prototype, do_unlink=True)

    layout_branches, layout_leaves = garden_tree(blossom, arrival=relief)
    if relief:
        layout_leaves = arrival_canopy(blossom)
    if canopy_only or hero_canopy:
        layout_branches = ()
    if hero_canopy:
        layout_leaves = ()
    vertices, faces, colors, smooth = [], [], [], []

    def add(geometry, polygons, color, shade):
        offset = len(vertices)
        vertices.extend(geometry)
        faces.extend(tuple(i+offset for i in polygon) for polygon in polygons)
        colors.extend([color]*len(polygons))
        smooth.extend([shade]*len(polygons))

    for a, b, pigment in layout_branches:
        start, end = blender(a[:3]), blender(b[:3])
        axis = (end-start).normalized()
        radial = axis.cross(Vector((0, 1, 0))).normalized()
        binormal = axis.cross(radial)
        segments = 6 if lod else 8
        bark = []
        for point, radius in ((start, a[3]), (end, b[3])):
            for index in range(segments):
                angle = index * tau / segments
                bark.append(point + radius * (cos(angle) * radial + sin(angle) * binormal))
        sides = [(i, (i+1)%segments, (i+1)%segments+segments, i+segments) for i in range(segments)]
        sides.extend((tuple(reversed(range(segments))), tuple(range(segments, segments*2))))
        add(bark, sides, pigment, False)

    if not lod and not canopy_only and not hero_canopy:
        sphere_vertices,sphere_faces=spheres[1]
        for point,pigment in garden_knuckles(layout_branches):
            anchor=blender(point[:3])
            radius=point[3]*1.0175
            add([anchor+direction*radius for direction in sphere_vertices],sphere_faces,pigment,True)

    for index, (center, size, angles, pigment, detail) in enumerate(layout_leaves):
        if lod and detail:
            continue
        sphere_vertices,sphere_faces=spheres[1 if lod or detail else 2]
        band = []
        for point in sphere_vertices:
            px, py, pz = point
            ragged = 1 + .09*sin(5.8*px+index*1.47)*cos(7.5*pz-index) + .05*sin(6.3*py-2*pz)
            shifted = rotate_garden_spray((px*size[0]*.5*ragged, py*size[1]*.5*ragged,
                                           pz*size[2]*.5*ragged), angles)
            band.append(blender(tuple(origin+offset for origin,offset in zip(center,shifted))))
        add(band, sphere_faces, pigment, blossom or not detail)

    if hero_canopy:
        for face, pigment in hero_canopy_faces(blossom):
            add([blender(point) for point in face], [(0, 1, 2)], pigment, False)
        sphere_vertices, sphere_faces = spheres[1]
        for center, size, pigment in hero_canopy_lobes(blossom):
            lobe = [blender(tuple(origin + axis * diameter / 2
                                  for origin, axis, diameter in zip(center, direction, size)))
                    for direction in sphere_vertices]
            add(lobe, sphere_faces, pigment, True)
    elif relief and (not lod or not blossom):
        for a, b, c, pigment in arrival_canopy_faces(blossom, lod=lod):
            add([blender(point) for point in (a, b, c)], [(0, 1, 2)], pigment, False)

    mesh = bpy.data.meshes.new(display_name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    model = bpy.data.objects.new(display_name, mesh)
    scene.collection.objects.link(model)
    model.select_set(True)
    bpy.context.view_layer.objects.active = model
    palette = {}
    for face, pigment, soften in zip(mesh.polygons, colors, smooth):
        if pigment not in palette:
            palette[pigment] = len(mesh.materials)
            mesh.materials.append(foliage_material(pigment))
        face.material_index = palette[pigment]
        face.use_smooth = soften
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.uv.smart_project(angle_limit=radians(72), island_margin=.009, area_weight=.24)
    bpy.ops.object.mode_set(mode="OBJECT")

    atlas=512 if lod else 1024
    color = bake(atlas, scene, mesh.materials, "DIFFUSE", {"COLOR"})
    ao = np.clip(bake(atlas, scene, mesh.materials, "AO")[:, :, :1], 0, 1)
    color[:, :, :3] *= .70 + .30 * ao
    color[:, :, :3] += color[:, :, :3] * (1-ao) * np.array([.11, .052, .018])
    color[:, :, 3] = 1

    image = bpy.data.images.new(display_name + " baked color", width=atlas, height=atlas,
                                alpha=False, float_buffer=True)
    image.pixels.foreach_set(color.ravel())
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGB"
    scene.render.image_settings.color_depth = "8"
    scene.view_settings.view_transform = "Standard"
    filename = display_name.replace(" ", "_")
    image_path = ART / (filename + "_Baked.png")
    image.save_render(str(image_path), scene=scene)
    image = bpy.data.images.load(str(image_path))
    image.pack()

    mesh.materials.clear()
    material = bpy.data.materials.new("Baked garden foliage")
    material.use_nodes = True
    image_node = material.node_tree.nodes.new("ShaderNodeTexImage")
    image_node.image = image
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Roughness"].default_value = .85
    material.node_tree.links.new(image_node.outputs["Color"], shader.inputs["Base Color"])
    mesh.materials.append(material)
    for polygon in mesh.polygons:
        polygon.material_index = 0
    bpy.ops.export_scene.gltf(filepath=str(ART / (filename + ".glb")), export_format="GLB", use_selection=True)


if __name__ == "__main__":
    if "--hero-arrival-canopies" in sys.argv[1:]:
        for tree, blossom in (("Pine", False), ("Blossom", True)):
            export_tree(f"Grand Dojo Arrival Hero {tree} Canopy", blossom, hero_canopy=True)
    elif "--arrival-pine-canopy" in sys.argv[1:]:
        for lod, suffix in ((False, ""), (True, " LOD1")):
            export_tree(f"Grand Dojo Arrival Pine Canopy{suffix}", False,
                        lod=lod, relief=True, canopy_only=True)
    else:
        relief = "--arrival" in sys.argv[1:]
        label = "Grand Dojo Arrival" if relief else "Grand Dojo"
        for tree, blossom in (("Blossom", True), ("Pine", False)):
            export_tree(f"{label} {tree}", blossom, relief=relief)
            export_tree(f"{label} {tree} LOD1", blossom, lod=True, relief=relief)
