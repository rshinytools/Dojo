"""Bake the Grand Dojo promenade for Roblox import using Blender 4.5 and Cycles."""
from pathlib import Path
import sys

import bpy
import numpy as np

ART = Path(__file__).resolve().parent
sys.path.insert(0, str(ART))
from promenade_layout import PROMENADE_BOUNDS, PROMENADE_GRADE, flagstones, promenade_sections, stone_pigment

WIDTH, HEIGHT = 1024, 2048
X_MIN, X_MAX, Z_MIN, Z_MAX = PROMENADE_BOUNDS
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 20
scene.render.threads_mode = "FIXED"
scene.render.threads = 8


def linear_channel(channel):
    if channel <= .04045:
        return channel / 12.92
    return ((channel + .055) / 1.055) ** 2.4


def sandstone(bevel):
    material = bpy.data.materials.new("Sandstone edge" if bevel else "Sandstone face")
    material.use_nodes = True
    nodes = material.node_tree.nodes
    links = material.node_tree.links
    stone = nodes.get("Principled BSDF")
    stone.inputs["Roughness"].default_value = .58
    tint = nodes.new("ShaderNodeVertexColor")
    tint.layer_name = "Promenade light colors"
    texture = nodes.new("ShaderNodeTexNoise")
    texture.inputs["Scale"].default_value = 11
    texture.inputs["Detail"].default_value = 4
    coords = nodes.new("ShaderNodeTexCoord")
    links.new(coords.outputs["Object"], texture.inputs["Vector"])
    stains = nodes.new("ShaderNodeTexNoise")
    stains.inputs["Scale"].default_value = 1.15
    stains.inputs["Detail"].default_value = 3.1
    links.new(coords.outputs["Object"], stains.inputs["Vector"])
    blend = nodes.new("ShaderNodeMixRGB")
    blend.inputs["Fac"].default_value = .57
    links.new(texture.outputs["Fac"], blend.inputs[1])
    links.new(stains.outputs["Fac"], blend.inputs[2])
    grain = nodes.new("ShaderNodeValToRGB")
    factors = (.60,.89) if bevel else (.77,1.13)
    for entry, factor in zip(grain.color_ramp.elements, factors):
        entry.color = (factor, factor, factor, 1)
    grain_tint = nodes.new("ShaderNodeMixRGB")
    grain_tint.blend_type = "MULTIPLY"
    grain_tint.inputs[0].default_value = 1
    links.new(blend.outputs["Color"], grain.inputs["Fac"])
    links.new(tint.outputs["Color"], grain_tint.inputs[1])
    links.new(grain.outputs["Color"], grain_tint.inputs[2])
    links.new(grain_tint.outputs["Color"], stone.inputs["Base Color"])
    return material


def assign_atlas_uvs(mesh):
    uv = mesh.uv_layers.new(name="Sandstone atlas")
    for loop in mesh.loops:
        x, y, _ = mesh.vertices[loop.vertex_index].co
        uv.data[loop.index].uv = ((x-X_MIN)/(X_MAX-X_MIN), (Z_MAX+y)/(Z_MAX-Z_MIN))


vertices, vertex_tints, faces, face_materials, undersides = [], [], [], [], []
for pigment, shoulder, face in flagstones():
    offset = len(vertices)
    count = len(face)
    for ring in (shoulder, face):
        for x,y,z in ring:
            painted = stone_pigment(pigment, (x,z))
            vertex_tints.append((*[linear_channel(int(painted[i:i+2],16)/255) for i in (0,2,4)], 1))
            vertices.append((x,-z,y-PROMENADE_GRADE))
    for edge in range(count):
        next_edge = (edge+1) % count
        faces.append(tuple(offset + index for index in (edge, edge+count, next_edge+count, next_edge)))
        face_materials.append(1)
    faces.append(tuple(offset+count+i for i in reversed(range(count))))
    face_materials.append(0)
    undersides.append(tuple(offset+i for i in range(count)))

mesh = bpy.data.meshes.new("Beveled sandstone")
mesh.from_pydata(vertices, [], faces)
mesh.update()
promenade = bpy.data.objects.new("Grand Dojo promenade flagstones", mesh)
scene.collection.objects.link(promenade)
assign_atlas_uvs(mesh)
mesh.materials.append(sandstone(False))
mesh.materials.append(sandstone(True))
colors = mesh.color_attributes.new(name="Promenade light colors", type="FLOAT_COLOR", domain="POINT")
for item, tint in zip(colors.data, vertex_tints):
    item.color = tint
for face, material_index in zip(mesh.polygons, face_materials):
    face.material_index = material_index

# The mortar receives shadows during the bake. The place retains its native mortar collider.
for left,right,north,south in promenade_sections():
    bpy.ops.mesh.primitive_plane_add(size=2, location=((left+right)/2,-(north+south)/2,-.008))
    bpy.context.object.scale = ((right-left)/2,(south-north)/2,1)
bpy.ops.object.select_all(action="DESELECT")
promenade.select_set(True)
bpy.context.view_layer.objects.active = promenade


def bake(name, kind, pass_filter=None):
    image = bpy.data.images.new(name,width=WIDTH,height=HEIGHT,alpha=True,float_buffer=True)
    image.colorspace_settings.name = "Non-Color"
    for material in mesh.materials:
        nodes = material.node_tree.nodes
        target = nodes.new("ShaderNodeTexImage")
        target.image = image
        nodes.active = target
    options = {"type": kind, "margin": 4, "margin_type": "EXTEND"}
    if pass_filter:
        options["pass_filter"] = pass_filter
    bpy.ops.object.bake(**options)
    data = np.empty(WIDTH * HEIGHT * 4, dtype=np.float32)
    image.pixels.foreach_get(data)
    return data.reshape((HEIGHT, WIDTH, 4))


color = bake("Sandstone color", "DIFFUSE", {"COLOR"})
occlusion = bake("Stone seams", "AO")[:, :, :1]
shade = np.clip(occlusion, 0, 1)
# Keep the shadow shallow and tint the bounced light toward amber at the bevels.
color[:, :, :3] *= .68 + .32 * shade
warm_bounce = (1-shade) * .12
color[:, :, :3] += color[:, :, :3] * warm_bounce * np.array([1, .45, .15])
color[:, :, 3] = 1
image = bpy.data.images.new("Sandstone baked color", width=WIDTH, height=HEIGHT, alpha=False, float_buffer=True)
image.pixels.foreach_set(color.ravel())
image_path = ART / "Promenade_Flagstones_Baked.png"
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGB"
scene.render.image_settings.color_depth = "8"
scene.view_settings.view_transform = "Standard"
image.save_render(str(image_path), scene=scene)
image = bpy.data.images.load(str(image_path))
image.pack()

# Cap the export after baking so the new undersides cannot change the visible atlas.
bake_mesh = mesh
mesh = bpy.data.meshes.new("Closed sandstone")
mesh.from_pydata(vertices, [], faces + undersides)
mesh.update()
promenade.data = mesh
bpy.data.meshes.remove(bake_mesh)
mesh.name = "Beveled sandstone"
assign_atlas_uvs(mesh)
material = bpy.data.materials.new("Baked sandstone")
material.use_nodes = True
nodes = material.node_tree.nodes
shader = nodes.get("Principled BSDF")
shader.inputs["Roughness"].default_value = .58
texture = nodes.new("ShaderNodeTexImage")
texture.image = image
material.node_tree.links.new(texture.outputs["Color"], shader.inputs["Base Color"])
mesh.materials.append(material)
bpy.ops.export_scene.gltf(filepath=str(ART / "Promenade_Flagstones.glb"), export_format="GLB", use_selection=True)
mesh.calc_loop_triangles()
print(f"Exported {len(mesh.loop_triangles)} triangles in {len(undersides)} closed flagstones with a {WIDTH} by {HEIGHT} baked atlas.")
