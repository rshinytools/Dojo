"""Author and bake the original Beast Dojo gateway in Blender 4.5.

Run inside Blender with -b --python, or with the official bpy wheel.
"""
from math import atan2, cos, pi, sin
from pathlib import Path

import bpy
import numpy as np
from mathutils import Vector

OUT = Path(__file__).resolve().parent
SIZE = 1024
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 12
scene.cycles.max_bounces = 4
scene.cycles.diffuse_bounces = 3
scene.render.threads_mode = "FIXED"
scene.render.threads = 6
scene.world = bpy.data.worlds.new("Peach dusk")
scene.world.use_nodes = True
background = scene.world.node_tree.nodes.get("Background")
background.inputs["Color"].default_value = (.33, .25, .30, 1)
background.inputs["Strength"].default_value = .55

def material(name, color, roughness=.72):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    root = mat.node_tree.nodes.get("Principled BSDF")
    root.inputs["Base Color"].default_value = (*color, 1)
    root.inputs["Roughness"].default_value = roughness
    return mat

red = material("Persimmon lacquer", (.39, .069, .036))
ink = material("Deep vermilion sign", (.21, .025, .023))
wood = material("Smoked cedar", (.144, .048, .027))
blue = material("Indigo ceramic", (.043, .060, .173), .48)
blue_lip = material("Glazed ridges", (.075, .106, .254), .46)
gold = material("Hammered gold", (.76, .386, .077), .58)
stone = material("Warm slate", (.25, .201, .218))
cream = material("Ivory leaf lettering", (.88, .683, .387))

parts = []

def apply_bevel(obj, width, segments=2):
    if not width:
        return
    bpy.context.view_layer.objects.active = obj
    bevel = obj.modifiers.new("Hand-finished bevel", "BEVEL")
    bevel.width = width
    bevel.segments = segments
    bpy.ops.object.modifier_apply(modifier=bevel.name)

def box(name, location, dimensions, mat, bevel=.04, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    apply_bevel(obj, bevel)
    obj.rotation_euler = rotation
    obj.data.materials.append(mat)
    parts.append(obj)
    return obj

def strut(name, start, end, width, depth, mat):
    start, end = Vector(start), Vector(end)
    direction = end-start
    obj = box(name, (start+end)/2, (width, depth, direction.length), mat, min(width*.16, .045))
    obj.rotation_euler = direction.to_track_quat("Z", "Y").to_euler()
    return obj

def arch_band(name, span, base, rise, height, depth, mat, y=0, segments=20):
    points = []
    faces = []
    for i in range(segments+1):
        x = span*(2*i/segments-1)
        z = base+rise*(1-(x/span)**2)
        points.extend((x, y+side*depth/2, z+h*height/2) for side,h in [(-1,-1), (-1,1), (1,1), (1,-1)])
    for i in range(segments):
        for side in range(4):
            next_side = (side+1)%4
            faces.append((4*i+side, 4*i+next_side, 4*(i+1)+next_side, 4*(i+1)+side))
    faces += [(0,3,2,1), (4*segments,4*segments+1,4*segments+2,4*segments+3)]
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(points, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(obj)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    apply_bevel(obj, .045)
    mesh.materials.append(mat)
    parts.append(obj)

for side in (-1,1):
    x = 11.85*side
    for z,w,h in [(.23,2.82,.46),(.58,2.4,.26),(.81,1.86,.2)]:
        box("Carved slate footing", (x,0,z), (w,w,h), stone, .11)
    box("Lacquered post", (x,0,4.91), (1.62,1.55,8.24), red, .12)
    box("Cedar post inset", (x,-.79,5.45), (.66,.10,4.07), wood, .04)
    for z in (1.35,2.04,7.83,8.72):
        box("Gold bracket", (x,0,z), (1.77,1.68,.18), gold, .042)
    strut("Temple bracket", (x,-.02,6.86),(x-side*2.03,-.02,8.33),.36,.61,wood)
    box("Indigo end cap", (side*13.3,0,10.88), (1.97,1.71,.27), blue_lip, .045,
        (0, side*-.24, 0))
    box("Gold roof tip", (side*14.04,-.01,11.08), (.43,1.83,.23), gold, .045,
        (0, side*-.24, 0))
    # Original reed emblem, constructed from thin solid gold leaves.
    seed = (side*9.28,-.68,8.65)
    for dx,dz in [(-.50,.99),(.12,1.23),(.73,.78)]:
        tip=(seed[0]+dx, seed[1], seed[2]+dz)
        strut("Beast Dojo reed stem",seed,tip,.045,.028,gold)
        for t in (.52,.72):
            leaf=tuple(a+(b-a)*t for a,b in zip(seed,tip))
            strut("Beast Dojo reed leaflet",leaf,(leaf[0]-.18,leaf[1],leaf[2]+.24),.073,.03,gold)

arch_band("Red arch timber", 13.14, 8.74, 1.11, .95, 1.04, red)
arch_band("Deep lacquer sign", 10.65, 8.89, .61, 2.13, .25, ink, y=-.51)
for z in (7.83,9.94):
    arch_band("Raised gold sign trim", 10.67, z, .61, .10, .23, gold, y=-.617)
for y,base in [(-.48,10.53), (0,10.66), (.47,10.55)]:
    arch_band("Glazed indigo coping", 13.35, base, .48, .26, .57, blue, y=y, segments=24)
for i in range(-14,15):
    x=i*.91
    z=10.65+.47*(1-(x/13.35)**2)
    slope=-2*.47*x/(13.35**2)
    box("Individual glazed roof tile",(x,-.12,z),(.24,1.55,.22),blue_lip,.046,(0,-atan2(slope,1),0))

bpy.ops.object.text_add(location=(0,-.66,9.05),rotation=(pi/2,0,0))
lettering = bpy.context.object
lettering.name = "Fighting Ring lettering"
lettering.data.body = "FIGHTING RING"
lettering.data.align_x = "CENTER"
lettering.data.align_y = "CENTER"
lettering.data.size = 1.59
lettering.data.extrude = .033
lettering.data.bevel_depth = .018
lettering.data.bevel_resolution = 1
lettering.data.resolution_u = 4
lettering.data.materials.append(cream)
bpy.ops.object.convert(target="MESH")
parts.append(bpy.context.object)

bpy.ops.object.select_all(action="DESELECT")
for obj in parts:
    obj.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.join()
gate = bpy.context.object
gate.name = "Beast Dojo Fighting Ring Gateway LOD0"
bpy.context.scene.cursor.location = (0,0,0)
bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.uv.smart_project(angle_limit=1.12, island_margin=.0026, area_weight=.16)
bpy.ops.object.mode_set(mode="OBJECT")

def area(name, position, energy, color, size):
    bpy.ops.object.light_add(type="AREA", location=position)
    lamp = bpy.context.object
    lamp.name = name
    lamp.data.energy = energy
    lamp.data.color = color
    lamp.data.shape = "DISK"
    lamp.data.size = size
    lamp.rotation_euler = (Vector((0,0,5))-lamp.location).to_track_quat("-Z","Y").to_euler()

area("Warm evening key",(-9,-12,15),2600,(1,.62,.39),9)
area("Amber reflected courtyard",(8,-8,3.7),900,(1,.64,.37),10)
area("Cool sky fill",(4,5,14),930,(.56,.65,1),12)

def bake(name, bake_type, filters=None):
    image = bpy.data.images.new(name,width=SIZE,height=SIZE,alpha=True,float_buffer=True)
    image.colorspace_settings.name = "Non-Color"
    for slot in gate.material_slots:
        tree = slot.material.node_tree
        node = tree.nodes.new("ShaderNodeTexImage")
        node.image = image
        tree.nodes.active = node
    bpy.ops.object.select_all(action="DESELECT")
    gate.select_set(True)
    bpy.context.view_layer.objects.active = gate
    options = dict(type=bake_type, margin=8, use_clear=True)
    if filters:
        options["pass_filter"]=filters
    bpy.ops.object.bake(**options)
    values = np.empty(SIZE*SIZE*4,dtype=np.float32)
    image.pixels.foreach_get(values)
    return values.reshape((SIZE,SIZE,4))

base = bake("Surface pigment", "DIFFUSE", {"COLOR"})
occlusion = bake("Ambient occlusion", "AO")
diffuse = bake("Evening bounce", "DIFFUSE", {"COLOR","DIRECT","INDIRECT"})
color = np.zeros_like(base)
color[:,:,:3] = base[:,:,:3]*(.60+.40*occlusion[:,:,:3]) + .25*diffuse[:,:,:3]
color[:,:,:3] = np.clip(color[:,:,:3],0,1)
color[:,:,3] = 1
if float(color[:,:,:3].std()) < .025 or float(occlusion[:,:,:3].std()) < .025:
    raise RuntimeError("Baked atlas has no meaningful variation")

atlas = bpy.data.images.new("Baked lacquer and stone",width=SIZE,height=SIZE,alpha=True,float_buffer=True)
atlas.colorspace_settings.name = "Linear Rec.709"
atlas.pixels.foreach_set(color.ravel())
atlas.file_format = "PNG"
atlas.filepath_raw = str(OUT/"Fighting_Ring_Gate_Baked.png")
atlas.save()
atlas.pack()

baked = material("Gate baked AO and warm bounce atlas", (.5,.5,.5))
source=baked.node_tree.nodes.new("ShaderNodeTexImage")
source.image=atlas
baked.node_tree.links.new(source.outputs["Color"], baked.node_tree.nodes.get("Principled BSDF").inputs["Base Color"])
gate.data.materials.clear()
gate.data.materials.append(baked)
for face in gate.data.polygons:
    face.material_index = 0

def export(obj, filename):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active=obj
    bpy.ops.export_scene.gltf(filepath=str(OUT/filename),export_format="GLB",use_selection=True)
    obj.data.calc_loop_triangles()
    print(f"Exported {obj.name} ({len(obj.data.loop_triangles)} tris)")

export(gate,"Fighting_Ring_Gate.glb")
lod = gate.copy()
lod.data = gate.data.copy()
scene.collection.objects.link(lod)
lod.name = "Beast Dojo Fighting Ring Gateway LOD1"
bpy.context.view_layer.objects.active = lod
reduce = lod.modifiers.new("Distance geometry", "DECIMATE")
reduce.ratio = .42
bpy.ops.object.modifier_apply(modifier=reduce.name)
export(lod,"Fighting_Ring_Gate_LOD1.glb")
lod.hide_set(True)
lod.hide_render=True

bpy.ops.object.camera_add(location=(11,-32,15))
camera=bpy.context.object
camera.name="Asset preview camera"
camera.data.type = "ORTHO"
camera.data.ortho_scale = 34
camera.rotation_euler = (Vector((0,0,5.3))-camera.location).to_track_quat("-Z","Y").to_euler()
scene.camera = camera
scene.render.resolution_x = 960
scene.render.resolution_y = 620
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.cycles.samples = 20
scene.cycles.use_denoising = True
scene.render.filepath = str(OUT/"Fighting_Ring_Gate_Preview.png")
bpy.ops.object.select_all(action="DESELECT")
gate.select_set(True)
bpy.context.view_layer.objects.active=gate
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/"Fighting_Ring_Gate.blend"))
bpy.ops.render.render(write_still=True)
