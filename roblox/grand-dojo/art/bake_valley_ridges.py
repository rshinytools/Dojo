"""Bake detailed and lower-detail Beast Dojo ridges with Blender 4.5."""
from collections import defaultdict
from math import sin
from pathlib import Path

import bpy
import numpy as np

from north_ridge_relief import north_ridge_facets
from valley_ridge_layout import VALLEY_RIDGES


ART = Path(__file__).resolve().parent
ATLAS_SIZE = 1024


def linear_component(channel):
    srgb = channel / 255
    return srgb / 12.92 if srgb < .04045 else ((srgb + .055) / 1.055) ** 2.4


def make_ridges(subdivisions):
    positions, faces, texcoords, tints = [], [], [], []
    for layer, profile in enumerate(VALLEY_RIDGES):
        vertices = {}
        panels = list(north_ridge_facets(*profile, lower_detail=subdivisions == 1))
        nearby_tints = defaultdict(list)
        for triangle, _, rgb in panels:
            for point in triangle:
                nearby_tints[point].append(rgb)
        summit = max(profile[4])
        for triangle, uv, rgb in panels:
            triangle_tints = [tuple(sum(channels)/len(channels) for channels in zip(*nearby_tints[p]))
                              for p in triangle] if subdivisions > 1 else [rgb] * 3
            grid = {}
            for i in range(subdivisions+1):
                for j in range(subdivisions+1-i):
                    u, v = i/subdivisions, j/subdivisions
                    weights = 1-u-v, u, v
                    x,y,z = (sum(value*weight for value,weight in zip(axis,weights)) for axis in zip(*triangle))
                    tex_u,tex_v = (sum(value*weight for value,weight in zip(axis,weights)) for axis in zip(*uv))
                    key = tuple(round(value, 5) for value in (x,y,z))
                    if key not in vertices:
                        vertices[key] = len(positions)
                        if subdivisions > 1:
                            envelope = max(0, min(1, y/24, (summit-y)/15, tex_v*12, (1-tex_v)*12))
                            y += envelope * (3.2*sin(.18*x+.22*z) + 1.4*sin(.48*x-.37*z))
                        positions.append((x, -z, y))
                    tint = (sum(value*weight for value,weight in zip(axis,weights)) for axis in zip(*triangle_tints))
                    sample_uv = (.015+tex_u*.97, (layer+.06+tex_v*.88)/len(VALLEY_RIDGES))
                    grid[i,j] = vertices[key],sample_uv,(*map(linear_component,tint),1)
            for i in range(subdivisions):
                for j in range(subdivisions-i):
                    cells = [((i,j),(i+1,j),(i,j+1))]
                    if i+j < subdivisions-1:
                        cells.append(((i+1,j),(i+1,j+1),(i,j+1)))
                    for cell in cells:
                        indices,uvs,colors = zip(*(grid[point] for point in cell))
                        faces.append(indices)
                        texcoords.extend(uvs)
                        tints.extend(colors)

    mesh = bpy.data.meshes.new("Valley ridge relief")
    mesh.from_pydata(positions, [], faces)
    mesh.update()
    if subdivisions > 1:
        for polygon in mesh.polygons:
            polygon.use_smooth = True
    atlas = mesh.uv_layers.new(name="Valley atlas")
    for index, uv in enumerate(texcoords):
        atlas.data[index].uv = uv
    color = mesh.color_attributes.new(name="Rock tints", domain="CORNER", type="FLOAT_COLOR")
    for index, value in enumerate(tints):
        color.data[index].color = value
    label = "Grand Dojo Valley Ridges" if subdivisions > 1 else "Grand Dojo Valley Ridges LOD1"
    model = bpy.data.objects.new(label, mesh)
    bpy.context.scene.collection.objects.link(model)
    bpy.context.view_layer.objects.active = model
    model.select_set(True)
    return model


def bake(scene, material, name, kind, pass_filter=None):
    image = bpy.data.images.new(name, width=ATLAS_SIZE, height=ATLAS_SIZE, alpha=False, float_buffer=True)
    tree = material.node_tree
    target = tree.nodes.new("ShaderNodeTexImage")
    target.image = image
    tree.nodes.active = target
    settings = {"type": kind, "margin": 10}
    if pass_filter:
        settings["pass_filter"] = pass_filter
    bpy.ops.object.bake(**settings)
    samples = np.empty(ATLAS_SIZE * ATLAS_SIZE * 4, dtype=np.float32)
    image.pixels.foreach_get(samples)
    tree.nodes.remove(target)
    bpy.data.images.remove(image)
    return samples.reshape((ATLAS_SIZE, ATLAS_SIZE, 4))


bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 18
scene.render.threads_mode = "FIXED"
scene.render.threads = 8
scene.world = bpy.data.worlds.new("Bake world")
model = make_ridges(3)

material = bpy.data.materials.new("Painted ridge rock")
material.use_nodes = True
model.data.materials.append(material)
tree = material.node_tree
shader = tree.nodes.get("Principled BSDF")
pigment = tree.nodes.new("ShaderNodeVertexColor")
pigment.layer_name = "Rock tints"
position = tree.nodes.new("ShaderNodeTexCoord")
flow = tree.nodes.new("ShaderNodeVectorMath")
flow.operation = "MULTIPLY"
flow.inputs[1].default_value = (1.2, .88, .34)
tree.links.new(position.outputs["Object"], flow.inputs[0])
grain = tree.nodes.new("ShaderNodeTexNoise")
grain.inputs["Scale"].default_value = .105
grain.inputs["Detail"].default_value = 4
tree.links.new(flow.outputs["Vector"], grain.inputs["Vector"])
strata = tree.nodes.new("ShaderNodeValToRGB")
strata.color_ramp.elements[0].color = (.77, .73, .79, 1)
strata.color_ramp.elements[1].color = (1, 1, 1, 1)
tree.links.new(grain.outputs["Fac"], strata.inputs[0])
combine = tree.nodes.new("ShaderNodeMixRGB")
combine.blend_type = "MULTIPLY"
combine.inputs[0].default_value = 1
tree.links.new(pigment.outputs["Color"], combine.inputs[1])
tree.links.new(strata.outputs["Color"], combine.inputs[2])
tree.links.new(combine.outputs[0], shader.inputs["Base Color"])

paint = bake(scene, material, "Rock paint", "DIFFUSE", {"COLOR"})
ao = np.clip(bake(scene, material, "Ravine ambient occlusion", "AO")[:, :, :1], 0, 1)
paint[:, :, :3] *= .76 + .24 * ao
paint[:, :, :3] += paint[:, :, :3] * (1 - ao) * np.array([.10, .040, .019])
paint[:, :, 3] = 1

image = bpy.data.images.new("Valley ridge baked color", width=ATLAS_SIZE, height=ATLAS_SIZE,
                            alpha=False, float_buffer=True)
image.pixels.foreach_set(paint.ravel())
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGB"
scene.render.image_settings.color_depth = "8"
scene.view_settings.view_transform = "Standard"
atlas_path = ART / "Grand_Dojo_Valley_Ridges_Baked.png"
image.save_render(str(atlas_path), scene=scene)

image = bpy.data.images.load(str(atlas_path))
image.pack()
baked = bpy.data.materials.new("Baked valley rock")
baked.use_nodes = True
source = baked.node_tree.nodes.new("ShaderNodeTexImage")
source.image = image
surface = baked.node_tree.nodes.get("Principled BSDF")
surface.inputs["Roughness"].default_value = .93
baked.node_tree.links.new(source.outputs["Color"], surface.inputs["Base Color"])
for mesh,filename in ((model,"Grand_Dojo_Valley_Ridges.glb"),(make_ridges(1),"Grand_Dojo_Valley_Ridges_LOD1.glb")):
    mesh.data.materials.clear()
    mesh.data.color_attributes.remove(mesh.data.color_attributes["Rock tints"])
    mesh.data.materials.append(baked)
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = mesh
    mesh.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(ART / filename), export_format="GLB", use_selection=True)
