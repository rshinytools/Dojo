"""Build Beast Dojo's South Ridge crest, its diffuse atlas and HUD icon.

Run with Blender 4.5 in background mode, or with its Python wheel.
The mesh uses Blender Z-up, with its decorated front facing -Y.
"""

from math import cos, pi, sin
from pathlib import Path
import json

import bpy
import numpy as np
from mathutils import Vector


OUT = Path(__file__).resolve().parent
ATLAS_SIZE = 512
ICON_SIZE = 384
STEM = 'South_Ridge_Emblem'
SECTIONS = 48

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.device = 'CPU'
scene.cycles.samples = 12
scene.cycles.max_bounces = 3
scene.render.threads_mode = 'FIXED'
scene.render.threads = 4
scene.world = bpy.data.worlds.new('Ridge evening')
scene.world.use_nodes = True
background = scene.world.node_tree.nodes.get('Background')
background.inputs['Color'].default_value = (.34, .42, .61, 1)
background.inputs['Strength'].default_value = .34


def pigment(name, color, roughness, grain=0):
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    tree = material.node_tree
    shader = tree.nodes.get('Principled BSDF')
    shader.inputs['Base Color'].default_value = (*color, 1)
    shader.inputs['Roughness'].default_value = roughness
    if grain:
        texture = tree.nodes.new('ShaderNodeTexNoise')
        texture.inputs['Scale'].default_value = 52
        texture.inputs['Detail'].default_value = 2
        ramp_node = tree.nodes.new('ShaderNodeValToRGB')
        ramp = ramp_node.color_ramp
        ramp.elements[0].color = (*(c * (1 - grain) for c in color), 1)
        ramp.elements[1].color = (*(min(1, c * (1 + grain)) for c in color), 1)
        tree.links.new(texture.outputs['Fac'], ramp_node.inputs['Fac'])
        tree.links.new(ramp_node.outputs['Color'], shader.inputs['Base Color'])
    return material


stone = pigment('Warm grey limestone', (.264, .192, .155), .89, .25)
stone_edge = pigment('Weathered sandstone edge', (.43, .33, .23), .75, .18)
inner = pigment('Deep enamel field', (.017, .076, .079), .53, .13)
rim = pigment('Satin worn brass', (.45, .255, .083), .55, .15)
line = pigment('Brass caught by sunset', (.78, .51, .186), .50, .12)
lowland = pigment('Ochre horizon', (.20, .115, .056), .7, .14)
ridge = pigment('Slate mountain face', (.076, .235, .216), .71, .12)
ridge_highlight = pigment('Mountain shoulder', (.179, .378, .327), .63, .11)
leaf_dark = pigment('Dark jade carving', (.036, .237, .176), .6, .1)
leaf = pigment('Polished green jade', (.091, .44, .288), .45, .09)
leaf_edge = pigment('Jade bevel highlight', (.249, .552, .343), .51, .08)

parts = []


def mesh(name, vertices, faces, materials, face_materials=None):
    geometry = bpy.data.meshes.new(name)
    geometry.from_pydata(vertices, [], faces)
    geometry.update()
    item = bpy.data.objects.new(name, geometry)
    scene.collection.objects.link(item)
    for material in materials:
        geometry.materials.append(material)
    if face_materials:
        for face, index in zip(geometry.polygons, face_materials):
            face.material_index = index
    parts.append(item)


def medallion():
    # Inner rings move forward, then return toward the stone bed to form a carved recess.
    profiles = (
        (1.62, .205), (1.8, .106), (1.8, -.067), (1.735, -.137),
        (1.625, -.158), (1.585, -.208), (1.47, -.208), (1.40, -.135),
        (1.35, -.141), (1.325, -.152), (1.30, -.136), (1.27, -.113),
    )
    points = [
        (radius * cos(2 * pi * i / SECTIONS), depth, radius * sin(2 * pi * i / SECTIONS))
        for radius, depth in profiles for i in range(SECTIONS)
    ]
    faces = [tuple(reversed(range(SECTIONS)))]
    slots = [0]
    for layer, slot in enumerate((0, 0, 1, 1, 2, 3, 2, 0, 3, 2, 0)):
        start = layer * SECTIONS
        for i in range(SECTIONS):
            a = start + i
            b = start + (i + 1) % SECTIONS
            faces.append((a, b, b + SECTIONS, a + SECTIONS))
            slots.append(slot)
    faces.append(tuple(range(len(points) - SECTIONS, len(points))))
    slots.append(4)
    mesh('Stone base and recessed brass rim', points, faces, (stone, stone_edge, rim, line, inner), slots)


def raised_shape(name, outline, front, thickness, face, bevel_material, bevel=.02):
    cx = sum(point[0] for point in outline) / len(outline)
    cz = sum(point[1] for point in outline) / len(outline)
    vertices = [(x, front + thickness, z) for x, z in outline]
    vertices.extend((x, front + thickness * .46, z) for x, z in outline)
    for x, z in outline:
        vector = Vector((cx - x, cz - z))
        dx, dz = vector.normalized() * min(bevel, vector.length * .22)
        vertices.append((x + dx, front, z + dz))
    count = len(outline)
    faces = [tuple(reversed(range(count)))]
    slots = [1]
    for layer in range(2):
        start = layer * count
        for index in range(count):
            a = start + index
            b = start + (index + 1) % count
            faces.append((a, b, b + count, a + count))
            slots.append(1)
    faces.append(tuple(range(count * 2, count * 3)))
    slots.append(0)
    mesh(name, vertices, faces, (face, bevel_material), slots)


def ridge_line():
    horizon = ((-1.13, .24), (-.56, .72), (-.24, .45), (.25, .93),
               (.59, .61), (.72, .67), (1.14, .26), (.98, .15), (-.94, .15))
    raised_shape('Recessed mountain line', horizon, -.159, .055, ridge, lowland)
    shoulder = ((-.24, .45), (.25, .93), (.20, .65), (.54, .60),
                (.65, .41), (.18, .45), (-.10, .33))
    raised_shape('Lit slate shoulder', shoulder, -.173, .029, ridge_highlight, leaf_dark, .012)
    sunset = tuple((.20 * cos(2 * pi * i / 24) - .48, .20 * sin(2 * pi * i / 24) + .87)
                   for i in range(24))
    raised_shape('Small rising sun', sunset, -.153, .047, line, rim, .016)


def reed_pair():
    # A pair of reeds opens into the V of the original valley crest.
    outlines = (
        ((-.08, -.83), (-.32, -.79), (-.65, -.67), (-.93, -.50),
         (-1.08, -.28), (-1.11, .02), (-.84, -.10), (-.62, -.16),
         (-.41, -.30), (-.22, -.52)),
        ((.01, -.82), (.16, -.59), (.32, -.37), (.55, -.21),
         (.84, -.14), (1.11, .02), (1.05, -.30), (.88, -.52),
         (.62, -.70), (.34, -.79), (.17, -.80)),
    )
    for number, outline in enumerate(outlines):
        raised_shape(f'Trace of brass around reed {number + 1}', outline, -.238, .137, rim, line, .028)
        inset = tuple((x * .91 + (-.024 if number == 0 else .029), (z + .4) * .83 - .4)
                      for x, z in outline)
        raised_shape(f'Inset green jade reed {number + 1}', inset, -.272, .065, leaf, leaf_edge, .021)

    veins = (
        ((-.12, -.78), (-.43, -.58), (-.71, -.39), (-1.01, -.11),
         (-.73, -.47), (-.45, -.66), (-.15, -.80)),
        ((.059, -.80), (.40, -.63), (.69, -.43), (1.03, -.106),
         (.71, -.50), (.43, -.69), (.09, -.81)),
    )
    for index, outline in enumerate(veins):
        raised_shape(f'Gold reed vein {index + 1}', outline, -.283, .026, line, rim, .005)

    for side in (-1, 1):
        mark = ((side*.168, -.88), (side*.105, -.92), (0, -.99), (side*.096, -1.045), (side*.172, -.993))
        raised_shape('Split gold crown point', mark, -.182, .073, line, rim, .011)


def cardinal_marks():
    for index in range(12):
        angle = 2 * pi * index / 12
        radius = 1.54
        angular_width = .031 if index % 3 else .041
        inset = .04 if index % 3 else .118
        mark = (
            (radius * cos(angle - angular_width), radius * sin(angle - angular_width)),
            (radius * cos(angle + angular_width), radius * sin(angle + angular_width)),
            ((radius-inset) * cos(angle), (radius-inset) * sin(angle)),
        )
        raised_shape('Inset compass tick', mark, -.220, .027, line, rim, .006)


medallion()
ridge_line()
reed_pair()
cardinal_marks()
bpy.ops.object.select_all(action='DESELECT')
for item in parts:
    item.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.join()
emblem = bpy.context.object
emblem.name = 'Beast Dojo South Ridge Emblem'
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.uv.smart_project(angle_limit=1.10, island_margin=.004, area_weight=.24)
bpy.ops.object.mode_set(mode='OBJECT')


def area(name, coordinates, color, energy, size):
    light = bpy.data.lights.new(name, 'AREA')
    light.energy = energy
    light.color = color
    light.shape = 'DISK'
    light.size = size
    item = bpy.data.objects.new(name, light)
    scene.collection.objects.link(item)
    item.location = coordinates
    item.rotation_euler = (-item.location).to_track_quat('-Z', 'Y').to_euler()


area('Dusk key', (-3.8, -4.5, 5.0), (1, .70, .48), 540, 4.0)
area('Cool sky fill', (3.0, -2.9, .8), (.63, .78, 1), 225, 3.1)
area('Sandstone bounce', (-1, -2.6, -3.1), (1, .68, .45), 125, 4.0)


def bake(name, bake_type, filters=None):
    image = bpy.data.images.new(name, ATLAS_SIZE, ATLAS_SIZE, alpha=True, float_buffer=True)
    image.colorspace_settings.name = 'Non-Color'
    for slot in emblem.material_slots:
        tree = slot.material.node_tree
        target = tree.nodes.new('ShaderNodeTexImage')
        target.image = image
        tree.nodes.active = target
    options = dict(type=bake_type, margin=5, use_clear=True)
    if filters:
        options['pass_filter'] = filters
    bpy.ops.object.bake(**options)
    pixels = np.empty(ATLAS_SIZE * ATLAS_SIZE * 4, dtype=np.float32)
    image.pixels.foreach_get(pixels)
    return pixels.reshape((ATLAS_SIZE, ATLAS_SIZE, 4))


base = bake('Pigment', 'DIFFUSE', {'COLOR'})
occlusion = bake('Contact shading', 'AO')
bounce = bake('Warm bounce', 'DIFFUSE', {'COLOR', 'DIRECT', 'INDIRECT'})
combined = np.ones_like(base)
combined[:, :, :3] = np.clip(base[:, :, :3] * (.61 + .39 * occlusion[:, :, :3])
                             + .17 * bounce[:, :, :3], 0, 1)
assert float(combined[:, :, :3].std()) > .06 and float(occlusion[:, :, :3].std()) > .03

linear_atlas = bpy.data.images.new('Linear stone, brass and jade bake', ATLAS_SIZE, ATLAS_SIZE,
                                   alpha=False, float_buffer=True)
linear_atlas.colorspace_settings.name = 'Linear Rec.709'
linear_atlas.pixels.foreach_set(combined.ravel())
scene.view_settings.view_transform = 'Standard'
scene.render.image_settings.file_format = 'PNG'
scene.render.image_settings.color_mode = 'RGB'
scene.render.image_settings.color_depth = '8'
scene.render.dither_intensity = 0
atlas_path = str(OUT / f'{STEM}_Baked.png')
linear_atlas.save_render(atlas_path, scene=scene)
atlas = bpy.data.images.load(atlas_path)
atlas.pack()

baked = pigment('South Ridge AO and bounce', (.5, .5, .5), .61)
tree = baked.node_tree
texture = tree.nodes.new('ShaderNodeTexImage')
texture.image = atlas
tree.links.new(texture.outputs['Color'], tree.nodes.get('Principled BSDF').inputs['Base Color'])
emblem.data.materials.clear()
emblem.data.materials.append(baked)
for polygon in emblem.data.polygons:
    polygon.material_index = 0

# Centering the origin simplifies placement on either a sign face or a deck.
bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')
emblem.location = (0, 0, 0)
bpy.ops.export_scene.gltf(filepath=str(OUT / f'{STEM}.glb'), export_format='GLB', use_selection=True,
                          export_yup=True)
emblem.data.calc_loop_triangles()

camera_data = bpy.data.cameras.new('UI crop camera')
camera = bpy.data.objects.new('UI crop camera', camera_data)
scene.collection.objects.link(camera)
camera.location = (1.0, -8.7, 1.25)
camera.rotation_euler = (-camera.location).to_track_quat('-Z', 'Y').to_euler()
camera_data.type = 'ORTHO'
camera_data.ortho_scale = 4.12
scene.camera = camera
scene.cycles.samples = 40
scene.cycles.use_denoising = True
scene.view_settings.view_transform = 'AgX'
scene.view_settings.look = 'AgX - Medium High Contrast'
scene.render.resolution_x = ICON_SIZE
scene.render.resolution_y = ICON_SIZE
scene.render.resolution_percentage = 100
scene.render.film_transparent = True
scene.render.image_settings.file_format = 'PNG'
scene.render.image_settings.color_mode = 'RGBA'
scene.render.filepath = str(OUT / f'{STEM}_Icon.png')
bpy.ops.render.render(write_still=True)

record = {
    'triangles': len(emblem.data.loop_triangles),
    'bake': [ATLAS_SIZE, ATLAS_SIZE],
    'icon': [ICON_SIZE, ICON_SIZE],
    'robloxDimensionsXYZ': [round(emblem.dimensions[i], 3) for i in (0, 2, 1)],
    'glTFFrontAxis': '+Z',
    'creativeSource': 'Original code-authored Blender geometry and material bakes',
}
(OUT / 'emblem.json').write_text(json.dumps(record, indent=2) + '\n')
print(record)
