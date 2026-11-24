"""Build the standalone Grand Dojo Roblox place from original geometry and Luau."""
from itertools import count
from math import atan2, ceil, cos, degrees, dist, hypot, radians, sin, tau
from pathlib import Path
import xml.etree.ElementTree as ET
import copy
import json
import random

from art.arrival_canopy_relief import arrival_canopy, arrival_canopy_faces
from art.arrival_distant_ridges import build_arrival_distant_ridges
from art.promenade_layout import (ARRIVAL_LAMPS, INLET_EDGE, INLET_NORTH, INLET_SOUTH,
                                   INLET_SWIM_Z, ORIGINAL_SOUTH_EDGE, PROMENADE_BOUNDS, PROMENADE_GRADE,
                                   flagstones, promenade_dampness, promenade_sections,
                                   ring_forecourt_pigment, stone_pigment, tint_stone)
from art.garden_tree_layout import garden_knuckles, garden_tree, rotate_garden_point
from art.north_ridge_relief import north_ridge_facets
from clay_lantern_shore import build_clay_lantern_shore
from clay_lantern_walk import (build_clay_lantern_walk,
                               road_coordinates as clay_lantern_road_coordinates)
from art.valley_ridge_layout import VALLEY_RIDGES
from art.cinder_hillside_layout import OUTLINE as CINDER_OUTLINE, hillside_faces, hillside_rings
from arrival_bank_planting import build_arrival_bank_planting
from arrival_canal_reflection import build_arrival_canal_reflection
from arrival_flagstone_detail import build_arrival_flagstone_detail
from arrival_hero_canopies import build_arrival_hero_canopy
from arrival_lantern_craft import craft_board_lantern, craft_hanging_lantern
from arrival_lotus_cove import build_arrival_lotus_cove
from arrival_lotus_leaves import build_arrival_lotus_leaves
from canal_lip_gardens import build_canal_lip_gardens
from cedarbank_rise import PATH as CEDARBANK_PATH, build_cedarbank_rise
from cinder_arrival_relief import build_cinder_arrival_relief
from cinder_harbor_road_relief import build_cinder_harbor_road_relief
from cinder_kilnwalk import GLAZE_RAIL_OPENING, POTTERS_NORTH_RAIL_END, build_cinder_kiln_walk
from cinder_ravine_terraces import build_cinder_ravine_terraces
from cinder_workshop_hall import build_cinder_workshop_hall
from city_boundary import build_south_boundary
from coastal_horizon import build_coastal_horizon
from creator_store_canal_stones import build_canal_store_stones
from cloudbreak_course import build_cloudbreak_course
from cloudbreak_scenery import build_cloudbreak_scenery
from crown_crossing import (KILN_JOIN as CROWN_KILN_JOIN, NAME as CROWN_CROSSING,
                            POINTS as CROWN_CROSSING_POINTS, build_crown_crossing)
from crown_crossing_markers import build_crown_crossing_markers
from crown_pavilion import CROWN_ENTRY_Z, CROWN_ROUTE_WIDTH, build_crown_pavilion
from crown_ravine_cedars import build_crown_ravine_cedars
from crown_ravine_gardens import build_crown_ravine_gardens
from district_gateways import build_district_gateway
from festival_bridge_details import build_festival_bridge_details
from frostglass_arrival_hall import build_frostglass_arrival_hall
from frostglass_snow_ridges import build_frostglass_snow_ridges
from frostglass_glacier_walk import ASCENT as GLACIER_ASCENT, BALCONY_JOIN, CROWN as GLACIER_PAVILION, build_frostglass_glacier_walk
from snowbell_ridge import (NAME as SNOWBELL_RIDGE, MISTLINE_SEGMENT, MISTLINE_OPENING,
                            build_snowbell_ridge, mistline_junction)
from snowbell_hollow import build_snowbell_hollow
from frostglass_reflectors import build_frostglass_reflectors
from frostglass_store_planting import build_frostglass_approach_planting, build_frostglass_store_planting
from hall_arrival_details import build_hall_arrival_details
from hall_arrival_mass import (build_hall_arrival_mass, build_hall_crown_roof, build_hall_cup_relief,
                               hall_portico_box, hall_portico_y,
                               build_hall_upper_bays, build_hall_wing_eave)
from hall_valley_facades import build_hall_valley_facades
from hall_garden_spill import build_hall_garden_spill
from hall_inner_portal import build_hall_inner_portal
from hall_split_stair import build_hall_split_stair
from hall_stair_court import build_hall_stair_court
from harbor_arrival_hall import build_harbor_arrival_hall
from harbor_cargo_hoist import build_harbor_cargo_hoist
from harbor_goods import build_harbor_goods
from harbor_roof_walk import BEACON_GUARDS as SKY_PIER_BEACON_GUARDS, build_harbor_roof_walk
from kiln_pass import NAME as KILN_PASS, POINTS as KILN_PASS_POINTS, WIND_OPENING, build_kiln_pass
from kiln_ridge_walk import PATH as KILN_RIDGE_PATH, build_kiln_ridge_walk
from lantern_arrival_relief import build_lantern_arrival_relief
from lantern_court_shopfronts import build_lantern_court_shopfronts
from lantern_foothill_gardens import build_lantern_foothill_gardens
from lantern_garden_walk import GARDENER, build_lantern_garden_walk
from lantern_guild_beacon import build_lantern_guild_beacon
from lantern_market_crossing import build_lantern_market_crossing
from lantern_market_frontage import build_lantern_market_frontage
from lantern_market_goods import build_lantern_market_goods
from lantern_tower_ramp import build_lantern_tower_ramp
from lantern_town_gate import build_lantern_town_gate
from meltwater_bridge_art import build_meltwater_bridge_art
from meltwater_high_walk import (MARKET_OPENING as MELTWATER_MARKET_OPENING,
                                 NAME as MELTWATER_HIGH_WALK, POINTS as MELTWATER_HIGH_POINTS,
                                 build_meltwater_high_walk)
from meltwater_valley_art import build_meltwater_valley_art
from lanternwood_ridge import build_lanternwood_ridge
from lanternmakers_overlook import CALLIGRAPHER, build_lanternmakers_overlook
from orchard_bluff import build_orchard_bluff
from orchard_high_walk import (ASCENT as ORCHARD_ASCENT, DESCENT as ORCHARD_DESCENT,
                                KEEPER as ORCHARD_KEEPER, NAME as ORCHARD_WALK,
                                ROAD_OPENING as ORCHARD_ROAD_OPENING, build_orchard_high_walk)
from plum_lantern_walk import NAME as PLUM_LANTERN_WALK, PATH as PLUM_LANTERN_PATH, build_plum_lantern_walk
from orchard_road_terraces import build_orchard_road_terraces
from pinecrest_trail import RIDGE_WIDTH, WIND_LOOKOUT_DECK, build_pinecrest_crossing, build_pinecrest_trail
from pinecrest_ravine import build_pinecrest_ravine
from skywalk_gatehouse import build_skywalk_gatehouse
from plaza_bank_art import build_bank_stone, build_golden_plumes
from relay_approach import build_relay_runner
from skywalk_foothill import build_skywalk_foothill
from skywalk_road_bank import build_skywalk_road_bank
from reedfall_arrival_backdrop import build_reedfall_arrival_backdrop
from reedfall_arrival_terraces import build_reedfall_arrival_terraces
from reedfall_crown_wayfinding import build_reedfall_crown_wayfinding
from reedfall_ledge_gardens import build_reedfall_ledge_gardens
from reedfall_turning_landings import build_reedfall_turning_landings
from reedfall_west_spill import build_reedfall_west_spill
from relay_arrival_portico import build_relay_arrival_portico
from ring_arrival_details import (build_ring_arrival_details, build_ring_ceiling_panels, build_ring_paper_lantern,
                                  build_ring_stair_lantern_plinth, build_ring_stone_cheeks)
from ring_canvas_detail import CANVAS_TINT, build_ring_canvas_detail
from ring_gate_standard import build_ring_gate_standard
from saltwind_bluff_art import FACE_TINTS as SALTWIND_SLATE, build_saltwind_bluff_art
from saltwind_high_walk import (NAME as SALTWIND_WALK, POINTS as SALTWIND_WALK_POINTS,
                                SALTWIND_OPENING, build_saltwind_high_walk)
from south_channel_arch import build_south_channel_arch
from south_ridge_trail import build_south_ridge_trail
from south_valley_backdrop import build_south_valley_backdrop, hillside_cedar, ridge_surface_height
from tidebank_landing import build_tidebank_landing
from tideharbor_offshore import build_tideharbor_offshore
from tideharbor_town_gate import build_tideharbor_town_gate
from tideharbor_loading_bay import build_tideharbor_loading_bay
from tideharbor_sea_stacks import SEA_STACK_MATERIAL, SEA_STACK_VARIANT, build_tideharbor_sea_stacks
from tideharbor_waterfront import build_tideharbor_waterfront
from tidewatch_walk import (BEACON_OPENING as TIDEWATCH_BEACON_OPENING,
                            CINDER_OPENING as TIDEWATCH_CINDER_OPENING,
                            KEEPER as TIDEWATCH_KEEPER, build_tidewatch_walk)
from west_valley_backdrop import build_west_valley_backdrop
from wind_court_architecture import build_wind_court_architecture
from wind_court_guardians import build_wind_court_guardians
from wind_court_side_ramp import build_wind_court_ramp
from windrest_creek_gardens import build_windrest_creek_gardens

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUTPUT = HERE / "Beast_Dojo_Grand_Dojo.rbxlx"
STORE_PROPS = json.loads((HERE / "art" / "creator-store-props.json").read_text())
STORE_STANDING_LANTERN = json.loads((HERE / "art" / "creator-store-standing-lantern.json").read_text())
STORE_BLOSSOM_PETAL = 243344623  # Texture from Creator Store model 3671107938.
rng = random.Random(20)
ids = count(1)
root = ET.Element("roblox", version="4")
for external in ("null", "nil"):
    ET.SubElement(root, "External").text = external


def prop(obj, kind, name, value):
    properties = obj.find("Properties")
    node = ET.SubElement(properties, kind, name=name)
    node.text = str(value).lower() if isinstance(value, bool) else str(value)
    return node


def item(parent, class_name, name):
    obj = ET.SubElement(parent, "Item", {"class": class_name, "referent": f"DOJO_{next(ids)}"})
    ET.SubElement(obj, "Properties")
    prop(obj, "string", "Name", name)
    return obj


def vector(obj, kind, name, fields, values):
    node = ET.SubElement(obj.find("Properties"), kind, name=name)
    for field, value in zip(fields, values):
        ET.SubElement(node, field).text = f"{value:.7g}"


def frame(obj, name, xyz, yaw=0, pitch=0, roll=0):
    y, p, r = map(radians, (yaw, pitch, roll))
    cy, sy, cp, sp, cr, sr = cos(y), sin(y), cos(p), sin(p), cos(r), sin(r)
    matrix = (cy*cr+sy*sp*sr, -cy*sr+sy*sp*cr, sy*cp,
              cp*sr, cp*cr, -sp,
              -sy*cr+cy*sp*sr, sy*sr+cy*sp*cr, cy*cp)
    vector(obj, "CoordinateFrame", name,
           ("X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22"),
           (*xyz, *matrix))


def rgb(value):
    return tuple(int(value[i:i+2], 16) for i in (0, 2, 4))


def color(obj, name, value):
    vector(obj, "Color3", name, ("R", "G", "B"), [v / 255 for v in rgb(value)])


def asset(obj, name, uri):
    content=ET.SubElement(obj.find("Properties"),"Content",name=name)
    # SoundId uses the legacy ContentId XML tag, unlike modern mesh content fields.
    ET.SubElement(content,"url" if name=="SoundId" else "uri").text=uri


def raise_geometry(parent,height):
    for transform in parent.iter("CoordinateFrame"):
        translation=transform.find("Y")
        translation.text=f"{float(translation.text)+height:.7g}"


INK, ROOF, EDGE = "182B35", "303C69", "465686"
RED, DARK, WOOD = "963C29", "532A2B", "855030"
GOLD, AMBER, CREAM = "F4BD4F", "FFAB4B", "FFF2C9"
JADE, GRASS, STONE = "357456", "728857", "88777A"
TILE = ("B4A19D", "AC9290", "A38A90", "B6A39B", "A2969A")
SMOOTH, WOOD_PLANK, NEON, SLATE, GRASS_MAT, LIMESTONE, SANDSTONE, FABRIC, GLASS = 272, 528, 288, 800, 1280, 820, 912, 1312, 1568
BRICK, ROCK, METAL = 848, 896, 1088
CLAY_ROOF = 2307
PROMENADE_STONE = "Honed promenade limestone"
PROMENADE_MORTAR = "Weathered promenade joints"
SUNSET_FLAGSTONE = "Rose sandstone flagstone"
FESTIVAL_FLAGSTONE = "Weathered festival sandstone"
ORNAMENT_BRASS = "Warm landmark brass"
CANOPY_FOLIAGE = "Garden leaf and blossom grain"
VALLEY_ROCK = "Valley slope rock"
BANK_STONE = "Canal and garden stone"
CINDER_STONE = "Cinder sandstone strata"
CINDER_BRICK = "Cinder fired brick"
INDIGO_TILE = "Glazed indigo clay tile"
ARENA_WEAVE = "Fighting Ring canvas weave"
ARENA_CEDAR = "Fighting Ring cedar grain"
LANDMARK_CEDAR = "Lacquered landmark cedar"
LEAFY_GRASS, SNOW = 1284, 1328
# Studio serializes the public BasePart.MaterialVariant string under this XML field.
MATERIAL_VARIANT_FIELD = "MaterialVariantSerialized"


def material_variant(service,name,base,studs,pattern,**maps):
    variant=item(service,"MaterialVariant",name)
    prop(variant,"token","BaseMaterial",base)
    prop(variant,"float","StudsPerTile",studs)
    prop(variant,"token","MaterialPattern",pattern)
    for channel,identifier in maps.items():
        asset(variant,f"{channel}MapContent",f"rbxassetid://{identifier}")


def part(parent, name, xyz, size, tint, *, yaw=0, pitch=0, roll=0,
         shape=1, material=SMOOTH, collide=True, transparency=0, class_name="Part", anchored=True):
    obj = item(parent, class_name, name)
    frame(obj, "CFrame", xyz, yaw, pitch, roll)
    vector(obj, "Vector3", "size", ("X", "Y", "Z"), size)
    prop(obj, "Color3uint8", "Color3uint8", 0xFF000000 + int(tint, 16))
    prop(obj, "token", "Material", material)
    if class_name == "Part":
        prop(obj, "token", "shape", shape)
    prop(obj, "bool", "Anchored", anchored)
    prop(obj, "bool", "CanCollide", collide)
    prop(obj, "bool", "CanTouch", False)
    prop(obj, "bool", "CanQuery", collide)
    prop(obj, "float", "Transparency", transparency)
    prop(obj, "token", "TopSurface", 0)
    prop(obj, "token", "BottomSurface", 0)
    return obj


def beam(parent, name, a, b, width, tint, *, collide=False):
    dx, dy, dz = (b[i] - a[i] for i in range(3))
    midpoint = tuple((a[i] + b[i]) / 2 for i in range(3))
    return part(parent, name, midpoint, (width, width, hypot(dx, dy, dz)), tint,
                yaw=degrees(atan2(dx, dz)), pitch=degrees(atan2(-dy, hypot(dx, dz))),
                collide=collide)


def air_effect(parent, name, position, volume, texture_id, *, tint, rate, lifetime,
               speed, size, opacity, drift, down=False, glow=0, orientation=0):
    source = part(parent, name, position, volume, tint, collide=False, transparency=1)
    prop(source, "bool", "CastShadow", False)
    emitter = item(source, "ParticleEmitter", "Ambient city particles")
    asset(emitter, "TextureContent", f"rbxassetid://{texture_id}")
    pigment = " ".join(f"{channel / 255:.7g}" for channel in rgb(tint))
    prop(emitter, "ColorSequence", "Color", f"0 {pigment} 0 1 {pigment} 0 ")
    prop(emitter, "bool", "Enabled", False)
    prop(emitter, "token", "EmissionDirection", 4 if down else 1)
    prop(emitter, "token", "Orientation", orientation)
    prop(emitter, "float", "Rate", rate)
    prop(emitter, "float", "LightEmission", glow)
    prop(emitter, "float", "LightInfluence", .25)
    prop(emitter, "float", "Drag", .35)
    for label, bounds in (("Lifetime", lifetime), ("Speed", speed), ("Rotation", (-45, 45)), ("RotSpeed", (-22, 22))):
        prop(emitter, "NumberRange", label, f"{bounds[0]} {bounds[1]} ")
    prop(emitter, "NumberSequence", "Size", f"0 {size[0]} 0 1 {size[1]} 0 ")
    prop(emitter, "NumberSequence", "Transparency", f"0 1 0 .22 {1-opacity} 0 .65 {1-opacity} 0 1 1 0 ")
    vector(emitter, "Vector3", "Acceleration", ("X", "Y", "Z"), drift)
    vector(emitter, "Vector2", "SpreadAngle", ("X", "Y"), (28, 28))


def horizontal_water_beam(parent,name,start,end,widths,color_sequence,transparency,texture_length,
                          *,light_influence=.33,light_emission=.19):
    anchors=[]
    for suffix,position in (("origin",start),("lip",end)):
        label=f"{name} {suffix}"
        marker=part(parent,label,position,(.2,.2,.2),CREAM,roll=90,transparency=1,collide=False)
        anchors.append(item(marker,"Attachment",label))
    ribbon=item(parent,"Beam",name)
    for index,attachment in enumerate(anchors):
        prop(ribbon,"Ref",f"Attachment{index}",attachment.get("referent"))
    asset(ribbon,"TextureContent","rbxassetid://4787437624")
    prop(ribbon,"ColorSequence","Color",color_sequence)
    prop(ribbon,"NumberSequence","Transparency",transparency)
    prop(ribbon,"bool","FaceCamera",False)
    prop(ribbon,"int","Segments",6)
    prop(ribbon,"token","TextureMode",1)
    for label,value in (("LightInfluence",light_influence),("LightEmission",light_emission),("TextureSpeed",0),
                        ("TextureLength",texture_length),("Width0",widths[0]),("Width1",widths[1])):
        prop(ribbon,"float",label,value)


def garden_prop(parent, key, position, scale, yaw, tint=None):
    source = STORE_PROPS[key]
    size = tuple(value*scale for value in source["size"])
    x, floor, z = position
    is_bank_rock = key == "bankRock"
    pigment = "".join(f"{round(value*255):02x}" for value in source["color"])
    if is_bank_rock:
        pigment = tint or "94848F"
    mesh = part(parent, source["name"], (x, floor+size[1]/2, z), size, pigment,
                yaw=yaw, material=ROCK if is_bank_rock else source["material"],
                collide=False, class_name="MeshPart")
    vector(mesh,"Vector3","InitialSize",("X","Y","Z"),source["size"])
    prop(mesh,"bool","CastShadow",is_bank_rock)
    prop(mesh,"bool","DoubleSided",source["doubleSided"] or key=="grassBlade")
    prop(mesh,"token","RenderFidelity",0)
    asset(mesh,"MeshContent",source["mesh"])
    if is_bank_rock:
        # The pack's opaque albedo carries a bright painted patch. Use the pack's
        # rock silhouette with our tinted matte finish; nearby planting carries the moss.
        prop(mesh,"string",MATERIAL_VARIANT_FIELD,BANK_STONE)
        return
    if source["texture"]:
        asset(mesh,"TextureContent",source["texture"])
    appearance = item(mesh,"SurfaceAppearance","Authored foliage material")
    prop(appearance,"token","AlphaMode",source["surface"]["alpha"])
    if tint:
        color(appearance,"Color",tint)
    else:
        vector(appearance,"Color3","Color",("R","G","B"),source["surface"]["color"])
    for name, channel in (("ColorMapContent","albedo"),("RoughnessMapContent","roughness"),
                          ("NormalMapContent","normal"),("MetalnessMapContent","metalness")):
        if source["surface"][channel]:
            asset(appearance,name,source["surface"][channel])


def triangle(parent, a, b, c, tint, *, name="Mountain facet", thickness=.17, material=SMOOTH,
             shadow=True, collide=False, transparency=0):
    """Build a triangular face from two right wedges along its longest edge."""
    sides=[(a,b,c),(b,c,a),(c,a,b)]
    a,b,c=max(sides,key=lambda pair:dist(pair[1],pair[2]))
    ab=tuple(end-start for start,end in zip(a,b))
    ac=tuple(end-start for start,end in zip(a,c))
    bc=tuple(end-start for start,end in zip(b,c))

    def normalize(point):
        length=hypot(*point)
        return tuple(v/length for v in point)

    def cross(u,v):
        return (u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0])

    back=normalize(bc)
    right=normalize(cross(ac,ab))
    up=cross(back,right)
    height=abs(sum(v*w for v,w in zip(ab,up)))
    for end,edge,sign in ((b,ab,1),(c,ac,-1)):
        depth=abs(sum(v*w for v,w in zip(edge,back)))
        if min(height,depth)<.06:
            continue
        center=tuple((u+v)/2 for u,v in zip(a,end))
        axes=(tuple(sign*v for v in right),up,tuple(sign*v for v in back))
        piece=part(parent,name,center,(thickness,height,depth),tint,
                   material=material,collide=collide,transparency=transparency,class_name="WedgePart")
        if not shadow:
            prop(piece,"bool","CastShadow",False)
        saved=piece.find("Properties/CoordinateFrame")
        for row in range(3):
            for column in range(3):
                saved.find(f"R{row}{column}").text=f"{axes[column][row]:.7g}"


def build_promenade(parent):
    for left,right,north,south in promenade_sections():
        mortar=part(parent,"Promenade mortar bed",((left+right)/2,PROMENADE_GRADE-.2,(north+south)/2),
                    (right-left,.40,south-north),"89727A",material=SLATE)
        prop(mortar,"string",MATERIAL_VARIANT_FIELD,PROMENADE_MORTAR)
    for pigment,shoulder,face in flagstones():
        stone=item(parent,"Model","Hewn promenade flagstone")
        prop(stone,"token","ModelStreamingMode",1)
        for a,b in zip(face[1:-1],face[2:]):
            center=tuple((face[0][i]+a[i]+b[i])/3 for i in (0,2))
            damp=promenade_dampness(center)
            triangle_tint=stone_pigment(pigment,center)
            first=len(stone)
            triangle(stone,face[0],a,b,triangle_tint,name="Sandstone cut",
                     thickness=.021,material=LIMESTONE,shadow=False)
            for facet in stone[first:]:
                prop(facet,"string",MATERIAL_VARIANT_FIELD,FESTIVAL_FLAGSTONE)
                if damp>.16:
                    prop(facet,"float","Reflectance",round(damp*.15,3))
        for i,(outer,inner) in enumerate(zip(shoulder,face)):
            next_inner=face[(i+1)%len(face)]
            dx,dz=next_inner[0]-inner[0],next_inner[2]-inner[2]
            length=hypot(dx,dz)
            if length<.08:
                continue
            nx,nz=-dz/length,dx/length
            depth=(inner[0]-outer[0])*nx+(inner[2]-outer[2])*nz
            center=((inner[0]+next_inner[0]-nx*depth)/2,(outer[1]+inner[1])/2,
                    (inner[2]+next_inner[2]-nz*depth)/2)
            edge_color=stone_pigment(pigment,(center[0],center[2]))
            # The face normal points out from the slab into the joint.
            sunward = max(0, -.34*nx + .94*nz)
            edge_tint = tint_stone(edge_color, (-21+24*sunward, -18+23*sunward, -18+18*sunward))
            rim=part(stone,"Beveled sandstone rim",center,(length,inner[1]-outer[1],depth),edge_tint,
                     yaw=degrees(atan2(-dz,dx)),material=LIMESTONE,collide=False,class_name="WedgePart")
            prop(rim,"bool","CastShadow",False)
            prop(rim,"string",MATERIAL_VARIANT_FIELD,FESTIVAL_FLAGSTONE)


def coastal_ridge(parent,x,z,width,depth,profile,front,planting,*,cliff_gardens=False):
    """Model the harbor hills with a short rock face and wider back slopes."""
    source=random.Random(int(x-z))
    spacing=width/(len(profile)-1)
    crest=[
        (x-width/2+i*spacing+source.uniform(-.09,.09)*spacing,y,
         z+source.uniform(-.055,.055)*depth)
        for i,y in enumerate(profile)
    ]
    ribs=[(source.uniform(-.30,.30)*spacing,source.uniform(-.07,.08),
           source.uniform(-.085,.085)) for _ in crest]
    bands=((0,1),(.20,.84),(.40,.62),(.55,.54),(.78,.24),(1,0))
    rock=(("7A7882","8A8587","969187"),("7C7D83","8C8784","9A9588"),
          ("85877B","949382","9E9C8A"),("777D70","808775","91937E"),
          ("6F7D63","798568","87906F"))
    for side in (-1,1):
        reach=depth*(.68 if side==front else 1)
        contours=[]
        faces=[]
        for travel,height in bands:
            swell=sin(travel*tau/2)
            contours.append([
                (px+sx*travel+spacing*.17*sin(index*.67+travel*4.2)*swell,
                 (py+py*fold*swell)*height-4.35*travel,
                 pz+side*reach*(travel+channel*swell))
                for index,((px,py,pz),(sx,fold,channel)) in enumerate(zip(crest,ribs))
            ])
        for index,(above,below) in enumerate(zip(contours,contours[1:])):
            for i,(a,b,c,d) in enumerate(zip(above,above[1:],below,below[1:])):
                tone=SALTWIND_SLATE[index] if cliff_gardens and side==front else rock[index]
                ridge_tint=tone[(i+index*2+(side==front))%len(tone)]
                seam_tint=tone[(i+index*2+1)%len(tone)]
                triangle(parent,a,c,b,ridge_tint,name="Coastal slate face",material=ROCK,shadow=False)
                triangle(parent,c,d,b,seam_tint,name="Coastal slate face",material=ROCK,shadow=False)
                faces.extend(((a,c,b),(c,d,b)))
        if side==front:
            for index in planting:
                px,py,pz=contours[3][index]
                bed_z=pz+side*.52
                toe_x,toe_y,toe_z=contours[4][index]
                lip=[(px+offset*spacing,py-.36+lift,bed_z+side*overhang)
                     for offset,lift,overhang in ((-.61,-.24,.31),(-.26,.06,1.23),
                                                  (.24,.0,1.17),(.62,-.21,.37))]
                toe=(.7*px+.3*toe_x, max(toe_y+.35,py-3.4), .53*toe_z+.47*pz-side*.75)
                for i,(a,b) in enumerate(zip(lip,lip[1:])):
                    triangle(parent,a,b,toe,("858284","928882","807C7D")[i],
                             name="Coastal slate face",material=ROCK,shadow=False)
                garden_shelf(parent,px,py+.055,bed_z,spacing*1.38,2.99,.65,"8F8985",
                             SLATE,collide=False)
                garden_shelf(parent,px,py+.16,bed_z+.09*side,spacing*1.21,2.56,.21,"7F8D59",
                             GRASS_MAT,collide=False)
                garden_prop(parent,"bankRock",(px-.47,py+.10,bed_z-.38*side),.18,29*index,"938990")
                garden_prop(parent,"mossFlowers",(px+.60,py+.13,bed_z+.22*side),.129,43*index,"E0ACB4")
                garden_prop(parent,"meadowCover",(px+.49,py+.123,bed_z-.19*side),.127,21*index,"ACC079")
                garden_prop(parent,"meadowGrass",(px-.75,py+.14,bed_z+.35*side),.115,53*index,"9FAE67")
            if cliff_gardens:
                build_saltwind_bluff_art(parent,faces,item=item,prop=prop,part=part,triangle=triangle,
                                         garden_prop=garden_prop,slate=SLATE,grass=GRASS_MAT,
                                         cedar=WOOD_PLANK,slate_variant=PROMENADE_MORTAR,
                                         variant_field=MATERIAL_VARIANT_FIELD)
    for wedge in parent.findall("Item[@class='WedgePart']"):
        if wedge.findtext("Properties/string[@name='Name']")=="Coastal slate face":
            prop(wedge,"string",MATERIAL_VARIANT_FIELD,VALLEY_ROCK)


def lantern_light(body, scale, *, warm_pool=False, light_profile=None):
    emitter = item(body, "PointLight", "Amber lantern light")
    brightness, reach = light_profile or (1.56 if warm_pool else 1.08, 15*scale)
    color(emitter, "Color", "FFB568" if warm_pool else "FFCA7C")
    prop(emitter, "float", "Brightness", brightness)
    prop(emitter, "float", "Range", reach)
    prop(emitter, "bool", "Enabled", False)
    prop(emitter, "bool", "Shadows", False)


def threshold_light(parent, x, y, z, *, reach, spread, brightness, tint="FFD195", yaw=0, pitch=0):
    fixture=part(parent,"Concealed lantern mount",(x,y,z),(.22,.18,.22),CREAM,
                 yaw=yaw,pitch=pitch,transparency=1,collide=False)
    prop(fixture,"bool","CastShadow",False)
    emitter=item(fixture,"SpotLight","Amber threshold light")
    color(emitter,"Color",tint)
    prop(emitter,"token","Face",4)
    prop(emitter,"float","Range",reach)
    prop(emitter,"float","Angle",spread)
    prop(emitter,"float","Brightness",brightness)
    prop(emitter,"bool","Shadows",False)
    prop(emitter,"bool","Enabled",False)


def lamp(parent, x, y, z, *, scale=1, light=False, warm_pool=False, light_profile=None):
    body = part(parent, "Golden paper lantern", (x, y, z), (1.27*scale, 1.65*scale, 1.27*scale),
                "FFD399" if warm_pool else "FFE0AC",
                material=NEON, collide=False)
    prop(body, "bool", "CastShadow", False)
    for dx in (-.65, .65):
        for dz in (-.65, .65):
            part(parent, "Lantern frame", (x+dx*scale, y, z+dz*scale),
                 (.105*scale, 1.72*scale, .105*scale), DARK, collide=False)
    for offset in (-.51, -.17, .17, .51):
        seam = part(parent, "Paper seam", (x, y+offset*scale, z),
                    (1.30*scale, .024*scale, 1.30*scale), "D3A16D", collide=False)
        prop(seam, "bool", "CastShadow", False)
    for offset in (-.86, .86):
        part(parent, "Lantern cap", (x, y+offset*scale, z),
             (1.53*scale, .22*scale, 1.53*scale), DARK, collide=False)
    part(parent, "Lantern tassel", (x, y-1.13*scale, z), (.15*scale, .36*scale, .15*scale), RED, collide=False)
    if light:
        lantern_light(body,scale,warm_pool=warm_pool,light_profile=light_profile)


def store_standing_lantern(parent, position, scale, *, light=True, warm_pool=False, paper_tint=None):
    model = item(parent, "Model", "Creator Store standing lantern")
    prop(model, "token", "ModelStreamingMode", 1)
    for member in STORE_STANDING_LANTERN["parts"]:
        xyz = tuple(base + offset * scale for base, offset in zip(position, member["position"]))
        size = tuple(length * scale for length in member["size"])
        lit = member["material"] == NEON
        tint = member["color"]
        if lit:
            tint = paper_tint or ("FFC138" if warm_pool else tint)
        detail = part(model, "Lantern paper core" if lit else "Lantern detail", xyz, size, tint,
                      shape=member.get("shape", 1), material=member["material"], collide=False,
                      transparency=member["transparency"], class_name=member["kind"])
        orient = detail.find("Properties/CoordinateFrame[@name='CFrame']")
        for axis, value in zip(list(orient)[3:], member["rotation"]):
            axis.text = f"{value:.7g}"
        prop(detail, "bool", "CastShadow", False)
        if lit and light:
            lantern_light(detail, .75, warm_pool=warm_pool)


def festival_lantern(parent,x,y,z,scale,*,light=True,tint=None,warm_pool=False,light_profile=None,
                     entrance_paper=False):
    width=1.38 if entrance_paper else 1.56
    height=1.12 if entrance_paper else 1
    default_paper="C48F60" if entrance_paper else ("FFD497" if warm_pool else "FFDEA5")
    body=part(parent,"Round amber paper lantern",(x,y,z),(width*scale,1.98*scale*height,width*scale),
              tint or default_paper,material=NEON,shape=0,collide=False)
    prop(body,"bool","CastShadow",False)
    for offset in (-.68,-.45,-.22,0,.22,.45,.68):
        diameter=(width*(1-(offset/.99)**2)**.5+.014)*scale
        rib=part(parent,"Rounded paper rib",(x,y+offset*scale*height,z),(.023*scale,diameter,diameter),
                 "B28155" if entrance_paper else "DDB17A",roll=90,shape=2,collide=False)
        prop(rib,"bool","CastShadow",False)
    for offset in (-.89,.89):
        part(parent,"Bronze lantern cap",(x,y+offset*scale*height,z),(.19*scale,.91*scale,.91*scale),
             "AF773B",roll=90,shape=2,collide=False)
    part(parent,"Woven lantern tassel",(x,y-1.11*scale*height,z),(.13*scale,.37*scale,.16*scale),
         "B65838",collide=False)
    if light:
        lantern_light(body,scale,warm_pool=warm_pool,light_profile=light_profile)


ARRIVAL_LANTERN_STYLE = dict(item=item, prop=prop, part=part, neon=NEON, wood=WOOD_PLANK, metal=METAL,
                             variant_field=MATERIAL_VARIANT_FIELD, cedar_variant=LANDMARK_CEDAR,
                             brass_variant=ORNAMENT_BRASS)


def arrival_hanging_lantern(parent, x, y, z, scale, *, light=True, entrance_paper=False, tint=None,
                            light_profile=None):
    body = craft_hanging_lantern(parent, x, y, z, scale, **ARRIVAL_LANTERN_STYLE,
                                 entrance_paper=entrance_paper, tint=tint)
    if light:
        lantern_light(body, scale, warm_pool=True, light_profile=light_profile)


def sign(parent, label, x, y, z, width, height, yaw=0, tint=DARK, *, roll=0, face_only=False,
         finished_back=False, reverse_label=None, single_line=False):
    def letters(board, message, face, canvas_size):
        surface=item(board,"SurfaceGui",message)
        prop(surface,"token","Face",face)
        prop(surface,"token","SizingMode",0)
        vector(surface,"Vector2","CanvasSize",("X","Y"),canvas_size)
        prop(surface,"float","LightInfluence",.16)
        lettering=item(surface,"TextLabel","Lettering")
        vector(lettering,"UDim2","Size",("XS","XO","YS","YO"),(1,0,1,0))
        prop(lettering,"float","BackgroundTransparency",1)
        prop(lettering,"string","Text",message)
        color(lettering,"TextColor3",CREAM)
        prop(lettering,"token","Font",4)
        prop(lettering,"bool","TextScaled",not single_line)
        if single_line:
            prop(lettering,"float","TextSize",round(canvas_size[1]*.69))
        prop(lettering,"float","TextStrokeTransparency",.65)

    if width > 5 and not face_only:
        part(parent, label + " gold frame", (x, y, z), (width+.32, height+.29, .42),
             GOLD, yaw=yaw, roll=roll, collide=False)
        if finished_back or reverse_label:
            backing = part(parent, label + " painted cedar back",
                           (x-.214*sin(radians(yaw)), y, z-.214*cos(radians(yaw))),
                           (width+.08, height+.07, .044), tint, yaw=yaw, roll=roll,
                           material=WOOD_PLANK, collide=False)
            prop(backing,"bool","CastShadow",False)
            if reverse_label:
                letters(backing,reverse_label,5,(800,190))
        setback=.18
        x+=sin(radians(yaw))*setback
        z+=cos(radians(yaw))*setback
    plaque = part(parent, label + " sign", (x, y, z), (width, height, .5), tint,
                  yaw=yaw, roll=roll, transparency=int(face_only), collide=False)
    canvas_size = (round(width*80), round(height*80)) if single_line else (
        (round(width*50), round(height*50)) if face_only else (800,190))
    letters(plaque,label,2,canvas_size)
    return plaque


MAP_WIDTH, MAP_HEIGHT = 580, 420


def map_box(parent,kind,name,bounds):
    x,y,width,height=bounds
    box=item(parent,kind,name)
    vector(box,"UDim2","Position",("XS","XO","YS","YO"),(x/MAP_WIDTH,0,y/MAP_HEIGHT,0))
    vector(box,"UDim2","Size",("XS","XO","YS","YO"),(width/MAP_WIDTH,0,height/MAP_HEIGHT,0))
    prop(box,"int","BorderSizePixel",0)
    return box


def map_text(parent,message,bounds,tint):
    box=map_box(parent,"TextLabel",message,bounds)
    prop(box,"string","Text",message)
    prop(box,"float","BackgroundTransparency",1)
    prop(box,"token","Font",4)
    prop(box,"bool","TextScaled",True)
    color(box,"TextColor3",tint)


def map_canvas(parent,districts,paths):
    canvas=map_box(parent,"Frame","CityMapCanvas",(0,0,MAP_WIDTH,MAP_HEIGHT))
    color(canvas,"BackgroundColor3","263B3D")
    for x in range(40,MAP_WIDTH,50):
        grid=map_box(canvas,"Frame","East-west grid",(x,20,1,354))
        color(grid,"BackgroundColor3","31484A")
    for y in range(24,375,48):
        grid=map_box(canvas,"Frame","North-south grid",(20,y,540,1))
        color(grid,"BackgroundColor3","31484A")

    def project(point):
        return point[0]+290,point[2]+326

    for title,points,shortcut in paths:
        for a,b in zip(points,points[1:]):
            x,y=project(a)
            tx,ty=project(b)
            segment=map_box(canvas,"Frame",title,((x+tx)/2,(y+ty)/2,hypot(tx-x,ty-y)+1.6,4.8))
            vector(segment,"Vector2","AnchorPoint",("X","Y"),(.5,.5))
            prop(segment,"float","Rotation",degrees(atan2(ty-y,tx-x)))
            color(segment,"BackgroundColor3","91CCB5" if shortcut else "E2AE6E")

    for name,point in districts.items():
        x,y=project(point)
        node=map_box(canvas,"Frame",name,(x-5.5,y-5.5,11,11))
        color(node,"BackgroundColor3","F9DE9A" if name=="Grand Dojo City" else "F5E5BF")
        prop(node,"float","Rotation",45)
        height="" if point[1]==0 else f" +{point[1]:g}"
        map_text(canvas,name+height,(max(8,min(MAP_WIDTH-162,x-77)),y+10,154,20),"FFEDC8")
    map_text(canvas,"N",(25,20,24,22),"D8C99F")
    for x,tint,caption,width in ((78,"E2AE6E","Dojo road",104),(219,"91CCB5","Town link",114)):
        sample=map_box(canvas,"Frame",caption,(x,31,23,4.4))
        color(sample,"BackgroundColor3",tint)
        map_text(canvas,caption,(x+24,24,width,18),"E3D6AE")
    map_text(canvas,"Height above plaza (studs)",(363,24,199,18),"E3D6AE")
    return canvas


def city_map_board(parent,districts,paths):
    board=item(parent,"Model","Plaza city map board")
    prop(board,"token","ModelStreamingMode",1)
    x,z,yaw=28.05,55.55,-48
    scale=.89
    c,s=cos(radians(yaw)),sin(radians(yaw))
    tilt=-27
    ct,st=cos(radians(tilt)),sin(radians(tilt))

    def point(dx,y,dz):
        return x+scale*(dx*c+dz*s),.15+scale*(y-.15),z+scale*(-dx*s+dz*c)

    def lectern(dx,dy,dz):
        return point(dx,2.20+ct*dy-st*dz,st*dy+ct*dz)

    def map_piece(name, location, size, tint, **options):
        return part(board,name,location,tuple(extent*scale for extent in size),tint,
                    yaw=yaw,collide=False,**options)

    for side in (-1,1):
        dx=side*1.98
        map_piece("Map slate pedestal",point(dx,.37,-.13),
                  (1.16,.43,1.69),"8A7880",material=SLATE)
        map_piece("Map cedar trestle",point(dx,1.41,-.23),(.49,1.76,.62),
                  "895640",pitch=11,material=WOOD_PLANK)
        map_piece("Map joinery cap",point(dx,2.14,-.30),(.66,.24,1.13),"9E674C",material=WOOD_PLANK)
    map_piece("Map trestle crossbar",point(0,.87,-.23),(4.14,.37,.34),"774938",material=WOOD_PLANK)
    map_piece("Map lacquer frame",lectern(0,0,0),(4.67,3.63,.34),"98563A",pitch=tilt,material=WOOD_PLANK)
    brass=map_piece("Map chart brass bezel",lectern(0,-.18,.19),(4.26,3.10,.10),
                    "C69355",pitch=tilt,material=METAL)
    prop(brass,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
    chart_height=2.90
    plate=map_piece("Etched city chart",lectern(0,-.18,.247),(chart_height*MAP_WIDTH/MAP_HEIGHT,chart_height,.08),
                    "263B3D",pitch=tilt)
    surface=item(plate,"SurfaceGui","Valley chart")
    prop(surface,"token","Face",2)
    prop(surface,"token","SizingMode",0)
    prop(surface,"float","LightInfluence",.12)
    prop(surface,"float","MaxDistance",57)
    vector(surface,"Vector2","CanvasSize",("X","Y"),(MAP_WIDTH,MAP_HEIGHT))
    map_canvas(surface,districts,paths)
    sign(board,"CITY MAP",*lectern(0,1.62,.10),3.65*scale,.53*scale,yaw,"683830")
    fascia=map_piece("Cedar garden direction fascia",point(0,.42,1.10),
                     (3.76,.52,.13),"526651",material=WOOD_PLANK)
    prop(fascia,"bool","CastShadow",False)
    direction=sign(board,"← PROMENADE GARDEN",*point(0,.42,1.169),
                   3.56*scale,.39*scale,yaw,"526651",face_only=True)
    prop(direction,"bool","CastShadow",False)
    # The nearby lantern lights the main promenade at the bend.
    lamp(board,10.97339,.91,63.05417,scale=.68,light=True)
    prompt=item(plate,"ProximityPrompt","CityMapPrompt")
    prop(prompt,"string","ActionText","Open city map")
    prop(prompt,"string","ObjectText","Grand Dojo City")
    prop(prompt,"float","MaxActivationDistance",12)
    prop(prompt,"bool","RequiresLineOfSight",False)


def district_map_post(parent,district,x,y,z,yaw):
    board=item(parent,"Model","District map post")
    prop(board,"token","ModelStreamingMode",1)
    part(board,"Map post stone base",(x,y+.25,z),(1.17,.50,1.0),"8D7B87",material=SLATE,
         yaw=yaw,collide=False)
    part(board,"Map post cedar upright",(x,y+1.48,z),(.42,2.90,.41),"785143",material=WOOD_PLANK,
         yaw=yaw,collide=False)
    plaque=sign(board,"CITY MAP",x,y+2.90,z,4.05,1.14,yaw,"6D3C32")
    prompt=item(plaque,"ProximityPrompt","CityMapPrompt")
    prop(prompt,"string","ActionText","Open city map")
    prop(prompt,"string","ObjectText",district)
    prop(prompt,"float","MaxActivationDistance",10)
    prop(prompt,"bool","RequiresLineOfSight",False)


def city_route_data(parent,districts,paths):
    module=item(parent,"ModuleScript","CityRoutes")
    destination_by_point={point:name for name,point in districts.items()}
    routes=[]
    for title,points,_ in paths:
        origin=json.dumps(destination_by_point[points[0]])
        destination=json.dumps(destination_by_point[points[-1]])
        length=sum(dist(a,b) for a,b in zip(points,points[1:]))
        routes.append(f"    {{name = {json.dumps(title)}, origin = {origin}, destination = {destination}, length = {length:.5f}}},")
    prop(module,"ProtectedString","Source","return {\n"+"\n".join(routes)+"\n}\n")


def curved_plaque(parent,x,z,profile,height,face,edge,*,rim_height=.17,rim_depth=.27):
    for name,depth,half_height,thickness,tint in (
        ("Marquee brass casting",z,height/2,.50,edge),
        ("Inlaid lacquer face",z+.29,height/2-.31,.21,face),
    ):
        for (left,low),(right,high) in zip(profile,profile[1:]):
            a,b=(x+left,low-half_height,depth),(x+right,high-half_height,depth)
            c,d=(x+right,high+half_height,depth),(x+left,low+half_height,depth)
            triangle(parent,a,b,c,tint,name=name,thickness=thickness)
            triangle(parent,a,c,d,tint,name=name,thickness=thickness)
    for (left,low),(right,high) in zip(profile,profile[1:]):
        width=hypot(right-left,high-low)+.03
        roll=degrees(atan2(high-low,right-left))
        for side,tint in ((1,"FFD177"),(-1,"BF682F")):
            y=(low+high)/2 + side*(height/2-.14)
            trim=part(parent,"Marquee brass bevel",(x+(left+right)/2,y,z+rim_depth),
                      (width,rim_height,.18),tint,roll=roll,collide=False,material=METAL)
            prop(trim,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
            prop(trim,"bool","CastShadow",False)


# Fredoka One advances in em units, measured from the original font.
MARQUEE_ADVANCES={" ":.253,"A":.765,"B":.657,"C":.681,"D":.718,"E":.638,"F":.637,
                  "G":.714,"H":.699,"J":.549,
                  "I":.257,"K":.639,"L":.587,"N":.720,"O":.775,"P":.632,"R":.631,
                  "S":.645,"T":.731,"U":.714,"W":.999,"Y":.686}


def marquee_title(parent,title,x,z,profile,em):
    """Paint one embossed, curved title onto a depth-tested world surface."""
    height_center=(max(y for _,y in profile)+min(y for _,y in profile))/2
    width=profile[-1][0]-profile[0][0]
    height=max(y for _,y in profile)-min(y for _,y in profile)+em*1.55
    carrier=part(parent,"Marquee lettering surface",(x,height_center,z+.50),(width,height,.08),
                 CREAM,collide=False,transparency=1)
    prop(carrier,"bool","CastShadow",False)
    surface=item(carrier,"SurfaceGui",title)
    prop(surface,"token","Face",2)
    prop(surface,"token","SizingMode",0)
    pixels=24
    canvas_width,canvas_height=round(width*pixels),round(height*pixels)
    vector(surface,"Vector2","CanvasSize",("X","Y"),(canvas_width,canvas_height))
    prop(surface,"float","LightInfluence",.08)
    prop(surface,"float","MaxDistance",360)

    def height_at(offset):
        for (left,low),(right,high) in zip(profile,profile[1:]):
            if left<=offset<=right:
                return low+(high-low)*(offset-left)/(right-left)
        raise ValueError(f"{title} glyph outside its marquee")

    tracking=em*.008
    advances=[em*MARQUEE_ADVANCES[glyph] for glyph in title]
    edge=-(sum(advances)+(len(title)-1)*tracking)/2
    for index,(glyph,advance) in enumerate(zip(title,advances),1):
        offset=edge+advance/2
        edge+=advance+tracking
        if glyph==" ":
            continue
        roll=degrees(atan2(height_at(offset-.17)-height_at(offset+.17),.34))
        cx=(offset/width+.5)*canvas_width
        cy=(.5-(height_at(offset)-height_center)/height)*canvas_height
        for layer,dx,dy,tint,order in (("Shadow",.045,.105,"562623",1),
                                        ("Letter",0,0,"FFE2A6",2)):
            label=item(surface,"TextLabel",f"{index:02d} {layer} {glyph}")
            # Roblox stores UDim offsets as integers. Scale coordinates retain
            # subpixel fitting across all three differently sized canvases.
            vector(label,"UDim2","Position",("XS","XO","YS","YO"),
                   ((cx+dx*pixels)/canvas_width,0,(cy+dy*pixels)/canvas_height,0))
            vector(label,"UDim2","Size",("XS","XO","YS","YO"),
                   (em*pixels*1.18/canvas_width,0,em*pixels*1.30/canvas_height,0))
            vector(label,"Vector2","AnchorPoint",("X","Y"),(.5,.5))
            prop(label,"float","Rotation",round(roll,3))
            prop(label,"int","ZIndex",order)
            prop(label,"bool","AutoLocalize",False)
            prop(label,"string","Text",glyph)
            prop(label,"float","BackgroundTransparency",1)
            prop(label,"token","Font",26)  # Enum.Font.FredokaOne
            prop(label,"float","TextSize",round(em*pixels))
            color(label,"TextColor3",tint)
            if order==2:
                color(label,"TextStrokeColor3","67352B")
                prop(label,"float","TextStrokeTransparency",.46)


def reed_mark(parent, x, y, z, scale=1, *, yaw=0):
    c,s=cos(radians(yaw)),sin(radians(yaw))

    def point(dx,dy):
        return (x+dx*c*scale,y+dy*scale,z-dx*s*scale)

    origin=point(-.35,-.69)
    for dx, dy in ((.51,1.32),(.96,.84),(.21,.95)):
        tip=point(dx,dy)
        beam(parent, "Gold reed", origin, tip, .083*scale, GOLD)
        for t in (.57,.77):
            stem=tuple(a+(b-a)*t for a,b in zip(origin,tip))
            leaf=(stem[0]-.22*c*scale,stem[1]+.26*scale,stem[2]+.22*s*scale)
            beam(parent, "Reed leaflet", stem, leaf, .065*scale, GOLD)


def banner(parent, x, y, z, scale=1, *, vermilion=False):
    pennant=item(parent,"Model","Reed festival pennant")

    def point(dx, dy, dz=0):
        return x+dx*scale,y+dy*scale,z+dz*scale

    cloth, shade, highlight = ("B83B2F","9D2C27","CC4A36") if vermilion else ("A43D30","8F322A","B74B36")
    part(pennant,"Vermilion pennant cloth",point(0,.15),(2.58*scale,3.44*scale,.13*scale),cloth,
         material=FABRIC,collide=False)
    triangle(pennant,point(-1.29,-1.56),point(1.29,-1.56),point(0,-2.35),cloth,
             name="Pennant pointed hem",material=FABRIC,thickness=.13*scale,shadow=False)
    for dx,width,tint in ((-.83,.56,shade),(.73,.62,highlight)):
        part(pennant,"Pennant dyed fold",point(dx,.16,.071),
             (width*scale,3.40*scale,.023*scale),tint,material=FABRIC,collide=False)
    for side in (-1,1):
        dx=side*1.16
        hem=point(dx,-1.53,.105)
        beam(pennant,"Pennant gold binding",point(dx,1.79,.105),hem,.077*scale,"EDAE58")
        beam(pennant,"Pennant gold binding",hem,point(0,-2.21,.105),.077*scale,"EDAE58")
        part(pennant,"Pennant hanging loop",point(side*.94,1.94,.04),
             (.24*scale,.35*scale,.22*scale),"AA4932",material=FABRIC,collide=False)
        part(pennant,"Pennant rod brass cap",point(side*1.48,2.08),
             (.14*scale,.23*scale,.23*scale),"D1A063",collide=False)
    part(pennant,"Pennant wooden crossbar",point(0,2.08),
         (2.90*scale,.16*scale,.18*scale),"794333",material=WOOD_PLANK,collide=False)
    root=point(-.64,-1.25,.13)
    for bend,tip,tilt in (((-.46,-.28),(-.19,.65),-17),
                           ((-.26,-.19),(.23,1.11),-25),
                           ((-.06,-.45),(.70,.44),-42)):
        elbow=point(*bend,.13)
        ear=point(*tip,.13)
        beam(pennant,"Pennant reed stem",root,elbow,.058*scale,"EBB360")
        beam(pennant,"Pennant reed tip",elbow,ear,.044*scale,"EBB360")
        lean=radians(-tilt)
        for step,(length,width,tint) in enumerate(((.39,.16,"FED790"),(.32,.13,"EDB965"),(.24,.105,"DB9B51"))):
            dx,dy=tip
            center=point(dx-step*.167*sin(lean),dy-step*.167*cos(lean),.145)
            part(pennant,"Pennant reed grain",center,(width*scale,length*scale,.064*scale),
                 tint,shape=0,roll=tilt,collide=False)
    for piece in pennant.findall("Item"):
        if piece.find("Properties/bool[@name='CastShadow']") is None:
            prop(piece,"bool","CastShadow",False)
    return pennant


def parcel_station(parent, name, x, y, z, yaw, title, action, place, accent):
    station=item(parent,"Model",name)
    prop(station,"token","ModelStreamingMode",1)
    c,s=cos(radians(yaw)),sin(radians(yaw))

    def point(dx, dy, dz):
        return x+c*dx+s*dz,y+dy,z-s*dx+c*dz

    for side in (-1,1):
        for depth in (-.67,.67):
            part(station,"Parcel trestle leg",point(side*1.73,.68,depth),(.34,1.36,.38),"88533D",
                 yaw=yaw,material=WOOD_PLANK)
        part(station,"Parcel sign post",point(side*2.19,2.36,-.82),(.24,2.53,.25),"815840",
             yaw=yaw,material=WOOD_PLANK,collide=False)
    part(station,"Parcel desk slate sill",point(0,.13,0),(4.66,.26,2.09),"8A7782",yaw=yaw,material=SLATE)
    part(station,"Parcel desk board",point(0,1.38,0),(4.68,.25,1.93),"AD7958",yaw=yaw,material=WOOD_PLANK)
    part(station,"Painted parcel desk apron",point(0,1.10,.86),(4.16,.35,.23),accent,yaw=yaw,collide=False)
    sign(station,title,*point(0,3.30,-.78),4.60,.78,yaw,accent)
    for dx,height,pigment in ((-.79,.57,"C68957"),(.31,.69,"9B6852")):
        part(station,"Wrapped harbor parcel",point(dx,1.505+height/2,.06),(1.02,height,.90),pigment,
             yaw=yaw,collide=False)
        part(station,"Parcel linen tie",point(dx,1.505+height+.007,.06),(.13,.035,.91),"DFBC86",
             yaw=yaw,collide=False)
        part(station,"Parcel jade tag",point(dx+.24,1.505+height+.026,.07),(.26,.032,.33),"87A68D",
             yaw=yaw+10,collide=False)
    lamp(station,*point(1.70,1.94,-.13),scale=.43,light=False)
    garden_prop(station,"mossFlowers",point(-2.23,.11,-.70),.103,yaw,"E8ABB9")
    garden_prop(station,"meadowFlowers",point(2.18,.105,-.72),.21,yaw+39,"F4C485")
    anchor=part(station,"Interaction",point(0,1.48,1.13),(.2,.2,.2),CREAM,collide=False,transparency=1)
    prompt=item(anchor,"ProximityPrompt","ParcelPrompt")
    prop(prompt,"string","ActionText",action)
    prop(prompt,"string","ObjectText",place)
    prop(prompt,"float","MaxActivationDistance",8)
    prop(prompt,"bool","RequiresLineOfSight",False)


def gate(parent, x, z, yaw=0, *, span=14, label=None, trim=RED, y=0, lanterns=True,
         straight_lintel=True):
    def point(dx, dy, dz):
        c, s = cos(radians(yaw)), sin(radians(yaw))
        return x+dx*c+dz*s, y+dy, z-dx*s+dz*c
    for side in (-1, 1):
        ox = side * span / 2
        part(parent, "Column base", point(ox, .56, 0), (2.35, 1.1, 2.35), STONE, yaw=yaw)
        part(parent, "Vermilion gate column", point(ox, 4.65, 0), (1.3, 8.3, 1.35), trim, yaw=yaw)
        part(parent, "Column cuff", point(ox, 2.2, 0), (1.4, .3, 1.4), GOLD, yaw=yaw, collide=False)
        part(parent, "Gate cap", point(ox, 8.7, 0), (2.5, .72, 2.7), DARK, yaw=yaw, collide=False)
        if lanterns:
            lamp(parent, *point(ox - side*2, 7.55, .2), light=bool(label))
    if straight_lintel:
        for height, width, depth, tint in ((8.5, span+3, 1.55, trim), (9.15, span+4.5, 2.5, ROOF),
                                           (9.55, span+5.4, 2.6, EDGE)):
            part(parent, "Layered gate lintel", point(0, height, 0), (width, .5, depth), tint, yaw=yaw, collide=False)
    if label:
        for side in (-1,1):
            part(parent, "Swept indigo crest", point(side*(span*.29), 9.83, .70),
                 (span*.26,.46,2.3), ROOF, yaw=yaw, roll=side*-9, collide=False)
            part(parent, "Brass crest tip", point(side*span*.56, 9.55, .74),
                 (1.42,.23,.47), GOLD, yaw=yaw, roll=side*24, collide=False)
        sign(parent, label, *point(0, 8.43, 1.18), span-2.6, 2.15, yaw, "7B2827")
        if label in ("DOJO RING","LANTERN RELAY") and not yaw:
            for side in (-1,1):
                banner(parent,*point(side*(span/2+1.47),5.27,1.0),scale=.86)


def stair(parent, x, z, width, steps, height=.42, depth=1.3):
    for step in range(steps):
        top=height*(step+1)
        part(parent, "Stone step", (x, top/2, z-step*depth), (width, top, depth+.06), STONE, material=SLATE)


def roof_panel(parent, name, point, size, tint, *, pitch=0, roll=0):
    panel = part(parent, name, point, size, tint, pitch=pitch, roll=roll,
                 material=CLAY_ROOF, collide=False)
    prop(panel,"string",MATERIAL_VARIANT_FIELD,INDIGO_TILE)


def roof_barrel(parent, name, point, length, diameter, tint, *, pitch=0, ceramic=False):
    # Roblox cylinders run along local X. Turn that axis along the roof slope.
    tile = part(parent,name,point,(length,diameter,diameter),tint,
                yaw=90,roll=pitch,shape=2,material=CLAY_ROOF if ceramic else SMOOTH,collide=False)
    prop(tile,"bool","CastShadow",False)
    if ceramic:
        prop(tile,"string",MATERIAL_VARIANT_FIELD,INDIGO_TILE)


def roof(parent, x, y, z, width, depth):
    sag=[(1,0),(.77,.35),(.52,1.06),(.27,1.96),(.08,2.76)]
    for side in (-1,1):
        for i, ((outer,low),(inner,high)) in enumerate(zip(sag,sag[1:])):
            horizontal=(outer-inner)*depth/2
            pitch=degrees(atan2(high-low,horizontal))*side
            length=hypot(horizontal,high-low)
            middle=(x,y+(low+high)/2,z+side*(outer+inner)*depth/4)
            panel_width=width-i*.28
            roof_panel(parent,"Sloping indigo tile course",middle,
                       (panel_width,.48,length+.21),ROOF if i%2 else EDGE,pitch=pitch)
            if i<3 and width>17:
                for rib in range(1,11):
                    px=x+(rib/12-.5)*panel_width
                    roof_barrel(parent,"Ceramic tile seam",(px,middle[1]+.24,middle[2]),
                                length+.23,.17,"536294",pitch=pitch)
    part(parent, "Roof ridge", (x, y+2.73, z), (width-.7, .52, .9), ROOF, collide=False)
    for side in (-1, 1):
        part(parent, "Raised ridge tip", (x+side*(width/2-.74), y+2.96, z),
             (2.4, .34, .81), GOLD, roll=25*side, collide=False)
        for i in range(11):
            px = x + ((i/10)-.5)*(width-2)
            roof_barrel(parent,"Rounded tile edge",(px,y+.04,z+side*(depth/2-.1)),
                        .75,.38,ROOF)


def swept_roof(parent, x, eave_y, z, width, depth, rise, *, fine_tiles=True, signature=False,
               corner_sweep=1.0, fine_tile_spacing=1.49, ridge_finial_scale=1.0):
    """Tile a peaked roof with shallow eaves and rising corner lines."""
    bands = ((1,0),(.78,.08),(.56,.23),(.34,.45),(.16,.72),(0,1))
    sections = ((-1,.35),(-.87,.17),(-.68,.025),(-.44,0),(0,0),
                (.44,0),(.68,.025),(.87,.17),(1,.35))
    if not fine_tiles:
        sections = ((-1,.35),(-.81,.11),(-.43,0),(.43,0),(.81,.11),(1,.35))
    sections=tuple((offset,lift*corner_sweep) for offset,lift in sections)
    standard_ribs = (.25,.72) if fine_tiles else (.31,.69)
    palettes = (("3B4164","3F466C","434A73","464E77","4A527C"),
                ("363B5E","3A4065","3F446D","414870","464D77")) if signature else (
                ("394778","414D81","48548A","4F5B8F","566299"),
                ("303B65","374471","3B4A7B","435184","4A598D"))
    for side in (-1,1):
        for band,((outer,low),(inner,high)) in enumerate(zip(bands,bands[1:])):
            travel = (outer-inner)*depth/2
            lift = (high-low)*rise
            pitch = side*degrees(atan2(lift,travel))
            for lane,((start,up_start),(end,up_end)) in enumerate(zip(sections,sections[1:])):
                span = (end-start)*width/2
                turn = (up_end-up_start)*rise*outer
                roll = degrees(atan2(turn,span))
                mid_x = x+(start+end)*width/4
                mid_y = eave_y+((low+high)/2+(up_start+up_end)*(outer+inner)/4)*rise
                mid_z = z+side*(outer+inner)*depth/4
                roof_panel(parent,"Swept tile panel",(mid_x,mid_y,mid_z),
                           (hypot(span,turn)+.13,.39,hypot(travel,lift)+.23),
                           palettes[(lane+side)%2][band],pitch=pitch,roll=roll)
                if fine_tiles or band==0:
                    if signature:
                        count=max(1,round(span/(fine_tile_spacing if fine_tiles else 1.30)))
                        rib_positions=tuple((index+.50)/count for index in range(count))
                    else:
                        rib_positions=standard_ribs
                    for index,rib in enumerate(rib_positions):
                        px = x+(start+(end-start)*rib)*width/2
                        py = mid_y+(rib-.5)*turn
                        lift_above_panel,diameter,tint=(.27,.34,("535A82","4A5279","575D85")[(lane+index)%3]) if signature else (
                            .22,.21,"58699C")
                        roof_barrel(parent,"Glazed barrel tile",(px,py+lift_above_panel,mid_z),
                                    hypot(travel,lift)+.30,diameter,tint,pitch=pitch,ceramic=signature)
                        if band==0:
                            lip_y=eave_y+(up_start+(up_end-up_start)*rib)*rise+.08
                            roof_barrel(parent,"Indigo eave tile end",(px,lip_y,z+side*(depth/2+.065)),
                                        .58 if signature else .42,.42 if signature else .28,
                                        "464B72" if signature else "465788",pitch=pitch,ceramic=signature)
                if band==0:
                    a = (x+start*width/2,eave_y+up_start*rise-.13,z+side*depth/2)
                    b = (x+end*width/2,eave_y+up_end*rise-.13,z+side*depth/2)
                    beam(parent,"Eave copper edging",a,b,.29 if signature else .23,
                         "C79250" if signature else "BA8246")
        for corner in (-1,1):
            tip=(x+corner*width*.5,eave_y+rise*.35*corner_sweep,z+side*depth/2)
            end=(tip[0]+corner*.75,tip[1]+.68,tip[2]+side*.15)
            beam(parent,"Upturned bronze finial",tip,end,.37,"E0A755")
            if signature:
                lining = part(parent,"Eave corner bronze shoe",(tip[0]-corner*.27,tip[1]+.13,tip[2]),
                              (.98,.42,1.08),"B78147",roll=corner*21,material=METAL,collide=False)
                prop(lining,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
                prop(lining,"bool","CastShadow",False)
                glint = part(parent,"Raised eave brass cheek",(end[0]-corner*.22,end[1]-.15,end[2]),
                             (.80,.39,.88),"E1AE6C",roll=corner*43,material=METAL,collide=False)
                prop(glint,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
                prop(glint,"bool","CastShadow",False)
    part(parent,"Raised ridge coping",(x,eave_y+rise+.02,z),(width-.24,.59,1.04),ROOF,collide=False)
    if signature:
        for factor in (-.36,-.17,0,.17,.36):
            part(parent,"Brass ridge binding",(x+width*factor,eave_y+rise+.33,z),(.32,.24,1.17),
                 "CA9657",collide=False)
        for side in (-1,1):
            border=x+side*width/2
            crest=eave_y+rise
            sweep=[(border+side*offset,crest+height*ridge_finial_scale,z) for offset,height in (
                (-2.04,.24),(-.77,.38),(.04,.80),(.54,1.42),(.66,1.84))]
            for (a,b),gauge,tint in zip(zip(sweep,sweep[1:]),(.63,.56,.44,.28),
                                        ("A87140","D39A52","EAB76C","F8CF89")):
                beam(parent,"Gilded ridge finial",a,b,gauge,tint)
            part(parent,"Brass ridge shoe",(border-side*1.82,crest+.27,z),
                 (.45,.49,1.22),"BB824B",collide=False)
    else:
        for side in (-1,1):
            beam(parent,"Crowned ridge tip",(x+side*(width/2-1.65),eave_y+rise+.22,z),
                 (x+side*(width/2+.27),eave_y+rise+1.03,z),.49,"E1A54E")


def lantern_window(parent, x, y, z, width, height, *, glow=True, tint=None):
    part(parent,"Dark window frame",(x,y,z),(width+.37,height+.38,.43),"532722",collide=False)
    part(parent,"Amber lattice pane",(x,y,z+.23),(width,height,.17),
         tint or ("FFB56A" if glow else "C68758"),material=NEON if glow else SMOOTH,collide=False)
    for offset in (-.30,0,.30):
        part(parent,"Window mullion",(x+width*offset,y,z+.38),(.103,height,.11),"743E29",collide=False)
    for offset in (-.26,.24):
        part(parent,"Window cross rail",(x,y+height*offset,z+.38),(width,.12,.11),"743E29",collide=False)


def house(parent, x, z, width, depth, height, label=None, walls=True, pedestal=0, with_roof=True):
    flooring = part(parent, "Pavilion foundation", (x, pedestal/2+.21, z), (width, pedestal+.42, depth), STONE)
    top = pedestal+.42
    if walls:
        part(parent, "Rear plaster wall", (x, top+height/2, z-depth/2+.5), (width, height, 1), "E7B97F")
        for side in (-1, 1):
            part(parent, "Side plaster wall", (x+side*(width/2-.5), top+height/2, z),
                 (1, height, depth), "C28F66")
            part(parent, "Warm lattice window", (x+side*width*.34, top+height*.47, z+depth/2-.5),
                 (width*.25, height*.54, 1), "E7B271", material=SMOOTH)
            for n in (-1, 0, 1):
                part(parent, "Window lattice", (x+side*width*.34+n*.95, top+height*.47, z+depth/2+.04),
                     (.14, height*.54, .13), WOOD, collide=False)
            for dy in (-.16,.02,.2):
                part(parent,"Window crossbar",(x+side*width*.34,top+height*(.47+dy),z+depth/2+.06),
                     (width*.25,.15,.15),DARK,collide=False)
    for dx in (-.47, -.17, .17, .47):
        part(parent, "Front cedar post", (x+width*dx, top+height/2, z+depth/2),
             (1.3, height+.9, 1.3), RED)
        part(parent, "Rear cedar post", (x+width*dx, top+height/2, z-depth/2),
             (1.3, height+.9, 1.3), RED)
    for dy in (.22, .93):
        part(parent, "Cedar header", (x, top+height*dy, z-depth/2), (width+1, .55, .8), DARK)
    part(parent, "Cedar fascia", (x, top+height, z+depth/2), (width+1, 1.1, 1.4), RED)
    if with_roof:
        roof(parent, x, top+height+1, z, width+4, depth+4)
    for side in (-1, 1):
        lamp(parent, x+side*width*.39, top+height*.76, z+depth/2+.7, light=True)
    if label:
        sign(parent, label, x, top+height-.55, z+depth/2+.9, width*.72, 2.7, tint=RED)
    return flooring


def showcase_tree(parent,x,z,pink,scale,yaw,elevation,*,height_scale=1,compact=False,
                  relief_crown=False,crown_palette=None,crown_spread=1,hero_crown=False,crown_turn=0):
    model=item(parent,"Model","Spreading blossom tree" if pink else "Spreading garden pine")
    prop(model,"token","ModelStreamingMode",1)
    prop(model,"token","LevelOfDetail",4)
    branches,leaves=garden_tree(pink,arrival=relief_crown)

    def heading(height):
        # Keep the two colliding trunk sections and roots on their original axis.
        return yaw+crown_turn*max(0,min(1,(height-4.13)/2.18))

    def position(point):
        px,py,pz=point[:3]
        spread=1+(crown_spread-1)*max(0,min(1,(py-4.13)/2.55))
        px,py,pz=rotate_garden_point((px*spread,py,pz),heading(py))
        return x+px*scale,elevation+py*scale*height_scale,z+pz*scale

    for index,(a,b,tint) in enumerate(branches):
        if compact and index>=4 and (max(a[1],b[1])<1 or b[3]<.075):
            continue
        start,end=position(a),position(b)
        dx,dy,dz=(high-low for low,high in zip(start,end))
        center=tuple((low+high)/2 for low,high in zip(start,end))
        diameter=(a[3]+b[3])*scale
        bearing=degrees(atan2(dx,dz))-90
        lean=degrees(atan2(dy,hypot(dx,dz)))
        if index<4:
            label="Tapered garden trunk"
        elif max(a[1],b[1])<1:
            label="Exposed garden root"
        else:
            label="Angled garden bough"
        bark=part(model,label,center,(dist(start,end)+.13*scale,diameter,diameter),
                  tint,yaw=bearing,roll=lean,shape=2,collide=index<2 and not compact)
        if label=="Exposed garden root" or compact:
            prop(bark,"bool","CastShadow",False)
    if not compact:
        for point,tint in garden_knuckles(branches):
            diameter=point[3]*scale*2.035
            knot=part(model,"Garden branch joint",position(point),(diameter,diameter,diameter),
                      tint,shape=0,collide=False)
            prop(knot,"bool","CastShadow",False)
    if hero_crown:
        build_arrival_hero_canopy(model,pink,position=position,item=item,prop=prop,part=part,triangle=triangle,
                                  leaf=LEAFY_GRASS,variant_field=MATERIAL_VARIANT_FIELD,variant=CANOPY_FOLIAGE)
        return model
    if relief_crown:
        leaves=arrival_canopy(pink,palette=crown_palette)
    for center,size,angles,tint,detail in leaves:
        if compact and detail and not relief_crown:
            continue
        name="Blossom tuft" if pink else "Pine needle tuft"
        if not detail:
            name="Blossom spray" if pink else "Pine foliage pad"
        bearing,tilt,lean=angles
        foliage=part(model,name,position(center),(size[0]*scale,size[1]*scale*height_scale,size[2]*scale),
                     tint,yaw=heading(center[1])+bearing,pitch=tilt,roll=lean,shape=0,material=LEAFY_GRASS,collide=False)
        prop(foliage,"string",MATERIAL_VARIANT_FIELD,CANOPY_FOLIAGE)
        if detail or compact:
            prop(foliage,"bool","CastShadow",False)
    if relief_crown:
        silhouette=item(model,"Folder","Irregular crown edges")
        for a,b,c,tint in arrival_canopy_faces(pink,palette=crown_palette):
            triangle(silhouette,position(a),position(b),position(c),tint,name="Crown leaf spray",
                     material=LEAFY_GRASS,thickness=.075,shadow=False)
        for face in silhouette.findall("Item"):
            prop(face,"string",MATERIAL_VARIANT_FIELD,CANOPY_FOLIAGE)
    return model


def decorative_garden_shelf(parent,x,top,z,width,depth,height,tint,material):
    """Build a clipped-corner footprint with three blocks and four wedges."""
    label="Garden terrace shelf"
    y=top-height/2
    near,far=-.470,.450
    left,right=-.235,.190

    def panel(x0,x1,z0,z1):
        part(parent,label,(x+(x0+x1)*width/2,y,z+(z0+z1)*depth/2),
             ((x1-x0)*width,height,(z1-z0)*depth),tint,material=material,collide=False)

    panel(left,right,near,far)
    for side,inner,outer,start,end in ((-1,left,-.435,-.313,.298),(1,right,.460,-.337,.180)):
        panel(min(inner,outer),max(inner,outer),start,end)
        for direction,a,b in ((-1,near,start),(1,end,far)):
            # The wedge's right angle is on its negative Y, positive Z edge.
            part(parent,label,(x+(inner+outer)*width/2,y,z+(a+b)*depth/2),
                 (height,abs(outer-inner)*width,(b-a)*depth),tint,material=material,
                 yaw=180 if direction>0 else 0,roll=90*side*direction,
                 collide=False,class_name="WedgePart")


def garden_shelf(parent,x,top,z,width,depth,height,tint,material,*,collide=True):
    """Build a layered garden ledge with a broad, irregular perimeter."""
    if not collide:
        decorative_garden_shelf(parent,x,top,z,width,depth,height,tint,material)
        return
    outline=((-.49,-.21),(-.36,-.47),(.14,-.50),(.46,-.34),
             (.50,.11),(.31,.46),(-.20,.48),(-.44,.30))
    rim=[(x+px*width,top-height/2,z+pz*depth) for px,pz in outline]
    for a,b in zip(rim[1:-1],rim[2:]):
        triangle(parent,rim[0],a,b,tint,name="Garden terrace shelf",thickness=height,material=material,collide=collide)


def shoreline_slate(parent,x,z,base,width,depth,height,yaw,*,shadow=True):
    """A low slate ledge with a recessed foot and an uneven cap."""
    outline=((-1,-.29),(-.63,-.87),(.30,-1),(.94,-.52),(.83,.45),(.12,1),(-.82,.73))
    heights=(.89,1.0,.91,.74,.71,.84,.98)
    c,s=cos(radians(yaw)),sin(radians(yaw))
    bands=[]
    for lift,wide,shift in ((.0,.77,-.09),(.47,1.0,.0),(1.0,.84,.10)):
        band=[]
        for (u,v),top in zip(outline,heights):
            px=(u*wide+shift)*width/2
            pz=v*depth*wide/2
            band.append((x+px*c+pz*s,base+lift*height*top,z-px*s+pz*c))
        bands.append(band)
    tints=(("786B78","716471","847281"),("9C8792","8C7988","AB958F"))
    for strip,(lower,upper) in enumerate(zip(bands,bands[1:])):
        for i in range(len(outline)):
            j=(i+1)%len(outline)
            tint=tints[strip][(i+strip)%3]
            triangle(parent,lower[i],lower[j],upper[i],tint,name="Shoreline cut stone",
                     material=SLATE,thickness=.12,shadow=shadow)
            triangle(parent,upper[i],lower[j],upper[j],tint,name="Shoreline cut stone",
                     material=SLATE,thickness=.12,shadow=shadow)
    crown=bands[-1]
    for i in range(1,len(crown)-1):
        triangle(parent,crown[0],crown[i],crown[i+1],("AA9795","9B8790")[i%2],
                 name="Shoreline weathered cap",material=SLATE,thickness=.13,shadow=shadow)
    return crown


def golden_sedge(parent,x,y,z,scale,lean):
    for dx,dz,height in ((-.59,-.19,1.66),(-.38,.14,2.18),(-.08,-.23,2.37),
                         (.16,.29,1.64),(.35,-.13,2.03),(.53,.16,1.36)):
        root=(x+dx*.40*scale,y,z+dz*.50*scale)
        joint=(x+(dx*.69+lean*.11)*scale,y+height*.57*scale,z+dz*.80*scale)
        tip=(x+(dx+lean*.35)*scale,y+height*scale,z+(dz-.20)*scale)
        beam(parent,"Golden sedge base",root,joint,.046*scale,"8A933F")
        beam(parent,"Golden sedge stem",joint,tip,.036*scale,"C0AD5D")
        rise=tuple(b-a for a,b in zip(joint,tip))
        pitch=degrees(atan2(rise[2],rise[1]))
        roll=-degrees(atan2(rise[0],rise[1]))
        for ratio,length,width,tint in ((.77,.35,.13,"D9B361"),(.92,.46,.22,"E7C983"),
                                        (1.09,.33,.12,"F5DCA0")):
            center=tuple(a+b*ratio for a,b in zip(joint,rise))
            part(parent,"Golden sedge head",center,(width*scale,length*scale,width*.57*scale),
                 tint,shape=0,pitch=pitch,roll=roll,collide=False)


def flowering_lotus(parent, x, z, scale, yaw, *, folded=False, notched_leaves=False):
    cluster=item(parent,"Model","Floating lotus group")
    prop(cluster,"token","ModelStreamingMode",1)
    if notched_leaves:
        build_arrival_lotus_leaves(cluster,x,z,scale,yaw,item=item,triangle=triangle,material=SMOOTH)
    else:
        for dx,dz,width,tint in ((-.87,.44,1.58,"7C9D41"),(.69,.72,1.22,"A0B656"),(.14,-.46,1.45,"658F46")):
            part(cluster,"Lotus leaf",(x+dx*scale,.16,z+dz*scale),(.07,width*scale,width*1.06*scale),
                 tint,roll=90,yaw=yaw,shape=2,collide=False)
    if folded:
        # The near-bank flowers show the fold and the backlit tip from path height.
        flower_z=z-.46*scale
        for count,reach,width,root_y,edge_y,tip_y,tones in (
                (7,.71,.176,.19,.18,.44,("C94F8B","E775AC")),
                (5,.46,.126,.27,.32,.66,("E368A5","FFA3C6"))):
            for petal in range(count):
                angle=(petal+.5)*tau/count+radians(yaw)
                radial=(sin(angle),cos(angle))
                side=(cos(angle),-sin(angle))
                root=(x+radial[0]*.035*scale,root_y*scale,flower_z+radial[1]*.035*scale)
                tip=(x+radial[0]*reach*scale,tip_y*scale,flower_z+radial[1]*reach*scale)
                for edge,tint in zip((-1,1),tones):
                    shoulder=(x+(radial[0]*reach*.55+side[0]*edge*width)*scale,
                              edge_y*scale,flower_z+(radial[1]*reach*.55+side[1]*edge*width)*scale)
                    triangle(cluster,root,shoulder,tip,tint,name="Folded lotus petal",
                             thickness=.044,shadow=False)
        center=part(cluster,"Lotus gold center",(x,.40*scale,flower_z),(.22*scale,.21*scale,.22*scale),
                    "F8C66B",shape=0,collide=False)
        prop(center,"bool","CastShadow",False)
        return
    for count,radius,height,size,palette in (
        (7,.31,.30,(.26,.17,.57),("DE6DA6","F49ABD")),
        (5,.17,.44,(.19,.16,.39),("F6AFCC","FFD0D8")),
    ):
        for petal in range(count):
            angle=(petal+.5)*tau/count+radians(yaw)
            position=(x+sin(angle)*radius*scale,height*scale+.12,z-.46*scale+cos(angle)*radius*scale)
            part(cluster,"Lotus petal",position,tuple(dimension*scale for dimension in size),palette[petal%2],
                 yaw=degrees(angle),pitch=-33,shape=0,collide=False)
    part(cluster,"Lotus gold center",(x,.64*scale+.12,z-.46*scale),(.24*scale,.19*scale,.24*scale),
         "F5C56A",shape=0,collide=False)


def canal_bank(parent, x, z, side, length, yaw, *, rock_scale):
    bank=item(parent,"Model","Layered canal bank")
    prop(bank,"token","ModelStreamingMode",1)
    garden_shelf(bank,x,.54,z,4.35,length,.51,"82747D",SLATE,collide=False)
    garden_shelf(bank,x+side*.28,.78,z+.27,3.82,length*.83,.29,"7C8D4A",GRASS_MAT,collide=False)
    for index,(dx,dz,scale) in enumerate(((-.95,-.36,1.02),(-.64,-.11,1.0),(-1.10,.25,.86))):
        px=x+side*dx
        pz=z+dz*length
        part(bank,"Slate embankment face",(px,.41*scale,pz),(1.65*scale,1.30*scale,1.91*scale),
             ("9A8991","8D7D87","AA969A")[index],material=SLATE,collide=False,
             yaw=yaw+69*index,roll=side*(10+index*4),class_name="WedgePart")
    garden_prop(bank,"bankRock",(x-side*.64,.15,z-length*.20),rock_scale,yaw+65,"907F87")
    garden_prop(bank,"meadowCover",(x+side*.28,.74,z+.15),.18,yaw,"98A962")
    garden_prop(bank,"meadowFlowers",(x+side*.48,.78,z+length*.25),.34,yaw+20,"F3B5C6")
    garden_prop(bank,"cattails" if side>0 else "tallReeds",(x-side*.89,.18,z+length*.34),.33,yaw+90)
    for index in range(8):
        px=x+side*(.58+(index%3)*.19)
        pz=z+(index-3.5)*length*.095
        height=.52+(index%4)*.21
        part(bank,"Creekbank sedge blade",(px,.78+height*.44,pz),(.143,height,.115),
             ("92A35A","ABB26B","BDA663")[index%3],yaw=yaw+index*61,roll=(index%5-2)*14,collide=False)


def tree(parent, x, z, pink=False, *, scale=1):
    parent=item(parent,"Model","Festival planting")
    prop(parent,"token","ModelStreamingMode",1)
    prop(parent,"token","LevelOfDetail",4)
    height = 7.4*scale
    part(parent, "Tree trunk", (x,height*.31,z),(1.15*scale,height*.62,1.02*scale),"865037",roll=-6)
    fork = (x+.35*scale, height*.6, z)
    colors = ("C9658D","DF87A7","F2A6B7","AE4C72","EDA0AD") if pink else ("617343","82954B","A0AD58","4F683E","879D4C")
    for j,(ox,oy,oz,sx) in enumerate([(-2.8,.2,.4,5.7),(1.95,1.35,-.9,5.3),(.1,2.48,.95,5.6),(3.35,.12,1,3.8),(-1.1,1.24,-2.1,4.2)]):
        crown = (x+ox*scale, height+oy*scale, z+oz*scale)
        elbow = tuple(a+(b-a)*.46 for a,b in zip(fork,crown))
        beam(parent, "Main tree bough", fork, elbow, .63*scale, "78452D")
        beam(parent, "Tapered tree bough", elbow, crown, .40*scale, "905A3B")
        buds=[(-.7,-.18,.32,.76,.31),(.61,.09,-.35,.83,.34),(-.08,.58,.04,.66,.36),(.26,.42,.83,.51,.27)]
        for i,(dx,dy,dz,w,h) in enumerate(buds):
            position = (crown[0]+dx*scale,crown[1]+dy*scale,crown[2]+dz*scale)
            tint=colors[(j+i*2)%len(colors)]
            part(parent,"Rounded blossom canopy" if pink else "Rounded leaf canopy",position,
                 (sx*w*scale,sx*h*scale,sx*(w-.1)*scale),tint,
                 shape=0,yaw=13+37*j,roll=(i-1)*8,collide=False)


workspace=item(root, "Workspace", "Workspace")
prop(workspace,"bool","StreamingEnabled",True)
prop(workspace,"int","StreamingMinRadius",64)
prop(workspace,"int","StreamingTargetRadius",256)
prop(workspace,"token","ModelStreamingBehavior",2)  # Improved
prop(workspace,"token","StreamOutBehavior",2)  # Opportunistic
prop(workspace,"token","StreamingIntegrityMode",3)  # PauseOutsideLoadedArea
terrain=item(workspace, "Terrain", "Terrain")
color(terrain, "WaterColor", "2A92AC")
prop(terrain, "float", "WaterReflectance", .54)
prop(terrain, "float", "WaterTransparency", .26)
prop(terrain, "float", "WaterWaveSize", .09)
prop(terrain, "float", "WaterWaveSpeed", 7)
camera=item(workspace, "Camera", "Camera")
frame(camera, "CFrame", (-.75, 6.55, 73.45), yaw=-1.3, pitch=-6.6)
prop(camera, "float", "FieldOfView", 72)
prop(workspace, "Ref", "CurrentCamera", camera.attrib["referent"])
lighting=item(root, "Lighting", "Lighting")
# Set the warm directional light from the same side as the painted sunset.
prop(lighting, "float", "GeographicLatitude", -42.5)
prop(lighting, "float", "Brightness", 2.56)
prop(lighting, "string", "TimeOfDay", "08:21:00")
prop(lighting, "float", "ExposureCompensation", -.09)
prop(lighting, "token", "LightingStyle", 0)
prop(lighting, "bool", "PrioritizeLightingQuality", False)
prop(lighting, "bool", "GlobalShadows", True)
prop(lighting, "float", "ShadowSoftness", .44)
prop(lighting, "float", "EnvironmentDiffuseScale", .20)
prop(lighting, "float", "EnvironmentSpecularScale", .51)
color(lighting, "Ambient", "746278")
color(lighting, "OutdoorAmbient", "928BA2")
color(lighting, "ColorShift_Top", "FFD1A8")
atmo=item(lighting, "Atmosphere", "Valley haze")
color(atmo, "Color", "F6B8B6")
color(atmo, "Decay", "9F83AF")
for name, value in {"Density":.226, "Haze":1.28, "Glare":.105, "Offset":.10}.items():
    prop(atmo, "float", name, value)
bloom=item(lighting, "BloomEffect", "Lantern glow")
for name, value in {"Intensity":.19, "Size":22, "Threshold":1.91}.items():
    prop(bloom, "float", name, value)
grade=item(lighting,"ColorCorrectionEffect","Peach dusk grade")
prop(grade,"float","Contrast",.110)
prop(grade,"float","Saturation",.020)
color(grade,"TintColor","FFFAFC")
sky=item(lighting,"Sky","Original Beast Dojo Sunset")
prop(sky,"bool","CelestialBodiesShown",False)
prop(sky,"int","StarCount",0)
# Lift the painted sun above Reedfall and keep it inside the mountain saddle.
vector(sky,"Vector3","SkyboxOrientation",("X","Y","Z"),(5.2,0,0))
# Roblox labels the side textures from outside the cube. The projection is from inside it.
# The top and bottom textures use the orientation measured in Studio.
for face, image in {
    "Front":92792711472741, "Left":73759569603841, "Back":119630345545934,
    "Right":90073662306430, "Up":132220171043727, "Down":133978058075992,
}.items():
    asset(sky, f"Skybox{face}Content", f"rbxassetid://{image}")

materials=item(root,"MaterialService","MaterialService")
# Reuse the tileable texture maps published by Roblox in its materials guide.
material_variant(materials,PROMENADE_STONE,LIMESTONE,7.5,1,
                 Color=9920561437,Normal=9439415191,Roughness=9439415495)
material_variant(materials,SUNSET_FLAGSTONE,LIMESTONE,4.15,1,
                 Color=9920561437,Normal=9439415191,Roughness=9439415495)
material_variant(materials,FESTIVAL_FLAGSTONE,LIMESTONE,3.2,1,
                 Color=9920561437,Normal=9439596530,Roughness=9439596711)
material_variant(materials,PROMENADE_MORTAR,SLATE,5.0,1,
                 Color=9920599782,Normal=9439612514,Roughness=9439612733)
material_variant(materials,ORNAMENT_BRASS,METAL,4.8,0,
                 Color=9920574687,Normal=9873295432,Metalness=9873318201,Roughness=9873318890)
material_variant(materials,CANOPY_FOLIAGE,LEAFY_GRASS,.95,1,
                 Normal=9439080781,Roughness=9439080950)
material_variant(materials,VALLEY_ROCK,ROCK,21,1,Normal=9439538417,Roughness=9439545859)
material_variant(materials,BANK_STONE,ROCK,3.4,1,Normal=9439538417,Roughness=9439545859)
material_variant(materials,CINDER_STONE,SANDSTONE,10.5,1,Normal=9439596530,Roughness=9439596711)
material_variant(materials,CINDER_BRICK,BRICK,5.4,0,Normal=9438453152,Roughness=9438453413)
material_variant(materials,INDIGO_TILE,CLAY_ROOF,4.8,0,Normal=18147683410,Roughness=18147684855)
material_variant(materials,ARENA_WEAVE,FABRIC,1.30,0,Normal=9873280412,Roughness=9873282563)
material_variant(materials,ARENA_CEDAR,WOOD_PLANK,5.1,0,Normal=9439650689,Roughness=9439658127)
material_variant(materials,LANDMARK_CEDAR,WOOD_PLANK,5.4,0,Normal=9439641376,Roughness=9439648605)
material_variant(materials,SEA_STACK_VARIANT,SEA_STACK_MATERIAL,15,1,
                 Color=13489135438,Normal=13489126540,Roughness=13489135542)

scene=item(workspace, "Model", "Grand Dojo City")
plaza=item(scene, "Folder", "Plaza & streets")
canal_x, canal_z = -18, 10
canal_width, canal_length = 12, 108
festival_bridge_z=38
canal_west=canal_x-canal_width/2
canal_east=canal_x+canal_width/2
cove_west,cove_north,cove_south=canal_west-4,48,64
# Cut the plaza foundation to leave room for a recessed Terrain water channel.
for name,x,z,w,d in (("West plaza foundation",(-125+cove_west)/2,-9,cove_west+125,248),
                   ("West canal north foundation",(cove_west+canal_west)/2,(cove_north-133)/2,4,cove_north+133),
                   ("West canal south foundation",(cove_west+canal_west)/2,(cove_south+115)/2,4,115-cove_south),
                   ("East plaza foundation",(INLET_EDGE+125)/2,-9,125-INLET_EDGE,248),
                   ("East canal north foundation",(canal_east+INLET_EDGE)/2,(INLET_NORTH-133)/2,
                    INLET_EDGE-canal_east,INLET_NORTH+133),
                   ("East canal south foundation",(canal_east+INLET_EDGE)/2,(INLET_SOUTH+115)/2,
                    INLET_EDGE-canal_east,115-INLET_SOUTH),
                   ("North canal end",canal_x,-88.5,canal_width,89),
                   ("South canal end",canal_x,89.5,canal_width,51)):
    part(plaza, name, (x,-2.2,z), (w,4,d), GRASS, material=GRASS_MAT)
hall_apron_tints = {(-3,-23): "C2A088", (3,-23): "CAA88D",
                    (-3,-17): "B9998C", (3,-17): "BE9D8E"}
for x in range(-87, 88, 6):
    for z in range(-71, 79, 6):
        if abs(x-canal_x)<canal_width/2 and abs(z-canal_z)<canal_length/2:
            continue
        if z>43 and (x<-24 or x>19) and (z>56 or abs(x)>41):
            continue
        if (abs(x)<36 or z>14 or -68<x<-31 or 36<x<80):
            tones=TILE if abs(x)<8 or 25<x<47 and 24<z<67 else ("9A817B","AB8A7E","9E827F","A98F86")
            if -12<x<18 and -11<z<72:
                continue
            tile_x,tile_width=x,5.98
            tint=rng.choice(tones)
            if PROMENADE_BOUNDS[0]<x<PROMENADE_BOUNDS[1] and ORIGINAL_SOUTH_EDGE<z<PROMENADE_BOUNDS[3]:
                continue
            left,right=x-tile_width/2,x+tile_width/2
            if left<cove_west<right<=canal_west and z+2.99>cove_north and z-2.99<cove_south:
                tile_x,tile_width=(left+cove_west)/2,cove_west-left
                if z-2.99<cove_north:
                    part(plaza,"Cove paving return",((cove_west+right)/2,-.05,(z-2.99+cove_north)/2),
                         (right-cove_west,.4,cove_north-z+2.99),tint,material=LIMESTONE)
            apron_tint = hall_apron_tints.get((x,z))
            paving=part(plaza,"Sandstone paving",(tile_x,-.05,z),(tile_width,.4,5.98),
                        apron_tint or tint,material=LIMESTONE)
            if apron_tint:
                prop(paving,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
walkway=item(plaza,"Folder","Hewn promenade paving")
build_promenade(walkway)
build_arrival_flagstone_detail(walkway,item=item,prop=prop,triangle=triangle,limestone=LIMESTONE)
arrival_lanterns=item(plaza,"Model","Arrival lantern markers")
prop(arrival_lanterns,"token","ModelStreamingMode",1)
for side,(x,z) in zip((-1,1),ARRIVAL_LAMPS):
    part(arrival_lanterns,"Lantern slate footing",(x,.26,z),(1.64,.34,1.60),
         "83717D",material=SLATE,collide=False)
    part(arrival_lanterns,"Lantern limestone cap",(x,.45,z),(1.37,.16,1.34),
         "AD8F85",material=LIMESTONE,collide=False)
    store_standing_lantern(arrival_lanterns,(x,.53,z),.48,warm_pool=True)
    garden_prop(arrival_lanterns,"bankRock",(x+side*1.12,.01,z-.70),.12,63*side,"918190")
    garden_prop(arrival_lanterns,"mossFlowers",(x+side*.86,.16,z+.52),.10,77*side,"ECC0A8")
    garden_prop(arrival_lanterns,"meadowGrass",(x+side*.92,.14,z-.43),.10,54*side,"A2A657")
    garden_prop(arrival_lanterns,"meadowFlowers",(x+side*.87,.14,z+.58),.17,34*side,"EEC08F")
canal=item(plaza,"Folder","Festival canal")
part(canal,"Canal bed",(canal_x,-3.81,canal_z),(canal_width,.4,canal_length),"345771",material=SLATE)
part(canal,"Canal water bounds",(canal_x,-2,canal_z),(canal_width,4,canal_length),"398A9B",
     collide=False,transparency=1)
preview_water=part(canal,"Canal edit preview",(canal_x,-.045,canal_z),(canal_width,.07,canal_length),"3F8899",
                   material=GLASS,collide=False,transparency=.19)
prop(preview_water,"bool","CastShadow",False)
cove_x,cove_z=(cove_west+canal_west)/2,(cove_north+cove_south)/2
cove_size=(canal_west-cove_west,4,cove_south-cove_north)
part(canal,"Arrival cove bed",(cove_x,-3.81,cove_z),(cove_size[0],.4,cove_size[2]),"3E7D83",material=SLATE)
part(canal,"Arrival cove water bounds",(cove_x,-2,cove_z),cove_size,"398A9B",collide=False,transparency=1)
cove_preview=part(canal,"Arrival cove edit preview",(cove_x,-.045,cove_z),
                  (cove_size[0],.07,cove_size[2]),"3F8899",material=GLASS,collide=False,transparency=.19)
prop(cove_preview,"bool","CastShadow",False)
inlet_x,inlet_z=(canal_east+INLET_EDGE)/2,(INLET_NORTH+INLET_SOUTH)/2
inlet_width,inlet_length=INLET_EDGE-canal_east,INLET_SOUTH-INLET_NORTH
part(canal,"Promenade inlet bed",(inlet_x,-3.81,inlet_z),
     (inlet_width,.40,inlet_length),"315F67",material=SLATE)
# Pad the fill one voxel beneath the paving and into the main channel.
# Terrain rounds its outer voxels down. The overlap keeps the corner level.
part(canal,"Promenade inlet water bounds",(inlet_x,-2,inlet_z+2),
     (inlet_width+8,4,inlet_length+4),"398A9B",collide=False,transparency=1)
inlet_preview=part(canal,"Promenade inlet edit preview",(inlet_x,-.045,inlet_z),
                   (inlet_width,.07,inlet_length),"3F8899",material=GLASS,collide=False,transparency=.19)
prop(inlet_preview,"bool","CastShadow",False)
for i in range(38):
    x,z=rng.uniform(-22.8,-13.2),rng.uniform(-44,63)
    length=rng.uniform(.7,1.8)
    if i%3==2:
        stripe=part(canal,"Warm lantern reflection",(x,.02,z),(length,.012,.08),
                    "C9A171",material=NEON,transparency=.69,collide=False)
        prop(stripe,"bool","CastShadow",False)
for x,z,scale,yaw in ((-17.71,53.9,1.2,14),(-19.70,40.1,.97,76),(-19.26,26.52,.88,137),
                      (-16.85,13.16,1.05,37),(-15.61,-16.24,.85,101),(-18.60,-38.65,.92,195)):
    flowering_lotus(canal,x,z,scale,yaw,folded=z==40.1)
for x,z in ((-18.85,48.85),(-18.4,28.8),(-17.46,14.72),(-17.3,-12),(-18.6,-33.7)):
    for index,(dx,dz,width) in enumerate(((-.60,.37,.92),(.15,.12,1.17),(.41,-.18,.75),
                                         (-.64,-.49,.58),(.29,-.80,.86))):
        reflection=part(canal,"Amber water glint",(x+dx,.057,z+dz),(width,.012,.065),
                        "E2AE7E",transparency=.45+index*.065,shape=0,collide=False)
        prop(reflection,"bool","CastShadow",False)
arrival_water=item(canal,"Model","Arrival canal shallows")
prop(arrival_water,"token","ModelStreamingMode",1)
build_arrival_canal_reflection(arrival_water,item=item,prop=prop,triangle=triangle,
                              water_beam=horizontal_water_beam,neon=NEON,smooth=SMOOTH,
                              bridge_z=festival_bridge_z)

for x,z,radius in ((-19.59,52.35,.86),(-16.24,42.05,.65),(-21.55,25.4,.78),(-25.80,57.62,.71)):
    for index,angle in enumerate((.17,.59,1.23,1.73,3.22,3.66,4.82)):
        for size,lift,tint,alpha in ((1,.049,"9ACCC7",.67),(1.41,.044,"77B8B6",.76)):
            r=radius*size
            ripple=part(arrival_water,"Broken lily ripple",(x+r*cos(angle),lift,z+r*.62*sin(angle)),
                        (.40+index%3*.10,.014,.052),tint,shape=0,collide=False,
                        yaw=degrees(atan2(-.62*cos(angle),-sin(angle))),transparency=alpha)
            prop(ripple,"bool","CastShadow",False)
for start,end,widths,palette in (
    ((-17.45,.102,57.1),(-19.00,.102,46.5),(2.18,1.16),"0 .23 .75 .78 0 .64 .43 .87 .83 0 1 .21 .60 .71 0 "),
    ((-25.09,.102,59.4),(-24.70,.102,50.0),(1.98,.96),"0 .23 .65 .74 0 .62 .45 .84 .81 0 1 .24 .62 .69 0 "),
    ((-19.90,.102,28.4),(-18.83,.102,22.1),(1.21,.72),"0 .82 .60 .42 0 .57 .94 .77 .56 0 1 .74 .54 .39 0 "),
    ((-14.20,.100,57.4),(-15.45,.100,48.7),(1.56,.98),"0 .18 .64 .77 0 .58 .31 .76 .87 0 1 .22 .58 .71 0 "),
    ((-22.24,.100,47.65),(-21.24,.100,39.84),(1.39,.84),"0 .17 .62 .72 0 .56 .34 .78 .84 0 1 .22 .59 .71 0 "),
):
    horizontal_water_beam(arrival_water,"Canal surface ripple",start,end,widths,palette,
                          "0 1 0 .27 .78 0 .69 .76 0 1 1 0 ",4.18)
bridge_reflections=item(arrival_water,"Model","Bridge lantern reflections")
prop(bridge_reflections,"token","ModelStreamingMode",1)
near_reflection_z=festival_bridge_z+4.25
for x,drift,reach in ((-23.06,1.11,9.68),(-13.31,-.42,3.39)):
    horizontal_water_beam(bridge_reflections,"Canal surface ripple",(x,.096,near_reflection_z),
                          (x+drift,.096,near_reflection_z+reach),(1.18,.52),
                          "0 .91 .63 .38 0 .38 1 .81 .54 0 1 .82 .57 .38 0 ",
                          "0 1 0 .26 .72 0 .65 .84 0 1 1 0 ",3.6)
for x,z,side,scale in ((-27.55,58.17,-1,1.12),(-5.22,58.02,1,.49),
                         (-27.67,50.20,-1,.99),(-12.49,38.15,1,.94)):
    shore=item(arrival_water,"Model","Planted shoreline ledge")
    slate_x=x+side*.53
    top=.81*scale
    shoreline_slate(shore,slate_x-side*.31,z,-.41,2.64*scale,3.81*scale,1.10*scale,15*side)
    for dx,dz,w,d,level,height,tint in ((-.74,-1.64,1.79,2.18,.19,.53,"817383"),
                                      (.58,.98,2.18,2.28,.53,.64,"95828F")):
        garden_shelf(shore,slate_x+side*dx,level*scale,z+dz,w*scale,d*scale,height*scale,tint,SLATE,collide=False)
    garden_shelf(shore,slate_x+side*.14,top,z-.37,2.08,2.75,.23,"84934C",GRASS_MAT,collide=False)
    garden_prop(shore,"bankRock",(x+side*.34,.11,z+.91),.17*scale,43*side,"978691")
    garden_prop(shore,"meadowCover",(slate_x+side*.07,top-.03,z-.45),.17,18*side,"B4C976")
    garden_prop(shore,"mossFlowers",(slate_x+side*.38,top-.04,z+.62),.16,64*side,"EAB7C8")
    garden_prop(shore,"grassBlade",(slate_x+side*.58,top-.01,z-1.06),.54,72*side,"DEC184")
    garden_prop(shore,"meadowGrass",(slate_x+side*.13,top-.02,z-.07),.23,26*side,"A2B667")
    garden_prop(shore,"reeds",(x-side*1.10,.03,z+.33),.24,37*side,"AEB85B")
for x,z,scale,yaw in ((-25.97,59.4,.58,37),(-20.3,44.92,.52,181),(-14.36,39.74,.44,253)):
    garden_prop(arrival_water,"lilyPads",(x,.091,z),scale,yaw)
cove_planting=item(arrival_water,"Folder","Arrival cove lotus beds")
for x,z,scale,yaw in ((-21.30,51.53,1.22,34),(-23.54,57.17,1.04,121),(-14.90,52.60,1.12,86)):
    flowering_lotus(cove_planting,x,z,scale,yaw,folded=True,notched_leaves=True)
for key,x,z,scale,yaw in (
        ("lilyPads",-23.71,53.57,.46,82),
        ("lilyPads",-25.40,55.60,.43,147),
        ("lilyFlowers",-25.07,50.86,.31,23),
        ("lilyPads",-16.63,53.34,.25,111),
        ("lilyPads",-14.05,54.57,.22,51),
):
    garden_prop(cove_planting,key,(x,.085,z),scale,yaw)
for plant in cove_planting.findall(".//Item[@class='Part']"):
    if plant.find("Properties/bool[@name='CastShadow']") is None:
        prop(plant,"bool","CastShadow",False)

bridge_banks=item(arrival_water,"Model","Reed beds by the red bridge")
prop(bridge_banks,"token","ModelStreamingMode",1)
for x,z,side,length,scale,yaw in ((-24.30,41.64,-1,4.26,1.04,37),
                                 (-24.48,46.22,-1,3.32,.99,127),
                                 (-12.41,39.83,1,2.65,.82,71)):
    garden_shelf(bridge_banks,x,.51,z,2.52*scale,length,.56,"81717D",SLATE,collide=False)
    garden_shelf(bridge_banks,x+side*.24,.78,z-.15,1.86*scale,length*.81,.34,
                 "A38A8A",SLATE,collide=False)
    garden_shelf(bridge_banks,x+side*.35,.97,z-.27,1.69*scale,length*.71,.22,
                 "8CA042",GRASS_MAT,collide=False)
    for key,dx,dz,y,asset_scale,rotation,tint in (
            ("bankRock",-.66,.72,.03,.157,0,"A48B93"),
            ("reeds",-.61,-.61,.33,.31,29,"9DB953"),
            ("tallReeds",.31,-.87,.74,.29,107,"B6C566"),
            ("meadowCover",.24,.12,.94,.135,83,"A9C456"),
            ("mossFlowers",.40,.69,.94,.141,196,"F6B0C4"),
            ("grassBlade",.54,.30,.94,.50,51,"EECB88")):
        garden_prop(bridge_banks,key,(x+side*dx*scale,y,z+dz*scale),
                    asset_scale*scale,yaw+rotation,tint)
for plant in bridge_banks.findall("Item"):
    if plant.find("Properties/bool[@name='CastShadow']") is None:
        prop(plant,"bool","CastShadow",False)

moss_seams=item(arrival_water,"Model","Moss seams and shore grasses")
prop(moss_seams,"token","ModelStreamingMode",1)
prop(moss_seams,"token","LevelOfDetail",4)
for x,z,top,width,length,side in (
    (-12.62,37.98,.46,1.38,2.10,1),(-25.80,51.24,.49,1.54,2.36,-1),
    (-11.20,47.80,.41,1.49,2.25,1),(-6.31,50.06,.35,1.52,1.45,1),
    (-6.03,58.96,.29,1.59,1.64,1),(-12.47,61.47,.21,1.42,1.74,1),
):
    garden_shelf(moss_seams,x,top-.07,z,width,length,.19,"87746B",SLATE,collide=False)
    garden_shelf(moss_seams,x+side*.06,top,z,width*.91,length*.95,.12,"82974D",LEAFY_GRASS,collide=False)
    for key,dx,dz,yaw,scale,tint in (
        ("meadowCover",-.39,.17,38,.137,"9DBA55"),
        ("meadowGrass",-.28,-.40,117,.092,"B7C65E"),
        ("meadowGrass",.33,.48,71,.116,"9DB052"),
        ("mossFlowers",.38,-.24,142,.079,"E9AAAE"),
        ("cattails",-.58,-.05,23,.16,"A6AD5B"),
    ):
        garden_prop(moss_seams,key,(x+side*dx,top-.047,z+dz*length*.68),scale,
                    yaw+18*side,tint)
for detail in moss_seams.findall("Item"):
    if detail.find("Properties/bool[@name='CastShadow']") is None:
        prop(detail,"bool","CastShadow",False)

inlet=item(arrival_water,"Model","Promenade inlet planting")
prop(inlet,"token","ModelStreamingMode",1)
flowering_lotus(inlet,-10.95,55.30,.86,55,notched_leaves=True)
flowering_lotus(inlet,-7.66,57.35,.81,71,folded=True,notched_leaves=True)
garden_prop(inlet,"lilyPads",(-6.52,.086,50.62),.31,113)
near_inlet=item(inlet,"Model","Near inlet lotus and sunset flecks")
flowering_lotus(near_inlet,-10.43,58.25,.95,38,folded=True)
garden_prop(near_inlet,"lilyPads",(-11.24,.085,57.08),.21,81)
for x,z,width,tint in ((-9.39,57.52,.71,"F2C895"),(-9.88,56.84,.46,"F8D69F"),
                       (-9.25,58.74,.58,"F6D693"),(-9.83,59.06,.29,"FFE6AA")):
    fleck=part(near_inlet,"Near inlet sunset fleck",(x,.094,z),(width,.010,.057),tint,
               material=NEON,transparency=.35,collide=False)
    prop(fleck,"bool","CastShadow",False)
for leaf in inlet.findall(".//Item[@class='Part']"):
    if leaf.find("Properties/bool[@name='CastShadow']") is None:
        prop(leaf,"bool","CastShadow",False)
build_arrival_lotus_cove(inlet,item=item,prop=prop,part=part,triangle=triangle,
                         garden_prop=garden_prop,flowering_lotus=flowering_lotus,
                         smooth=SMOOTH,neon=NEON)
for x, intervals in ((canal_west,((-44,cove_north),)),(cove_west,((cove_north,cove_south),)),
                      (canal_east,((-44,-4.1),(.1,41.9),(46.1,INLET_NORTH)))):
    for start,end in intervals:
        count=max(1,round((end-start)/9))
        segment=(end-start)/count
        for i in range(count):
            part(canal,"Canal coping",(x,.24,start+(i+.5)*segment),
                 (1.36,.46,segment-.07),("887783","9F8990","93808A")[i%3],material=SLATE)
for z in (cove_north,cove_south):
    part(canal,"Arrival cove return coping",(cove_x,.265,z),(4.67,.51,1.36),"93808A",material=SLATE)
for z in (INLET_NORTH,INLET_SOUTH):
    part(canal,"Promenade inlet return coping",(inlet_x,.18,z),
         (inlet_width,.35,.58),"93808A",material=SLATE)
# The original swim opening stays centered on z=54. Extend the low
# south-bank curb along the new reach without narrowing that opening.
for start,end in ((INLET_NORTH+.03,INLET_SWIM_Z-2.165),
                  (INLET_SWIM_Z+2.165,INLET_SOUTH-.025)):
    segments=ceil((end-start)/4)
    length=(end-start)/segments
    for index in range(segments):
        part(canal,"Promenade inlet low coping",(INLET_EDGE,.16,start+(index+.5)*length),
             (.62,.31,length-.025),"94808B",material=SLATE)

inlet_steps=item(canal,"Model","Lotus inlet swim steps")
prop(inlet_steps,"token","ModelStreamingMode",1)
for step in range(5):
    top=-.04-step*.34
    tread=part(inlet_steps,"Rose slate swim tread",(INLET_EDGE-.37-step*.74,top-.25,INLET_SWIM_Z),
               (.78,.50,3.75),"968589",material=SLATE)
    prop(tread,"string",MATERIAL_VARIANT_FIELD,PROMENADE_MORTAR)
    rim=part(inlet_steps,"Honed swim tread edge",(INLET_EDGE-.70-step*.74,top-.046,INLET_SWIM_Z),
             (.10,.09,3.67),"AF9B8C",material=LIMESTONE,collide=False)
    prop(rim,"bool","CastShadow",False)

inlet_terraces=item(canal,"Model","Lotus inlet stone terraces")
prop(inlet_terraces,"token","ModelStreamingMode",1)
for x,z,span,profile,yaw in ((-5.66,49.22,3.01,.88,-12),(-5.63,58.43,2.44,.68,17)):
    shoreline_slate(inlet_terraces,x,z,-.52,span,2.30,profile,yaw,shadow=False)
    garden_prop(inlet_terraces,"bankRock",(x+.74,.03,z-.30),.22,yaw+31,"9F8B8A")
    garden_prop(inlet_terraces,"meadowCover",(x+.55,.25,z-.45),.14,yaw+71,"95AB63")
    garden_prop(inlet_terraces,"cattails",(x-.88,-.04,z+.24),.26,yaw+112,"99AB55")
    garden_prop(inlet_terraces,"mossFlowers",(x+.25,.20,z+.44),.17,yaw+35,"E6A6B4")
build_canal_lip_gardens(canal,item=item,prop=prop,part=part,triangle=triangle,garden_prop=garden_prop,
                        rock=ROCK,grass=LEAFY_GRASS,stone_variant=BANK_STONE,variant_field=MATERIAL_VARIANT_FIELD)
build_canal_store_stones(canal,item=item,part=part,prop=prop,vector=vector,asset=asset,plastic=256)
for x,z in [(-24,30),(-12,33),(-24,3),(-11.8,.7),(-23.7,-12),(-11.9,-38),(-24.4,-40)]:
    for offset in (-.8,.53):
        part(plaza,"Faceted canal stone",(x+offset,.39,z+offset),
             (1.35,.82,1.42),rng.choice(TILE),yaw=rng.randint(-60,60),collide=False,class_name="WedgePart")
    for n in range(4):
        part(plaza,"Bank reed",(x+(n-1.5)*.19,.62,z+.39),(.1,.92+n*.10,.16),"86983F",
             roll=(n-1.5)*13,collide=False)
for index,z in enumerate((53,44,35,26,19,6,-6,-15,-36,-41)):
    pocket = item(plaza,"Model","Canal garden pocket")
    prop(pocket,"token","ModelStreamingMode",1)
    x = -21.6 if index%2==0 else -14.5
    side = -1 if index%2==0 else 1
    garden_prop(pocket,"lilyFlowers" if index in (1,4,5) else "lilyPads",(x,.178,z),.73,index*31)
    garden_prop(pocket,"reeds" if index%2 else "cattails",(x+side*1.10,.10,z+1.15),.31,index*71)
    rock_scale=.13 if z==44 else .22
    garden_prop(pocket,"bankRock",(x+side*1.88,.07,z-1.5),rock_scale,index*67)
    if index in (0,3,6):
        garden_prop(pocket,"tallReeds",(x+side*2.24,.14,z+2.6),.36,index*61)
        garden_prop(pocket,"mossFlowers",(x+side*2.42,.20,z-2.5),.24,index*27)
for x,z,side,length,yaw,rock_scale in ((-28.89,53.41,-1,7.1,36,.26),(-11.16,49.40,1,3.08,75,.14),
                                      (-24.76,22.68,-1,6.4,112,.26),(-11.42,22.05,1,5.4,-13,.26),
                                      (-24.90,1.02,-1,5.3,153,.26),(-11.62,-13.52,1,6.7,104,.26)):
    canal_bank(plaza,x,z,side,length,yaw,rock_scale=rock_scale)
for z in (festival_bridge_z,8,-24.25):
    bridge=item(canal,"Model","Arched red footbridge")
    prop(bridge,"token","ModelStreamingMode",1)
    signature=z==festival_bridge_z
    half=8.82 if signature else 7.56
    if signature:
        # Near-level crest and controlled shoulders on the same two landings.
        # The Lantern Courier takes its height from these same plank joins.
        climb=[.17]
        for grade in (.375,.400,.405,.370,.265,.075):
            climb.append(climb[-1]+grade*half/6)
        heights=climb+climb[-2::-1]
    else:
        heights=[.17+sin(i/12*tau/2)*1.70 for i in range(13)]
    samples=[(canal_x+half*(i/6-1),height) for i,height in enumerate(heights)]
    for (ax,ay),(bx,by) in zip(samples,samples[1:]):
        angle=atan2(by-ay,bx-ax)
        roll=degrees(angle)
        mid=((ax+bx)/2,(ay+by)/2,z)
        center=(mid[0]+.165*sin(angle),mid[1]-.165*cos(angle),z) if signature else (mid[0],mid[1]-.165,z)
        deck=part(bridge,"Bridge cedar deck",center,(hypot(bx-ax,by-ay)+.12,.33,7.1),
                  "9B634C",roll=roll,material=WOOD_PLANK)
        if signature:
            prop(deck,"string",MATERIAL_VARIANT_FIELD,ARENA_CEDAR)
            seam=part(bridge,"Fitted bridge plank seam",(mid[0],mid[1]+.004,z),(.055,.012,6.80),
                      "875344",roll=roll,collide=False)
            prop(seam,"bool","CastShadow",False)
        for side in (-1,1):
            rz=z+side*3.48
            beam(bridge,"Red bridge handrail",(ax,ay+1.48,rz),(bx,by+1.48,rz),.25,"B54937",collide=True)
            beam(bridge,"Lower red bridge rail",(ax,ay+.69,rz),(bx,by+.69,rz),.18,"8F3933",collide=True)
            beam(bridge,"Arched cedar apron",(ax,ay-.27,rz),(bx,by-.27,rz),.42,"764332")
    for x,y in samples[::3]:
        for side in (-1,1):
            rz=z+side*3.48
            part(bridge,"Bridge baluster",(x,y+.79,rz),(.30,1.61,.34),"A64336")
            part(bridge,"Brass bridge cap",(x,y+1.61,rz),(.39,.17,.40),"D29755",collide=False)
            if signature:
                part(bridge,"Bridge forged pin",(x,y+.83,rz+side*.175),(.115,.115,.062),
                     "D7A05A",shape=0,collide=False)
    if signature:
        canal_bridge_walk=[(x,y,z-.74) for x,y in samples]
        start_x=canal_x-half
        part(bridge,"West bridge landing",(start_x-1.05,.032,z),(2.24,.27,7.14),
             "9B8587",material=LIMESTONE)
        build_festival_bridge_details(bridge,samples=samples,z=z,canal_x=canal_x,canal_width=canal_width,
                                      item=item,prop=prop,part=part,triangle=triangle,beam=beam,
                                      slate=SLATE,wood=WOOD_PLANK,
                                      metal=METAL,variant_field=MATERIAL_VARIANT_FIELD,
                                      stone_variant=PROMENADE_MORTAR)
        for bank in (-1,1):
            x=canal_x+bank*7.66
            for side in (-1,1):
                pz=z+side*4.04
                part(bridge,"Lacquered bridge newel",(x,.97,pz),(.56,1.91,.65),"AD5033",collide=False)
                part(bridge,"Bridge newel base",(x,.21,pz),(.83,.42,.94),"887681",material=SLATE,collide=False)
                festival_lantern(bridge,x,2.41,pz,.62,light=side>0)
                garden_prop(bridge,"bankRock",(x+bank*.41,.09,pz+side*.94),.23,47*bank,"93818A")
                garden_prop(bridge,"meadowFlowers",(x+bank*.71,.19,pz+side*.66),.23,54*side,"EDB1A9")
# The underwater steps give swimmers a way back to the promenade.
for z in (44,-2):
    for i in range(7):
        top = -.03-i*.48
        part(canal,"Canal exit step",(-12.42-i*.78,top-.35,z),(.83,.70,4),"807681",material=SLATE)
for x,z,depth,scale,yaw,tint in (
        (-23.65,53,-.58,.42,21,"797381"),(-23.74,43,-.24,.20,154,"817982"),
        (-5.06,50.22,-.75,.23,43,"766F80"),(-23.35,21,-.72,.47,67,"777080"),
        (-12.34,18,-.36,.31,78,"837983"),(-23.41,-14,-.48,.42,33,"796F7D"),
):
    garden_prop(canal,"bankRock",(x,depth,z),scale,yaw,tint)
for x, z in [(-8, 42), (11, 37), (21, 14), (-30, 15), (-4, -18), (16, -19), (-41, -47), (65, 37), (73, -24)]:
    part(plaza,"Stone lantern plinth",(x,.54,z),(1.25,1.08,1.25),STONE)
    if (x, z) in {(-8, 42), (11, 37)}:
        store_standing_lantern(plaza, (x, 1.08, z), .79)
    else:
        lamp(plaza,x,1.62,z,scale=.75,light=True)
for x,z,w in [(13,45,5.9),(-13,40,4.3),(18,36,3.4),(-5.32,47.18,2.8),(12,-16,3)]:
    part(plaza,"Plaza planting bed",(x,.21,z),(w,.28,1.88),"687342",yaw=-21,collide=False)
    for n in range(10):
        dx=rng.uniform(-w*.43,w*.43)
        blade=rng.uniform(.54,1.21)
        part(plaza,"Ornamental golden grass",(x+dx,.26+blade*.42,z+rng.uniform(-.45,.45)),
             (.10,blade,.15),rng.choice(("C9A65A","9DA451","7D914A")),roll=rng.uniform(-28,28),collide=False)
    for offset in (-1.7,1.2):
        part(plaza,"Split slate garden stone",(x+offset,.39,z+.39),(1.24,.69,1.04),
             "847478",yaw=rng.uniform(-60,60),collide=False,class_name="WedgePart")

for x,z,length,accent in [(12.8,53,10,"6F8149"),(15.1,30,12,"718747"),(-7.9,4,9,"637A4C")]:
    edge=item(plaza,"Model","Promenade garden border")
    prop(edge,"token","ModelStreamingMode",1)
    if z>=53:
        garden_shelf(edge,x,.46,z,4.60,length+.88,.37,"8D7D87",SLATE,collide=False)
        garden_shelf(edge,x+.15,.79,z+.16,3.84,length-.12,.40,"A39396",SLATE,collide=False)
        garden_shelf(edge,x,.93,z-.13,3.73,length-.65,.26,accent,GRASS_MAT,collide=False)
        flank=-1 if x<0 else 1
        for seed,dz in enumerate((-.34*length,.065*length,.35*length)):
            px,pz=x+flank*.66,z+dz
            garden_prop(edge,"bankRock",(px,.51,pz),(.245,.20,.22)[seed],27+seed*62,"8E7D88")
            garden_prop(edge,"mossFlowers",(px-flank*.49,.89,pz+.60),.17,69+seed*23,"F0ADB8")
            garden_prop(edge,"meadowCover",(px,.96,pz-.34),.145,33+seed*61,"A8B96F")
            garden_prop(edge,"grassBlade",(px-flank*.94,.95,pz+.26),.50,38+seed*39,"DDC184")
    else:
        part(edge,"Raised garden curb",(x,.42,z),(3.1,.64,length),"978186",material=SLATE)
        part(edge,"Green ground cover",(x,.77,z),(2.82,.26,length-.42),accent,material=GRASS_MAT)
    for offset in (-.31,0,.31):
        garden_prop(edge,"meadowGrass",(x,.87,z+offset*length),.22,12,"96A758")
        garden_prop(edge,"meadowFlowers",(x-.39,.89,z+offset*length+.66),.40,27,"FFC18D")
    if z>=53:
        for group,offset in enumerate((-3.65,1.83)):
            garden_prop(edge,"mossFlowers",(x,.88,z+offset),.19,90,"E9AFBA")
            garden_prop(edge,"grassBlade",(x+.50,.88,z+offset-.55),.46,58+group*43,"B6A76D")
            for i in range(5):
                start=(x+(i-2)*.23,.83,z+offset+(i%3-1)*.22)
                tip=(start[0]+(i-2)*.28,start[1]+(1.28,.80,1.03,1.39,.95)[i],start[2]-.29)
                beam(edge,"Golden meadow stalk",start,tip,.065,"AA975C")
                part(edge,"Sunlit seed plume",tip,(.26,.68,.22),("D4B375","EAC787","DCC28B")[i%3],
                     roll=17*(2-i),pitch=-16,shape=0,collide=False)
    edge_rng=random.Random(int(x*31+z))
    for i in range(int(length*2)):
        px=x+edge_rng.uniform(-1.11,1.11)
        pz=z+edge_rng.uniform(-length*.44,length*.44)
        h=edge_rng.uniform(.48,1.05)
        part(edge,"Sedge frond",(px,.87+h*.39,pz),(.13,h,.22),
             edge_rng.choice(("8F9C53","6F8E4F","AEB367","AA8E4F")),
             roll=edge_rng.uniform(-35,35),yaw=edge_rng.randint(0,360),collide=False)
        if i%4==0:
            part(edge,"Low shrub",(px,.97,pz),(1.1,.64,1.25),"647D48",shape=0,collide=False)
        if i%5==0:
            part(edge,"Garden blossom",(px,1.23,pz),(.36,.31,.43),"CE8298",shape=0,collide=False)

foreground=item(plaza,"Folder","Plaza gardens")
for position, volume in (((-31.7, 8.1, -21), (7.2, .55, 5.5)),
                         ((48.44, 9.9, 44.45), (9.3, .55, 6.4))):
    air_effect(foreground, "Creator Store blossom petals", position, volume, STORE_BLOSSOM_PETAL,
               tint="FFD5DF", rate=3.5, lifetime=(3, 4.4), speed=(.7, 1.25),
               size=(.30, .48), opacity=.85, drift=(.62, -.65, .19), down=True, glow=.12)
for x,z,pink,scale,yaw in ((-31.7,-21,True,1.32,-24),(13.8,-17.9,False,.98,22),(37.3,-39.6,True,1.13,47)):
    showcase_tree(foreground,x,z,pink,scale,yaw,.15)
for x,z,width,depth,pink,root_offset,yaw,scale,height_scale in (
    (-41.2,46.8,16,10,False,.07,31,1.52,1.21),(50.4,45.55,14,11,True,-.14,-21,1.56,1.50),
    (-55,36,19,9,True,-.16,15,1.29,1),(59,57,19,12,False,-.16,-44,1.30,1),
):
    garden=item(foreground,"Model","Terraced garden island")
    prop(garden,"token","ModelStreamingMode",1)
    prop(garden,"token","LevelOfDetail",4)
    garden_shelf(garden,x,1.02,z,width,depth,.89,"877983",SLATE)
    garden_shelf(garden,x,1.46,z,width-.70,depth-.70,.50,"5B7143",GRASS_MAT)
    garden_shelf(garden,x+width*root_offset,2.10,z-depth*.1,width*.56,depth*.56,.70,"66814B",GRASS_MAT)
    # Keep the west blossom rooted in the upper planter, clear of the tower ramp.
    tree_x,tree_z=x+width*root_offset,z-depth*.1
    if x==-55:
        tree_x,tree_z=tree_x-.60,tree_z-2.05
    showcase_tree(garden,tree_x,tree_z,pink,scale,yaw,2.10,
                  height_scale=height_scale,
                  relief_crown=x==-41.2,crown_turn=-55 if x==-41.2 else 0)
    understory=item(garden,"Folder","Garden island understory")
    for i,(u,v) in enumerate(((-.34,-.17),(-.23,-.32),(.08,-.36),(.33,-.28),
                              (.36,.05),(.23,.29),(-.05,.33),(-.27,.27))):
        px,pz=x+u*width,z+v*depth
        garden_prop(understory,"meadowGrass",(px,1.45,pz),.15+(i%3)*.028,33+i*47,
                    ("9BB75C","829B55","ABBD68")[i%3])
        if i%2==0:
            garden_prop(understory,"mossFlowers",(px+.29,1.49,pz-.21),.112,67+i*32,
                        "EDA3BC" if pink else "E4B4AB")
        else:
            garden_prop(understory,"meadowFlowers",(px-.28,1.50,pz+.16),.30,11+i*42,
                        "E8ADC0" if pink else "E5C38A")
    for u,v,bearing in ((-.29,.20,26),(.26,-.19,61)):
        garden_prop(understory,"bankRock",(x+u*width,1.44,z+v*depth),.17,bearing,"8E8189")
    for dx,dz,yaw in [(-.24,-.25,17),(.29,.17,21),(.24,-.27,150),(-.18,.25,110)]:
        px,pz=x+dx*width,z+dz*depth
        garden_prop(garden,"meadowCover",(px,1.44,pz),.19,yaw,"A0AE75")
        garden_prop(garden,"grassBlade",(px,1.45,pz+.45),.45,65+yaw,"B9A65C")
        garden_prop(garden,"meadowFlowers",(px+.39,1.49,pz),.43,yaw,"E39B9B" if pink else "FFCA85")

for x,z,direction,rock_scale in ((-9.8,-18.7,-1,.29),(17.1,-26.65,1,.29),(-33.4,20.6,-1,.24)):
    bank=item(foreground,"Model","Planted slate rock bank")
    prop(bank,"token","ModelStreamingMode",1)
    garden_shelf(bank,x,.67,z,4.8,3.43,.52,"95858D",SLATE,collide=False)
    turf_x=x+direction*.23
    garden_shelf(bank,turf_x,.85,z-.16,4.2,2.98,.21,"778746",GRASS_MAT,collide=False)
    for index in range(3):
        px=x+direction*(index-1)*1.42
        garden_prop(bank,"meadowCover",(px,.81,z+.25),.21,49*index,"91A35B")
        flower_x=turf_x+.90*(px+.34-turf_x)
        garden_prop(bank,"meadowFlowers",(flower_x,.84,z-.38),.44,71*index,"F0A7BC")
        if index!=1:
            garden_prop(bank,"bankRock",(px,.37,z+.87),rock_scale,53*index,"897C86")

relay_banks=item(foreground,"Model","Lantern lane stepped gardens")
prop(relay_banks,"token","ModelStreamingMode",1)
prop(relay_banks,"token","LevelOfDetail",4)
for x,z,angle in ((-31.6,18.3,-11),(-32.8,25.9,24)):
    shoreline_slate(relay_banks,x,z,.16,3.30,2.73,.47,angle,shadow=False)
    garden_shelf(relay_banks,x+.11,.76,z-.10,2.80,2.19,.24,"7A854C",GRASS_MAT,collide=False)
    garden_prop(relay_banks,"mossFlowers",(x-.48,.72,z+.43),.23,angle+57,"E9ACB0")
    garden_prop(relay_banks,"meadowCover",(x+.35,.71,z-.42),.27,angle+21,"9AAA63")
    garden_prop(relay_banks,"grassBlade",(x+.57,.73,z+.39),.44,angle+38,"C5AA64")
    store_standing_lantern(relay_banks,(x+.47,.75,z-.37),.53,light=False,paper_tint="FFC376")

directions=item(plaza,"Model","Plaza direction post")
prop(directions,"token","ModelStreamingMode",1)
direction_x,direction_z=-4.68,46.55
part(directions,"Direction post slate foot",(direction_x,.28,direction_z),(.91,.54,.83),
     "967E85",material=SLATE,collide=False)
part(directions,"Direction post cedar",(direction_x,1.86,direction_z),(.33,3.00,.39),
     "8B543D",material=WOOD_PLANK,collide=False)
part(directions,"Direction post cap",(direction_x,3.38,direction_z),(.50,.24,.48),
     "BA8751",collide=False)
for label,y,tint in (("DOJO RING  →",3.02,"883B33"),
                     ("TROPHY HALL  ↑",2.30,"735B3A"),
                     ("←  LANTERN RELAY",1.58,"734960")):
    sign(directions,label,direction_x+.18,y,direction_z+.16,3.5,.61,yaw=49,tint=tint)

spawn=part(workspace, "Grand Dojo Spawn", (1.10, .22, 62.95), (6, .4, 4.8), CREAM,
           transparency=1, class_name="SpawnLocation")
prop(spawn,"bool","Neutral",True)
prop(spawn,"int","Duration",0)

ring=item(scene,"Model","Fighting Ring")
prop(ring,"token","ModelStreamingMode",1)
ring_offset=5.2
ring_deck_lift=3.36
ring_rise=.92+ring_deck_lift
ring_floor=2.92+ring_rise
ring_forecourt_y=1.40
forecourt_lantern_lift=ring_forecourt_y-.98
part(ring,"Basalt arena foundation",(36,1.20+ring_deck_lift/2,5),
     (37,2.4+ring_deck_lift,31),"6D606E",material=SLATE)
deck=part(ring,"Cedar arena platform",(36,2.91+ring_deck_lift,5),
          (36.5,1.02,30.8),"75493F",material=WOOD_PLANK)
prop(deck,"string",MATERIAL_VARIANT_FIELD,ARENA_CEDAR)
part(ring,"Ring edge",(36,2.6+ring_rise,5),(36,.35,30),"A44A31")
part(ring,"Warm ring canvas",(36,ring_floor-.12,5),(32,.24,26),"E5BC7E")
cloth=part(ring,"Woven arena canvas",(36,ring_floor-.007,5),(31.98,.020,25.98),CANVAS_TINT,
           material=FABRIC,collide=False)
prop(cloth,"string",MATERIAL_VARIANT_FIELD,ARENA_WEAVE)
prop(cloth,"bool","CastShadow",False)
build_ring_canvas_detail(ring, center=(36,ring_floor,5),item=item,part=part,prop=prop,
                         triangle=triangle,fabric=FABRIC)
stair_count=12
stair_front,stair_back=30.12,19.93
stair_run=(stair_front-stair_back)/stair_count
stair_top_y=ring_floor-.18
stair_rise=(stair_top_y-ring_forecourt_y)/stair_count
stair_width, stair_taper=15.80,.39
ring_steps=item(ring,"Model","Fighting Ring entry stairs")
prop(ring_steps,"token","LevelOfDetail",4)
for step in range(stair_count):
    top=ring_forecourt_y+stair_rise*(step+1)
    front=stair_front-step*stair_run
    z=front-stair_run/2
    width=stair_width-step*stair_taper
    tread_tint=("BD9B90","B69588","C09C90")[(step//2)%3]
    tread=part(ring_steps,"Arena slate tread",(36,top/2,z),(width,top,stair_run+.035),tread_tint,material=SLATE)
    prop(tread,"string",MATERIAL_VARIANT_FIELD,PROMENADE_MORTAR)
    # Separate the thin nosing from the tread surface to avoid overlapping depth.
    nosing=part(ring_steps,"Sandstone stair nosing",(36,top-.054,front-.037),(width,.108,.195),
                ("DCB79B","D1AA8E")[(step//2)%2],material=LIMESTONE,collide=False)
    prop(nosing,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
    prop(nosing,"bool","CastShadow",False)
    breaks=(-.50,-.20,.15,.50) if step%2==0 else (-.50,-.33,.03,.30,.50)
    for column,(left,right) in enumerate(zip(breaks,breaks[1:])):
        face=part(ring_steps,"Slate stair riser facing",(36+width*(left+right)/2,top-.219,front+.038),
                  (width*(right-left)-.040,.212,.052),
                  ("947B7E","987C7A","9A807F","8D7678")[(step//2+column)%4],material=SLATE,collide=False)
        prop(face,"bool","CastShadow",False)
        prop(face,"string",MATERIAL_VARIANT_FIELD,PROMENADE_MORTAR)
stair_dressing=item(ring_steps,"Model","Ring stair masonry")
build_ring_stone_cheeks(stair_dressing,center=36,front=stair_front,back=stair_back,
                       widths=(stair_width,stair_width-(stair_count-1)*stair_taper),
                       start_y=ring_forecourt_y+.42,end_y=stair_top_y+.12,
                       item=item,prop=prop,triangle=triangle,slate=SLATE,limestone=LIMESTONE,
                       stone_variant=PROMENADE_MORTAR,cap_variant=PROMENADE_STONE,
                       variant_field=MATERIAL_VARIANT_FIELD)
for side in (-1,1):
    plinth_x=36+side*9.73
    part(ring_steps,"Stair lantern plinth",(plinth_x,1.11+forecourt_lantern_lift,29.93),
         (1.62,1.62,1.75),"846F7A",material=SLATE)
    build_ring_stair_lantern_plinth(stair_dressing,plinth_x,29.93,item=item,part=part,prop=prop,
                                   slate=SLATE,limestone=LIMESTONE,stone_variant=PROMENADE_STONE,
                                   variant_field=MATERIAL_VARIANT_FIELD,floor_lift=forecourt_lantern_lift)
    lamp_scale=.87 if side<0 else .97
    lamp_y=2.01+lamp_scale*1.19+forecourt_lantern_lift
    build_ring_paper_lantern(ring_steps,plinth_x,lamp_y,29.93,lamp_scale*1.075,
                            item=item,part=part,prop=prop,neon=NEON,wood=WOOD_PLANK,metal=METAL,
                            lantern_light=lantern_light,light_profile=(.98,11.3),standing=True)
    x=36+side*11.77
    part(ring,"Gold ring deck edging",(x,3.43+ring_deck_lift,20.46),(13.05,.13,.16),"BC8C57",collide=False)
    for i in range(4):
        px=x+(i-1.5)*3.28
        part(ring,"Dressed ring foundation block",(px,.67,20.58),(3.13,1.12,.31),
             ("847481","7B6C79","90818B","7D6E7B")[i],material=SLATE,collide=False)
    planter_x=36+side*11.20
    garden_shelf(ring,planter_x,.52,26.32,5.90,3.17,.49,"8F7D82",SLATE,collide=False)
    garden_shelf(ring,planter_x+side*.19,.66,26.47,5.18,2.67,.20,"74834D",GRASS_MAT,collide=False)
    garden_prop(ring,"meadowGrass",(planter_x,.66,26.31),.19,32*side,"A0A65C")
    garden_prop(ring,"mossFlowers",(planter_x+side*.28,.67,26.77),.19,38,"F0ABBC")
    garden_prop(ring,"bankRock",(planter_x+side*1.47,.49,26.14),.27,52*side,"97858B")
    garden_prop(ring,"meadowCover",(planter_x+side*1.21,.67,26.63),.17,-34*side,"9BAB69")
    garden_prop(ring,"meadowFlowers",(planter_x-side*1.19,.66,26.32),.40,41*side,"F1BBA7")
    garden_prop(ring,"grassBlade",(planter_x+side*.99,.64,25.57),.44,76*side,"D6BC7F")
for piece in stair_dressing.findall("Item"):
    prop(piece,"bool","CastShadow",False)
post_corners=[(20,18),(52,18),(52,-8),(20,-8)]
for x,z in post_corners:
    part(ring,"Corner post",(x,5.2+ring_rise,z),(1.13,4.5,1.13),DARK)
    part(ring,"Corner pad",(x,5.6+ring_rise,z),(1.4,2.65,1.4),"A94331")
    lamp(ring,x,8.05+ring_rise,z,scale=.65,light=True)
for x in (30,42):
    part(ring,"Rope entrance post",(x,4.56+ring_rise,18),(.62,3.30,.62),"743A34",collide=False)
    part(ring,"Rope post tip",(x,6.25+ring_rise,18),(.73,.22,.73),"E0A44F",collide=False)
    part(ring,"Rope post iron shoe",(x,3.07+ring_rise,18),(.85,.32,.85),"53414B",collide=False)
rope_courses=tuple((height+ring_rise,tint,thickness) for height,tint,thickness in (
    (3.80,"B35146",.25),(4.80,"D85F4D",.28),(5.80,"EB7255",.30)
))
for x,z in post_corners+[(30,18),(42,18)]:
    width=.76 if x in (30,42) else 1.48
    for y,_,_ in rope_courses:
        part(ring,"Rope binding",(x,y,z),(width,.14,width),"D18A45",collide=False)
round_ropes=item(ring,"Model","Red ring ropes")
for start,end in (((20,18),(30,18)),((42,18),(52,18)),
                  ((52,18),(52,-8)),((52,-8),(20,-8)),((20,-8),(20,18))):
    length=dist(start,end)
    sections=max(4,round(length/3.8))
    sag=min(.26,length*.013)
    for y,tint,thickness in rope_courses:
        samples=[(start[0]+(end[0]-start[0])*t,y-4*sag*t*(1-t),start[1]+(end[1]-start[1])*t)
                 for t in (index/sections for index in range(sections+1))]
        for a,b in zip(samples,samples[1:]):
            dx,dy,dz=(q-p for p,q in zip(a,b))
            rope=part(round_ropes,"Red practice rope",tuple((p+q)/2 for p,q in zip(a,b)),
                      (dist(a,b)+.036,thickness,thickness),tint,shape=2,
                      yaw=degrees(atan2(dx,dz))-90,roll=degrees(atan2(dy,hypot(dx,dz))),
                      material=FABRIC,collide=False)
            prop(rope,"bool","CastShadow",False)
ring_front_z=28.15
portal_rise=3.45

marquee=item(ring,"Model","Fighting Ring arrival marquee")
prop(marquee,"token","LevelOfDetail",4)
marquee_z=ring_front_z+1.46
ring_marquee_span=18.95

def ring_marquee_height(offset):
    return 12.72+portal_rise+2.52*(1-(offset/ring_marquee_span)**2)

ring_profile=[(offset,ring_marquee_height(offset)) for offset in
              (-ring_marquee_span,-16,-13,-10,-7,-3.5,0,3.5,7,10,13,16,ring_marquee_span)]
# The cedar lintel spans both piers and conceals the old lettering cast into the gateway mesh.
part(marquee,"Recessed cedar lintel",(36,12.71+portal_rise,ring_front_z+.91),
     (32.9,1.91,.34),"643830",material=WOOD_PLANK,collide=False)
part(marquee,"Cedar lintel chamfer",(36,11.80+portal_rise,ring_front_z+1.04),
     (32.9,.17,.23),"784633",material=WOOD_PLANK,collide=False)
curved_plaque(marquee,36,marquee_z,ring_profile,5.04,"AA2E25","FFB950",rim_height=.31,rim_depth=.43)
for (a,low),(b,high) in zip(ring_profile,ring_profile[1:]):
    mid=(a+b)/2
    y=(low+high)/2+2.78
    angle=degrees(atan2(high-low,b-a))
    roof_panel(marquee,"Glazed indigo marquee roof",(36+mid,y,marquee_z-.19),
               (hypot(b-a,high-low)+.17,.56,2.07),"384E84",roll=angle)
    roof_barrel(marquee,"Marquee tile crest",(36+mid,y+.29,marquee_z-.18),
                2.18,.30,"5572A6")
    part(marquee,"Roof tile bronze seam",(36+mid,y+.14,marquee_z+.68),
         (.21,.57,.28),"B8844B",roll=angle,collide=False)
for side in (-1,1):
    offset=side*16.62
    reed_mark(marquee,36+offset,ring_marquee_height(offset)-.23,marquee_z+.42,1.18)
    x=36+side*18.72
    y=ring_marquee_height(side*18.72)+2.65
    part(marquee,"Marquee upward endcap",(x,y,marquee_z-.13),(2.45,.46,2.08),
         "444568",roll=side*19,collide=False)
    part(marquee,"Cast gold endcap tip",(x+side*.92,y+.38,marquee_z-.12),(.66,.51,2.14),
         "D6A054",roll=side*19,collide=False)
    beam(marquee,"Marquee timber brace",(36+side*15.79,11.52+portal_rise,ring_front_z+.55),
         (36+side*13.02,12.67+portal_rise,marquee_z-.16),.54,"995337")

marquee_title(marquee,"DOJO RING",36,marquee_z,ring_profile,4.65)
sign(marquee,"Combat to Earn Rewards",36,portal_rise+11.52,marquee_z+.13,10.2,.93,
     tint="62332B",single_line=True)

def ring_entry_pier(parent,x,z,side):
    """Frame the stairs with slate and lacquer in both gateway modes."""
    pier=item(parent,"Model","Ring entry pier")
    # The plinths stand outside the stair and forecourt walking envelopes.
    for label,y,size in (("Ring entry slate podium",1.28,(4.08,2.56,3.42)),
                         ("Ring entry podium cap",2.48,(4.24,.28,3.59))):
        part(pier,label,(x,y,z),size,"72636F",material=SLATE,transparency=1)

    outline=((-1,-.74),(-.75,-1),(.75,-1),(1,-.74),(1,.74),(.75,1),(-.75,1),(-1,.74))
    bands=[]
    for height,half_width,half_depth in ((.10,2.54,2.38),(.46,2.44,2.29),(2.34,2.26,2.06)):
        bands.append([(x+u*half_width,height,z+.20+v*half_depth) for u,v in outline])
    shades=("82747F","746671","827681","72646E","8D7C86","9B8890","A59096","8F7D83")
    for course,(lower,upper) in enumerate(zip(bands,bands[1:])):
        for index,a in enumerate(lower):
            j=(index+1)%len(outline)
            shade=shades[index] if course else "6C606D"
            triangle(pier,a,lower[j],upper[index],shade,name="Beveled portal slate",material=SLATE,thickness=.14)
            triangle(pier,upper[index],lower[j],upper[j],shade,name="Beveled portal slate",material=SLATE,thickness=.14)

    for label,y,size,tint,material in (
        ("Slate rim under cap",2.30,(4.59,.19,4.24),"6F616B",SLATE),
        ("Honed sandstone cap",2.48,(4.70,.27,4.35),"AD9693",LIMESTONE),
        ("Lacquer plinth shoe",2.77,(3.38,.30,3.18),"64342C",WOOD_PLANK),
        ("Portal cedar column",7.16+portal_rise/2,(2.60,8.52+portal_rise,2.40),"B34430",WOOD_PLANK),
        ("Lacquer face panel",7.18+portal_rise/2,(1.76,7.38+portal_rise,.20),"CD5337",WOOD_PLANK),
        ("Portal foot collar",3.22,(2.99,.24,2.78),"E3A848",METAL),
        ("Portal upper collar",10.55+portal_rise,(2.94,.25,2.72),"DFA049",METAL),
        ("Lower corbel tier",10.90+portal_rise,(3.24,.40,2.86),"773728",WOOD_PLANK),
        ("Upper corbel tier",11.24+portal_rise,(3.95,.34,3.13),"9A472E",WOOD_PLANK),
    ):
        front=1.46 if label=="Lacquer face panel" else .24
        part(pier,label,(x,y,z+front),size,tint,material=material,collide=False)
    for direction in (-1,1):
        part(pier,"Inset cedar edge",(x+direction*1.09,7.04+portal_rise/2,z+1.49),(.13,7.25+portal_rise,.13),
             "743729",material=WOOD_PLANK,collide=False)
        part(pier,"Portal collar gold face",(x+direction*.92,3.22,z+1.65),(.37,.23,.15),
             "E2AC5D",material=METAL,collide=False)
    beam(pier,"Cedar corbel brace",(x-side*.93,10.16+portal_rise,z+.69),(x-side*2.72,11.96+portal_rise,z+.78),.63,"89442E")
    beam(pier,"Bronze corbel inlay",(x-side*1.03,10.40+portal_rise,z+1.07),(x-side*2.61,11.91+portal_rise,z+1.13),.12,"D59C51")
    build_ring_gate_standard(pier,x+side*1.41,z+2.03,column_x=x,
                             item=item,part=part,prop=prop,beam=beam,triangle=triangle,
                             fabric=FABRIC,wood=WOOD_PLANK,brass=METAL,
                             fabric_variant=ARENA_WEAVE,variant_field=MATERIAL_VARIANT_FIELD,
                             height_gain=portal_rise)
    banner(pier,x,1.33,z+2.51,scale=.51,vermilion=True)


for side in (-1,1):
    x=36+side*15.79
    ring_entry_pier(ring,x,ring_front_z,side)
    anchor=x-side*2.92
    beam(ring,"Entrance bronze lantern bracket",(anchor,12.10+portal_rise,ring_front_z+.52),
         (anchor,11.24+portal_rise,ring_front_z+1.92),.20,"A46C43")
    arrival_hanging_lantern(ring,anchor,9.83+portal_rise,ring_front_z+1.91,1.72,entrance_paper=True)
canopy=item(ring,"Model","Grand Dojo ring canopy")
prop(canopy,"token","LevelOfDetail",4)
canopy_lift=4.60
for side in (-1,1):
    x=52.7 if side>0 else 17.85
    for z in (-10.1,22.8):
        part(canopy,"Stacked pavilion footing",(x,1.45,z),(3.15,2.9,3.18),"7C6870",material=SLATE)
        part(canopy,"Lacquered pavilion pillar",(x,8.66+canopy_lift/2,z),(2.06,11.7+canopy_lift,2.06),
             "A94D32",material=WOOD_PLANK)
        part(canopy,"Pillar inset panel",(x,8.57+canopy_lift/2,z+1.06),(1.18,8.17+canopy_lift,.13),
             "B65B38",material=WOOD_PLANK,collide=False)
        for face in (-1,1):
            part(canopy,"Pavilion pillar gilded edge",(x+face*.76,8.61+canopy_lift/2,z+1.14),
                 (.10,7.95+canopy_lift,.10),"BE8755",collide=False)
        for y in (3.25,4.02,12.6+canopy_lift):
            part(canopy,"Antique brass collar",(x,y,z),(2.23,.29,2.23),"C58A49",collide=False)
        for i in range(3):
            width=2.31+i*.61
            part(canopy,"Stacked cedar bracket",(x,12.90+canopy_lift+i*.55,z),(width,.66,width*.82),
                 ("75362B","B45433","773C30")[i],collide=False)
        brace_z = z+2.9 if z<0 else z-2.9
        beam(canopy,"Cedar knee brace",(x,11.28+canopy_lift,z),(x,13.69+canopy_lift,brace_z),.74,"8F4C34")
        inside_x=x-side*3.95
        beam(canopy,"Transverse pavilion brace",(x,11.23+canopy_lift,z+.15),
             (inside_x,13.77+canopy_lift,z+.15),.69,"8C4632")
        beam(canopy,"Pavilion brace brass inlay",(x-side*.77,11.81+canopy_lift,z+.53),
             (inside_x+side*.32,13.54+canopy_lift,z+.53),.105,"C79354")
    beam(canopy,"Canopy side sill",(x,13.74+canopy_lift,-11.4),(x,13.74+canopy_lift,24.3),.87,"9C4C33")
cross_ties=(-5.1,1.1,7.4,13.7,20.1)
purlins=(22.75,29.01,35.28,41.55,47.81)
purlin_height=14.87+canopy_lift
for z in cross_ties:
    part(canopy,"Cedar ceiling cross tie",(35.28,14.53+canopy_lift,z),(35.8,.58,.65),
         "834630",material=WOOD_PLANK,collide=False)
for x in purlins:
    beam(canopy,"Cedar ceiling purlin",(x,purlin_height,-10.12),
         (x,purlin_height,22.75),.43,"784230")
build_ring_ceiling_panels(canopy,purlins=purlins,cross_ties=cross_ties,height=purlin_height,item=item,
                          part=part,prop=prop,wood=WOOD_PLANK,
                          variant_field=MATERIAL_VARIANT_FIELD,cedar_variant=LANDMARK_CEDAR)
for z in (-10.1,22.8):
    part(canopy,"Crossed cedar roof beam",(35.28,13.85+canopy_lift,z),(37.0,.80,1.25),"9E482F",collide=False)
    part(canopy,"Gold canopy fascia",(35.28,14.44+canopy_lift,z),(37.2,.23,1.40),"CF994F",collide=False)
    for x in (20.1,25.4,30.7,36.0,41.3,46.6,51.9):
        part(canopy,"Eave crossbeam end",(x,14.79+canopy_lift,z),(.64,.49,2.26),
             "9C5D43",material=WOOD_PLANK,collide=False)
        front=1 if z>0 else -1
        part(canopy,"Eave beam end bronze shoe",(x,14.79+canopy_lift,z+front*1.14),
             (.48,.27,.13),"CB9452",material=METAL,collide=False)
    for index,x in enumerate((23.3,30,36,42,48.7)):
        lamp_y=13.33
        beam(canopy,"Lantern hook",(x,lamp_y+.71,z),(x,13.66+canopy_lift,z),.14,DARK)
        lantern_scale=(.72,1.04,1.14,1.04,.72)[index] if z>0 else .74
        build_ring_paper_lantern(canopy,x,lamp_y,z,lantern_scale,
                                item=item,part=part,prop=prop,neon=NEON,wood=WOOD_PLANK,metal=METAL,
                                lantern_light=lantern_light,light_profile=(1.08,11.55) if z>0 else None)
for x,y,scale in ((26.65,13.83,1.02),(36,15.04,1.05),(45.35,13.83,1.02)):
    rear_z=-10.61
    for side in (-1,1):
        hanger_x=x+side*.94*scale
        hook=beam(canopy,"Rear pennant hanger",(hanger_x,13.95+canopy_lift,-10.37),
                  (hanger_x,y+2.08*scale,rear_z),.10,"94603B")
        prop(hook,"bool","CastShadow",False)
    banner(canopy,x,y,rear_z,scale=scale,vermilion=True)
# Keep the east roof edge over the gallery and stop the west tiles above the
# pillar's inset face. This opens the Reedfall view behind the canopy.
swept_roof(canopy,38.35,15.04+canopy_lift,6.2,38.9,39,7.35,signature=True)
# Both fixtures share the nearby-lantern budget and cast no shadows.
threshold_light(canopy,38.40,13.60,19.10,reach=18.5,spread=88,brightness=1.72,tint="FFD4A0",yaw=-29,pitch=43)
mat_mount=part(canopy,"Concealed mat lantern mount",(36.80,16.85,8.5),(13.2,.2,6.6),
               CREAM,collide=False,transparency=1)
prop(mat_mount,"bool","CastShadow",False)
mat_light=item(mat_mount,"SurfaceLight","Amber threshold light")
color(mat_light,"Color","FFDDB7")
prop(mat_light,"token","Face",4)
prop(mat_light,"float","Range",15.5)
prop(mat_light,"float","Angle",90)
prop(mat_light,"float","Brightness",.80)
prop(mat_light,"bool","Enabled",False)
prop(mat_light,"bool","Shadows",False)
for x in (23,49):
    apron=item(ring,"Model","Ring front pennant")
    front=20.86
    part(apron,"Ring pennant cloth",(x,2.20,front),(3.04,2.66,.16),"A84434",
         material=FABRIC,collide=False)
    triangle(apron,(x-1.52,.89,front),(x+1.52,.89,front),(x,.23,front),"A84434",
             name="Ring pennant point",material=FABRIC,thickness=.16)
    for side in (-1,1):
        px=x+side*1.42
        beam(apron,"Ring pennant gilt piping",(px,3.38,front+.10),(px,.92,front+.10),.065,"DDA258")
        beam(apron,"Ring pennant gilt piping",(px,.92,front+.10),(x,.32,front+.10),.065,"DDA258")
    beam(apron,"Ring pennant cedar rod",(x-1.76,3.53,front),(x+1.76,3.53,front),.17,"6E4438")
    reed_mark(apron,x,2.01,front+.105,.89)
    raise_geometry(apron,ring_deck_lift*.71)
target=item(ring,"Model","Practice Target")
part(target,"Target stand",(36,3.15+ring_rise,-.5),(3.2,.5,3.2),DARK)
part(target,"Target post",(36,4.52+ring_rise,-.5),(.62,2.45,.62),WOOD)
part(target,"Target pad",(36,5.5+ring_rise,-.3),(2.7,2.9,2.4),"B87644",shape=0)
part(target,"Target stripe",(36,5.5+ring_rise,.96),(1.65,.28,.14),RED,collide=False)
hit=part(target,"TargetPrompt",(36,4.75+ring_rise,1.35),(1,1,1),CREAM,transparency=1,collide=False)
prompt=item(hit,"ProximityPrompt","PracticePrompt")
prop(prompt,"string","ActionText","Strike target")
prop(prompt,"string","ObjectText","Ring practice")
prop(prompt,"float","MaxActivationDistance",7)
prop(prompt,"bool","RequiresLineOfSight",False)
spar=item(ring,"Model","Bot Spar Corner")
spar_x,spar_z,spar_width,spar_depth=27.5,5,11.2,22
part(spar,"Sparring Bounds",(spar_x,ring_floor+3,spar_z),(spar_width,6,spar_depth),
     CREAM,transparency=1,collide=False)
for side in (-1,1):
    part(spar,"Stitched side line",(spar_x+side*spar_width/2,ring_floor+.032,spar_z),
         (.11,.025,spar_depth),"755044",collide=False)
    part(spar,"Stitched end line",(spar_x,ring_floor+.032,spar_z+side*spar_depth/2),
         (spar_width,.025,.11),"755044",collide=False)
for name,z,tint in (("Player corner",12,"9A4640"),("Bot corner",-2.2,"397569")):
    part(spar,name,(spar_x,ring_floor+.031,z),(3.4,.034,1.25),tint,collide=False)
for x in (22.7,26.9):
    part(spar,"Spar board post",(x,ring_floor+1.12,14.1),(.24,2.24,.30),WOOD,collide=False)
sign(spar,"BOT SPAR",24.8,ring_floor+2.18,14.16,5.2,1.3,tint="325B51")
spar_gate=part(spar,"Sparring Gate",(28.5,ring_floor+2,14.1),(1,1,1),CREAM,
          transparency=1,collide=False)
prompt=item(spar_gate,"ProximityPrompt","SparPrompt")
prop(prompt,"string","ActionText","Start bot spar")
prop(prompt,"string","ObjectText","Juniper Tortoise")
prop(prompt,"float","MaxActivationDistance",6)
prop(prompt,"bool","RequiresLineOfSight",False)
for transform in ring.iter("CoordinateFrame"):
    x=transform.find("X")
    x.text=f"{float(x.text)+ring_offset:.7g}"


def trophy_hall_wing_frontage(parent, side):
    x=side*20.85
    front=-35.36
    eave=15.79
    bay=item(parent,"Model","Trophy Hall lantern wing")
    prop(bay,"token","LevelOfDetail",4)
    swept_roof(bay,x,11.05,-47.14,14.7,17.50,2.58,fine_tiles=False)
    build_hall_wing_eave(bay,x,eave,item=item,prop=prop,part=part,
                        beam=beam,swept_roof=swept_roof,lantern_window=lantern_window,
                        cedar=WOOD_PLANK,brass=METAL,variant_field=MATERIAL_VARIANT_FIELD,
                        wood_variant=LANDMARK_CEDAR,brass_variant=ORNAMENT_BRASS)
    part(bay,"Upper wing rear gable",(x,13.97,-39.44),(12.92,3.51,.54),
         "873D31",material=WOOD_PLANK,collide=False)
    part(bay,"Window bay stone base",(x,-.11,front-1.28),(12.9,1.70,2.95),
         "97818A",material=SLATE,collide=False)
    part(bay,"Window bay limestone cap",(x,.84,front-1.28),(13.12,.35,3.10),
         "B1978C",material=LIMESTONE,collide=False)
    part(bay,"Window bay vermilion wall",(x,8.26,front-.54),(12.92,14.26,.72),
         "A85036",collide=False)
    for offset in (-6.25,0,6.25):
        px=x+offset
        part(bay,"Window bay cedar post",(px,8.56,front-.07),(.73,14.96,.88),
             "963D2F",material=WOOD_PLANK,collide=False)
        for y in (1.37,8.57,10.42,14.63):
            part(bay,"Window bay brass collar",(px,y,front-.05),(.87,.20,.98),
                 "C58745",collide=False)
    for offset in (-3.16,3.16):
        px=x+offset
        lantern_window(bay,px,4.87,front+.28,4.16,5.97)
        part(bay,"Window bay cedar sill",(px,1.75,front+.51),(4.74,.32,.73),
             "88422E",material=WOOD_PLANK,collide=False)
        part(bay,"Window bay upper panel",(px,9.09,front+.03),(4.52,1.24,.27),
             "BD754D",collide=False)
        lantern_window(bay,px,12.40,front+.20,4.28,2.42,glow=False)
        part(bay,"Window bay transom gilt sill",(px,11.02,front+.37),(4.66,.19,.50),
             "BF8750",collide=False)
    for y,width,height,tint in ((8.13,12.57,.48,"783E31"),(10.32,13.08,.46,"793926"),
                               (14.22,14.15,.46,"793926"),(14.72,14.57,.29,"CD9457"),
                               (15.20,15.38,.46,"89442D")):
        part(bay,"Window bay cornice",(x,y,front+.07),(width,height,.93),tint,collide=False)
    part(bay,"Window bay eave tie",(x,15.55,-30.61),(17.95,.49,.67),"9B542F",
         material=WOOD_PLANK,collide=False)
    for offset in (-6.19,-3.10,0,3.10,6.19):
        beam(bay,"Window bay carved bracket",(x+offset,13.94,front+.27),
             (x+offset,15.45,-30.64),.52,"9A4D31")
        part(bay,"Window bay gilded bracket tip",(x+offset,15.34,-30.36),
             (.60,.33,.15),"D1A468",collide=False)
    outer=x+side*6.22
    banner(bay,outer,6.25,front+.69,scale=.92)
    festival_lantern(bay,x-side*5.2,8.70,front+1.08,.73,light=False,tint="F8B268")
    for y,tint,length in ((1.53,"967883",3.45),(.41,"827580",4.15)):
        garden_shelf(bay,outer+side*.49,y-2.64,front+.95,3.25,length,.98,tint,SLATE,collide=False)
    garden_prop(bay,"bankRock",(outer+side*.61,-1.18,front+1.01),.29,47*side,"A18B92")
    garden_prop(bay,"meadowCover",(outer+side*.25,-1.10,front+1.11),.15,38*side,"AEB36D")
    garden_prop(bay,"mossFlowers",(outer+side*.42,-1.08,front+1.74),.15,79*side,"F8B7CC")
    garden_prop(bay,"meadowFlowers",(outer+side*.80,-1.05,front+1.33),.25,54*side,"F6BD94")


hall=item(scene,"Model","Trophy Hall")
prop(hall,"token","ModelStreamingMode",1)
house(hall,0,-44,31,22,11.84,pedestal=.55,with_roof=False)
for side in (-1,1):
    x=side*20.85
    wing=item(hall,"Model","Hall side pavilion")
    house(wing,x,-46.8,10.8,14.4,8.75,pedestal=.55,with_roof=False)
    part(wing,"Pavilion stone terrace",(x,-.82,-46.8),(11.5,1.64,14.9),"7D6A76",material=SLATE)
    trophy_hall_wing_frontage(wing,side)
for x in (-8,0,8):
    part(hall,"Display plinth base",(x,1.18,-47),(4.1,.55,4.1),STONE)
    part(hall,"Display plinth",(x,2.18,-47),(3.3,1.6,3.3),DARK,material=WOOD_PLANK)
    part(hall,"Brass plinth rim",(x,3.04,-47),(3.6,.22,3.6),GOLD)
    sign(hall,"LANTERN KEEPER" if x==0 else "COMING SOON",x,2.44,-45.23,3.28,.62)
hall_marker=part(hall,"HallPrompt",(0,3.25,-44),(1,1,1),CREAM,transparency=1,collide=False)
hall_prompt=item(hall_marker,"ProximityPrompt","TrophyPrompt")
prop(hall_prompt,"string","ActionText","Inspect trophy")
prop(hall_prompt,"string","ObjectText","Lantern Keeper")
prop(hall_prompt,"float","MaxActivationDistance",10)
prop(hall_prompt,"bool","RequiresLineOfSight",False)
facade=item(hall,"Model","Crowned gallery")
prop(facade,"token","LevelOfDetail",4)
swept_roof(facade,0,13.11,-44,43.2,29.8,4.38,signature=True)
crown_delta=7.90
hall_crown_lift=6.55+crown_delta
part(facade,"Gallery side walls",(0,19.88+hall_crown_lift/2,-44),(29.6,10.05+hall_crown_lift,17.35),
     "AD5236",collide=False)
part(facade,"Gallery stone terrace",(0,15.22,-44),(32.0,.74,20.1),"67464A",collide=False)
for x in (-14.62,14.62):
    part(facade,"Gallery cedar column",(x,19.91+hall_crown_lift/2,-34.85),(1.52,10.24+hall_crown_lift,1.15),
         "9C412F",material=WOOD_PLANK,collide=False)
    trim=part(facade,"Gallery gold trim",(x,19.70+hall_crown_lift/2,-34.23),(.16,8.58+hall_crown_lift,.13),
              "C99146",material=METAL,collide=False)
    prop(trim,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
for x in (-12.02,12.02):
    lantern_window(facade,x,22.13,-35.13,3.86,8.16)
    lantern_window(facade,x,28.07+crown_delta,-35.14,3.79,2.83)
    part(facade,"Gallery lintel collar",(x,29.95+crown_delta,-34.83),(4.78,.68,.98),"AC5937",collide=False)
    for y in (18.16,26.58):
        part(facade,"Gallery window lintel",(x,y,-34.63),(4.76,.31,.55),"8A4B39",
             material=WOOD_PLANK,collide=False)
clerestory=item(facade,"Model","Trophy Hall upper lantern windows")
part(clerestory,"Clerestory cedar fascia",(0,28.04+crown_delta,-35.04),(20.65,3.02,.48),
     "703B32",material=WOOD_PLANK,collide=False)
for x in (-7.72,-3.86,0,3.86,7.72):
    lantern_window(clerestory,x,28.12+crown_delta,-34.91,2.65,2.17,tint="D9924E")
    part(clerestory,"Clerestory brass sill",(x,26.91+crown_delta,-34.50),(3.13,.18,.55),
         "C98743",material=METAL,collide=False)
part(clerestory,"Clerestory red cedar beam",(0,29.62+crown_delta,-34.75),(21.16,.48,.74),
     "9D4C33",material=WOOD_PLANK,collide=False)
build_hall_upper_bays(facade,item=item,prop=prop,part=part,beam=beam,cedar=WOOD_PLANK,
                      clay=CLAY_ROOF,brass=METAL,neon=NEON,variant_field=MATERIAL_VARIANT_FIELD,
                      tile_variant=INDIGO_TILE,brass_variant=ORNAMENT_BRASS)
for y,width,height,tint in ((30.77,33.6,.72,"8F4333"),(31.23,34.2,.39,"C79553"),(31.61,35.1,.53,"793B2F")):
    part(facade,"Gallery cornice",(0,y+crown_delta,-34.85),(width,height,1.25),tint,collide=False)
for x in (-13.25,-8.82,-4.41,0,4.41,8.82,13.25):
    beam(facade,"Carved cornice bracket",(x,30.55+crown_delta,-34.21),
         (x,31.60+crown_delta,-30.92),.47,"A45735")
    part(facade,"Cornice bracket brass end",(x,31.48+crown_delta,-30.78),(.52,.32,.21),
         "BB7D47",material=METAL,collide=False)
build_hall_crown_roof(facade,25.07+hall_crown_lift,item=item,prop=prop,part=part,
                      triangle=triangle,clay=CLAY_ROOF,brass=METAL,
                      variant_field=MATERIAL_VARIANT_FIELD,tile_variant=INDIGO_TILE,brass_variant=ORNAMENT_BRASS)

marquee=item(facade,"Model","Swept Trophy Hall marquee")
plaque_profile=((-16,13.89),(-13.0,14.70),(-8.0,15.33),(0,15.71),
                (8.0,15.33),(13.0,14.70),(16,13.89))
curved_plaque(marquee,0,-25.76,plaque_profile,4.86,"9D382D","F3B249",rim_height=.24)
marquee_title(marquee,"TROPHY HALL",0,-25.76,plaque_profile,3.69)
for side in (-1,1):
    x=side*18.0
    beam(facade,"Forecourt standard bracket",(x,15.48,-30.67),(x,13.91,-28.80),.25,"9C6542")
    banner(facade,x,11.13,-28.80,scale=1.31,vermilion=True)
for side in (-1,1):
    x=side*6.0
    part(facade,"Porch lantern pier",(x,4.63,-31.93),(.66,7.33,.76),"BC5033",collide=False)
    for y in (1.23,7.84):
        part(facade,"Porch brass collar",(x,y,-31.92),(.82,.24,.88),"C89855",collide=False)
    beam(facade,"Bronze entrance bracket",(x,7.13,-31.75),(side*4.87,8.60,-31.75),.27,"C18648")
    lamp(facade,side*6.79,7.63,-31.26,scale=.85,light=True,warm_pool=True)
    lantern_window(facade,side*6.78,5.28,-32.52,2.31,7.57,tint="FFD095")
threshold_light(facade,0,9.06,-30.78,reach=14,spread=104,brightness=1.56,tint="FFC889")
for x in (-13.25,13.25):
    lantern_window(facade,x,6.31,-32.59,3.34,6.31)
    part(facade,"Hall lantern fascia",(x,10.22,-31.0),(4.35,.49,.66),"A25934",collide=False)
    lamp(facade,x,8.22,-30.98,scale=.95,light=True)
for x in (-9.6,9.6):
    banner(hall,x,6.1,-32.35,scale=1.19,vermilion=True)
crest=item(facade,"Folder","Trophy Hall cup crest")
crest_outline=((-7.65,16.61),(-7.65,22.35),(-4.64,23.68),(0,24.18),
               (4.64,23.68),(7.65,22.35),(7.65,16.61))
for factor,z,tint,thickness in ((1,-33.56,"F2A940",.40),(.94,-33.30,"9C3028",.26)):
    edge=[(x*factor,20.4+(y-20.4)*factor,z) for x,y in crest_outline]
    for left,right in zip(edge,edge[1:]+edge[:1]):
        triangle(crest,(0,20.4,z),left,right,tint,name="Arched cup plaque",thickness=thickness)
for side in (-1,1):
    reed_mark(crest,side*5.22,18.67,-32.98,1.33)
# Enlarge the complete emblem about its center so the facets and handles stay aligned.
crest_scale=1.49
for transform in crest.iter("CoordinateFrame"):
    for axis,old_center,new_center in (("X",0,0),("Y",20.4,23.05),("Z",-33.56,-32.74)):
        center=transform.find(axis)
        center.text=f"{new_center+(float(center.text)-old_center)*crest_scale:.7g}"
for size in crest.iterfind(".//Vector3[@name='size']"):
    for extent in size:
        extent.text=f"{float(extent.text)*crest_scale:.7g}"
build_hall_cup_relief(crest,item=item,prop=prop,part=part,vector=vector,asset=asset,metal=METAL,
                      variant_field=MATERIAL_VARIANT_FIELD,brass_variant=ORNAMENT_BRASS)
part(hall,"Trophy backdrop",(0,4.9,-52.91),(7.1,6.05,.14),"812D2C",material=FABRIC,collide=False)
reed_mark(hall,0,5.31,-52.79,1.55)
for x in (-7.4,7.4):
    lamp(hall,x,6.85,-47,scale=1,light=True)
part(hall,"LanternTrophyMount",(0,4.51,-47),(.2,.2,.2),CREAM,transparency=1,collide=False)
raise_geometry(hall,2.64)


def hall_viewing_gallery(parent):
    gallery=item(parent,"Model","Trophy Hall viewing gallery")
    prop(gallery,"token","LevelOfDetail",4)
    entry_y,upper_y=3.61,10.17
    stairs_x,stairs_z=-12.43,-36.10
    tread,steps=.97,16
    stair_width=3.55
    for index in range(steps):
        y=entry_y+(upper_y-entry_y)*(index+1)/steps
        z=stairs_z-index*tread
        part(gallery,"Viewing gallery tread",(stairs_x,(entry_y+y)/2,z),
             (stair_width,y-entry_y,tread+.038),"A6795E",material=WOOD_PLANK)
        part(gallery,"Dark cedar stair nosing",(stairs_x,y-.095,z+.475),
             (stair_width+.040,.124,.16),"774939",collide=False,material=WOOD_PLANK)
    for side in (-1,1):
        x=stairs_x+side*(stair_width/2-.09)
        for lift in (.56,1.32):
            beam(gallery,"Gallery stair railing",(x,entry_y+lift+.22,stairs_z+.40),
                 (x,upper_y+lift,stairs_z-(steps-1)*tread),.205,"844E3F",collide=True)
        for step in (0,4,8,12,15):
            y=entry_y+(upper_y-entry_y)*(step+1)/steps
            z=stairs_z-step*tread
            part(gallery,"Cedar stair newel",(x,y+.61,z),(.28,1.32,.29),"6E443B",collide=False)
            part(gallery,"Gallery newel brass cap",(x,y+1.28,z),(.43,.13,.43),"B88449",collide=False)
    part(gallery,"Rear gallery walk",(0,upper_y-.25,-52.45),(28.62,.50,4.42),"A17054",material=WOOD_PLANK)
    part(gallery,"East viewing walk",(12.18,upper_y-.234,-43.49),(4.14,.50,14.12),
         "A57755",material=WOOD_PLANK)
    part(gallery,"Rear dark fascia",(0,upper_y-.32,-50.12),(27.87,.43,.21),"743F37",
         material=WOOD_PLANK,collide=False)
    part(gallery,"East dark fascia",(10.12,upper_y-.28,-43.55),(.23,.43,14.14),"743F37",
         material=WOOD_PLANK,collide=False)
    for (ax,az),(bx,bz) in (((-10.35,-50.39),(10.31,-50.39)),
                          ((10.31,-50.39),(10.31,-36.60)),((10.31,-36.60),(14.17,-36.60))):
        for lift in (.55,1.31):
            beam(gallery,"Gallery carved guardrail",(ax,upper_y+lift,az),
                 (bx,upper_y+lift,bz),.24,"784235",collide=True)
        length=hypot(bx-ax,bz-az)
        posts=max(2,round(length/2))
        for index in range(posts+1):
            t=index/posts
            x,z=ax+(bx-ax)*t,az+(bz-az)*t
            part(gallery,"Carved gallery baluster",(x,upper_y+.66,z),(.23,1.29,.23),"925641",collide=False)
            part(gallery,"Gallery rail cap",(x,upper_y+1.35,z),(.33,.11,.33),"C69258",collide=False)
    for x,z in ((-13.89,-50.67),(13.95,-48.04),(13.95,-40.77),(-13.90,-53.3)):
        part(gallery,"Carved support column",(x,6.53,z),(.56,5.82,.62),"843E33",
             material=WOOD_PLANK,collide=False)
        part(gallery,"Column slate shoe",(x,3.85,z),(.90,.48,.90),"8B747C",material=SLATE,collide=False)
    for x in (-8.50,-2.73,3.08,8.50):
        part(gallery,"Archive planter",(x,upper_y+.25,-53.94),(1.62,.50,.81),"8C694E",
             material=WOOD_PLANK,collide=False)
        garden_prop(gallery,"meadowFlowers",(x,upper_y+.50,-53.90),.15,49,"F4CC96")
        garden_prop(gallery,"mossFlowers",(x+.11,upper_y+.50,-54.00),.061,63,"DCA2B4")
    for z in (-47.23,-40.42):
        lamp(gallery,13.65,upper_y+2.88,z,scale=.58)
    part(gallery,"Viewing gallery cedar bench",(13.62,upper_y+.47,-44.05),(.87,.31,3.91),"AE7657",
         material=WOOD_PLANK,collide=False)
    for z in (-45.23,-42.88):
        part(gallery,"Bench slate foot",(13.62,upper_y+.18,z),(.58,.36,.44),"8D7374",
             material=SLATE,collide=False)
    sign(gallery,"VIEWING GALLERY",-12.32,7.52,-35.81,4.02,.79,tint="794630",face_only=True)
    part(gallery,"Woven hall runner",(0,entry_y+.018,-39.44),(5.68,.036,9.76),"82473D",
         material=FABRIC,collide=False)
    for x in (-2.64,2.64):
        part(gallery,"Runner brocade border",(x,entry_y+.042,-39.44),(.12,.014,9.61),"CC9E64",
             material=FABRIC,collide=False)
        for z in (-35.24,-37.24,-39.24,-41.24,-43.24):
            part(gallery,"Runner embroidered diamond",(x*.88,entry_y+.043,z),(.22,.015,.22),"DAB87A",
                 yaw=45,material=FABRIC,collide=False)
    for x in (-9.3,0,9.3):
        lantern_window(gallery,x,12.23,-54.30,3.16,2.29)
    for x in (-14.34,14.34):
        for z in (-37.0,-43.7,-50.36):
            part(gallery,"Inset timber pilaster",(x,8.68,z),(.29,9.96,.56),"8C4C3C",
                 material=WOOD_PLANK,collide=False)
        part(gallery,"Upper hall timber frieze",(x,14.88,-44.16),(.26,.72,20.61),
             "845344",material=WOOD_PLANK,collide=False)
    for z in (-35.68,-39.85,-44.02,-48.19,-52.36):
        part(gallery,"Cedar ceiling recess",(0,15.64,z),(29.73,.19,4.10),"725044",
             material=WOOD_PLANK,collide=False)
        part(gallery,"Crossed ceiling timber",(0,15.47,z+2.02),(29.84,.29,.35),"573B35",
             material=WOOD_PLANK,collide=False)
    threshold_light(gallery,0,14.67,-47.0,reach=13,spread=75,brightness=.82)


hall_viewing_gallery(hall)
part(hall,"Raised retaining foundation",(0,1.25,-44),(32.5,2.5,23.5),"74616D",material=SLATE)
for side in (-1,1):
    x=side*12.1
    part(hall,"Trophy Hall terrace ledge",(x,1.56,-30.40),(7.1,3.12,4.30),"9E8085",material=SLATE)
    part(hall,"Terrace garden top",(x,3.23,-29.29),(6.8,.25,1.82),"647450",material=GRASS_MAT)
    for lane in range(8):
        offset=(lane-3.5)*.75
        y=3.77+abs(offset)*.13
        part(hall,"Terrace foliage",(x+offset,y,-29.29),
             (1.16,.71,.95),("59814B","78864E","A4697E")[lane%3],
             yaw=lane*11,collide=False,class_name="WedgePart")
    lamp(hall,x+side*1.5,4.38,-28.8,scale=.91,light=True)
    for offset in (-2.05,0,2.05):
        garden_prop(hall,"meadowCover",(x+offset,3.42,-29.42),.13,28,"A9B66E")
        garden_prop(hall,"meadowFlowers",(x+offset+.32,3.50,-28.91),.26,51,"FFC09D")
    garden_prop(hall,"bankRock",(x+side*1.98,.16,-26.6),.30,71,"827971")
    garden_prop(hall,"mossFlowers",(x+side*2.33,.17,-27.4),.26,13,"A6A375")
build_hall_split_stair(hall,item=item,prop=prop,part=part,garden_shelf=garden_shelf,
                       garden_prop=garden_prop,standing_lantern=store_standing_lantern,
                       slate=SLATE,sandstone=LIMESTONE,grass=GRASS_MAT,
                       variant_field=MATERIAL_VARIANT_FIELD,stone_variant=PROMENADE_MORTAR,
                       trim_variant=PROMENADE_STONE)
for side in (-1,1):
    x=side*7.43
    middle_z=-26.06 if side<0 else -24.71
    foundation=((x,.91,-21.25),(x,2.21,middle_z),(x,3.89,-29.15))
    for position, next_position in zip(foundation,foundation[1:]):
        beam(hall,"Slate stair coping",position,next_position,.38,"C2A391")
    for px,py,pz in foundation:
        part(hall,"Slate stair pier",(px,py-.57,pz),(1.36,1.22,1.34),"9C8287",material=SLATE)
        part(hall,"Pier cap stone",(px,py+.07,pz),(1.55,.25,1.55),"BE9E94",material=SLATE)
build_hall_stair_court(hall,item=item,part=part,prop=prop,triangle=triangle,
                      lantern_light=lantern_light,garden_prop=garden_prop,slate=SLATE,
                      sandstone=LIMESTONE,cedar=WOOD_PLANK,brass=METAL,neon=NEON)

portico=item(hall,"Model","Trophy Hall arrival portico")
prop(portico,"token","LevelOfDetail",4)
swept_roof(portico,0,hall_portico_y(11.54),-29.60,30.9,7.10,1.81,fine_tiles=False)


def portico_piece(label,position,size,tint,**options):
    position,size=hall_portico_box(position,size)
    return part(portico,label,position,size,tint,collide=False,**options)


portico_piece("Portico cedar tie beam",(0,11.38,-27.37),(26.0,.64,.79),"8D472F",
              material=WOOD_PLANK)
portico_piece("Portico gilt fascia",(0,11.42,-26.97),(25.7,.18,.16),"CF9C56")
for side in (-1,1):
    x=side*9.12
    z=-29.47
    part(portico,"Portico stepped slate base",(x,3.55,z),(1.82,.79,1.74),"887680",
         material=SLATE,collide=False)
    part(portico,"Portico dressed slate cap",(x,3.99,z),(1.96,.24,1.86),"AA9194",
         material=SLATE,collide=False)
    portico_piece("Portico vermilion column",(x,7.75,z),(1.25,7.35,1.22),"A64C33",
                  material=WOOD_PLANK)
    portico_piece("Portico column inset",(x,7.71,z+.64),(.56,5.68,.08),"BA6742")
    for y in (4.49,10.31,11.01):
        portico_piece("Portico brass collar",(x,y,z),(1.39,.21,1.34),"CB934B")
    beam(portico,"Carved portico knee brace",(x,hall_portico_y(9.29),z),(side*6.85,hall_portico_y(11.24),-28.44),.45,"915039")
    beam(portico,"Portico lantern hook",(side*6.41,hall_portico_y(10.25),-27.71),
         (side*6.41,hall_portico_y(11.20),-27.96),.16,"82543B")
    arrival_hanging_lantern(portico,side*6.41,hall_portico_y(9.34),-27.60,1.02,light=False,tint="FFD59D")
    lantern_window(portico,side*8.12,hall_portico_y(7.64),-30.73,1.83,5.85)
    banner(portico,side*11.48,hall_portico_y(7.66),-27.9,scale=.86)
    bed_x=side*11.78
    garden_prop(portico,"bankRock",(bed_x,3.12,-27.94),.25,39*side,"95818A")
    garden_prop(portico,"mossFlowers",(bed_x+side*.43,3.48,-28.40),.15,28*side,"E3B3B7")
    garden_prop(portico,"meadowCover",(bed_x-side*.60,3.53,-28.22),.12,41*side,"A2B373")
    garden_prop(portico,"meadowFlowers",(bed_x+side*.74,3.54,-28.30),.31,64*side,"FFD1A5")

relay=item(scene,"Folder","Lantern Relay")
relay_skyline=item(relay,"Model","Lantern district tower")
prop(relay_skyline,"token","ModelStreamingMode",1)
prop(relay_skyline,"token","LevelOfDetail",4)
tower_x,tower_z=-61.3,12.7
tower_deck=6.56
lookout_deck=2.42
tower_stair_x,tower_stair_z=-64.4,32.7
tower_steps,tower_tread=10,.91
tower_stair_width=5.7
house(relay_skyline,tower_x,tower_z,15.4,17.2,12.15,pedestal=.6,with_roof=False)
tower_lantern_bay=item(relay_skyline,"Model","Lantern Tower east lantern bay")
prop(tower_lantern_bay,"token","LevelOfDetail",4)
tower_wall=tower_x+7.73
for z in (tower_z-4.90,tower_z,tower_z+4.90):
    part(tower_lantern_bay,"Relay-side cedar window case",(tower_wall,5.35,z),
         (.40,4.68,3.48),"713930",material=WOOD_PLANK,collide=False)
    part(tower_lantern_bay,"Relay-side amber lattice",(tower_wall+.24,5.37,z),
         (.10,3.87,2.76),"D48E56",material=NEON,collide=False)
    for offset in (-.93,0,.93):
        part(tower_lantern_bay,"Relay-side lattice upright",(tower_wall+.34,5.37,z+offset),
             (.10,3.90,.098),"84452F",collide=False)
    for y in (4.21,5.37,6.53):
        part(tower_lantern_bay,"Relay-side lattice crossbar",(tower_wall+.34,y,z),
             (.10,.097,2.77),"84452F",collide=False)
    part(tower_lantern_bay,"Relay-side brass window sill",(tower_wall+.29,3.12,z),
         (.46,.22,3.63),"C08A4A",collide=False)
for z in (tower_z-7.74,tower_z-2.45,tower_z+2.45,tower_z+7.74):
    part(tower_lantern_bay,"Festival lane cedar pilaster",(tower_wall+.02,5.65,z),
         (.36,9.22,.63),"A04C33",material=WOOD_PLANK,collide=False)
    part(tower_lantern_bay,"Festival lane slate shoe",(tower_wall+.07,1.25,z),
         (.51,.63,.89),"86727F",material=SLATE,collide=False)
for y in (2.51,8.34):
    part(tower_lantern_bay,"Festival lane cedar belt",(tower_wall+.08,y,tower_z),
         (.37,.30,16.62),"86412E",material=WOOD_PLANK,collide=False)
for pane in tower_lantern_bay.findall("Item"):
    prop(pane,"bool","CastShadow",False)
swept_roof(relay_skyline,tower_x,13.38,tower_z,22.5,23.4,4.35,fine_tiles=False,signature=True)
for base,w,d,h,rise in ((16.03,12.28,13.28,7.98,4.32),(26.65,9.35,10.39,7.2,4.75)):
    front=tower_z+d/2
    y=base+h/2
    part(relay_skyline,"Tower plaster story",(tower_x,y,tower_z),(w,h,d),"B97252",collide=False)
    for offset in (-.46,-.16,.16,.46):
        for side in (-1,1):
            part(relay_skyline,"Tower cedar upright",(tower_x+offset*w,y,tower_z+side*d/2),
                 (.35,h+.16,.38),"803A34",material=WOOD_PLANK,collide=False)
            part(relay_skyline,"Side cedar upright",(tower_x+side*w/2,y,tower_z+offset*d),
                 (.38,h+.16,.35),"803A34",material=WOOD_PLANK,collide=False)
    for offset in (-.31,0,.31):
        lantern_window(relay_skyline,tower_x+offset*w,y+.16,front+.15,w*.22,h*.62)
        for side in (-1,1):
            part(relay_skyline,"Side amber window",(tower_x+side*(w/2+.13),y+.16,tower_z+offset*d),
                 (.28,h*.60,d*.21),"ECA368",material=NEON,collide=False)
    for band in (.11,.90):
        part(relay_skyline,"Tower cedar fascia",(tower_x,base+h*band,tower_z),(w+.5,.48,d+.5),
             "943F31",material=WOOD_PLANK,collide=False)
    swept_roof(relay_skyline,tower_x,base+h+.46,tower_z,w+6.45,d+6.1,rise,
               fine_tiles=False,signature=True)

balcony=item(relay_skyline,"Model","Lantern Tower balcony")
part(balcony,"Cedar balcony walking deck",(tower_x,tower_deck-.26,22.54),(15.42,.52,4.65),"AD724D",material=WOOD_PLANK)
for x in (-68.06,-59.16,-54.16):
    part(balcony,"Balcony slate footing",(x,.52,23.11),(1.6,.92,1.65),"85737C",material=SLATE)
    part(balcony,"Tall balcony pier",(x,3.55,23.11),(.85,5.89,.84),"96442E",material=WOOD_PLANK)
    part(balcony,"Bronze balcony pier cap",(x,6.01,23.11),(1.30,.27,1.30),"C89153",collide=False)
part(balcony,"Balcony apron",(tower_x,6.03,24.87),(15.46,.62,.39),"803C30",material=WOOD_PLANK,collide=False)
for x in (-67.94,-61.28,-54.74):
    festival_lantern(balcony,x,9.57,23.66,.78,light=False)
    beam(balcony,"Balcony lantern hook",(x,10.44,23.66),(x,12.65,23.66),.10,"805536")
sign(balcony,"LANTERN TOWER",-60.9,11.73,24.0,11.0,1.58,tint="7C372D",face_only=True)
lantern_window(balcony,-60.7,8.7,21.88,3.17,3.22)
for side in (-1,1):
    garden_prop(balcony,"meadowFlowers",(tower_x+side*7.03,6.72,22.62),.33,27*side,"FFD98D")
    garden_prop(balcony,"mossFlowers",(tower_x+side*6.92,6.68,21.94),.17,36*side,"EAA5A3")
    garden_shelf(balcony,tower_x+side*7.05,6.72,22.25,1.18,1.92,.32,"816C72",SLATE,collide=False)
for left,right in (((-68.9,20.44),(-68.9,24.84)),
                   ((-68.9,24.84),(tower_stair_x-tower_stair_width/2,24.84)),
                   ((tower_stair_x+tower_stair_width/2,24.84),(-53.70,24.84))):
    for height in (.39,1.27):
        beam(balcony,"Balcony cedar railing",(left[0],tower_deck+height,left[1]),
             (right[0],tower_deck+height,right[1]),.24,"A74932",collide=True)
    for x,z in (left,right):
        part(balcony,"Balcony railing post",(x,tower_deck+.68,z),(.36,1.39,.36),"79392E",collide=False)
relay_portal=item(relay,"Model","Lantern Relay entrance")
prop(relay_portal,"token","ModelStreamingMode",1)
prop(relay_portal,"token","LevelOfDetail",4)
relay_entrance_x=-37
build_relay_arrival_portico(relay_portal,center=relay_entrance_x,item=item,part=part,prop=prop,
                           beam=beam,banner=banner,curved_plaque=curved_plaque,marquee_title=marquee_title,
                           reed_mark=reed_mark,roof_panel=roof_panel,roof_barrel=roof_barrel,
                           arrival_hanging_lantern=arrival_hanging_lantern,festival_lantern=festival_lantern,
                           threshold_light=threshold_light,wood=WOOD_PLANK,slate=SLATE,limestone=LIMESTONE,
                           metal=METAL,fabric=FABRIC,variant_field=MATERIAL_VARIANT_FIELD,
                           wood_variant=LANDMARK_CEDAR,metal_variant=ORNAMENT_BRASS,
                           stone_variant=PROMENADE_MORTAR,fabric_variant=ARENA_WEAVE)
air_effect(relay_portal,"Relay entrance glints",(relay_entrance_x,4.9,31.2),(13.0,2.8,1.25),5860841663,
           tint="FFD899",rate=1.5,lifetime=(1.0,1.7),speed=(.39,.72),
           size=(.21,.12),opacity=.68,drift=(.35,-.05,.11),glow=.55)
# Keep the start counter on the dry canal side to open the view under the marquee.
board_x,board_z=-31.2,40.6
board=part(relay,"EventBoard",(board_x,2.0,board_z),(3.38,1.95,.49),"6E3830",
           material=WOOD_PLANK,collide=False)
part(relay,"Relay desk plaque frame",(board_x,2.05,board_z+.24),(3.22,1.16,.13),
     "C28F53",material=METAL,collide=False)
sign(relay,"RELAY START",board_x,2.05,board_z+.23,2.95,.92,tint="95372D")
for side in (-1,1):
    px=board_x+side*1.34
    part(relay,"Relay desk slate shoe",(px,.31,board_z),(.58,.37,.72),"8D7E86",
         material=SLATE,collide=False)
    part(relay,"Relay desk cedar leg",(px,.81,board_z),(.32,1.19,.39),"6F4031",
         material=WOOD_PLANK,collide=False)
part(relay,"Relay desk rounded sill",(board_x,2.99,board_z),(3.55,.21,.63),"985130",
     material=WOOD_PLANK,collide=False)
lamp(relay,board_x+1.26,3.50,board_z,scale=.57,light=True,light_profile=(.68,12.0))
part(relay,"Relay music volume",(-42.35,5.2,24.0),(18.5,8,20),STONE,
     transparency=1,collide=False)
board_prompt=item(board,"ProximityPrompt","BoardPrompt")
prop(board_prompt,"string","ActionText","Open event board")
prop(board_prompt,"string","ObjectText","Lantern Relay")
prop(board_prompt,"float","MaxActivationDistance",13)
prop(board_prompt,"bool","RequiresLineOfSight",False)
for x,z in ((-34.1,37.6),(-35.44,34.5),(-37.0,31.48),(-38.75,28.65)):
    for side in (-1,1):
        beam(relay,"Gold route inlay",(x+side*.64,.18,z+.40),(x,.18,z-.31),.073,"DCAF64")


def relay_checkpoint_arch(parent,x,z,yaw,peak):
    crown=item(parent,"Model","Curved relay checkpoint header")
    c,s=cos(radians(yaw)),sin(radians(yaw))

    def point(offset,lift=0,depth=0):
        height=peak-(peak-8.90)*(offset/7.28)**2
        return x+offset*c+depth*s,height+lift,z-offset*s+depth*c

    sections=(-7.28,-5.49,-3.70,-1.85,0,1.85,3.70,5.49,7.28)
    for a,b in zip(sections,sections[1:]):
        beam(crown,"Vermilion checkpoint arch",point(a),point(b),.59,"AC4D37")
        beam(crown,"Indigo checkpoint coping",point(a,.38),point(b,.38),.28,"374D81")
        beam(crown,"Gold checkpoint fillet",point(a,.11,.33),point(b,.11,.33),.12,"DB9D4D")
    for side in (-1,1):
        post=side*7.0
        for lift,width,tint in ((-.75,1.54,"7F463D"),(-.37,1.78,"A06143"),(-.04,2.02,"713C37")):
            part(crown,"Stacked cedar shoulder",point(post,lift,.02),(width,.23,2.07),
                 tint,yaw=yaw,material=WOOD_PLANK,collide=False)
        beam(crown,"Carved checkpoint brace",point(post,-2.17,.40),
             point(side*5.03,-.30,.40),.38,"9D563C")
        beam(crown,"Checkpoint brace brass edge",point(post,-1.98,.58),
             point(side*5.16,-.36,.58),.081,"D79450")
    for index,offset in enumerate((-5.08,-2.56,0,2.56,5.08)):
        scale=.87 if offset==0 else .67
        beam(crown,"Relay lantern hanger",point(offset,-.51,.10),point(offset,.03,.10),.090,"834631")
        festival_lantern(crown,*point(offset,-1.21,.10),scale,light=False,
                         tint=("FFC575","FFB667","FFD087","FFB667","FFC575")[index])
    for piece in crown.findall("Item"):
        prop(piece,"bool","CastShadow",False)


checkpoints=item(relay,"Model","Checkpoints")
prop(checkpoints,"token","ModelStreamingMode",2)
course=[(-42,22),(-45,7),(-59,-4),(-63,-20),(-59,-38),(-47,-52),(-28,-58)]
previous=(relay_entrance_x,31)
for i,(x,z) in enumerate(course,1):
    yaw=degrees(atan2(previous[0]-x,previous[1]-z))
    model=item(relay,"Model",f"Lantern Gate {i}")
    gate(model,x,z,yaw,span=14,trim=RED,label="FINISH" if i==len(course) else None,
         lanterns=i>2,straight_lintel=i>2)
    if i<=2:
        relay_checkpoint_arch(model,x,z,yaw,11.64-.29*i)
    if i==len(course):
        air_effect(model,"Relay finish glints",(x,4.85,z),(10.5,2.5,1.4),5860841663,
                   tint="FFD899",rate=2.2,lifetime=(.95,1.55),speed=(.48,.83),
                   size=(.28,.15),opacity=.67,drift=(.19,.02,.13),glow=.57)
    part(checkpoints,str(i),(x,3.5,z),(13,8,4.5),GOLD,yaw=yaw,transparency=1,collide=False)
    if i<=2:
        stripe=part(model,"Lantern threshold",(x,.185,z),(12,.06,.51),"D39F5B",
                    yaw=yaw,material=METAL,collide=False)
        prop(stripe,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
        prop(stripe,"bool","CastShadow",False)
    else:
        part(model,"Lantern threshold",(x,.18,z),(12,.1,1.25),AMBER,yaw=yaw,material=NEON,collide=False)
    previous=(x,z)
for (x,z),(nx,nz) in zip(course,course[1:]):
    for d in (.28,.58,.85):
        part(relay,"Golden trail inlay",(x+(nx-x)*d,.18,z+(nz-z)*d),(1.1,.05,1.1),GOLD,yaw=45,material=NEON,collide=False)


def relay_festoon(parent,x,z,yaw,index):
    arch=item(parent,"Model",f"Relay lantern span {index+1}")
    prop(arch,"token","ModelStreamingMode",1)
    prop(arch,"token","LevelOfDetail",4)
    c,s=cos(radians(yaw)),sin(radians(yaw))
    apex=10.26+(index%2)*.40
    half_width=7.18

    def point(across,y,depth):
        return (x+across*c+depth*s,y,z-across*s+depth*c)

    def height(offset):
        return apex-2.47*(offset/half_width)**2

    for side in (-1,1):
        dx=side*half_width
        part(arch,"Festoon slate foot",point(dx,.43,0),(1.97,.83,1.80),"8A747C",
             yaw=yaw,material=SLATE,collide=False)
        part(arch,"Festoon lacquer post",point(dx,(height(dx)+.70)/2,0),(1.02,height(dx)-.70,1.04),
             "AB4935",yaw=yaw,material=WOOD_PLANK,collide=False)
        for y in (1.13,height(dx)-.34):
            part(arch,"Festoon bronze collar",point(dx,y,0),(1.19,.22,1.20),"C68A4C",
                 yaw=yaw,collide=False)
        beam(arch,"Festival arch brace",point(dx,height(dx)-1.78,0),
             point(dx-side*1.66,height(dx-side*1.66)-.12,0),.32,"985234")

    sections=(-7.18,-5.82,-4.2,-2.12,0,2.12,4.2,5.82,7.18)
    for a,b in zip(sections,sections[1:]):
        beam(arch,"Swept lacquer crosspiece",point(a,height(a),0),point(b,height(b),0),.46,"AB4C34")
        beam(arch,"Copper festoon rim",point(a,height(a)+.24,.13),point(b,height(b)+.24,.13),.105,"D39551")
    part(arch,"Brass arch clasp",point(0,apex+.05,0),(.59,.84,.49),"D6A35A",yaw=yaw,collide=False)

    offsets=(-5.06,-2.68,0,2.68,5.06) if index<2 else (-4.47,0,4.47)
    for lamp_index,offset in enumerate(offsets):
        scale=.66 if offset==0 else .56
        lamp_y=height(offset)-1.14
        beam(arch,"Lantern hanging cord",point(offset,lamp_y+.64,0),point(offset,height(offset)-.12,0),.066,DARK)
        festival_lantern(arch,*point(offset,lamp_y,.07),scale,light=(offset==0 and index in (0,3)),
                         tint=("FFC577","FFD899","FFB873")[(lamp_index+index)%3])

    if index in (0,1,3):
        for side in (-1,1):
            bx,_,bz=point(side*9.0,0,.58)
            garden_shelf(arch,bx,.56,bz,3.88,2.82,.47,"8A7780",SLATE,collide=False)
            garden_shelf(arch,bx,.66,bz,3.60,2.55,.18,"637A4B",GRASS_MAT,collide=False)
            garden_prop(arch,"grassBlade",(bx-.17,.61,bz-.14),.44,75+index*15,"C4A962")
            garden_prop(arch,"meadowFlowers",(bx+.39,.64,bz+.33),.32,61-side*25,"FFD694")
            garden_prop(arch,"mossFlowers",(bx-.28,.65,bz+.64),.14,96+side*47,"EFB2B8")
    for fixture in arch.findall("Item"):
        if fixture.get("class") in ("Part","WedgePart"):
            prop(fixture,"bool","CastShadow",False)


for index,((x,z),(nx,nz)) in enumerate(zip(course,course[1:])):
    fraction=(.52,.52,.54,.54,.50,.55)[index]
    yaw=degrees(atan2(x-nx,z-nz))
    relay_festoon(relay,x+(nx-x)*fraction,z+(nz-z)*fraction,yaw,index)

sign(relay,"TROPHY HALL  →",-24.9,4.1,-54.2,6.4,1.4,-90,"28635E")
for x,z in [(-27,-51),(-27,-46),(-27,-41),(-27,-36),(-27,-31),(-25,-24.25),(-9,-24.25),(-5,-29)]:
    part(plaza,"Jade hall marker",(x,.17,z),(.9,.04,.9),"59A996",yaw=45,collide=False)

district=item(scene,"Folder","City streets")
lookout=item(district,"Model","Garden Lookout")
part(lookout,"Garden retaining terrace",(-69,1.11,39.8),(24,2.22,15),"74616D",material=SLATE)
part(lookout,"Lookout courtyard",(-69,lookout_deck-.10,39.8),(23.8,.2,14.8),"A89978",material=LIMESTONE)
part(lookout,"Garden stair landing",(-69,-.075,54.58),(7.7,.45,3.34),"9C817F",material=SLATE)
stair(lookout,-69,52.7,7.5,6,height=.402,depth=1.08)
sign(lookout,"GARDEN LOOKOUT",-69,4.25,46.1,7,1.19,tint="315F54")
for x,z in [(-79,44),(-59,44),(-79,34),(-59,34)]:
    part(lookout,"Carved railing post",(x,3.12,z),(.78,1.44,.78),RED)
    lamp(lookout,x,4.20,z,scale=.69)
for start,end in [((-79,3.35,44),(-79,3.35,34)),((-59,3.35,44),(-59,3.35,38.8)),
                  ((-79,3.35,34),(tower_stair_x-tower_stair_width/2,3.35,34)),
                  ((tower_stair_x+tower_stair_width/2,3.35,34),(-59,3.35,34))]:
    beam(lookout,"Lookout rail",start,end,.25,DARK)
tower_steps_model=item(relay_skyline,"Model","Lantern Tower stairs")
tower_rise=(tower_deck-lookout_deck)/tower_steps
for index in range(tower_steps):
    z=tower_stair_z-index*tower_tread
    top=lookout_deck+(index+1)*tower_rise
    part(tower_steps_model,"Lantern Tower stone step",(tower_stair_x,top/2,z),
         (tower_stair_width,top,tower_tread+.07),"A18A87",material=SLATE)
    part(tower_steps_model,"Slate tread lip",(tower_stair_x,top-.04,z+tower_tread/2),
         (tower_stair_width+.06,.13,.14),"B69A91",material=SLATE,collide=False)
for side in (-1,1):
    x=tower_stair_x+side*(tower_stair_width/2+.14)
    a=(x,lookout_deck+1.23,tower_stair_z+.35)
    b=(x,tower_deck+1.23,tower_stair_z-(tower_steps-1)*tower_tread)
    beam(tower_steps_model,"Lantern Tower stair handrail",a,b,.25,"9C4734",collide=True)
    for index in (0,3,6,9):
        y=lookout_deck+(index+1)*tower_rise
        z=tower_stair_z-index*tower_tread
        part(tower_steps_model,"Cedar stair newel",(x,y+.51,z),(.34,1.08,.34),"74392F",collide=False)
sign(lookout,"LANTERN TOWER",-61.17,4.05,33.87,4.41,.81,tint="795142",face_only=True)
for x,z in [(-76,36),(-72,35.6),(-66,35.6),(-62,36)]:
    part(lookout,"Terrace garden bed",(x,2.54,z),(3.7,.25,3),"49644B",collide=False)
    for n in range(3):
        part(lookout,"Garden flowering foliage",(x+(n-1)*.93,3.06+n*.09,z),
             (1.53,1.0,1.51),("8D596F","BC7590","79A865")[n],
             yaw=27*n,collide=False,class_name="WedgePart")
gate(district,70,-8,span=18,label="REED MARKET",trim="277C79")
parcel_station(district,"Parcel Dispatch",84.3,-.20,-4.35,-150,
               "PARCEL DISPATCH","Pick up parcel","Reed Market","3C6C61")
for i,(x,z) in enumerate([(59,-18),(79,-23),(61,-37),(82,-44), (51,-54)]):
    stall=item(district,"Model",f"Market stall {i+1}")
    prop(stall,"token","ModelStreamingMode",1)
    prop(stall,"token","LevelOfDetail",4)
    pcolors=["BD5C62","428F91","B8803F","694F91","2F7D6C"]
    house(stall,x,z,10,8,4.4,walls=False)
    for n in range(7):
        part(stall,"Striped awning",(x-4.9+n*1.63,4.62,z+4.7),(1.65,.26,2.8),
             pcolors[i] if n%2 else CREAM,pitch=12,collide=False)
    part(stall,"Vendor counter",(x,1.58,z+2.7),(8.8,2,1.3),DARK)
    for n in range(5):
        part(stall,"Festival parcel",(x-3.3+n*1.58,2.82,z+2.7),(.91,.58,.79),
             rng.choice(pcolors),yaw=rng.randint(-20,20),collide=False)
gate(district,22,-70,span=21,label="UPPER CITY",trim="725781")
gate(district,-83,9,span=18,label="GARDEN WALK",trim="3D795D")
for x,z in [(30,-51),(36,-65),(10,-69),(92,-53),(98,4),(-92,25),(-85,-24),(-70,-46),(-99,-53),(-25,-66)]:
    tree(district,x,z,pink=(x+z)%2==0)
for x,z in [(-52,47),(25,61),(11,-25),(-27,-21),(-28,-41),(-72,12),(-59,-60),(57,18),(43,-34)]:
    tree(district,x,z,pink=x%2==0,scale=.8)
for x,z,width,depth,height in [(-57,-81,22,16,8),(60,-108,27,17,11),(53,-89,21,16,8),
                                (108,-53,18,17,7),(-95,-20,17,14,7),(-110,-52,20,14,8)]:
    house(district,x,z,width,depth,height)

landscape=item(scene,"Folder","Valley skyline")
build_south_valley_backdrop(landscape, item=item, prop=prop, part=part, triangle=triangle,
                            rock=ROCK, smooth=SMOOTH, rock_variant=VALLEY_ROCK,
                            variant_field=MATERIAL_VARIANT_FIELD)
build_west_valley_backdrop(landscape,item=item,prop=prop,part=part,triangle=triangle,
                           beam=beam,slate=SLATE,rock=ROCK,smooth=SMOOTH,neon=NEON,
                           cedar=WOOD_PLANK,grass=LEAFY_GRASS,garden_prop=garden_prop,rock_variant=VALLEY_ROCK,
                           variant_field=MATERIAL_VARIANT_FIELD)
build_meltwater_valley_art(landscape,item=item,prop=prop,part=part,triangle=triangle,
                           slate=SLATE,smooth=SMOOTH)
terrain_profiles=item(landscape,"Folder","Foothill profiles")
for label,x,z,width,depth,summit,cover in (
    ("Tideharbor bluff",136,47,46,39,13,GRASS_MAT),
    ("Kiln clay ridge",91,-140,38,52,24,SANDSTONE),
    ("Glaze Terrace clay shoulder",207,-175,64,74,12.4,SANDSTONE),
    ("Skywalk west wall",-31,-205,74,51,25,SLATE),
    ("Skywalk east wall",71,-211,54,47,28,SLATE),
    ("Wind Court west terrace bank",-.5,-249,30,32,20,SLATE),
    ("Wind Court east terrace bank",44.2,-248,30,31,22,SLATE),
    ("Frostglass bank",-106,-135,32,47,19,SLATE),
    ("Frostglass east talus",-146.2,-152.2,44.0,27.4,9.1,SLATE),
    # Leave headroom for Terrain's voxel smoothing beneath the summit paving.
    ("Lantern orchard hill",-147,-7,51,39,10.0,GRASS_MAT),
    ("Mistline west shoulder",-141,-192,48,45,12,SLATE),
    ("Mistline upland shoulder",-101,-214,51,47,16,SLATE),
):
    part(terrain_profiles,label,(x,(summit-5)/2,z),(width,summit+5,depth),"7C8560",
         collide=False,transparency=1,material=cover)
ridge_groves = {
    2: ((-184,-321,1.04),(-179,-318,1.32),(-175,-323,1.01),(-169,-318,1.12),
        (-135,-314,1.43),(-129,-319,1.29),(-124,-319,1.05),(-119,-321,1.01),
        (-113,-317,.89)),
    3: ((179,-319,1.05),(183,-316,.95),(187,-319,1.17),(191,-312,1.40),
        (195,-315,1.29),(201,-314,1.49),(206,-317,1.15),(211,-313,.98),
        (215,-314,1.11)),
}

def north_ridge_cedar_part(parent, name, position, size, tint, **rotation):
    piece=part(parent,name,position,size,tint,
               material=WOOD_PLANK if name.endswith("trunk") else SMOOTH,collide=False,**rotation)
    prop(piece,"bool","CastShadow",False)


def cedar_root_ledge(parent, faces, x, y, z, scale):
    # Sink the back of each small shelf into the rock and fit the front foot
    # to the same face as the tree root.
    left=(x-1.48*scale,y-.37,z+1.12*scale)
    nose=(x+.23*scale,y-.26,z+1.70*scale)
    right=(x+1.31*scale,y-.40,z+.74*scale)
    back=(x-.16*scale,y-.52,z-.88*scale)
    foot_x,foot_z=x+.15*scale,z+.74*scale
    foot=(foot_x,ridge_surface_height(faces,foot_x,foot_z)-.22,foot_z)
    for a,b,c,tint in ((left,back,nose,"817584"),(nose,back,right,"867986"),
                       (left,nose,foot,"756978"),(nose,right,foot,"7D6F7E")):
        triangle(parent,a,b,c,tint,name="Cedar root slate ledge",material=SLATE,
                 thickness=.21,shadow=False)


for index,ridge_profile in enumerate(VALLEY_RIDGES):
    model=item(landscape,"Model","Layered valley ridge")
    prop(model,"token","ModelStreamingMode",2)
    prop(model,"token","LevelOfDetail",4)
    surface=ROCK if index>=2 else SMOOTH
    facets=list(north_ridge_facets(*ridge_profile))
    for face,_,tint in facets:
        triangle(model,*face,"".join(f"{channel:02x}" for channel in tint),material=surface,shadow=False)
    if surface==ROCK:
        for wedge in model.findall("Item"):
            prop(wedge,"string",MATERIAL_VARIANT_FIELD,VALLEY_ROCK)
        grove=item(model,"Folder","North ridge cedar grove")
        faces=[face for face,_,_ in facets]
        for tree_index,(px,pz,scale) in enumerate(ridge_groves[index]):
            floor=ridge_surface_height(faces,px,pz)
            cedar_root_ledge(grove,faces,px,floor,pz,scale)
            hillside_cedar(north_ridge_cedar_part,grove,px,floor-.68,pz,scale,tree_index)
        if index == 2:
            build_pinecrest_ravine(landscape,faces,item=item,prop=prop,part=part,vector=vector,
                                   asset=asset,color=color,triangle=triangle,garden_prop=garden_prop,
                                   cedar_part=north_ridge_cedar_part,rock=ROCK,grass=GRASS_MAT,
                                   cedar=WOOD_PLANK,plastic=256,rock_variant=VALLEY_ROCK,
                                   variant_field=MATERIAL_VARIANT_FIELD)
build_arrival_distant_ridges(landscape,item=item,prop=prop,triangle=triangle,smooth=SMOOTH)
build_orchard_bluff(landscape,item=item,prop=prop,part=part,triangle=triangle,
                    garden_shelf=garden_shelf,garden_prop=garden_prop,slate=SLATE,
                    rock=ROCK,grass=GRASS_MAT,cedar=WOOD_PLANK,rock_variant=VALLEY_ROCK,
                    variant_field=MATERIAL_VARIANT_FIELD)
build_lanternwood_ridge(landscape,item=item,prop=prop,part=part,triangle=triangle,slate=SLATE,
                        rock=ROCK,grass=GRASS_MAT,cedar=WOOD_PLANK,neon=NEON,
                        rock_variant=VALLEY_ROCK,variant_field=MATERIAL_VARIANT_FIELD)
build_orchard_road_terraces(landscape,item=item,prop=prop,part=part,triangle=triangle,
                             garden_prop=garden_prop,showcase_tree=showcase_tree,
                             rock=ROCK,grass=GRASS_MAT,cedar=WOOD_PLANK,
                             rock_variant=VALLEY_ROCK,variant_field=MATERIAL_VARIANT_FIELD)
for label,x,z,width,depth,profile,front,planting in (
    ("North Tideharbor ridge",156,-54,117,24,
     (0,4,10,14,21,25,28,27,31,36,31,28,26,20,18,12,8,4,0),1,(5,8,11,14)),
    ("Saltwind coastal bluff",148,71,76,25.5,
     (0,4,10,18,22,24,22,25,26,31,29,25,21,17,10,6,0),-1,(4,6,9,11,13)),
):
    model=item(landscape,"Model",label)
    prop(model,"token","ModelStreamingMode",1)
    prop(model,"token","LevelOfDetail",4)
    coastal_ridge(model,x,z,width,depth,profile,front,planting,
                   cliff_gardens=label=="Saltwind coastal bluff")
build_crown_ravine_gardens(landscape,item=item,prop=prop,part=part,triangle=triangle,
                           garden_prop=garden_prop,rock=ROCK,grass=GRASS_MAT,cedar=WOOD_PLANK,
                           rock_variant=VALLEY_ROCK,variant_field=MATERIAL_VARIANT_FIELD)
build_crown_ravine_cedars(landscape,item=item,part=part,prop=prop,vector=vector,asset=asset,
                          plastic=256,smooth=SMOOTH)
build_windrest_creek_gardens(landscape,item=item,prop=prop,part=part,triangle=triangle,
                             garden_prop=garden_prop,rock=ROCK,grass=GRASS_MAT,cedar=WOOD_PLANK,
                             rock_variant=VALLEY_ROCK,variant_field=MATERIAL_VARIANT_FIELD)
falls=item(landscape,"Model","Reedfall terraced cliffs")
prop(falls,"token","ModelStreamingMode",1)
prop(falls,"token","LevelOfDetail",4)


def reedfall_buttress(parent,x,z,width,depth,base,top,offset,yaw):
    outline=((-1,-.18),(-.51,-1),(.61,-.85),(1,.14),(.51,.94),(-.59,.77))
    c,s=cos(radians(yaw)),sin(radians(yaw))
    bands = []
    for proportion,span,shift in ((0,1,0),(.52,.89,.31),(1,.68,1)):
        bands.append([(x+u*width*span*c+v*depth*span*s+offset*shift,
                       base+(top-base)*proportion+(.12 if i%2==0 else -.12),
                       z-u*width*span*s+v*depth*span*c)
                      for i,(u,v) in enumerate(outline)])
    tones=(("827780","8E7D84","746C79","705F6B","86737E","A18B8F"),
           ("92818A","9D898F","877582","796A74","94808B","AD9497"))
    before=len(parent)
    for course,(lower,upper) in enumerate(zip(bands,bands[1:])):
        for i,shade in enumerate(tones[course]):
            j=(i+1)%len(tones)
            for face in ((lower[i],upper[i],lower[j]),(lower[j],upper[i],upper[j])):
                triangle(parent,*face,shade,name="Reedfall rock face",material=ROCK,shadow=False)
    for stone in parent[before:]:
        prop(stone,"string",MATERIAL_VARIANT_FIELD,BANK_STONE)
    cap=bands[-1]
    for a,b in zip(cap[1:-1],cap[2:]):
        triangle(parent,cap[0],a,b,"A18A94",name="Reedfall rock ledge",material=SLATE,shadow=False)


for x,z,width,depth,base,top,shift,yaw in (
    (26.7,-51.2,4.5,3.0,5.5,16.9,-.5,-16),
    (37.75,-52.5,4.1,3.25,17.8,29.85,.63,21),
    (42.8,-47.1,5.1,3.3,6.0,19.55,1.4,27),
    (39.9,-42.8,4.2,2.8,1.0,10.4,.6,-28),
    (23.5,-49.2,3.8,3.1,23.0,40.20,-.6,-12),
    (35.7,-47.95,4.8,3.9,25.2,47.30,.85,12),
):
    reedfall_buttress(falls,x,z,width,depth,base,top,shift,yaw)
    garden_prop(falls,"bankRock",(x+shift,top-.52,z+.34),.43,yaw+21,"AA939C")
    garden_prop(falls,"meadowCover",(x+shift+.26,top-.06,z+.87),.30,yaw,"869D61")
    garden_prop(falls,"rockVine",(x+shift+.14,top-2.20,z+depth*.75),.87,yaw*.66)

for index,(x,z,height,width) in enumerate(((28.5,-56.5,30.5,5.4),(32.9,-56.6,38.8,5.7),
                                           (37.1,-58.7,41.3,6.9),(41.3,-54.9,27.4,6.1),
                                           (45.2,-58.8,24.9,7.4),(37.9,-52.5,15.7,7.0))):
    part(falls,"Fractured cliff slab",(x,height*.37-1,z),(width+2,height*.76,9),
         ("736373","83717C","95818D")[index%3],yaw=25-index*7,roll=(-1)**index*11,collide=False)
    part(falls,"Split cliff shoulder",(x+.5,height*.78,z-.3),(width+1,height*.6,10),
         ("9A828B","7D727F","8E7986")[index%3],yaw=index*19,roll=(-1)**index*15,
         collide=False,class_name="WedgePart")
    part(falls,"Rock garden shelf",(x-.4,height*.71+.12,z+3.39),(width*.73,.53,2.55),
         "6B8253",yaw=index*23,collide=False)
    if index%2==0:
        garden_prop(falls,"rockVine",(x+.65,height*.39,z+4.32),.87,0)
for x,z,shelf_y,pink,scale,yaw in ((27.0,-53.7,13.8,True,.74,44),(43.75,-48.7,16.3,False,.89,-24)):
    garden_shelf(falls,x,shelf_y,z,10.6,7.3,shelf_y+.13,"847783",SLATE,collide=False)
    garden_shelf(falls,x,shelf_y+.38,z,9.8,6.3,.45,"637B49",GRASS_MAT,collide=False)
    showcase_tree(falls,x+.41,z-.36,pink,scale,yaw,shelf_y+.38)
    for side in (-1,1):
        garden_prop(falls,"rockVine",(x+side*3.06,shelf_y-1.90,z+2.53),.64,137+side*8)
        garden_prop(falls,"meadowGrass",(x+side*2.17,shelf_y+.34,z+.87),.28,40+side*12,"A0AB63")
        garden_prop(falls,"bankRock",(x+side*3.62,shelf_y+.04,z+1.77),.35,49+side*35,"998996")

def reedfall_flow_beam(parent, start, end, width0, width1, curve_size0, curve_size1):
    anchors=[]
    for label,position,tangent in (
        ("Water source",start,-69),
        ("Water impact",end,-52),
    ):
        anchor=part(parent,label,position,(.2,.2,.2),"A6D6E2",yaw=-90,roll=tangent,
                    transparency=1,collide=False)
        anchors.append(item(anchor,"Attachment",label))
    stream=item(parent,"Beam","Reedfall flowing water")
    for index,attachment in enumerate(anchors):
        prop(stream,"Ref",f"Attachment{index}",attachment.get("referent"))
    asset(stream,"TextureContent","rbxassetid://16808804567")
    prop(stream,"ColorSequence","Color","0 .65 .86 .94 0 .45 .57 .83 .95 0 1 .89 .96 .98 0 ")
    prop(stream,"NumberSequence","Transparency","0 .91 0 .18 .60 0 .73 .62 0 .91 .43 0 1 .79 0 ")
    prop(stream,"bool","FaceCamera",True)
    prop(stream,"int","Segments",10)
    prop(stream,"token","TextureMode",1)
    for label,value in (("LightInfluence",.25),("LightEmission",.18),("TextureSpeed",0),
                        ("TextureLength",3.9),("Width0",width0),("Width1",width1),
                        ("CurveSize0",curve_size0),("CurveSize1",curve_size1),("ZOffset",.18)):
        prop(stream,"float",label,value)

def reedfall_cascade(parent,x,z,top,bottom,width,basin_reach):
    height=top-bottom
    # Roll off the lip, draw the flow together, then fan out at the impact.
    bands=((0,.74,-.62,-.063),(.075,.82,-.32,-.044),(.19,.85,.08,-.016),(.39,.74,.43,.016),
           (.68,.78,.65,.039),(.90,.93,.98,.057),(1,1.08,1.42,.077))
    across=((-0.50,-.055,-.08),(-.31,.012,.12),(-.07,.035,.25),(.19,-.007,.15),(.50,.033,-.058))
    sheet=[
        [(x+width*(u*spread+shift),top-height*progress+lift,z+depth+bulge)
         for u,lift,bulge in across]
        for progress,spread,depth,shift in bands
    ]
    def water_span(row,column):
        a,b=sheet[row][column:column+2]
        if column==0 and height<10:
            # The lower falls break around a narrow exposed strip of rock.
            reach=(1,.94,.74,.58,.57,.78,1)[row]
            b=tuple(u+(v-u)*reach for u,v in zip(a,b))
        return a,b

    tones=(("599CB6","74B7D0","8BC8D9","5CA3BD"),("4C8AA9","66A9C5","8AC9DF","568EAF"),
           ("4C87A5","68AFCB","80BFD5","548FAD"),("5998B1","76B6CB","90CBDC","62A5BD"),
           ("65A9BD","8AC4D4","9BD2DD","72B0C2"),("82C3D2","ABD6DE","C9E7EB","89C8D8"))
    for row,colors in enumerate(tones):
        for column,tint in enumerate(colors):
            a,d=water_span(row,column)
            b,c=water_span(row+1,column)
            transparency=(.28,.13,.18,.24)[column]
            triangle(parent,a,b,c,tint,name="Reedfall water sheet",thickness=.075,shadow=False,transparency=transparency)
            triangle(parent,a,c,d,tint,name="Reedfall water sheet",thickness=.075,shadow=False,transparency=transparency)

    for column,trace,tint in (
        (0,((0,.55,.023),(1,.68,.042),(2,.59,.15),(3,.44,.064),(4,.36,.018)),"AAD8E2"),
        (1,((1,.63,.035),(2,.54,.16),(3,.61,.20),(4,.72,.085),(5,.59,.022)),"BEE6EB"),
        (2,((0,.28,.016),(1,.40,.075),(2,.46,.17),(3,.60,.091),(4,.58,.066),(5,.67,.133),(6,.71,.092)),"D1EBEE"),
        (3,((2,.44,.016),(3,.42,.09),(4,.55,.13),(5,.64,.16),(6,.53,.09)),"B8DFEA"),
    ):
        edges=[]
        for row,middle,span in trace:
            a,b=water_span(row,column)
            edges.append([tuple(t+(u-t)*fraction for t,u in zip(a,b)) for fraction in
                          (middle-span*.38,middle+span*.38)])
        for (a,d),(b,c) in zip(edges,edges[1:]):
            a,b,c,d=((px,py,pz+.12) for px,py,pz in (a,b,c,d))
            triangle(parent,a,b,c,tint,name="Reedfall water highlight",thickness=.044,shadow=False,transparency=.24)
            triangle(parent,a,c,d,tint,name="Reedfall water highlight",thickness=.044,shadow=False,transparency=.24)

    basin_scale=basin_reach/4.15
    for dx,dz,wide,deep,tint in ((0,1.35,1.48,4.96,"47889A"),(.09,1.83,.96,4.47,"669EAD")):
        pool=part(parent,"Waterfall plunge shelf",(x+dx,bottom+.057+dx*.7,z+dz*basin_scale),
                  (width*wide,.11,deep*basin_scale),tint,
                  shape=0,material=GLASS,transparency=.16,collide=False)
        prop(pool,"bool","CastShadow",False)
    for dx,dz,wide,deep,turn in ((-.39,.98,.18,.68,-11),(-.24,1.53,.28,1.02,14),(-.09,1.94,.26,.72,-18),
                                (.11,1.69,.23,1.13,7),(.31,1.35,.21,.87,22),(.40,2.10,.13,.46,6),
                                (.02,2.66,.20,.69,-15),(-.21,2.98,.16,.35,-4),(.20,2.95,.14,.47,-23)):
        foam=part(parent,"Waterfall foam",(x+width*dx,bottom+.14,z+.82+(dz-.82)*basin_scale),
                   (width*wide,.10,deep*basin_scale),"D8EDF0",
                   yaw=turn,shape=0,transparency=.26,collide=False)
        prop(foam,"bool","CastShadow",False)
    impact_x,impact_z=x+width*.076,z+1.48
    for dx,dz,h,w,tint in ((-.31,.37,.41,.55,"C6DFDC"),(-.19,.21,.71,.47,"DAEEEB"),
                           (-.07,.32,.94,.61,"D9EBE8"),(.07,.50,.58,.52,"C4E6EA"),
                           (.20,.29,.73,.46,"D1E6E4"),(.33,.37,.34,.56,"B7DDE2")):
        plume=part(parent,"Reedfall splash crest",(impact_x+width*dx,bottom+.19+h*.29,impact_z+dz),
                   (w,h,.48),tint,shape=0,roll=dx*-39,collide=False,transparency=.25)
        prop(plume,"bool","CastShadow",False)
    for radius,angle,tint in ((.22,.08,"E0EAE3"),(.35,.21,"C4DFE3"),(.48,.34,"A8CFDA")):
        arc=[(impact_x+width*radius*cos(phase),bottom+.189+radius*.04,
              impact_z+radius*width*.48*sin(phase))
             for phase in (angle,.52+angle,1.09+angle,1.66+angle,2.19+angle,2.78+angle)]
        for a,b in zip(arc,arc[1:]):
            segment=beam(parent,"Reedfall foam arc",a,b,.045,tint)
            prop(segment,"bool","CastShadow",False)

    reedfall_flow_beam(parent, (x-width*.05,top-.06,z-.28), (x+width*.077,bottom+.14,z+1.58),
                       width*.55, width*.83, height*.31, height*.22)


reedfall_drops=((29.20,-43.65,43.72,22.17,10.60,12.8),
                (32.20,-33.35,22.06,9.16,6.78,6.9),
                (30.76,-26.74,9.04,.68,7.14,4.42))
upper_x,upper_z,upper_top,_,upper_width,_=reedfall_drops[0]
garden_shelf(falls,upper_x,upper_top-1.09,upper_z-4.12,upper_width+2.15,8.35,3.20,"887988",SLATE,collide=False)
garden_shelf(falls,upper_x,upper_top-.11,upper_z-3.13,upper_width+1.72,7.55,1.43,"9E8891",SLATE,collide=False)
spring=part(falls,"Reedfall spring channel",(upper_x-.14,upper_top-.04,upper_z-2.60),(upper_width*.81,.14,5.69),"7AB6C6",
            material=GLASS,transparency=.16,collide=False,shape=0)
prop(spring,"bool","CastShadow",False)
garden_prop(falls,"bankRock",(upper_x-upper_width*.46,upper_top-.41,upper_z-2.95),.38,-21,"A48E97")
garden_prop(falls,"bankRock",(upper_x+upper_width*.43,upper_top-.44,upper_z-2.38),.34,48,"A9939F")
garden_prop(falls,"mossFlowers",(upper_x-upper_width*.51,upper_top-.17,upper_z-3.70),.18,74,"D9A4BD")
garden_prop(falls,"meadowCover",(upper_x+upper_width*.45,upper_top-.15,upper_z-3.49),.23,-16,"9FB471")
for x,z,top,bottom,width,basin_reach in reedfall_drops:
    rock_height=top-.90-bottom
    reedfall_buttress(falls,x+.93,z-4.72,width*.70,4.2,max(0,bottom-9),top-.54,-.30,0)
    garden_shelf(falls,x,bottom+rock_height*.47,z-3.0,width*1.77,4.9,
                 max(1.05,rock_height*.93),"827784",SLATE,collide=False)
    if bottom>1:
        garden_shelf(falls,x-.28,bottom-.028,z+basin_reach*.40,width*1.79,basin_reach*.97,
                     2.10,"907F88",SLATE,collide=False)
        for side in (-1,1):
            bank_x=x+side*width*.69
            bank_z=z+basin_reach*.48
            garden_shelf(falls,bank_x,bottom+.18,bank_z,2.78,basin_reach*.58,.61,
                         "74824A",GRASS_MAT,collide=False)
            garden_prop(falls,"bankRock",(bank_x,bottom-.19,bank_z-.78),.34,side*43,"A3969C")
            garden_prop(falls,"rockVine",(bank_x,bottom-1.49,bank_z+.62),.49,side*27)
            garden_prop(falls,"mossFlowers",(bank_x+side*.32,bottom+.14,bank_z+.45),.17,side*92,"E9ACBE")
            garden_prop(falls,"meadowGrass",(bank_x-side*.32,bottom+.18,bank_z+.31),.21,side*132,"AABE6D")
    reedfall_cascade(falls,x,z,top,bottom,width,basin_reach)
    garden_prop(falls,"rockVine",(x+width*.71,bottom+rock_height*.45,z-1.26),.52,12)
    garden_prop(falls,"meadowCover",(x+width*.69,bottom+.05,z-.58),.129,34,"94A469")
for source,downstream in zip(reedfall_drops,reedfall_drops[1:]):
    x,z,_,bottom,width,_=source
    next_x,next_z,next_top,_,next_width,_=downstream
    start=(x+width*.07,bottom+.09,z+2.58)
    end=(next_x-next_width*.05,next_top+.018,next_z-.32)
    # Each ledge holds shallow water between the curtains, with a pale
    # strip on the far bank and darker teal toward its broken rim.
    bank=((*start,width),(x+(next_x-x)*.46,bottom+.111,(start[2]+end[2])*.5,(width+next_width)*.43),
          (*end,next_width*.79))
    for (ax,ay,az,aw),(bx,by,bz,bw) in zip(bank,bank[1:]):
        for left,right,tint in ((-.51,-.20,"5B8A97"),(-.20,.24,"427D91"),(.24,.51,"6EA8B6")):
            a,b=(ax+left*aw,ay,az),(ax+right*aw,ay,az)
            c,d=(bx+right*bw,by,bz),(bx+left*bw,by,bz)
            triangle(falls,a,b,c,tint,name="Reedfall basin outflow",thickness=.036,shadow=False,transparency=.18)
            triangle(falls,a,c,d,tint,name="Reedfall basin outflow",thickness=.036,shadow=False,transparency=.18)
    horizontal_water_beam(falls,"Reedfall outflow foam",start,end,(3.15,1.98),
                          "0 .76 .88 .87 0 .62 .94 .98 .92 0 1 .83 .93 .92 0 ",
                          "0 1 0 .29 .42 0 .72 .36 0 1 1 0 ",3.04)
build_reedfall_ledge_gardens(falls, item=item, prop=prop, part=part, triangle=triangle,
                             garden_prop=garden_prop, showcase_tree=showcase_tree,
                             cedar_part=north_ridge_cedar_part,
                             slate=SLATE, rock=ROCK, grass=GRASS_MAT, rock_variant=VALLEY_ROCK,
                             variant_field=MATERIAL_VARIANT_FIELD)
build_reedfall_arrival_backdrop(falls, item=item, prop=prop, part=part, triangle=triangle,
                               garden_prop=garden_prop, showcase_tree=showcase_tree,
                               slate=SLATE, rock=ROCK, grass=GRASS_MAT, rock_variant=VALLEY_ROCK,
                               variant_field=MATERIAL_VARIANT_FIELD)
build_reedfall_arrival_terraces(falls, item=item, prop=prop, part=part, triangle=triangle,
                               beam=beam, garden_prop=garden_prop, rock=ROCK, grass=GRASS_MAT,
                               cedar=WOOD_PLANK, rock_variant=VALLEY_ROCK,
                               variant_field=MATERIAL_VARIANT_FIELD)

build_reedfall_west_spill(falls, item=item, prop=prop, part=part, triangle=triangle,
                          garden_shelf=garden_shelf, garden_prop=garden_prop,
                          horizontal_water_beam=horizontal_water_beam, flow_beam=reedfall_flow_beam,
                          vector=vector, asset=asset, slate=SLATE, grass=GRASS_MAT, glass=GLASS,
                          rock=ROCK, rock_variant=VALLEY_ROCK, variant_field=MATERIAL_VARIANT_FIELD)

# Two smaller drops step forward along the east shoulder. Their shallow pools
# trace the path from the upper notch to the lower basin in the arrival view.
side_spill=item(falls,"Model","Reedfall side spill")
side_falls=(
    ((37.67,40.43,-42.14,2.65), (37.81,40.21,-41.10,3.22),
     (38.02,38.99,-40.53,3.55), (38.24,35.61,-40.37,3.28),
     (38.45,33.77,-39.80,3.92)),
    ((40.24,33.56,-36.93,3.55), (40.38,32.91,-36.19,4.08),
     (40.57,29.29,-35.53,3.93), (40.84,24.88,-35.22,4.16),
     (41.06,22.10,-34.81,4.63)),
)
side_sections=((-0.50,0,-.11),(-.16,.035,.20),(.13,.054,.24),(.50,-.02,-.06))
for bands in side_falls:
    contours=[[(x+width*u,y+rise,z+reach) for u,rise,reach in side_sections]
              for x,y,z,width in bands]
    for upper,lower in zip(contours,contours[1:]):
        for index,(tint,opacity) in enumerate((("69ABC8",.20),("B0E2ED",.13),("7FBFD3",.17))):
            a,b=upper[index:index+2]
            c,d=lower[index:index+2]
            for vertices in ((a,c,d),(a,d,b)):
                triangle(side_spill,*vertices,tint,name="Reedfall side curtain",thickness=.052,
                         shadow=False,transparency=opacity)
    # A pale roll-over and broken foam line emphasize the horizontal pauses.
    for index in (1,-1):
        x,y,z,width=bands[index]
        crest=part(side_spill,"Reedfall side foam",(x+.05,y+.034,z+.28),
                   (width*.72,.062,.32 if index==1 else .65),"C6E8EB",
                   shape=0,material=GLASS,transparency=.19,collide=False)
        prop(crest,"bool","CastShadow",False)

for x,y,z,width,depth in ((37.67,40.42,-42.61,3.68,1.93),
                         (38.52,33.71,-40.21,5.1,4.83),
                         (39.97,33.55,-37.87,5.8,3.16),
                         (40.49,22.01,-34.97,7.9,3.72)):
    first=len(side_spill)
    garden_shelf(side_spill,x,y-.21,z-.51,width,depth,1.08,"988591",SLATE,collide=False)
    for stone in side_spill[first:]:
        prop(stone,"bool","CastShadow",False)
    pocket=part(side_spill,"Reedfall side plunge pool",(x,y,z),(width*.80,.081,depth*.90),
                "69AABA",shape=0,material=GLASS,transparency=.16,collide=False)
    prop(pocket,"bool","CastShadow",False)

for x,y,z,scale,yaw in ((40.47,33.83,-40.38,.26,29),(42.60,33.48,-37.91,.32,-9),
                        (43.34,22.13,-34.10,.35,44),(37.30,22.02,-34.83,.22,-21)):
    first=len(side_spill)
    garden_prop(side_spill,"bankRock",(x,y-.35,z),scale,yaw,"998B91")
    garden_prop(side_spill,"meadowCover",(x+.17,y-.09,z+.09),scale*.64,yaw+24,"829F60")
    for detail in side_spill[first:]:
        shadow=detail.find("Properties/bool[@name='CastShadow']")
        if shadow is not None:
            shadow.text="false"

air_effect(falls,"Reedfall upper lip foam",(31.76,22.26,-33.77),(4.6,.08,.73),16808075391,
           tint="DDEFF0",rate=3,lifetime=(.67,1.10),speed=(.36,.74),size=(.74,1.88),
           opacity=.32,drift=(.1,-1.15,.55),down=True,glow=.10)

garden_shelf(falls,30.52,.46,-25.15,12.45,8.91,.35,"6A858B",SLATE)
part(falls,"Waterfall catch pool",(30.52,.55,-25.19),(11.4,.12,7.81),"3C879C",
     material=GLASS,transparency=.16,collide=False,shape=0)
for index,(x,z,scale) in enumerate(((24.48,-26.43,.40),(25.44,-23.33,.37),(28.21,-21.70,.28),
                                    (33.06,-21.44,.27),(35.82,-23.79,.37),(36.27,-27.34,.54))):
    garden_prop(falls,"bankRock",(x,.15,z),scale,31+index*44,"8E818B")
    garden_prop(falls,"reeds" if index%2 else "cattails",(x+.44,.44,z+.52),.27,23+index*49)
    garden_prop(falls,"meadowCover",(x-.36,.17,z+.39),.16,31+index*34,"85A057")
lower_x,lower_z,_,_,lower_width,_=reedfall_drops[-1]
impact_x=lower_x+lower_width*.076
impact_z=lower_z+1.48
air_effect(falls, "Reedfall mist", (impact_x+.34,.81,impact_z+.32), (5.5,.3,1.9), 16830667309,
           tint="FFF0D6", rate=5, lifetime=(1.35, 2.35), speed=(1.15, 2.9),
           size=(1.55, 4.7), opacity=.35, drift=(.9, .5, 1.45), glow=.24)
air_effect(falls, "Reedfall foam ripples", (impact_x+.42,.77,impact_z+.58), (4.2,.06,1.60), 16811365086,
           tint="D8EFF1", rate=2, lifetime=(1.0, 1.65), speed=(.08,.14),
           size=(1.28,3.35), opacity=.48, drift=(0,0,0), orientation=3, glow=.15)
air_effect(falls, "Reedfall splash", (impact_x-.22,.89,impact_z+.37), (3.55,.13,.75), 16829556885,
           tint="D8F0EF", rate=3, lifetime=(.48,.88), speed=(1.15,2.15),
           size=(.68,1.54), opacity=.47, drift=(.32,-3.3,.45), glow=.16)
overlook=item(falls,"Model","Reedfall overlook")
stair(overlook,42,-18.4,7.2,5,height=.37,depth=.82)
part(overlook,"Reedfall terrace slab",(42,.875,-25.55),(12.0,1.75,7.6),"8B7986",material=SLATE)
part(overlook,"Reedfall viewing deck",(42,1.795,-25.55),(11.84,.11,7.5),"A49AA0",material=LIMESTONE)
for side in (-1,1):
    x=42+side*5.62
    for z in (-22.6,-28.8):
        part(overlook,"Overlook stone pillar",(x,2.68,z),(.7,1.65,.7),"8C7D87",material=SLATE)
    beam(overlook,"Reedfall side rail",(x,3.08,-22.6),(x,3.08,-28.8),.28,"875A4C",collide=True)
    lamp(overlook,x,3.88,-28.84,scale=.62,light=True)
beam(overlook,"Reedfall pool rail",(36.38,3.08,-28.8),(47.62,3.08,-28.8),.29,"875A4C",collide=True)
sign(overlook,"REEDFALL",42,2.68,-29.14,4.6,1.0,0,"34616C")
air_effect(landscape, "Lantern garden motes", (-40, 3.3, 31), (12, 4, 7), 14302399641,
           tint="FFD58E", rate=4, lifetime=(2.1, 3.8), speed=(.23, .8),
           size=(.16, .24), opacity=.72, drift=(.32, -.14, .14), glow=.62)
for x,z in [(-103,-91),(-99,-96),(90,-109),(109,-86),(49,-108),(-49,-104)]:
    tree(landscape,x,z,scale=1.3)

district_markers=item(scene,"Model","District Markers")
prop(district_markers,"token","ModelStreamingMode",2)
part(district_markers,"Grand Dojo City",(0,0,0),(.25,.25,.25),STONE,collide=False,transparency=1)


def route(parent,name,points,width,tint,*,surface=SANDSTONE,stone_footings=True,join_overlap=1.5,railings=True):
    """A continuous, gently graded native path with overlapping joints."""
    for start,end in zip(points,points[1:]):
        dx,dy,dz=(end[i]-start[i] for i in range(3))
        level_length=hypot(dx,dz)
        middle=tuple((u+v)/2 for u,v in zip(start,end))
        middle=(middle[0],middle[1]-.25,middle[2])
        part(parent,name,middle,(width,.5,hypot(level_length,dy)+2*join_overlap),tint,
             yaw=degrees(atan2(dx,dz)),pitch=-degrees(atan2(dy,level_length)),material=surface)
        if level_length<20:
            continue
        yaw=degrees(atan2(dx,dz))
        if stone_footings:
            for t in (.18,.5,.82):
                x,y,z=tuple(a+(b-a)*t for a,b in zip(start,end))
                height=max(1,y+3.1)
                part(parent,"Stone road footing",(x,y-.5-height/2,z),(width+2.0,height,7.4),
                     "74676F",yaw=yaw,material=SLATE)
        if railings and min(start[1],end[1]) >= 3:
            for side in (-1,1):
                offset=(side*width*.5*dz/level_length,1.05,-side*width*.5*dx/level_length)
                a=tuple(p+o for p,o in zip(start,offset))
                b=tuple(p+o for p,o in zip(end,offset))
                beam(parent,"Elevated route rail",a,b,.20,DARK,collide=True)


def road_sign(parent, origin, destination, label, tint, *, width=8, reverse_label=None):
    """Face approaching travelers from just beyond the road shoulder."""
    x,y,z=origin
    dx,dz=destination[0]-x,destination[2]-z
    length=hypot(dx,dz)
    yaw=degrees(atan2(-dx,-dz))
    shoulder=7+width/2
    x+=dx/length*2+dz/length*shoulder
    z+=dz/length*2-dx/length*shoulder
    part(parent,"Wayfinding post",(x,y+2.54,z),(.43,5.40,.43),"754438",yaw=yaw,collide=False)
    part(parent,"Wayfinding stone foot",(x,y+.25,z),(1.17,.50,1.17),"85767D",collide=False)
    sign(parent,label,x,y+4.18,z,width,1.72,yaw,tint,reverse_label=reverse_label)
    lamp(parent,x,y+5.63,z,scale=.52)


def scenic_walk(parent, label, start, end, tone, rail_tint, *, west_entry=False, rear_entry=False, rear_opening=0):
    lookout=item(parent,"Model",label)
    prop(lookout,"token","ModelStreamingMode",1)
    route(lookout,"Lookout approach",[start,end],5.20,tone)
    x,y,z=end
    part(lookout,"Overlook deck",(x,y-.24,z-2),(8,.48,6),tone,material=SLATE)
    for side in (-1,1):
        px=x+side*3.82
        for dz in (-4.82,.62):
            part(lookout,"Lookout railing post",(px,y+.72,z+dz),(.34,1.43,.34),rail_tint)
        if side>0 or not west_entry:
            beam(lookout,"Lookout side rail",(px,y+1.08,z-4.82),(px,y+1.08,z+.62),.30,rail_tint,collide=True)
        lamp(lookout,px,y+1.63,z-4.82,scale=.56)
    if rear_opening:
        for side in (-1, 1):
            beam(lookout,"Lookout rear rail",
                 (x+side*3.82,y+1.08,z-4.82),(x+side*rear_opening/2,y+1.08,z-4.82),
                 .30,rail_tint,collide=True)
    elif rear_entry:
        sign(lookout,label,x+3.68,y+2.18,z-4.67,4.60,1.19,tint=rail_tint)
    else:
        beam(lookout,"Lookout rear rail",(x-3.82,y+1.08,z-4.82),(x+3.82,y+1.08,z-4.82),.30,rail_tint,collide=True)
        sign(lookout,label,x,y+2.12,z-4.67,6.90,1.16,tint=rail_tint)
    return lookout


def path_edge(path,distance):
    normals=[]
    for (ax,_,az),(bx,_,bz) in zip(path,path[1:]):
        length=hypot(bx-ax,bz-az)
        normals.append(((bz-az)/length,(ax-bx)/length))
    edge=[]
    for i,(x,y,z) in enumerate(path):
        a,b=normals[max(0,i-1)],normals[min(i,len(normals)-1)]
        scale=distance/(1+a[0]*b[0]+a[1]*b[1])
        edge.append((x+(a[0]+b[0])*scale,y,z+(a[1]+b[1])*scale))
    return edge


build_lantern_tower_ramp(relay_skyline,item=item,prop=prop,part=part,triangle=triangle,
                        beam=beam,path_edge=path_edge,sign=sign,lantern=arrival_hanging_lantern,
                        cedar=WOOD_PLANK,slate=SLATE,metal=METAL,cedar_variant=LANDMARK_CEDAR,
                        variant_field=MATERIAL_VARIANT_FIELD)
build_skywalk_foothill(landscape,item=item,prop=prop,part=part,triangle=triangle,beam=beam,
                      path_edge=path_edge,sign=sign,garden_prop=garden_prop,lantern=arrival_hanging_lantern,
                      rock=ROCK,grass=GRASS_MAT,cedar=WOOD_PLANK,limestone=LIMESTONE,metal=METAL,
                      rock_variant=VALLEY_ROCK,path_variant=PROMENADE_STONE,variant_field=MATERIAL_VARIANT_FIELD)
build_skywalk_road_bank(landscape,item=item,prop=prop,part=part,vector=vector,asset=asset,
                        triangle=triangle,garden_prop=garden_prop,rock=ROCK,grass=GRASS_MAT,
                        cedar=WOOD_PLANK,rock_variant=VALLEY_ROCK,variant_field=MATERIAL_VARIANT_FIELD)
build_relay_runner(relay,item=item,prop=prop,triangle=triangle,path_edge=path_edge,
                   slate=SLATE,limestone=LIMESTONE,stone_variant=PROMENADE_STONE,
                   slate_variant=PROMENADE_MORTAR,variant_field=MATERIAL_VARIANT_FIELD)


def ring_forecourt(parent):
    court=item(parent,"Model","Fighting Ring forecourt")
    prop(court,"token","LevelOfDetail",4)
    center=36+ring_offset
    deck_y=ring_forecourt_y
    part(court,"Raised sandstone forecourt",(center,deck_y-.42,28.99),(16.20,.84,8.36),
         "96807A",material=LIMESTONE)
    ramp=item(court,"Model","Forecourt ramp")
    ramp_start,ramp_finish=38.75,33.14
    route(ramp,"Forecourt entry grade",[(center,.15,ramp_start),(center,deck_y,ramp_finish)],12.8,
          "97817B",surface=LIMESTONE,stone_footings=False,join_overlap=.11,railings=False)
    ramp_grade=(deck_y-.15)/(ramp_start-ramp_finish)
    ramp_top=.15+.25*((1+ramp_grade**2)**.5-1)
    palette=("B9A395","B8A093","B49A8E","C1AA9A","AF9589")
    for width,z_min,z_max,rows,grade,low in (
        (16.14,24.84,33.14,4,0,deck_y),
        (12.74,33.20,38.71,3,ramp_grade,ramp_top+(ramp_start-38.71)*ramp_grade),
    ):
        row_width=width/7
        row_depth=(z_max-z_min)/rows
        slant=hypot(1,grade)
        for row in range(rows):
            z=z_min+(row+.5)*row_depth
            y=low+(z_max-z)*grade+.011
            offset=.5*(row%2)
            edges=[0,*((column+offset)*row_width for column in range(1,7)),width]
            for column,(left,right) in enumerate(zip(edges,edges[1:])):
                x=center-width/2+(left+right)/2
                tint=ring_forecourt_pigment(palette[(row*3+column*2)%len(palette)],x-center,z)
                paver=part(court,"Staggered forecourt sandstone",(x,y,z),
                     (right-left-.055,.023,(row_depth-.056)*slant),tint,
                     pitch=degrees(atan2(grade,1)),material=LIMESTONE,collide=False)
                prop(paver,"string",MATERIAL_VARIANT_FIELD,FESTIVAL_FLAGSTONE)
                prop(paver,"bool","CastShadow",False)
    for side in (-1,1):
        end_x=center+side*8.10
        skirt_height=deck_y-.11
        part(court,"Slate forecourt apron",(end_x-side*.11,skirt_height/2+.035,29.15),(.28,skirt_height,8.16),
             "88747A",material=SLATE,collide=False)
        part(court,"Sandstone forecourt rim",(end_x-side*.08,deck_y-.01,29.12),(.20,.16,8.00),
             "C0A394",material=LIMESTONE,collide=False)
        garden=item(court,"Model","Ring forecourt rock garden")
        prop(garden,"token","ModelStreamingMode",1)
        prop(garden,"token","LevelOfDetail",4)
        for shoulder in (0,1):
            x=center+side*(10.54+shoulder*1.13)
            z=30.66+shoulder*4.05
            high=.86+shoulder*.32
            canal_side=side<0
            if canal_side:
                x-=.65+shoulder*.87
                high-=.43+shoulder*.16
            garden_shelf(garden,x,high-.16,z,6.12,5.18,high-.29,"776971",SLATE,collide=False)
            garden_shelf(garden,x+side*.10,high+.04,z-.12,5.82,4.92,.36,"9D8A8A",SLATE,collide=False)
            garden_shelf(garden,x+side*.28,high+.24,z-.18,5.03,4.61,.31,"6D8848",GRASS_MAT,collide=False)
            if shoulder==0:
                shoreline_slate(garden,x+side*.46,z-.61,high-.16,4.07,2.91,
                                .59 if canal_side else 1.67,23*side,shadow=False)
            else:
                golden_sedge(garden,x+side*.36,high+.23,z+1.06,.35 if canal_side else .93,side)
                for stalk in garden.findall("Item"):
                    if stalk.findtext("Properties/string[@name='Name']").startswith("Golden sedge"):
                        prop(stalk,"bool","CastShadow",False)
            for key,(dx,dz),size,tint in (
                ("bankRock",(1.30,-.39),.24,"96847D"),("grassBlade",(-.61,.65),.61,"D9BC74"),
                ("meadowCover",(.13,.72),.18,"93AA5D"),("meadowGrass",(1.04,.63),.23,"909F58"),
                ("mossFlowers",(-.72,-.60),.19,"E6A2AD"),("meadowFlowers",(.52,-.31),.37,"EEC184"),
                ("mossFlowers",(.92,1.16),.15,"D591A1"),("grassBlade",(1.21,-1.16),.35,"A3B462"),
                ("meadowCover",(-.82,1.06),.10,"94AC58"),("rockVine",(.19,-1.01),.12,"82A453"),
            ):
                floor=high+.24
                if key=="rockVine" and shoulder==0:
                    floor+=.34
                if canal_side and key=="grassBlade":
                    size*=.68
                if canal_side and key=="bankRock":
                    size*=.67
                garden_prop(garden,key,(x+side*dx,floor,z+dz),size,
                            side*39+shoulder*52+dx*19,tint)

    for side in (-1,1):
        x=center+side*7.38
        z=33.97
        # The shorter canal-side lantern leaves the ring steps visible from plaza arrival.
        footprint_scale, height_scale = (.75, .70) if side < 0 else (1., 1.)
        x += -.63 if side < 0 else 0
        for label,y,w,h,tint in (
            ("Slate lantern plinth",.43,1.94,.80,"77717B"),
            ("Stone lantern foot",.92,1.53,.24,"A18E88"),
            ("Stone lantern stem",1.35,.68,.69,"95817F"),
            ("Stone lantern sill",1.80,1.38,.22,"B09483"),
            ("Carved slate lantern cap",2.70,1.65,.28,"6E5960"),
            ("Bronze finial",2.92,.43,.18,"B88C51"),
        ):
            part(court,label,(x,y*height_scale,z),(w*footprint_scale,h*height_scale,w*footprint_scale),
                 tint,material=SLATE,collide=False)
        part(court,"Amber inset lantern",(x,2.20*height_scale,z),
             (1.03*footprint_scale,.66*height_scale,1.03*footprint_scale),"FFC177",material=NEON,collide=False)
        for dx in (-.58,.58):
            for dz in (-.58,.58):
                part(court,"Stone lantern aperture post",(x+dx*footprint_scale,2.20*height_scale,z+dz*footprint_scale),
                     (.21*footprint_scale,.65*height_scale,.21*footprint_scale),
                     "8B6F65",material=SLATE,collide=False)

    approach=item(court,"Model","Fighting Ring sandstone approach")
    start_x,start_z=30.0,53.7
    run_x,run_z=center-start_x,ramp_start-start_z
    distance=hypot(run_x,run_z)
    right_x,right_z=-run_z/distance,run_x/distance
    yaw=degrees(atan2(-run_x,-run_z))
    tile_depth=distance/8
    for row in range(8):
        edges=(-3.65,-1.24,1.08,3.65) if row%2==0 else (-3.65,-2.1,.16,2.26,3.65)
        for column,(a,b) in enumerate(zip(edges,edges[1:])):
            lateral=(a+b)/2
            depth=(row+.5)/8
            x=start_x+run_x*depth+right_x*lateral
            z=start_z+run_z*depth+right_z*lateral
            tint=("C8A68D","C4A18A","CAA98F")[(row+column)%3] if abs(lateral)<1.5 else palette[(row*2+column)%len(palette)]
            tile=part(approach,"Ring approach sandstone course",(x,.167,z),
                      (b-a-.06,.030,tile_depth-.05),tint,
                      yaw=yaw,material=LIMESTONE,collide=False)
            prop(tile,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
            prop(tile,"bool","CastShadow",False)


ring_forecourt(ring)
build_ring_arrival_details(ring, center=36+ring_offset, deck_lift=ring_deck_lift,
                           item=item, part=part, prop=prop, beam=beam,
                           banner=banner, slate=SLATE, limestone=LIMESTONE, wood=WOOD_PLANK, metal=METAL,
                           stone_variant=PROMENADE_MORTAR, variant_field=MATERIAL_VARIANT_FIELD)


def ring_viewing_terrace(parent):
    terrace=item(parent,"Model","Ring Viewing Terrace")
    prop(terrace,"token","ModelStreamingMode",1)
    prop(terrace,"token","LevelOfDetail",4)
    top=9.24
    west,east,north,south=65.1,80.0,-4.55,13.12
    rail_tint="904D3A"
    ramp_width=6.65
    plaza_entry=[(71.65,.15,44.46),(71.65,.15,40.52),(71.65,top,south)]
    market_exit=[(east,top,-.70),(91.15,5.89,-.70),(108.95,.15,-.70),(110.65,.15,-.70)]

    def balustrade(a,b,*,model=terrace,first_post=True,last_post=True):
        length=dist(a,b)
        count=max(1,ceil(length/3.60))
        for lift,width in ((.48,.23),(1.28,.28)):
            beam(model,"Terrace cedar guardrail",(a[0],a[1]+lift,a[2]),
                 (b[0],b[1]+lift,b[2]),width,rail_tint,collide=True)
        for index in range(0 if first_post else 1,count+int(last_post)):
            x,y,z=(u+(v-u)*index/count for u,v in zip(a,b))
            part(model,"Terrace rail newel",(x,y+.65,z),(.33,1.42,.33),"763E32")
            part(model,"Terrace newel brass cap",(x,y+1.39,z),(.46,.16,.46),"CD9B5D",collide=False)

    for path,title,first in ((plaza_entry,"Terrace plaza ramp",1),(market_exit,"Terrace market ramp",0)):
        route(terrace,title,path,ramp_width,"A68C87",surface=LIMESTONE,
              stone_footings=False,join_overlap=.19,railings=False)
        for a,b in zip(path[first:],path[first+1:]):
            dx,dy,dz=(v-u for u,v in zip(a,b))
            length=hypot(dx,dz)
            slope=atan2(dy,length)
            rows=round(length/2.35)
            for index in range(1,rows):
                fraction=index/rows
                x,y,z=(u+(v-u)*fraction for u,v in zip(a,b))
                joint=part(terrace,"Inset ramp paving joint",(x,y+.25*(1/cos(slope)-1)+.009,z),
                           (6.04,.017,.065),"917E83",yaw=degrees(atan2(dx,dz)),pitch=-degrees(slope),
                           material=LIMESTONE,collide=False)
                prop(joint,"bool","CastShadow",False)
        for side in (-1,1):
            rail=path_edge(path,side*3.15)
            for a,b in zip(rail[first:],rail[first+1:]):
                if max(a[1],b[1])<=.70:
                    continue
                balustrade(a,b)
                if a[1]>2.4 or b[1]>2.4:
                    beam(terrace,"Terrace ramp fascia",(a[0],a[1]-.35,a[2]),
                         (b[0],b[1]-.35,b[2]),.57,"73636E")
    for a,b in (((56.65,.18,38.48),(65.01,.18,42.10)),
                ((65.01,.195,42.10),(71.65,.195,44.18))):
        route(terrace,"Terrace plaza landing",[a,b],6.10,"AF968D",surface=LIMESTONE,
              stone_footings=False,join_overlap=.72,railings=False)
    route(terrace,"Terrace causeway landing",[(110.65,.167,-.70),(110.65,.167,11.95)],7.42,
          "AF968D",surface=LIMESTONE,stone_footings=False,join_overlap=.42,railings=False)

    midpoint=((west+east)/2,top-.36,(south+north)/2)
    part(terrace,"Terrace limestone deck",midpoint,(east-west,.72,south-north),
         "AB9594",material=LIMESTONE)
    for row in range(5):
        for column in range(4):
            x=west+(column+.5)*(east-west)/4
            z=north+(row+.5)*(south-north)/5
            tint=("BFADA8","AF9894","B6A29A","C1A79A")[(row+3*column)%4]
            stone=part(terrace,"Terrace floor inlay",(x,top+.009,z),
                       ((east-west)/4-.055,.016,(south-north)/5-.057),tint,
                       material=LIMESTONE,collide=False)
            prop(stone,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
            prop(stone,"bool","CastShadow",False)
    for x in (66.40,72.55,78.74):
        for z in (-3.26,9.0):
            part(terrace,"Terrace dressed slate plinth",(x,.48,z),(1.91,1.15,1.91),"7F6C77",material=SLATE)
            part(terrace,"Terrace limestone pier",(x,4.58,z),(1.39,7.62,1.39),"907B82",material=SLATE)
            part(terrace,"Terrace carved corbel",(x,8.23,z),(1.92,.87,1.91),"AD9492",material=SLATE)
    for x,z,height in ((68.61,31.5,3.16),(74.70,23.10,5.74),
                       (87.0,-3.56,6.84),(98.20,-3.56,3.41)):
        part(terrace,"Ramp slate pier",(x,height/2,z),(1.24,height,1.30),
             "86737A",material=SLATE)
        part(terrace,"Ramp cedar bearing",(x,height,z),(1.52,.29,1.48),
             "945745",material=WOOD_PLANK,collide=False)
    balcony_north,balcony_south=-3.37,8.93
    balustrade((west+.26,top,north+.24),(west+.26,top,balcony_north),first_post=False)
    balustrade((west+.26,top,balcony_south),(west+.26,top,south-.24),last_post=False)
    for ax,az,bx,bz in ((west+.26,north+.24,71.45,north+.24),
                        (77.05,north+.24,east-.24,north+.24),
                        (west+.26,south-.24,68.50,south-.24),
                        (74.80,south-.24,east-.24,south-.24),
                        (east-.24,2.45,east-.24,south-.24)):
        balustrade((ax,top,az),(bx,top,bz))

    balcony=item(terrace,"Model","Ring spectator balcony")
    prop(balcony,"token","LevelOfDetail",4)
    deck_x,deck_z=62.86,(balcony_north+balcony_south)/2
    floor=part(balcony,"Spectator limestone deck",(deck_x,top-.247,deck_z),
               (5.21,.52,12.77),"AA918A",material=LIMESTONE)
    prop(floor,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
    for z in (-2.35,.16,2.70,5.23,7.75):
        part(balcony,"Spectator cedar floor joint",(62.70,top+.019,z),(4.68,.018,.065),
             "93777B",material=WOOD_PLANK,collide=False)
    front=60.50
    balustrade((front,top,balcony_north),(front,top,balcony_south),model=balcony)
    for z in (balcony_north,balcony_south):
        balustrade((front,top,z),(west+.26,top,z),model=balcony,first_post=False,last_post=False)
        beam(balcony,"Cantilever timber brace",(65.82,6.34,z),(61.31,8.66,z),.63,"805343")
        beam(balcony,"Balcony cedar outlook girder",(60.35,8.84,z),(66.41,8.84,z),.38,"76504A")
    seat_x=61.67
    for z in (-.77,2.77,6.31):
        seat=part(balcony,"Ring spectator seat",(seat_x,top+.53,z),(1.70,.19,1.10),
                  "B07750",yaw=90,material=WOOD_PLANK,class_name="Seat")
        seat.find("Properties/bool[@name='CanTouch']").text="true"
        part(balcony,"Spectator slate seat base",(seat_x,top+.21,z),(.72,.44,1.15),
             "8F7D86",material=SLATE,collide=False)
        for offset in (-.66,.66):
            part(balcony,"Brass bench end binding",(seat_x,top+.51,z+offset),(1.12,.105,.13),
                 "CC9A57",material=METAL,collide=False)
    for z in (balcony_north+.34,balcony_south-.38):
        lamp_x=62.15
        part(balcony,"Balcony lantern slate plinth",(lamp_x,top+.17,z),(.88,.33,.91),
             "8D787F",material=SLATE,collide=False)
        store_standing_lantern(balcony,(lamp_x,top+.35,z),.38,light=False)
        garden_prop(balcony,"mossFlowers",(lamp_x+.72,top+.02,z),.084,68,"F0B5BA")
        garden_prop(balcony,"meadowCover",(lamp_x-.67,top+.03,z),.07,31,"9BA86D")
    sign(balcony,"RING BALCONY",63.20,top+1.62,balcony_south+.04,4.81,.78,tint="884633")

    # Keep the deck center and the view behind a player entering the skybridge open.
    shelter=item(terrace,"Model","Terrace cedar shelter")
    shelter_x=78.19
    for x in (76.62,79.14):
        for z in (3.82,10.17):
            part(shelter,"Cedar shelter pillar",(x,top+2.62,z),(.69,5.24,.69),
                 "A64A35",material=WOOD_PLANK)
            for lift in (.37,4.86):
                part(shelter,"Shelter brass ferrule",(x,top+lift,z),(.82,.19,.82),"C48D57",collide=False)
        festival_lantern(shelter,x,top+4.34,9.61,.68,light=False)
    swept_roof(shelter,shelter_x,top+5.28,6.995,4.82,8.68,2.32,fine_tiles=False)
    sign(shelter,"RING VIEWING TERRACE",shelter_x,top+4.78,10.44,4.57,.91,tint="845039",face_only=True)
    bench_x=78.24
    for z in (5.06,8.39):
        part(shelter,"Bench stone base",(bench_x,top+.22,z),(.65,.44,.68),"8D7883",material=SLATE)
    part(shelter,"Bench cedar seat",(bench_x,top+.57,6.73),(.89,.22,4.17),"AA7453",material=WOOD_PLANK)
    part(shelter,"Bench cedar back",(bench_x+.43,top+.97,6.73),(.16,.57,4.17),"AA7453",material=WOOD_PLANK)
    for x,z,yaw in ((66.66,-2.96,30),(78.59,12.17,102),(67.11,11.70,65)):
        part(terrace,"Terrace slate planter",(x,top+.24,z),(1.71,.48,1.64),"947F8B",material=SLATE,
             collide=False)
        garden_prop(terrace,"meadowCover",(x,top+.46,z),.093,yaw,"A0B975")
        garden_prop(terrace,"mossFlowers",(x+.16,top+.47,z+.14),.104,yaw,"E9A6B9")
        garden_prop(terrace,"meadowFlowers",(x-.29,top+.50,z-.21),.23,yaw+38,"F5BC8D")
    for x,z,yaw in ((66.96,43.60,-9),(114.77,2.98,48)):
        part(terrace,"Terrace wayfinding post",(x,1.46,z),(.38,2.65,.41),
             "864B3C",material=WOOD_PLANK,collide=False)
        sign(terrace,"RING VIEWING TERRACE",x,2.40,z,5.95,.98,yaw,"596A58")

    signpost_x,signpost_z=68.98,-3.58
    part(terrace,"Skybridge junction post",(signpost_x,top+1.72,signpost_z),(.40,3.48,.45),
         "864B3C",material=WOOD_PLANK,collide=False)
    sign(terrace,"WEAVERS’ WALK  ↑",signpost_x,top+3.05,signpost_z,5.25,.88,tint="37655E")
    sign(terrace,"TIDEHARBOR ROAD  →",signpost_x,top+1.78,signpost_z,5.25,.88,tint="596A58")


ring_viewing_terrace(scene)
build_cedarbank_rise(landscape, item=item, prop=prop, part=part, triangle=triangle, beam=beam,
                    route=route, path_edge=path_edge, garden_prop=garden_prop, sign=sign, lamp=lamp,
                    stone=LIMESTONE, slate=SLATE, cedar=WOOD_PLANK, grass=GRASS_MAT, rock=ROCK,
                    metal=METAL, rock_variant=VALLEY_ROCK, variant_field=MATERIAL_VARIANT_FIELD)


def promenade_garden(parent):
    garden=item(parent,"Model","Promenade Garden")
    prop(garden,"token","ModelStreamingMode",1)
    prop(garden,"token","LevelOfDetail",4)
    walk=[(19.0,.225,58),(20.80,.225,55.50),(21.05,1.52,50.0),(21.05,1.52,44.20),
          (20.15,.225,39.0),(18.4,.225,37.70)]
    route(garden,"Promenade Garden walk",walk,5.20,"A39391",surface=LIMESTONE,stone_footings=False,
          join_overlap=.34,railings=False)
    for slab in garden.findall("Item"):
        prop(slab,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)

    seat_y=1.575
    deck=part(garden,"Garden seating terrace",(18.71,seat_y-.205,47.16),(5.18,.41,5.10),
              "A69396",material=LIMESTONE)
    prop(deck,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
    garden_shelf(garden,18.71,seat_y-.37,47.16,5.45,5.54,1.18,"8C7A85",SLATE,collide=False)
    for z in (46.13,48.10):
        part(garden,"Garden bench slate foot",(16.81,seat_y+.23,z),(.84,.46,.52),"80717D",material=SLATE)
    part(garden,"Canal-facing cedar bench",(16.81,seat_y+.54,47.10),(1.08,.29,3.10),
         "9E664F",material=WOOD_PLANK)
    beam(garden,"Terrace low rail",(16.25,seat_y+.74,44.7),(16.25,seat_y+.74,49.61),.22,
         "8F5545",collide=True)
    for z in (44.76,49.61):
        part(garden,"Garden terrace newel",(16.30,seat_y+.42,z),(.52,.84,.52),"7F6E78",material=SLATE)
        lamp(garden,16.30,seat_y+1.09,z,scale=.54)
    rim=path_edge(walk,-2.44)
    for start,end in zip(rim[1:-2],rim[2:-1]):
        beam(garden,"Garden east coping",(start[0],start[1]+.57,start[2]),
             (end[0],end[1]+.57,end[2]),.225,"93614E",collide=True)
        x,y,z=start
        part(garden,"Garden rail stone foot",(x,y+.31,z),(.46,.62,.46),"93828A",material=SLATE,collide=False)
    for index,(x,z,high,width,depth,rock_scale) in enumerate((
        (15.42,54.02,.91,3.67,3.50,.32), (24.36,52.97,.71,2.99,4.72,.18),
        (24.26,44.49,.95,2.67,4.82,.14), (16.10,41.76,.77,3.15,3.40,.32),
    )):
        garden_shelf(garden,x,high,z,width,depth,high-.05,"92828D",SLATE,collide=False)
        garden_shelf(garden,x+.10,high+.14,z+.12,width-.42,depth-.48,.25,"74864D",GRASS_MAT,collide=False)
        garden_prop(garden,"bankRock",(x+.25,high-.16,z-.68),rock_scale,15+index*43,"96848B")
        garden_prop(garden,"meadowGrass",(x-.37,high+.13,z+.28),.18,32+index*37,"A2AD6D")
        garden_prop(garden,"grassBlade",(x+.62,high+.11,z+.55),.40,85+index*36,"CCB17D")
        garden_prop(garden,"mossFlowers",(x-.18,high+.12,z-.43),.16,40+index*32,"E7ACB9")
        garden_prop(garden,"meadowFlowers",(x+.31,high+.15,z+.37),.36,22+index*28,"F3C286")
    part(garden,"Garden wayfinding post",(17.43,1.77,39.86),(.32,3.16,.32),
         "8C5C46",material=WOOD_PLANK,collide=False)
    sign(garden,"PROMENADE GARDEN",17.43,3.03,40.03,4.96,.82,157,"4A6C50")



promenade_garden(plaza)


def arrival_canal_lookout(parent):
    lookout=item(parent,"Model","Arrival canal lookout")
    prop(lookout,"token","ModelStreamingMode",1)
    prop(lookout,"token","LevelOfDetail",4)
    top=1.14
    south_shift=5.0
    path=[(-5.85,.15,62.8),(-11.72,top,62.8)]
    route(lookout,"Lookout approach",path,3.70,"9D8A83",surface=LIMESTONE,
          join_overlap=.16,railings=False)
    for slab in lookout.findall("Item"):
        prop(slab,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
    first_cheek=len(lookout)
    for z in (60.96,64.64):
        triangle(lookout,(-5.81,.14,z),(-11.72,.14,z),(-11.72,top-.15,z),
                 "847680",name="Slate ramp cheek",thickness=.16,material=SLATE,collide=False)
        beam(lookout,"Sandstone ramp edge",(-5.83,.12,z),(-11.73,top-.03,z),.11,"A59585")
    for stone in list(lookout)[first_cheek:]:
        if stone.findtext("Properties/token[@name='Material']")==str(SLATE):
            prop(stone,"string",MATERIAL_VARIANT_FIELD,PROMENADE_MORTAR)
    incline=-degrees(atan2(top-.15,5.87))
    # Form six rose-stone courses over the common ramp collider.
    span=hypot(5.87,top-.15)
    surface_rise=.25*(1/cos(radians(incline))-1)
    course_tints=("B3998C","AD9388","C0A497","AD9189","B59C90","A58A83")
    for course,tint in enumerate(course_tints):
        fraction=(course+.5)/len(course_tints)
        for (width,across) in (((1.32,-1.17),(2.31,.67)) if course%2 else ((1.90,-.86),(1.73,.98))):
            pad=part(lookout,"Fitted rose-stone ramp course",
                     (-5.85-5.87*fraction,.15+(top-.15)*fraction+surface_rise+.012,62.8+across),
                     (width,.030,span/len(course_tints)-.042),tint,yaw=-90,pitch=incline,
                     material=LIMESTONE,collide=False)
            prop(pad,"string",MATERIAL_VARIANT_FIELD,SUNSET_FLAGSTONE)
            prop(pad,"bool","CastShadow",False)

    for x in (-16.32,-12.67):
        for z in (58.39,64.76):
            part(lookout,"Slate lookout footing",(x,-1.55,z),(1.22,4.24,1.22),
                 "85747D",material=SLATE,collide=False)
            part(lookout,"Cedar lookout brace",(x,.43,z),(1.04,.95,1.04),
                 "785141",material=WOOD_PLANK,collide=False)
    part(lookout,"Cedar lookout beam",(-14.60,top-.46,61.80),(5.95,.40,8.92),
         "615149",material=WOOD_PLANK,collide=False)
    for index in range(14):
        board=part(lookout,"Lookout cedar deck board",(-14.64,top-.15,57.67+index*.635),
                   (5.89,.30,.652),("796456","846B58","8B7361","7E6757")[index%4],
                   material=WOOD_PLANK)
        prop(board,"string",MATERIAL_VARIANT_FIELD,ARENA_CEDAR)

    # The cedar profiles sit inside the original guard volumes to retain the deck boundary.
    for x,z in ((-17.44,57.48),(-17.44,61.47),(-17.44,66.04),(-14.57,66.04),
                (-11.85,66.04),(-11.85,57.48),(-14.57,57.48),(-11.85,60.66),(-11.85,64.96)):
        guard=part(lookout,"Vermilion lookout newel",(x,top+.58,z),(.44,1.16,.44),
                   "943F30",material=WOOD_PLANK,transparency=1)
        prop(guard,"bool","CastShadow",False)
        part(lookout,"Weathered lookout cedar newel",(x,top+.58,z),(.29,1.16,.29),
             "73594B",material=WOOD_PLANK,collide=False)
        cap=part(lookout,"Lookout aged brass cap",(x,top+1.15,z),(.34,.075,.34),
                 "947454",material=METAL,collide=False)
        prop(cap,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
    for x1,z1,x2,z2 in ((-17.44,57.48,-17.44,66.04),(-17.44,66.04,-11.85,66.04),
                        (-17.44,57.48,-11.85,57.48),(-11.85,57.48,-11.85,60.66),
                        (-11.85,64.96,-11.85,66.04)):
        for level,old_tint,tint,width in ((.42,"873A31","685247",.095),
                                         (1.02,"A7533C","785C4E",.135)):
            start,end=(x1,top+level,z1),(x2,top+level,z2)
            guard=beam(lookout,"Lookout cedar rail",start,end,.23,old_tint,collide=True)
            guard.find("Properties/float[@name='Transparency']").text="1"
            prop(guard,"bool","CastShadow",False)
            rail=beam(lookout,"Weathered lookout cedar rail",start,end,width,tint)
            rail.find("Properties/token[@name='Material']").text=str(WOOD_PLANK)
        bays=max(1,round(hypot(x2-x1,z2-z1)/1.75))
        for i in range(1,bays):
            fraction=i/bays
            part(lookout,"Lookout rail slat",(x1+(x2-x1)*fraction,top+.72,z1+(z2-z1)*fraction),
                 (.064,.55,.064),"6C564A",material=WOOD_PLANK,collide=False)
    for x,z in ((-17.44,57.48),(-17.44,66.04)):
        festival_lantern(lookout,x,top+1.51,z,.39,light=False)

    seat_x,seat_z,seat_yaw=-13.36,59.55,70
    c,s=cos(radians(seat_yaw)),sin(radians(seat_yaw))
    for arm in (-1.19,1.19):
        x,z=seat_x+c*arm,seat_z-s*arm
        part(lookout,"Canal bench stone foot",(x,top+.24,z),(.34,.48,.57),
             "8C7984",yaw=seat_yaw,material=SLATE,collide=False)
        part(lookout,"Canal bench end",(x,top+.52,z),(.40,.15,1.16),
             "A26D56",yaw=seat_yaw,material=WOOD_PLANK,collide=False)
    seat=part(lookout,"Canal bench seat",(seat_x,top+.52,seat_z),(1.99,.15,1.16),
              "A26D56",yaw=seat_yaw,material=WOOD_PLANK,class_name="Seat")
    seat.find("Properties/bool[@name='CanTouch']").text="true"
    part(lookout,"Canal bench back",(seat_x+s*.58,top+.98,seat_z+c*.58),(3.04,.51,.16),
         "90503E",yaw=seat_yaw,material=WOOD_PLANK,collide=False)

    plantings=item(lookout,"Model","Lookout bank planting")
    for x,z,width,depth,yaw in ((-11.24,66.36,3.30,2.04,38),(-7.10,66.21,3.28,2.75,110),
                                (-11.04,58.02,2.23,2.50,74)):
        garden_shelf(plantings,x,.64,z,width,depth,.59,"857781",SLATE,collide=False)
        garden_shelf(plantings,x+.08,.78,z-.06,width-.39,depth-.27,.20,"6B814E",GRASS_MAT,collide=False)
        shoreline_slate(plantings,x-.43,z+.14,.42,width*.56,depth*.77,.65,yaw)
        for key,dx,dz,y,scale,tint in (
            ("bankRock",-.29,.26,.70,.13,"99868E"),
            ("meadowCover",.47,.31,.77,.15,"A0B65D"),
            ("mossFlowers",.07,-.50,.77,.15,"F0B0B7"),
            ("grassBlade",-.14,.11,.74,.37,"C7AC74"),
            ("meadowFlowers",.43,-.42,.76,.30,"F0CB8D"),
            ("meadowGrass",-.41,.34,.76,.20,"A1AB67"),
        ):
            garden_prop(plantings,key,(x+dx,y,z+dz),scale,yaw,tint)
        for i,lift in enumerate((.78,1.32,1.74,1.49,1.02)):
            dx=(i-2)*.13
            root=(x+.48+dx,.74,z+.40+(.08 if i%2 else -.06))
            tip=(root[0]+dx*.95,root[1]+lift*.67,root[2]-.18)
            beam(plantings,"Golden bank stalk",root,tip,.042,"A08E5D")
            part(plantings,"Golden bank plume",tip,(.18,.36,.17),
                 ("D7BA85","C1A470","DDC18C")[i%3],roll=-18*dx/.26,pitch=-15,shape=0,collide=False)
    for placement in lookout.iter("CoordinateFrame"):
        z=placement.find("Z")
        z.text=f"{float(z.text)+south_shift:.7g}"


arrival_canal_lookout(plaza)


def arrival_festival_board(parent):
    stand=item(parent,"Model","Arrival Festival Board")
    prop(stand,"token","ModelStreamingMode",1)
    prop(stand,"token","LevelOfDetail",4)
    x,z,yaw=-9.15,65.49,32
    scale=.65
    c,s=cos(radians(yaw)),sin(radians(yaw))

    def location(offset, y, front=0):
        return x+scale*(offset*c+front*s),.15+scale*(y-.15),z+scale*(-offset*s+front*c)

    def board_piece(name, offset, y, front, size, tint, material=WOOD_PLANK, *, collide=False):
        detail=part(stand,name,location(offset,y,front),tuple(scale*dimension for dimension in size),tint,
                    yaw=yaw,material=material,collide=collide)
        if material==WOOD_PLANK:
            prop(detail,"string",MATERIAL_VARIANT_FIELD,LANDMARK_CEDAR)
        elif material==METAL:
            prop(detail,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
        return detail

    for side in (-1,1):
        column=side*1.96
        foot=side*1.88
        board_piece("Event board slate footing",foot,.38,0,(.74,.49,.72),"8B7580",SLATE,collide=True)
        board_piece("Event board footing cap",foot,.64,0,(.66,.14,.66),"B2938F",LIMESTONE)
        board_piece("Event board cedar upright",column,2.40,0,(.47,3.51,.53),"9A5943",collide=True)
        board_piece("Event board upright insert",column,2.39,.274,(.22,3.08,.063),"B8764F")
        board_piece("Event board brass pin",column,3.66,.322,(.12,.14,.045),"D4A55E",METAL)
    board=board_piece("EventBoard",0,2.42,0,(3.53,2.73,.37),"6D3331",collide=True)
    board_piece("Vermilion event board field",0,2.42,.212,(3.36,2.47,.12),"883A35")
    for y,width,tint in ((1.16,4.54,"915840"),(3.81,4.70,"A36747"),(4.08,4.88,"B87952")):
        board_piece("Event board cedar crosspiece",0,y,.02,(width,.21,.61),tint)
    for y in (1.29,3.50):
        board_piece("Event board brass inlay",0,y,.278,(3.24,.058,.04),"CF9962",METAL)
    for side in (-1,1):
        board_piece("Event board painted border",side*1.64,2.39,.281,
                    (.059,2.16,.04),"CF9962",METAL)
    lettering=sign(stand,"EVENT BOARD",*location(0,3.17,.05),3.14*scale,.60*scale,
                   yaw,"883A35",face_only=True)
    canvas=lettering.find("Item/Properties/Vector2[@name='CanvasSize']")
    canvas.find("X").text="157"
    canvas.find("Y").text="30"
    reed_mark(stand,*location(-.15,2.06,.325),.56*scale,yaw=yaw)

    prompt=item(board,"ProximityPrompt","BoardPrompt")
    prop(prompt,"string","ActionText","Open event board")
    prop(prompt,"string","ObjectText","Festival Plaza")
    prop(prompt,"float","MaxActivationDistance",11.6)
    prop(prompt,"bool","RequiresLineOfSight",False)

    lantern_position=location(2.12,.42,.57)
    board_piece("Event board lantern stone rest",2.12,.26,.57,(.69,.31,.69),"8E7B84",SLATE)
    craft_board_lantern(stand,*lantern_position,.65,**ARRIVAL_LANTERN_STYLE,yaw=yaw)
    for key,offset,front,size,tint in (
        ("bankRock",-2.18,.65,.12,"AC9397"),
        ("meadowCover",-1.89,.73,.145,"9CB167"),
        ("mossFlowers",-1.73,.62,.13,"E8ABB5"),
        ("meadowFlowers",2.70,.68,.22,"E5B575"),
    ):
        garden_prop(stand,key,location(offset,.18,front),size*scale,yaw+33,tint)


arrival_festival_board(plaza)

build_lantern_garden_walk(
    plaza, item=item, prop=prop, part=part, triangle=triangle, beam=beam, route=route, path_edge=path_edge,
    sign=sign, festival_lantern=festival_lantern, garden_shelf=garden_shelf, garden_prop=garden_prop,
    showcase_tree=showcase_tree, stone=LIMESTONE, cedar=WOOD_PLANK, grass=GRASS_MAT, slate=SLATE,
    metal=METAL, flagstone_variant=SUNSET_FLAGSTONE, variant_field=MATERIAL_VARIANT_FIELD,
)


def arrival_boulder(parent,x,y,z,width,height,depth,yaw):
    """Shape a tilted rock with a dark shoulder and a sunlit stone cap."""
    outline=((-1,-.43),(-.42,-.97),(.62,-.85),(1,.08),(.47,1),(-.83,.80))
    crown_heights=(.79,.88,1.0,.91,.73,.65)
    c,s=cos(radians(yaw)),sin(radians(yaw))
    levels=[]
    for lift,spread,shift in ((0,.76,-.04),(.35,1,0),(1,.72,-.17)):
        ring=[]
        for (u,v),top in zip(outline,crown_heights):
            px,pz=(u*spread+shift)*width*.5,v*spread*depth*.5
            ring.append((x+c*px+s*pz,y+lift*top*height,z-s*px+c*pz))
        levels.append(ring)
    palette=(("786773","827180","84747F","6F6375","756778","786B79"),
             ("9F8B93","B5A0A2","A28C94","887481","93808E","A68F99"))
    for tones,(lower,upper) in zip(palette,zip(levels,levels[1:])):
        for i,(a,b) in enumerate(zip(lower,upper)):
            neighbor=(i+1)%len(outline)
            triangle(parent,a,lower[neighbor],b,tones[i],name="Arrival boulder face",material=ROCK,shadow=False)
            triangle(parent,b,lower[neighbor],upper[neighbor],tones[i],name="Arrival boulder face",material=ROCK,shadow=False)
    crown=levels[-1]
    for i,(a,b) in enumerate(zip(crown[1:-1],crown[2:])):
        triangle(parent,crown[0],a,b,("B6A4A2","A59097","B09A9B","BCA8A4")[i],
                 name="Arrival boulder face",material=ROCK,shadow=False)


def arrival_planting(parent,x,z,scale,lean,*,wet_bank=False,sunlit_front=False):
    bank=item(parent,"Model","Sunlit arrival planting")
    prop(bank,"token","ModelStreamingMode",1)
    prop(bank,"token","LevelOfDetail",4)
    if wet_bank:
        garden_shelf(bank,x-.11,.22,z,4.4*scale,5.28*scale,1.35,"80717D",SLATE,collide=False)
    for dx,dz,top,width,depth,height,tint,material in (
        (0,0,.43,4.77,5.57,.30,"91808A",SLATE),
        (.08*lean,-.12,.70,4.32,5.15,.42,"AE999A",SLATE),
        (.19*lean,-.16,.91,3.85,4.67,.33,"77994B",GRASS_MAT),
    ):
        garden_shelf(bank,x+dx*scale,top*scale,z+dz*scale,width*scale,depth*scale,
                     height*scale,tint,material,collide=False)
    for key,dx,dy,dz,size,yaw,tint in (
        ("bankRock",.95,.40,.47,.27,39,"AA979D"),
        ("bankRock",-1.14,.48,-1.15,.20,104,"8D8193"),
        ("mossFlowers",.48,.87,-.54,.16,79,"E898A8"),
        ("meadowCover",.08,.90,.77,.17,42,"AAC06D"),
        ("meadowGrass",.86,.90,.53,.19,121,"ADBA69"),
        ("meadowFlowers",-.52,.91,-1.16,.36,121,"F1BD82"),
        ("grassBlade",-.87,.89,.65,.44,39,"D5B974"),
        ("grassBlade",.67,.89,-.84,.31,111,"ADBC6D"),
        ("mossFlowers",-.75,.84,.58,.14,103,"E0A1A9"),
        ("meadowGrass",.35,.78,1.42,.16,70,"9ABD62"),
        ("meadowCover",-.41,.89,-1.02,.14,124,"A8BF64"),
        ("grassBlade",.72,.90,1.11,.52,72,"D6C172"),
    ):
        if sunlit_front and key=="bankRock" and dx>0:
            dx,dy,dz,size,tint=1.39,.50,.44,.193,"766C72"
        if sunlit_front and key=="grassBlade":
            size*=.72
        garden_prop(bank,key,(x+dx*scale,dy*scale,z+dz*scale),size*scale,yaw*lean,tint)
    if sunlit_front:
        for dx,dz,width,height,depth,yaw,moss in ((-.29,.59,1.72,1.14,1.67,33,True),
                                                  (-.65,-1.02,1.79,.94,1.55,81,False)):
            build_bank_stone(bank,(x+dx*scale,.44*scale,z+dz*scale),
                             (width*scale,height*scale,depth*scale),yaw,
                             triangle=triangle,prop=prop,rock=ROCK,leaf=LEAFY_GRASS,
                             stone_variant=BANK_STONE,variant_field=MATERIAL_VARIANT_FIELD,moss=moss)
        for key,dx,dz,size,yaw,tint in (("meadowCover",.19,.94,.178,49,"9AB55D"),
                                         ("meadowGrass",.04,1.5,.137,13,"779B4D"),
                                         ("mossFlowers",-.61,1.22,.143,91,"F1AEBC"),
                                         ("meadowCover",.28,-.61,.154,58,"93AC50")):
            garden_prop(bank,key,(x+dx*scale,.91*scale,z+dz*scale),size*scale,yaw,tint)
        for dx,dz,size,fan in ((.49,1.03,1.05,1),(.99,1.21,.83,1),(-.75,-.45,.53,-1)):
            build_golden_plumes(bank,(x+dx*scale,.91*scale,z+dz*scale),size*scale,fan,
                                part=part,prop=prop,beam=beam,triangle=triangle,grass=LEAFY_GRASS)
    else:
        for dx,dz,w,h,d,yaw in ((.61*lean,.66,2.54,1.78,2.35,27),(-.67*lean,-1.08,2.15,1.21,1.76,94)):
            arrival_boulder(bank,x+dx*scale,.47*scale,z+dz*scale,w*scale,h*scale,d*scale,yaw*lean)
        for dx,dz,size in ((-.73,.29,1.3),(.72,-.92,.87)):
            golden_sedge(bank,x+dx*scale,.90*scale,z+dz*scale,scale*size,lean)
    for plant in bank.findall("Item"):
        label=plant.findtext("Properties/string[@name='Name']")
        if label.startswith("Golden sedge"):
            prop(plant,"bool","CastShadow",False)
        elif label=="Arrival boulder face":
            prop(plant,"string",MATERIAL_VARIANT_FIELD,VALLEY_ROCK)


arrival_planting(plaza,11.83,66.08,1.13,1,sunlit_front=True)
arrival_planting(plaza,15.07,62.52,.79,-1)
arrival_planting(arrival_water,-27.76,54.60,.91,-1,wet_bank=True)
build_arrival_bank_planting(plaza,item=item,prop=prop,beam=beam,triangle=triangle,
                            garden_prop=garden_prop,grass=LEAFY_GRASS)
# The near end of the east bed gives the camera a ground-level frame.
plume_bank=item(plaza,"Model","Arrival plume bank")
prop(plume_bank,"token","ModelStreamingMode",1)
prop(plume_bank,"token","LevelOfDetail",4)
for top,width,depth,height,tint,material in (
    (.40,3.88,3.32,.31,"857578",SLATE),
    (.61,3.58,2.96,.27,"A88E82",SLATE),
    (.76,3.32,2.68,.22,"778C40",LEAFY_GRASS),
):
    garden_shelf(plume_bank,10.38,top,69.12,width,depth,height,tint,material,collide=False)
for shelf in plume_bank.findall("Item"):
    prop(shelf,"bool","CastShadow",False)
build_bank_stone(plume_bank,(9.85,.46,69.45),(1.62,.88,1.41),-28,
                 triangle=triangle,prop=prop,rock=ROCK,leaf=LEAFY_GRASS,
                 stone_variant=BANK_STONE,variant_field=MATERIAL_VARIANT_FIELD,moss=True)
for key,x,z,scale,yaw,tint in (
    ("meadowCover",9.63,68.50,.19,73,"9BAD54"),
    ("meadowGrass",9.28,68.68,.19,33,"8FA54C"),
    ("meadowGrass",9.18,69.29,.16,110,"A0AB4C"),
    ("meadowCover",10.19,68.70,.20,118,"89A248"),
    ("mossFlowers",10.35,69.44,.12,55,"ECB4B1"),
    ("meadowFlowers",9.05,69.06,.24,103,"F0CC92"),
):
    garden_prop(plume_bank,key,(x,.75,z),scale,yaw,tint)
build_golden_plumes(plume_bank,(9.01,.75,68.57),1.05,-1,
                   part=part,prop=prop,beam=beam,triangle=triangle,grass=LEAFY_GRASS)

# Pampas Grass by cube3D. Use just the screened render mesh and its texture.
pampas=item(plume_bank,"Model","Creator Store pampas accent")
pampas_original=(4.0,5.56048584,3.95563745)
pampas_size=tuple(axis*.36 for axis in pampas_original)
tuft=part(pampas,"Cream pampas tuft",(9.64,.75+pampas_size[1]/2,69.00),pampas_size,"A3A2A5",
          yaw=-38,collide=False,class_name="MeshPart")
vector(tuft,"Vector3","InitialSize",("X","Y","Z"),pampas_original)
prop(tuft,"bool","CastShadow",False)
prop(tuft,"token","RenderFidelity",0)
asset(tuft,"MeshContent","rbxassetid://108046810556749")
asset(tuft,"TextureContent","rbxassetid://83306621502526")

pine_garden=item(foreground,"Model","East arrival pine garden")
prop(pine_garden,"token","ModelStreamingMode",1)
prop(pine_garden,"token","LevelOfDetail",4)
pine_x,pine_z=34.4,51.5
for dx,dz,top,width,depth,height,tint,material in (
    (-.18,.12,.42,6.7,6.15,.36,"847684",SLATE),
    (0,0,.79,6.23,5.73,.55,"9E8A8B",SLATE),
    (.15,-.26,1.05,5.45,4.79,.40,"718747",GRASS_MAT),
):
    garden_shelf(pine_garden,pine_x+dx,top,pine_z+dz,width,depth,height,tint,material,collide=False)
showcase_tree(pine_garden,pine_x,pine_z,False,1.55,12,1.045,
              height_scale=1.72,relief_crown=True,hero_crown=True)
for dx,dz,size,height,yaw in ((-2.02,1.18,1.38,1.29,27),(1.96,-1.28,1.71,1.43,83)):
    arrival_boulder(pine_garden,pine_x+dx,.53,pine_z+dz,size,height,size*.82,yaw)
for key,dx,dz,scale,yaw,tint in (
    ("bankRock",-1.20,-1.70,.22,42,"948390"),
    ("meadowCover",1.15,-1.60,.18,19,"A6BB67"),
    ("meadowGrass",.70,1.66,.22,102,"A4B166"),
    ("grassBlade",-1.45,.96,.47,63,"DBC081"),
    ("mossFlowers",-1.42,-.53,.12,94,"E5A1AE"),
    ("meadowFlowers",1.28,1.29,.38,83,"F2BF82"),
    ("meadowCover",.45,-1.70,.15,24,"99B45F"),
    ("grassBlade",1.51,-.92,.35,71,"C7B077"),
):
    garden_prop(pine_garden,key,(pine_x+dx,1.02,pine_z+dz),scale,yaw,tint)

blossom_garden=item(foreground,"Model","Relay bank blossom garden")
prop(blossom_garden,"token","ModelStreamingMode",1)
prop(blossom_garden,"token","LevelOfDetail",4)
blossom_x,blossom_z=-32.2,5.8
garden_shelf(blossom_garden,blossom_x,.67,blossom_z,5.45,5.11,.66,"877782",SLATE,collide=False)
garden_shelf(blossom_garden,blossom_x-.20,1.26,blossom_z+.15,4.79,4.37,.74,"A08D95",SLATE,collide=False)
garden_shelf(blossom_garden,blossom_x-.14,1.49,blossom_z+.13,4.28,3.91,.32,"758B51",GRASS_MAT,collide=False)

# Set the taller blossom canopy behind the west gallery in the arrival view.
# Sakura Tree by @plentune, Creator Store model 3725991689.
grove=item(foreground,"Model","Trophy Hall west blossom grove")
prop(grove,"token","ModelStreamingMode",1)
prop(grove,"token","LevelOfDetail",4)
sakura_x,sakura_z=-42,-38
for dx,dz,top,width,depth,height,tint,material in (
    (0,0,.76,5.01,4.70,.61,"877782",SLATE),
    (-.18,.14,1.30,4.41,4.02,.68,"A08D95",SLATE),
    (-.13,.12,1.51,3.94,3.60,.29,"758B51",GRASS_MAT),
):
    garden_shelf(grove,sakura_x+dx,top,sakura_z+dz,width,depth,height,tint,material,collide=False)
sakura=item(grove,"Model","Relay garden Sakura tree")
prop(sakura,"token","ModelStreamingMode",1)
sakura_yaw=-31
sakura_base=1.50
trunk_size=(19.594587,37.661224,15.228602)
sakura_scale=(.9844,.77,.9844)


def scaled_sakura_size(axes):
    return tuple(value*scale for value,scale in zip(axes,sakura_scale))


placed_trunk_size=scaled_sakura_size(trunk_size)
trunk=part(sakura,"Sakura trunk",(sakura_x,sakura_base+placed_trunk_size[1]/2,sakura_z),placed_trunk_size,
           "816A5D",yaw=sakura_yaw,material=SLATE,collide=False,class_name="MeshPart")
prop(trunk,"bool","CastShadow",False)
prop(trunk,"token","RenderFidelity",1)
vector(trunk,"Vector3","InitialSize",("X","Y","Z"),(6.797350,11.199409,5.221320))
asset(trunk,"MeshContent","rbxassetid://743209096")
leaf_offset=scaled_sakura_size((.876709,trunk_size[1]/2+7.286158,1.120193))
leaf_x,leaf_y,leaf_z=rotate_garden_point(leaf_offset,sakura_yaw)
leaves=part(sakura,"Sakura blossom sprays",(sakura_x+leaf_x,sakura_base+leaf_y,sakura_z+leaf_z),
            scaled_sakura_size((3.344402,8.555678,3.344402)),"A3A2A5",yaw=sakura_yaw,
            material=FABRIC,collide=False,transparency=.40)
prop(leaves,"bool","CastShadow",False)
leaf_mesh=item(leaves,"SpecialMesh","Textured blossom branches")
prop(leaf_mesh,"token","MeshType",5)
vector(leaf_mesh,"Vector3","Scale",("X","Y","Z"),scaled_sakura_size((2.894195,)*3))
asset(leaf_mesh,"MeshContent","rbxassetid://743209371")
asset(leaf_mesh,"TextureContent","rbxassetid://5834464899")

for key,dx,dz,scale,yaw,tint in (
    ("bankRock",1.44,.61,.18,78,"98848C"),
    ("meadowGrass",.53,1.16,.18,65,"ACBC6A"),
    ("meadowCover",-.87,-.92,.22,117,"A4B96A"),
    ("mossFlowers",-1.42,.60,.14,30,"DE95B0"),
    ("bankRock",-.46,-.18,.29,28,"8E7C83"),
    ("meadowCover",.68,-.76,.28,105,"99AB5C"),
    ("meadowFlowers",.18,.40,.30,51,"F4BCB3"),
    ("meadowGrass",-1.28,-.52,.23,74,"9CAA6F"),
):
    garden_prop(blossom_garden,key,(blossom_x+dx,1.43,blossom_z+dz),scale,yaw,tint)


def trophy_hall_approach(parent):
    terrace=item(parent,"Model","Trophy Hall upper forecourt")
    prop(terrace,"token","LevelOfDetail",4)
    top=3.665
    ramp_top=3.705
    rail="895142"
    ramp_x=19.76
    approach=[(ramp_x,.233,-15.34),(ramp_x,.233,-17.80),
              (ramp_x,ramp_top,-28.92),(ramp_x,ramp_top,-31.33)]
    route(terrace,"Trophy Hall garden ramp",approach,5.57,"9F898F",surface=LIMESTONE,
          stone_footings=False,join_overlap=.34,railings=False)
    for side in (-1,1):
        x=ramp_x+side*2.60
        edge=[(x,y,z) for _,y,z in approach[1:-1]]+[(x,ramp_top,-30.19)]
        for a,b in zip(edge,edge[1:]):
            for lift in (.61,1.37):
                beam(terrace,"Garden ramp rail",(x,a[1]+lift,a[2]),(x,b[1]+lift,b[2]),
                     .23,rail,collide=True)
            for fraction in (.05,.43,.81):
                y,z=(a[i]+(b[i]-a[i])*fraction for i in (1,2))
                part(terrace,"Garden ramp baluster",(x,y+.68,z),(.31,1.38,.31),rail)
                part(terrace,"Ramp brass cap",(x,y+1.43,z),(.43,.14,.43),"C99B5C",collide=False)
                if side==1 and y>.6:
                    part(terrace,"Ramp slate pier",(x,y/2-.16,z),(1.16,y+.22,1.38),
                         "8D7986",material=SLATE,collide=False)

    west,east,north,south=-15.73,22.70,-34.06,-30.15
    cx,cz=(west+east)/2,(north+south)/2
    part(terrace,"Upper hall walk",(cx,top-.26,cz),(east-west,.52,south-north),"C1A69B",material=LIMESTONE)
    part(terrace,"Porch carved slate face",(cx,top-.74,south-.17),(east-west,.45,.32),
         "9D848A",material=SLATE,collide=False)
    landing=item(terrace,"Model","Trophy Hall sandstone landing")
    prop(landing,"token","LevelOfDetail",4)
    tile_depth=(south-north)/2
    for row in range(2):
        z=north+(row+.5)*tile_depth
        for column in range(6):
            x=(column-2.5)*2.14
            tile=part(landing,"Landing sandstone flag",(x,top+.013,z),(2.075,.019,tile_depth-.086),
                      ("CAAFA0","C2A79B","D1B4A0")[(row+column)%3],
                      material=LIMESTONE,collide=False)
            prop(tile,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
            prop(tile,"bool","CastShadow",False)
    for x in (-14.2,-9.7,9.7,15.94,21.47):
        part(terrace,"Forecourt dressed pier",(x,1.51,-31.75),(1.62,3.0,1.72),"8D7983",
             material=SLATE,collide=False)
        part(terrace,"Forecourt pier crown",(x,2.96,-31.75),(1.86,.37,1.97),"A18B8F",
             material=SLATE,collide=False)
    for ax,az,bx,bz in ((west+.23,south-.14,-7.38,south-.14),
                        (7.38,south-.14,ramp_x-2.60,south-.14),
                        (west+.23,north+.24,west+.23,south-.14),
                        (east-.24,north+.24,east-.24,south-.14),
                        (16.10,north+.24,east-.24,north+.24)):
        for lift in (.58,1.31):
            beam(terrace,"Upper forecourt rail",(ax,top+lift,az),(bx,top+lift,bz),.23,rail,collide=True)
        for t in (0,.5,1):
            x,z=ax+(bx-ax)*t,az+(bz-az)*t
            part(terrace,"Forecourt baluster",(x,top+.68,z),(.30,1.40,.30),rail)
    for x in (-8.4,8.4):
        lamp(terrace,x,top+1.54,south-.34,scale=.61,light=True)

    shoulders=item(terrace,"Model","Trophy Hall planted stair shoulders")
    prop(shoulders,"token","ModelStreamingMode",1)
    prop(shoulders,"token","LevelOfDetail",4)
    for side in (-1,1):
        # Step the garden grade toward the existing high porch on each side.
        # Keep the main stair, jade approach and east ramp outside the beds.
        front_z=-26.60 if side<0 else -21.96
        for tier,(x,z,height,width,depth) in enumerate((
            (12.71,-22.44,.68,4.51,4.28),
            (12.28,-24.70,1.31,4.54,4.52),
            (12.30,-26.74,2.26,5.04,4.68),
        )):
            x*=side
            if side<0:
                z=(-27.33,-28.25,-29.16)[tier]
                depth*=.74
            else:
                z-=.16
            garden_shelf(shoulders,x,height,z,width,depth,height-.11,
                         ("9E8288","AD9495","987F88")[tier],SLATE,collide=False)
            garden_shelf(shoulders,x+side*.05,height+.13,z-.11,width-.37,depth-.42,.22,
                         ("697E4B","70864C","7B9154")[tier],GRASS_MAT,collide=False)
            garden_prop(shoulders,"meadowCover",(x-side*.20,height+.12,z+.76),.085,26+side*17,"A9BB76")
            garden_prop(shoulders,"meadowFlowers",(x+side*.50,height+.12,z+.92),.21,56+side*27,"F7C595")
        scale=.50 if side<0 else 1.0
        arrival_boulder(shoulders,side*12.74,.65,front_z-1.98*scale,3.45,1.32,2.53,29*side)
        garden_prop(shoulders,"bankRock",(side*13.52,1.32,front_z-3.59*scale),.15,68*side,"908495")
        garden_prop(shoulders,"mossFlowers",(side*12.23,2.40,front_z-5.22*scale),.13,32*side,"EE9DAF")
        garden_prop(shoulders,"grassBlade",(side*11.41,.82,front_z+.08),.40,59*side,"DEBD81")
        for y,height,width,tint in ((.87,.34,1.98,"8C7883"),(1.10,.16,1.78,"AA9092")):
            part(shoulders,"Dressed lantern plinth",(side*13.26,y,front_z),(width,height,1.55),
                 tint,material=SLATE,collide=False)
        store_standing_lantern(shoulders,(side*13.26,1.18,front_z),.51,light=False,paper_tint="FFC138")

    for index,(x,z,bed_y) in enumerate(((24.25,-21.0,.68),(24.95,-26.6,1.29))):
        garden_shelf(terrace,x,bed_y,z,4.48,4.12,bed_y-.04,"8F7B85",SLATE,collide=False)
        garden_shelf(terrace,x,bed_y+.12,z,3.95,3.54,.22,"687E4B",GRASS_MAT,collide=False)
        garden_prop(terrace,"bankRock",(x+.59,bed_y-.12,z-.55),.295,57*index,"9B8390")
        garden_prop(terrace,"meadowGrass",(x-.66,bed_y+.11,z+.33),.18,78*index,"9FA66A")
        garden_prop(terrace,"meadowFlowers",(x+.30,bed_y+.13,z+.47),.35,47*index,"F1C08D")
        garden_prop(terrace,"mossFlowers",(x+.13,bed_y+.11,z-.8),.117,32*index,"E4A5B8")
    garden=item(terrace,"Model","Reedfall garden terraces")
    prop(garden,"token","ModelStreamingMode",1)
    prop(garden,"token","LevelOfDetail",4)
    for x,z,base,crest,width,depth,yaw in (
        (25.08,-27.55,.16,3.35,4.36,3.97,18),
        (24.95,-29.51,1.09,5.27,3.83,3.62,-18),
        (25.18,-31.45,2.49,7.49,3.71,3.46,14),
    ):
        shoreline_slate(garden,x,z,base,width,depth,crest-base,yaw,shadow=False)
        shelf=base+(crest-base)*.82
        garden_shelf(garden,x-.07,shelf+.11,z-.06,width*.68,depth*.67,.30,
                     "758958",GRASS_MAT,collide=False)
        for key, dx, dz, scale, tint in (
            ("bankRock",-.58,.43,.16,"A4939A"),
            ("meadowCover",.39,.28,.13,"9CAF72"),
            ("mossFlowers",-.38,-.23,.17,"E0A5AE"),
            ("meadowFlowers",.43,-.52,.24,"EFBC9E"),
            ("rockVine",.51,.48,.34,"8B9E66"),
        ):
            garden_prop(garden,key,(x+dx,shelf-.026 if key=="rockVine" else shelf+.11,z+dz),
                        scale,yaw+37,tint)
    showcase_tree(garden,25.14,-31.55,True,.59,37,6.73,compact=True,height_scale=.91,
                  crown_spread=.84)
    build_hall_garden_spill(garden,item=item,prop=prop,part=part,triangle=triangle,glass=GLASS)
    for x,y,z,width,label in (
        (15.65,3.69,-17.02,6.62,"TROPHY HALL RAMP  →"),
        (20.35,top+2.39,-32.96,4.85,"HALL ENTRY  ←"),
    ):
        part(terrace,"Ramp wayfinding post",(x,y-1.53,z),(.32,3.10,.32),rail,collide=False)
        sign(terrace,label,x,y,z+.23,width,.93,tint="426C62")


trophy_hall_approach(hall)
build_hall_arrival_details(hall, item=item, prop=prop, part=part, beam=beam, slate=SLATE,
                           wood=WOOD_PLANK, metal=METAL, variant_field=MATERIAL_VARIANT_FIELD,
                           ornament_brass=ORNAMENT_BRASS)
build_hall_arrival_mass(hall,item=item,prop=prop,part=part,beam=beam,triangle=triangle,
                        slate=SLATE,sandstone=LIMESTONE,cedar=WOOD_PLANK,brass=METAL,neon=NEON,
                        variant_field=MATERIAL_VARIANT_FIELD,stone_variant=PROMENADE_MORTAR,
                        brass_variant=ORNAMENT_BRASS)
build_hall_inner_portal(hall,item=item,prop=prop,part=part,beam=beam,triangle=triangle,
                        slate=SLATE,wood=WOOD_PLANK,metal=METAL,neon=NEON,
                        variant_field=MATERIAL_VARIANT_FIELD,wood_variant=LANDMARK_CEDAR,
                        brass_variant=ORNAMENT_BRASS)
build_hall_valley_facades(hall,item=item,prop=prop,part=part,wood=WOOD_PLANK,
                          metal=METAL,neon=NEON,wood_variant=LANDMARK_CEDAR,
                          brass_variant=ORNAMENT_BRASS,variant_field=MATERIAL_VARIANT_FIELD)


LOOKOUT_ENTRY_X = 52.13
REEDFALL_GALLERY_Y = 8.85
REEDFALL_GALLERY_NORTH = -52.90


def reedfall_gallery(parent):
    gallery=item(parent,"Model","Reedfall Gallery")
    prop(gallery,"token","ModelStreamingMode",1)
    prop(gallery,"token","LevelOfDetail",4)
    top=REEDFALL_GALLERY_Y
    rail_tint="8E4B3A"
    west,east,north,south=48.5,65.8,REEDFALL_GALLERY_NORTH,-44.5
    approach=[(42,.15,-16.4),(51.55,.15,-16.4),(51.55,.15,-21.1),(51.55,2.91,-28.85),
              (51.55,6.25,-38.05),(51.55,top,-45.08)]
    descent=[(65.42,top,-48.55),(68.92,top,-48.55),(69.60,top,-52.00),
             (70.20,6.55,-58.80),(69.76,4.90,-64.60),(70.39,3.65,-68.90),
             (72.22,2.56,-72.13),(75.23,1.43,-73.99),(78.58,.44,-74.48),
             (82.0,.44,-74.45),(86.77,.44,-74.00)]
    for path,label in ((approach,"Reedfall gallery rise"),(descent,"Cinder return ramp")):
        route(gallery,label,path,5.90,"9F8888",surface=SLATE,stone_footings=False,
              join_overlap=.43,railings=False)
        for side in (-1,1):
            edge=path_edge(path,side*2.67)
            for segment,(a,b) in enumerate(zip(edge,edge[1:])):
                if path is approach and segment<2:
                    continue
                if path is descent and segment>=len(edge)-3:
                    continue
                for lift in (.58,1.36):
                    beam(gallery,"Gallery ramp rail",(a[0],a[1]+lift,a[2]),(b[0],b[1]+lift,b[2]),
                         .24,rail_tint,collide=True)
                for t in (.07,.52,.96):
                    x,y,z=(k+(l-k)*t for k,l in zip(a,b))
                    part(gallery,"Gallery baluster",(x,y+.73,z),(.32,1.51,.32),rail_tint)
                    part(gallery,"Brass baluster cap",(x,y+1.49,z),(.42,.14,.42),"C5975A",collide=False)
                    if y>2.45 and t==.52:
                        part(gallery,"Stone ramp piling",(x,(y-1.1)/2-.27,z),(1.36,y+1.1,1.36),
                             "7D6C79",material=SLATE)

    cx,cz=(west+east)/2,(north+south)/2
    part(gallery,"Reedfall gallery deck",(cx,top-.37,cz),(east-west,.74,south-north),
         "A99596",material=LIMESTONE)
    for x in (49.56,57.5,64.7):
        for z in (-51.78,-45.60):
            part(gallery,"Gallery slate foot",(x,.52,z),(1.86,1.04,1.86),"786875",material=SLATE)
            part(gallery,"Gallery slate pier",(x,4.48,z),(1.38,7.20,1.38),"847480",material=SLATE)
            part(gallery,"Gallery pier crown",(x,7.93,z),(1.82,.71,1.82),"9A8791",material=SLATE)
    for ax,az,bx,bz in ((west+.24,north+.25,LOOKOUT_ENTRY_X-2.49,north+.25),
                        (LOOKOUT_ENTRY_X+2.49,north+.25,east-.24,north+.25),
                        (west+.24,north+.25,west+.24,south-.25),
                        (west+.24,south-.25,48.88,south-.25),
                        (54.22,south-.25,east-.24,south-.25),
                        (east-.24,north+.25,east-.24,-51.22),
                        (east-.24,-45.88,east-.24,south-.25)):
        for lift in (.58,1.36):
            beam(gallery,"Gallery deck rail",(ax,top+lift,az),(bx,top+lift,bz),.24,rail_tint,collide=True)
        for t in (0,.5,1):
            x,z=ax+(bx-ax)*t,az+(bz-az)*t
            part(gallery,"Gallery deck post",(x,top+.73,z),(.34,1.51,.34),rail_tint)

    for x in (56.35,63.48):
        for z in (-51.82,-46.72):
            part(gallery,"Shelter cedar pillar",(x,top+2.76,z),(.63,5.52,.63),"9B472F",material=WOOD_PLANK)
            part(gallery,"Shelter brass collar",(x,top+4.97,z),(.78,.22,.78),"C38D50",collide=False)
        festival_lantern(gallery,x,top+4.52,-46.70,.68,light=x<60)
    swept_roof(gallery,59.92,top+5.60,-49.43,9.42,6.86,2.18,fine_tiles=False)
    sign(gallery,"REEDFALL GALLERY",59.92,top+5.32,-46.10,6.95,.96,tint="744333")
    for x,z,yaw in ((49.42,-51.68,25),(54.94,-51.62,58),(61.2,-51.65,32),(64.44,-45.58,92)):
        part(gallery,"Gallery planter",(x,top+.26,z),(1.54,.52,1.38),"897587",material=SLATE)
        garden_prop(gallery,"meadowGrass",(x,top+.49,z),.11,yaw,"9CAD69")
        garden_prop(gallery,"mossFlowers",(x+.14,top+.51,z+.10),.118,yaw,"EDB7C0")
    for x,y,z,yaw,label in ((48.3,4.35,-17.9,0,"REEDFALL GALLERY"),
                            (81.41,3.92,-77.72,67,"REEDFALL GALLERY"),
                            (64.79,top+2.24,-51.85,0,"CINDER ROAD  →")):
        part(gallery,"Gallery wayfinding post",(x,y-1.58,z),(.32,3.26,.34),rail_tint,collide=False)
        sign(gallery,label,x,y,z+.22,6.25,.92,yaw,"426B64")


reedfall_gallery(falls)
build_reedfall_crown_wayfinding(falls, item=item, prop=prop, part=part, sign=sign,
                               garden_shelf=garden_shelf, garden_prop=garden_prop,
                               slate=SLATE, limestone=LIMESTONE, cedar=WOOD_PLANK,
                               brass=METAL, grass=GRASS_MAT)


def cascade_lookout(parent):
    lookout=item(parent,"Model","Cascade Lookout")
    prop(lookout,"token","ModelStreamingMode",1)
    prop(lookout,"token","LevelOfDetail",4)
    entry_x,return_x=LOOKOUT_ENTRY_X,62.02
    start_y,landing_y,top=REEDFALL_GALLERY_Y,15.13,21.20
    landing_front,landing_back=-74.20,-79.35
    west,east,north,south=54.38,67.70,-54.43,-44.84
    ascent=[(entry_x,start_y,REEDFALL_GALLERY_NORTH+.10),(entry_x,start_y,-54.78),
            (entry_x,landing_y,landing_front-.12)]
    return_ramp=[(return_x,landing_y,landing_front-.12),(return_x,top,north-.68),
                 (return_x,top,north+.12)]
    rail_tint="92543D"

    def guard(a,b):
        for lift in (.56,1.42):
            beam(lookout,"Lookout cedar guardrail",(a[0],a[1]+lift,a[2]),
                 (b[0],b[1]+lift,b[2]),.24,rail_tint,collide=True)
        count=max(1,round(hypot(b[0]-a[0],b[2]-a[2])/3.6))
        for index in range(count+1):
            x,y,z=(u+(v-u)*index/count for u,v in zip(a,b))
            part(lookout,"Lookout cedar baluster",(x,y+.74,z),(.33,1.50,.33),rail_tint)
            part(lookout,"Lookout brass rail cap",(x,y+1.52,z),(.43,.15,.43),"BD8951",collide=False)

    for path,label in ((ascent,"Lookout lower ramp"),(return_ramp,"Lookout upper ramp")):
        route(lookout,label,path,4.94,"A48A8D",surface=SLATE,
              stone_footings=False,join_overlap=.24,railings=False)
        for direction in (-1,1):
            edge=path_edge(path,direction*2.31)
            for a,b in zip(edge,edge[1:]):
                guard(a,b)

    def platform(label,x0,x1,z0,z1,y):
        part(lookout,label,((x0+x1)/2,y-.39,(z0+z1)/2),(x1-x0,.78,z1-z0),
             "A19398",material=LIMESTONE)
        part(lookout,"Lookout slate rim",((x0+x1)/2,y-.63,(z0+z1)/2),(x1-x0+.22,.22,z1-z0+.19),
             "786777",material=SLATE,collide=False)

    landing_left,landing_right=49.52,64.64
    platform("Lookout turning landing",landing_left,landing_right,landing_back,landing_front,landing_y)
    build_reedfall_turning_landings(lookout,left=landing_left,right=landing_right,north=landing_back,
                                    south=landing_front,level=landing_y,item=item,prop=prop,part=part,
                                    sign=sign,garden_prop=garden_prop,slate=SLATE,limestone=LIMESTONE,
                                    cedar=WOOD_PLANK,brass=METAL)
    platform("Cascade lookout deck",west,east,north,south,top)
    for y,segments in ((landing_y,(
         ((landing_left+.19,landing_back+.19),(landing_right-.19,landing_back+.19)),
         ((landing_left+.19,landing_back+.19),(landing_left+.19,landing_front-.21)),
         ((landing_right-.19,landing_back+.19),(landing_right-.19,landing_front-.21)),
         ((entry_x+2.49,landing_front-.21),(return_x-2.49,landing_front-.21)),
    )),(top,(
        ((west+.24,south-.22),(east-.24,south-.22)),
        ((west+.24,north+.23),(west+.24,south-.22)),
        ((east-.24,north+.23),(east-.24,CROWN_ENTRY_Z-CROWN_ROUTE_WIDTH/2)),
        ((east-.24,CROWN_ENTRY_Z+CROWN_ROUTE_WIDTH/2),(east-.24,south-.22)),
        ((west+.24,north+.23),(return_x-2.52,north+.23)),
        ((return_x+2.52,north+.23),(east-.24,north+.23)),
    ))):
        for (ax,az),(bx,bz) in segments:
            guard((ax,y,az),(bx,y,bz))

    for x,y,z in ((entry_x,11.03,-61.51),(entry_x,13.94,-70.44),
                  (return_x,16.74,-69.15),(return_x,19.33,-61.15),
                  (52.31,landing_y,-77.83),(62.73,landing_y,-77.83),
                  (55.24,top,-53.68),(66.96,top,-53.68),(55.24,top,-45.50),(66.96,top,-45.50)):
        part(lookout,"Lookout slate footing",(x,-.64,z),(1.74,1.32,1.77),
             "8C7C85",material=SLATE,collide=False)
        part(lookout,"Lookout masonry pier",(x,(y-1.19)/2,z),(1.12,y-1.19,1.16),
             "807481",material=SLATE,collide=False)
        part(lookout,"Lookout cedar corbel",(x,y-.78,z),(1.66,.40,1.58),
             "8C5140",material=WOOD_PLANK,collide=False)
        part(lookout,"Lookout pier collar",(x,y-1.75,z),(1.31,.34,1.35),
             "A48B80",material=LIMESTONE,collide=False)

    for x in (56.20,60.08):
        for z in (-52.05,-49.27):
            part(lookout,"Lookout shelter pillar",(x,top+2.38,z),(.44,4.76,.47),
                 "A45137",material=WOOD_PLANK,collide=False)
            part(lookout,"Lookout shelter brass collar",(x,top+4.54,z),(.55,.18,.55),
                 "D0A162",collide=False)
        festival_lantern(lookout,x,top+3.73,-48.91,.57,light=False)
    swept_roof(lookout,58.13,top+4.85,-50.61,6.36,4.78,1.62,fine_tiles=False)
    bench=part(lookout,"South-facing lookout bench",(58.13,top+.52,-50.05),(2.60,.18,.77),
               "966044",material=WOOD_PLANK,class_name="Seat",yaw=180)
    bench.find("Properties/bool[@name='CanTouch']").text="true"
    part(lookout,"Lookout bench back",(58.13,top+1.01,-50.47),(2.63,.73,.18),
         "8D5140",material=WOOD_PLANK,collide=False)
    for x in (57.23,59.03):
        part(lookout,"Lookout bench leg",(x,top+.24,-50.05),(.23,.48,.68),
             "754535",material=WOOD_PLANK,collide=False)

    for x,y,z,yaw in ((50.52,landing_y,-78.45,15),(63.66,landing_y,-78.45,-30),
                      (55.37,top,-46.42,28),(66.58,top,-46.15,-60)):
        part(lookout,"Lookout fern planter",(x,y+.29,z),(1.43,.58,1.22),
             "7E6A77",material=SLATE,collide=False)
        garden_prop(lookout,"meadowGrass",(x,y+.55,z),.086,yaw,"98AF65")
        garden_prop(lookout,"mossFlowers",(x+.08,y+.54,z+.13),.095,yaw+18,"F4BCC3")
        garden_prop(lookout,"meadowFlowers",(x-.16,y+.55,z-.11),.18,yaw+50,"F9C699")
        garden_prop(lookout,"bankRock",(x+.14,y+.29,z-.29),.075,yaw+74,"A58C93")
    for x in (entry_x-2.65,entry_x+2.65):
        part(lookout,"Lookout entrance post",(x,start_y+2.68,-52.58),(.38,5.36,.40),
             rail_tint,material=WOOD_PLANK,collide=False)
    for x,y,z,label,width in ((entry_x,start_y+5.31,-52.43,"CASCADE LOOKOUT",6.75),
                             (58.13,top+4.60,-48.31,"CASCADE LOOKOUT",5.76),
                             (65.95,top+2.53,-54.08,"GALLERY  ↓",2.80)):
        sign(lookout,label,x,y,z,width,.94,tint="385D55")
    build_crown_pavilion(lookout, east, top, item=item, prop=prop, part=part, beam=beam,
                         route=route, swept_roof=swept_roof, sign=sign, lamp=lamp,
                         garden_prop=garden_prop, slate=SLATE, cedar=WOOD_PLANK,
                         stone=LIMESTONE, cloth=FABRIC, brass=METAL)
    return 64.82,top,-46.52


cascade_keeper=cascade_lookout(falls)


def weavers_walk(parent):
    terrace=item(parent,"Model","Weavers’ Walk")
    prop(terrace,"token","ModelStreamingMode",1)
    prop(terrace,"token","LevelOfDetail",4)
    top=7.34
    west,east,north,south=99.65,120.55,-40.1,-20.1
    arrival=[(77.85,.15,-11.0),(85.7,.15,-11.45),(94.0,2.72,-12.7),(100.4,5.27,-14.86),
             (104.80,top,-18.86),(108.32,top,-22.06)]
    descent=[(118.74,top,-32.10),(122.2,top,-29.305),(127.4,5.75,-25.105),(130.6,4.10,-18.7),
             (131.0,2.25,-10.25),(129.47,.95,-3.70),(126.45,.56,2.60),(123.90,.51,8.65),
             (122.40,.47,13.14)]
    rail="456661"
    for path,label in ((arrival,"Weavers’ Walk market ramp"),(descent,"Weavers’ Walk harbor ramp")):
        route(terrace,label,path,5.90,"AD9790",surface=LIMESTONE,stone_footings=False,
              join_overlap=.43,railings=False)
        for distance in (-2.68,2.68):
            edge=path_edge(path,distance)
            for index,(a,b) in enumerate(zip(edge,edge[1:])):
                if path is arrival and index==0 or path is descent and index>=len(edge)-3:
                    continue
                for lift in (.58,1.36):
                    beam(terrace,"Weavers’ ramp rail",(a[0],a[1]+lift,a[2]),(b[0],b[1]+lift,b[2]),
                         .23,rail,collide=True)
                for t in (.22,.73):
                    x,y,z=(start+(end-start)*t for start,end in zip(a,b))
                    part(terrace,"Weavers’ rail post",(x,y+.72,z),(.33,1.49,.33),rail)
                    part(terrace,"Weavers’ brass cap",(x,y+1.46,z),(.42,.14,.42),"C69455",collide=False)
                    if y>1.10 and t==.73:
                        base=-5.25 if x>125 else -.52
                        underside=y-.33
                        part(terrace,"Dressed ramp pier",(x,(base+underside)/2,z),(1.35,underside-base,1.39),
                             "7D6D7C",material=SLATE,collide=False)

    garden_shelf(terrace,130.1,-.29,-10.1,11.4,24.5,4.97,"827481",SLATE)
    garden_shelf(terrace,130.1,-.12,-10.1,10.6,23.7,.23,"77864E",GRASS_MAT)
    cx,cz=(west+east)/2,(north+south)/2
    part(terrace,"Weavers’ terrace deck",(cx,top-.225,cz),(east-west,.56,south-north),
         "AA9791",material=LIMESTONE)
    part(terrace,"Weavers’ masonry plinth",(cx,3.30,cz),(20.4,6.64,19.75),"7F6D7A",material=SLATE)
    for y,w,d,tint in ((5.77,20.72,19.95,"8B7781"),(6.89,21.08,20.10,"9D8689")):
        part(terrace,"Carved terrace stringcourse",(cx,y,cz),(w,.29,d),tint,material=SLATE,collide=False)
    for x in (100.52,107.20,113.90,119.58):
        part(terrace,"Stone terrace buttress",(x,3.14,south+.16),(1.24,6.28,1.25),
             "8F7E88",material=SLATE,collide=False)
        part(terrace,"Buttress slate crown",(x,6.41,south+.18),(1.56,.60,1.53),
             "A18A8D",material=SLATE,collide=False)
    edges=((west+.24,north+.25,east-.24,north+.25),
           (west+.24,north+.25,west+.24,-31.72),(west+.24,-26.18,west+.24,south-.24),
           (west+.24,south-.24,101.74,south-.24),(110.98,south-.24,east-.24,south-.24),
           (east-.24,north+.25,east-.24,-34.61),(east-.24,-26.99,east-.24,south-.24))
    for ax,az,bx,bz in edges:
        for lift in (.58,1.36):
            beam(terrace,"Weavers’ terrace rail",(ax,top+lift,az),(bx,top+lift,bz),.23,rail,collide=True)
        for t in (0,.5,1):
            x,z=ax+(bx-ax)*t,az+(bz-az)*t
            part(terrace,"Weavers’ terrace post",(x,top+.71,z),(.33,1.48,.33),rail)

    workshop=item(terrace,"Model","Reed Weaving Workshop")
    shop_x,shop_z=107.0,-35.32
    house(workshop,shop_x,shop_z,10.5,7.5,5.95,walls=False,with_roof=False)
    part(workshop,"Workshop rear wall",(shop_x,3.22,shop_z-3.57),(10.5,5.62,.43),"AA684C",
         material=WOOD_PLANK)
    lantern_window(workshop,shop_x,3.66,shop_z-3.30,4.62,2.81)
    swept_roof(workshop,shop_x,6.98,shop_z,12.85,9.62,2.41,fine_tiles=False)
    sign(workshop,"REED WEAVING",shop_x,5.92,shop_z+4.0,5.19,.79,tint="346761")
    festival_lantern(workshop,shop_x-3.38,4.97,shop_z+4.03,.63,light=False,tint="FFD08D")
    festival_lantern(workshop,shop_x+3.38,4.97,shop_z+4.03,.63,light=False,tint="EAC898")
    for x in (shop_x-3.38,shop_x+3.38):
        part(workshop,"Loom cedar upright",(x,2.40,shop_z-1.82),(.30,3.95,.31),"98674D")
        banner(workshop,x,3.62,shop_z+3.96,scale=.50)
    beam(workshop,"Loom upper crossbar",(shop_x-3.38,4.21,shop_z-1.82),(shop_x+3.38,4.21,shop_z-1.82),
         .29,"A16F51")
    part(workshop,"Loom cloth roll",(shop_x,1.42,shop_z-1.72),(6.12,.31,.31),"8B6859",
         shape=2,collide=False)
    for index in range(15):
        x=shop_x+(index-7)*.38
        beam(workshop,"Reed loom warp",(x,1.51,shop_z-1.61),(x,4.04,shop_z-1.69),.045,
             ("D9BB7F","AD7850","B98D61")[index%3])
    for index,tint in enumerate(("BC6C53","D9AD63","5C9590","8F6A84","D9AD63","B17457")):
        part(workshop,"Loom woven band",(shop_x,1.61+index*.28,shop_z-1.53),(5.87,.26,.07),tint,
             material=FABRIC,collide=False)
    for index,tint in enumerate(("A65456","519386","CE9A60")):
        x=shop_x+(index-1)*2.24
        part(workshop,"Folded rug on sill",(x,.73,shop_z+.68),(1.55,.41,1.34),tint,
             material=FABRIC,yaw=(index-1)*11,collide=False)
    raise_geometry(workshop,top-.315)

    for index,(x,z) in enumerate(((100.88,-24.70),(112.60,-21.75),(118.96,-23.7),(118.55,-38.35))):
        part(terrace,"Weavers’ slate planter",(x,top+.23,z),(1.70,.46,1.57),"8D7C84",material=SLATE)
        garden_prop(terrace,"mossFlowers",(x,top+.43,z),.12,36+index*57,"E9ACAE")
        garden_prop(terrace,"meadowGrass",(x+.18,top+.43,z-.07),.109,67+index*39,"A6AD66")
        garden_prop(terrace,"meadowFlowers",(x-.35,top+.43,z+.18),.23,52+index*17,"F8CD98")
    for x,y,z,yaw,label in ((88.60,3.23,-9.03,33,"WEAVERS’ WALK"),
                            (124.79,3.42,10.89,0,"WEAVERS’ WALK"),
                            (117.4,top+2.80,-26.40,0,"TIDEHARBOR  →")):
        part(terrace,"Weavers’ wayfinding post",(x,y-1.56,z),(.34,3.18,.34),rail,collide=False)
        sign(terrace,label,x,y,z+.21,6.35,.97,yaw,"386662")

    for x,z,width,depth,yaw in ((101.8,-6.1,7.40,5.12,41),(111.02,-7.2,7.10,4.62,94),
                                (118.2,-3.12,8.58,6.15,106)):
        bed=item(terrace,"Model","Dye garden planting")
        garden_shelf(bed,x,.54,z,width,depth,.46,"8D7C87",SLATE,collide=False)
        garden_shelf(bed,x+.19,.82,z-.18,width*.89,depth*.86,.32,"A18E94",SLATE,collide=False)
        garden_shelf(bed,x-.05,.99,z-.17,width*.79,depth*.73,.25,"70864D",GRASS_MAT,collide=False)
        garden_prop(bed,"bankRock",(x+width*.23,.45,z+depth*.20),.29,yaw,"9D8B91")
        garden_prop(bed,"meadowCover",(x-.68,.98,z),.17,yaw+48,"A2B375")
        garden_prop(bed,"meadowFlowers",(x-width*.21,1.01,z+.34),.50,yaw+81,"E9AE9B")
        for offset in (-.72,.72):
            part(bed,"Dye planter terracotta rim",(x+offset,1.30,z-.77),(.16,.54,.54),"BB7761",
                 roll=90,shape=2,collide=False)
            part(bed,"Dye planter terracotta body",(x+offset,1.12,z-.77),(.38,.43,.43),"9F5B4B",
                 roll=90,shape=2,collide=False)
            garden_prop(bed,"mossFlowers",(x+offset,1.34,z-.77),.078,yaw+60,"E7BAA1")

    parcel_station(terrace,"Parcel Stamp Desk",116.6,7.395,-35.90,0,
                   "WEAVERS’ STAMP","Stamp parcel","Reed Weaving","66566F")


weavers_walk(district)


def reed_market_skybridge(parent):
    bridge=item(parent,"Model","Reed Market Skybridge")
    prop(bridge,"token","ModelStreamingMode",1)
    prop(bridge,"token","LevelOfDetail",4)
    high,middle,lower=11.95,11.30,9.19
    thickness=.27
    palette=("B6A09B","A8908A","BDABA0","A99695")
    climbs=(
        [(74.25,9.24,-1.75),(74.25,11.27,-7.40),(74.25,high,-12.40)],
        [(77.25,high,-15.40),(87.70,middle,-15.40)],
        [(90.70,middle,-18.40),(90.70,lower,-25.95)],
        [(93.70,lower,-28.95),(99.82,7.395,-28.95)],
    )
    for path in climbs:
        for a,b in zip(path,path[1:]):
            dx,dy,dz=(end-start for start,end in zip(a,b))
            length=hypot(dx,dz)
            grade=atan2(dy,length)
            yaw=degrees(atan2(dx,dz))
            center=((a[0]+b[0])/2,(a[1]+b[1]-thickness)/2,(a[2]+b[2])/2)
            part(bridge,"Skybridge sandstone span",center,(6.0,thickness,hypot(length,dy)+.34),
                 "AB9590",yaw=yaw,pitch=-degrees(grade),material=LIMESTONE)
            right_x,right_z=dz/length,-dx/length
            rows=max(1,round(length/2.05))
            for row in range(rows):
                x,y,z=(start+(end-start)*(row+.5)/rows for start,end in zip(a,b))
                edges=(-2.92,-.93,1.08,2.92) if row%2==0 else (-2.92,-1.66,.42,2.92)
                for column,(left,right) in enumerate(zip(edges,edges[1:])):
                    offset=(left+right)/2
                    tile=part(bridge,"Span sandstone inlay",
                              (x+offset*right_x,y+.009+thickness/2*(1/cos(grade)-1),z+offset*right_z),
                              (right-left-.06,.017,hypot(length,dy)/rows-.055),
                              palette[(row+column*3)%len(palette)],material=LIMESTONE,
                              yaw=yaw,pitch=-degrees(grade),collide=False)
                    prop(tile,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
                    prop(tile,"bool","CastShadow",False)
            for side in (-1,1):
                ox,oz=right_x*side*2.96,right_z*side*2.96
                beam(bridge,"Skybridge cedar fascia",(a[0]+ox,a[1]-.24,a[2]+oz),
                     (b[0]+ox,b[1]-.24,b[2]+oz),.24,"88523D")

    landings=((74.25,high,-15.40),(90.70,middle,-15.40),(90.70,lower,-28.95))
    for x,y,z in landings:
        part(bridge,"Skybridge turning landing",(x,y-.27,z),(6.0,.54,6.0),"AB9590",material=LIMESTONE)
        for row in range(3):
            for column in range(3):
                tile=part(bridge,"Landing sandstone inlay",(x+(column-1)*2,y+.008,z+(row-1)*2),
                          (1.94,.016,1.94),palette[(column+row*2)%len(palette)],
                          material=LIMESTONE,collide=False)
                prop(tile,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
                prop(tile,"bool","CastShadow",False)

    rails=(
        [(71.45,10.16,-4.31),(71.45,11.27,-7.40),(71.45,high,-18.20),(87.90,middle,-18.20)],
        [(77.05,10.16,-4.31),(77.05,11.27,-7.40),(77.05,high,-12.60),
         (87.70,middle,-12.60),(93.50,middle,-12.60)],
        [(93.50,middle,-12.60),(93.50,middle,-18.40),(93.50,lower,-26.15),(99.89,7.395,-26.18)],
        [(87.90,middle,-18.20),(87.90,lower,-25.95),(87.90,lower,-31.75),
         (93.70,lower,-31.75),(99.89,7.395,-31.72)],
    )
    for line in rails:
        for a,b in zip(line,line[1:]):
            for lift,depth in ((.52,.22),(1.36,.28)):
                beam(bridge,"Skybridge lacquered guardrail",(a[0],a[1]+lift,a[2]),
                     (b[0],b[1]+lift,b[2]),depth,"815544",collide=True)
            count=max(1,ceil(dist(a,b)/3.4))
            for i in range(count):
                x,y,z=(u+(v-u)*i/count for u,v in zip(a,b))
                part(bridge,"Skybridge cedar newel",(x,y+.69,z),(.34,1.48,.34),"744639")
                part(bridge,"Skybridge brass rail cap",(x,y+1.44,z),(.46,.14,.45),"D0A15F",collide=False)

    for x,y,z in ((71.88,high,-16.92),(86.20,11.39,-17.65),(92.96,10.06,-22.82),
                  (92.69,lower,-30.75),(98.76,7.68,-31.15)):
        part(bridge,"Skybridge rock footing",(x,.49,z),(1.84,.78,1.80),"766774",material=SLATE)
        part(bridge,"Skybridge dressed slate pier",(x,(y+.25)/2,z),(1.22,y-1.45,1.25),"8B7882",material=SLATE)
        part(bridge,"Skybridge carved corbel",(x,y-.54,z),(1.77,.64,1.73),"A48D93",material=SLATE,collide=False)
        for key,dx,dz,scale in (("bankRock",-.78,.43,.17),("mossFlowers",.61,-.64,.10),
                                ("meadowCover",-.46,-.63,.12)):
            garden_prop(bridge,key,(x+dx,.17,z+dz),scale,44+x,"BAA28F")

    for x,y,z in ((72.00,high,-17.50),(92.91,middle,-13.26),(88.50,lower,-31.20)):
        part(bridge,"Skybridge lantern shelf",(x,y+.16,z),(.97,.32,.91),"96838B",material=SLATE,collide=False)
        store_standing_lantern(bridge,(x,y+.32,z),.39,light=False)
        garden_prop(bridge,"meadowFlowers",(x+.68,y+.08,z),.13,24,"F6C88E")
    for x in (79.25,85.60):
        height=high+(middle-high)*(x-77.25)/10.45
        banner(bridge,x,height-.91,-12.36,scale=.57)
    sign(bridge,"REED MARKET SKYBRIDGE",82.42,11.0,-12.44,5.42,1.00,tint="38635C")
    sign(bridge,"RING TERRACE  ←",101.28,9.65,-27.46,4.58,.86,-84,"774739")


reed_market_skybridge(district)


def lantern_market_terrace(parent,x,y,z):
    market=item(parent,"Model","Upper Lantern Market")
    prop(market,"token","ModelStreamingMode",1)
    prop(market,"token","LevelOfDetail",4)
    cx,top,cz=x-19.5,y+7.2,z-33.4
    arrival=[(x-28.2,y+4.8,z-16),(x-28.2,y+4.8,z-19),(x-28.2,top,z-27.15),
             (x-28.2,top,z-30.0)]
    descent=[(x-10.2,top,cz),(x-5.8,top,cz),(x+4.3,y+4.20,cz-.80),
             (x+15.3,y+.10,z-30.5),(x+17.9,y,z-29.4)]
    for path,label in ((arrival,"Upper market walk"),(descent,"Street return ramp")):
        for index,(start,end) in enumerate(zip(path,path[1:])):
            lift=.044+index*.015 if path is arrival else index*.015
            floor=[(px,py+lift,pz) for px,py,pz in (start,end)]
            route(market,label,floor,5.75,"88718B",surface=SLATE,stone_footings=False,
                  join_overlap=.57,railings=False)
        for side in (-1,1):
            edge=path_edge(path,side*2.60)
            for index,(start,end) in enumerate(zip(edge,edge[1:])):
                if path is arrival and index==0:
                    start=tuple(a+(b-a)*.66 for a,b in zip(start,end))
                if path is descent and index==0:
                    start=tuple(a+(b-a)*.59 for a,b in zip(start,end))
                if path is descent and index==len(edge)-2:
                    end=tuple(a+(b-a)*.43 for a,b in zip(start,end))
                for h in (.64,1.35):
                    beam(market,"Plum market rail",(start[0],start[1]+h,start[2]),
                         (end[0],end[1]+h,end[2]),.23,"774C73",collide=True)
                for t in (.27,.72):
                    px,py,pz=(a+(b-a)*t for a,b in zip(start,end))
                    part(market,"Market ramp post",(px,py+.69,pz),(.34,1.39,.34),"724C72")
                    part(market,"Market rail cap",(px,py+1.42,pz),(.48,.15,.48),"CC9969",collide=False)
                    part(market,"Stone ramp piling",(px,(py-4)/2,pz),(.86,py+4,1.05),"6F6175",
                         material=SLATE,collide=False)

    part(market,"Raised market deck",(cx,top-.24,cz),(23.45,.62,11.65),"A8909E",material=LIMESTONE)
    for tier,width,depth,height,tint in ((0,23.30,11.55,2.54,"776580"),(1,21.7,11.06,3.25,"847083"),
                                        (2,20.1,10.7,6.1,"706072")):
        upper=top-.59-tier*2.45
        garden_shelf(market,cx-.23*tier,upper,cz,width,depth,height,tint,SLATE)
    opening_north,opening_south=(edge-cz for edge in MELTWATER_MARKET_OPENING)
    edges=((-11.48,-5.54,11.48,-5.54),(-11.48,-5.54,-11.48,opening_north),
           (-11.48,opening_south,-11.48,5.54),
           (-6.0,5.54,11.48,5.54),(11.48,-5.54,11.48,-2.88),(11.48,2.88,11.48,5.54))
    for ax,az,bx,bz in edges:
        for height in (.59,1.31):
            beam(market,"Gallery rail",(cx+ax,top+height,cz+az),(cx+bx,top+height,cz+bz),
                 .23,"794D72",collide=True)
        for t in (0,.45,1):
            px,pz=cx+ax+(bx-ax)*t,cz+az+(bz-az)*t
            part(market,"Gallery cedar pier",(px,top+.68,pz),(.35,1.42,.35),"775075")
    for index,(offset,cloth,name) in enumerate(((-7.46,"9E5B83","PAPER LANTERNS"),
                                               (0,"73669C","FESTIVAL FABRICS"),
                                               (7.32,"53838B","TEA & SWEETS"))):
        px,pz=cx+offset,cz-3.78
        for side in (-1,1):
            part(market,"Stall lacquer support",(px+side*2.31,top+1.89,pz),(.34,3.78,.35),"68475C")
        part(market,"Pleated silk awning",(px,top+3.63,pz+.41),(5.10,.19,2.96),cloth,
             pitch=10,material=FABRIC,collide=False)
        for rib in range(5):
            part(market,"Awning gold stitching",(px+(rib-2)*.95,top+3.42,pz+1.94),(.49,.21,.14),
                 "CCA279",collide=False)
        part(market,"Market counter",(px,top+1.23,pz+.38),(4.62,.40,1.64),"A37659",material=WOOD_PLANK)
        sign(market,name,px,top+3.02,pz+1.49,3.95,.61,tint="765469")
        for column,tint in enumerate(("FFCA7A","FF9EB3","97DCC2")):
            sx=px+(column-1)*1.23
            if index==0:
                festival_lantern(market,sx,top+1.80,pz+.53,.36,light=False,tint=tint)
            elif index==1:
                for layer,dye in enumerate(("8D6488","B286AA",tint)):
                    part(market,"Folded festival cloth",(sx,top+1.52+layer*.17,pz+.45),(.98,.17,.86),
                         dye,material=FABRIC,collide=False,yaw=(column-1)*12+layer*4)
            else:
                for height,diameter,dy,dye in ((.08,.56,.04,"CEBA92"),(.31,.30,.24,"79A6A0"),(.057,.32,.42,"F0DAC2")):
                    part(market,"Glazed festival teacup",(sx,top+1.44+dy,pz+.66),(height,diameter,diameter),
                         dye,roll=90,shape=2,collide=False)
                part(market,"Festival sweet",(sx+.28,top+1.57,pz+.49),(.22,.19,.25),tint,shape=0,collide=False)
        lamp(market,px+2.07,top+2.59,pz+1.09,scale=.46,light=index!=1)
    for index,(dx,dz) in enumerate(((-10.21,-3.29),(-2.78,4.15),(10.2,4.6))):
        garden_prop(market,"mossFlowers",(cx+dx,top+.09,cz+dz),.143,37+index*17,"F5A8C4")
        garden_prop(market,"meadowCover",(cx+dx+.24,top+.07,cz+dz+.31),.132,61+index*19,"A9B477")
    cable=[(cx+dx,top+height,cz+.52) for dx,height in ((-10.66,6.32),(-5.3,5.05),(0,4.81),
                                                       (5.3,5.05),(10.66,6.32))]
    cable[0]=(cable[0][0],cable[0][1],cz-3.0)
    for px,py,pz in (cable[0],cable[-1]):
        part(market,"Lantern string post",(px,(top+py)/2,pz),(.29,py-top,.30),"7D565F",collide=False)
    for index,(start,end) in enumerate(zip(cable,cable[1:])):
        beam(market,"Lantern string",start,end,.061,"79545E")
        px,py,pz=tuple((a+b)/2 for a,b in zip(start,end))
        festival_lantern(market,px,py-.59,pz,.62,light=False,
                         tint=("FFD07D","E9A5D7","A4E8C7","FFBB8D")[index])
    for side in (-1,1):
        part(market,"Upper market sign pier",(x-28.2+side*3.19,top+2.61,z-29.16),
             (.35,5.21,.38),"764E6C",collide=False)
    sign(market,"UPPER LANTERN MARKET",x-28.2,top+5.27,z-28.99,6.45,1.16,tint="764C75")
    sign(market,"STREET & FROSTGLASS",x-8.43,top+2.10,cz+2.84,5.35,.89,-90,"654E77")


CLOUDSTEP_CINDER_OFFSET = 2.45
CLOUDSTEP_WIDTH = 6.25


def potters_yard(parent,x,y,z):
    yard=item(parent,"Model","Potters' Yard")
    prop(yard,"token","ModelStreamingMode",1)
    prop(yard,"token","LevelOfDetail",4)
    cx,top,cz=x-48.2,y+8.3,z-24
    up=[(x-28,y+4.8,cz),(x-31.49,y+4.8,cz),(x-40,top,cz),(x-43,top,cz)]
    down=[(cx+.22,top,cz+7.9),(cx+.22,y+4.76,z+.86),(cx+.60,y+4.46,z+2.87),
          (cx+2.05,y+4.26,z+4.27),(cx+4.21,y+3.96,z+5.20),(x-31.4,y,z+8.7),(x-28.0,y,z+9.6)]
    for label,path in (("Upper kiln walk",up),("Potters' return path",down)):
        route(yard,label,path,5.2,"9A7066",surface=SLATE,stone_footings=False,railings=False,
              join_overlap=.39 if path is up else .80)
        for side in (-1,1):
            edge=path_edge(path,side*2.43)
            for index,(start,end) in enumerate(zip(edge,edge[1:])):
                if path is up and index==0:
                    # The first railing starts at the old deck edge, past the turn.
                    start=tuple(a+(b-a)*.78 for a,b in zip(start,end))
                if path is down and index==len(edge)-2:
                    end=tuple(a+(b-a)*.40 for a,b in zip(start,end))
                for height in (.65,1.35):
                    beam(yard,"Copperwood lane rail",(start[0],start[1]+height,start[2]),
                         (end[0],end[1]+height,end[2]),.23,"823E32",collide=True)
                for t in (.10,.48,.84):
                    px,py,pz=(a+(b-a)*t for a,b in zip(start,end))
                    part(yard,"Lane railing post",(px,py+.70,pz),(.31,1.43,.31),"8A4838")
                    part(yard,"Lane post bronze cap",(px,py+1.48,pz),(.49,.14,.49),"C8844A",collide=False)
                    part(yard,"Stepped path pilaster",(px,(py-4)/2,pz),(.95,py+4,1.15),"76575C",material=SLATE,collide=False)

    part(yard,"Potters' terrace paving",(cx,top-.30,cz),(16.5,.60,16.5),"AA8172",material=LIMESTONE)
    bluff=item(yard,"Folder","Cinder rock face")
    for px,upper,pz,width,depth,bottom,tint in (
        (cx-.6,4.4,cz+8.3,35.9,44.8,-5.55,"74606A"),
        (cx-1.1,8.3,cz+5.8,30.7,37.1,3.8,"8A6B68"),
        (cx-1.4,12.5,cz+2.1,23.8,26.4,7.7,"99736B"),
    ):
        garden_shelf(bluff,px,upper,pz,width,depth,upper-bottom,tint,SLATE)
    for dx,dz,h,roll,tint in ((-12.86,-1.3,10.8,-9,"89706D"),(9.6,5.2,6.7,11,"A18076"),
                              (-6.3,13.5,5.2,-17,"936F69"),(5.5,13.0,5.6,10,"8F716F")):
        part(bluff,"Exposed cinder outcrop",(cx+dx,h*.52-.42,cz+dz),(6.9,h,6.3),tint,
             yaw=14+dx*2,roll=roll,material=SLATE,class_name="WedgePart",collide=False)
    for dx,dz,scale,angle in ((-11.1,-4.2,.44,70),(9.9,7.4,.36,102),(-6.7,12.9,.61,41)):
        garden_prop(bluff,"bankRock",(cx+dx,8.26,cz+dz),scale,angle,"997A70")
        garden_prop(bluff,"meadowCover",(cx+dx+.21,8.35,cz+dz+.65),.20,angle,"9D9B5E")
    for course,(width,depth,bottom,upper,tint) in enumerate((
        (17.0,16.8,top-2.1,top-.61,"976F67"),(15.3,15.6,top-4.3,top-2.1,"8A6562"),
        (13.2,14.2,top-7.4,top-4.3,"785B60"),(10.8,11.2,-4,top-7.4,"74616A"),
    )):
        garden_shelf(yard,cx-.26*course,upper,cz-.13*course,width,depth,upper-bottom,tint,SLATE,collide=False)
    west_low=CLOUDSTEP_CINDER_OFFSET-CLOUDSTEP_WIDTH/2-.10
    west_high=CLOUDSTEP_CINDER_OFFSET+CLOUDSTEP_WIDTH/2+.10
    walls=((-8,-7.95,POTTERS_NORTH_RAIL_END,-7.95),(-8,-7.95,-8,west_low),(-8,west_high,-8,7.95),
           (8,-7.95,8,-2.6),(8,2.6,8,7.95),
           (-8,7.95,-2.35,7.95),(2.80,7.95,8,7.95))
    for sx,sz,ex,ez in walls:
        for height in (.65,1.35):
            beam(yard,"Yard cedar guardrail",(cx+sx,top+height,cz+sz),(cx+ex,top+height,cz+ez),
                 .25,"823E32",collide=True)
        for t in (0,.5,1):
            px,pz=cx+sx+(ex-sx)*t,cz+sz+(ez-sz)*t
            part(yard,"Yard railing pier",(px,top+.71,pz),(.36,1.45,.37),"8A4838")

    for px,pz in ((cx-5.35,cz-6.95),(cx+4.26,cz-6.95),(cx-5.35,cz-2.46),(cx+4.26,cz-2.46)):
        part(yard,"Workshop pillar plinth",(px,top+.24,pz),(.93,.48,.96),"A0827D",material=SLATE)
        part(yard,"Workshop cedar pillar",(px,top+2.26,pz),(.69,4.12,.70),"9A523A")
    roof(yard,cx-.55,top+4.43,cz-4.6,12.3,7.0)
    sign(yard,"POTTERS' YARD",cx-.55,top+3.79,cz-2.31,8.0,1.32,tint="783F39")
    for side in (-1,1):
        px=cx-.56+side*2.47
        part(yard,"Pottery workbench",(px,top+1.19,cz-5.08),(4.59,.26,1.81),"AD7353",material=WOOD_PLANK)
        for dx in (-1.86,1.86):
            part(yard,"Bench trestle",(px+dx,top+.54,cz-5.08),(.28,1.10,1.25),"805142")
        lamp(yard,px,top+3.02,cz-2.70,scale=.56,light=True)
        for index,(dx,scale,tint) in enumerate(((-1.42,.77,"BE704C"),(.12,1.05,"D18458"),(1.34,.63,"71948A"))):
            base=top+1.32
            for height,diameter,y_offset,color in ((.19,.52,.095,tint),(.32,.81,.34,tint),(.41,1.00,.68,tint),
                                                   (.22,.71,1.0,tint),(.14,.56,1.17,"C09A70")):
                part(yard,"Glazed clay jar",(px+dx,base+y_offset*scale,cz-5.08+index*.08),
                     (height*scale,diameter*scale,diameter*scale),color,roll=90,shape=2,collide=False)
    for dx,dz,yaw in ((-5.92,5.99,18),(5.9,4.43,77),(6.61,-4.24,92)):
        garden_prop(yard,"bankRock",(cx+dx,top,cz+dz),.16,yaw,"967874")
        garden_prop(yard,"meadowFlowers",(cx+dx+.19,top+.07,cz+dz+.42),.33,yaw,"E3A876")
    sign(yard,"POTTERS' YARD",x-32.98,y+7.12,cz+2.11,5.62,1.06,90,"783F39")
    sign(yard,"LOWER STREET",cx+3.38,top+1.85,cz+6.98,4.53,1.04,180,"783F39")


def frostglass_walk(parent,x,y,z):
    walk=item(parent,"Model","Frostglass Walk")
    prop(walk,"token","ModelStreamingMode",1)
    prop(walk,"token","LevelOfDetail",4)
    deck_y=y+4.6
    west=[(x-5.17,y,z+17.8),(x-5.17,y+2.8,z+7.9),(x-5.29,deck_y,z-.33),
          (x-4.71,deck_y,z-1.67),(x-2.72,deck_y,z-4.12)]
    east=[(x+2.24,deck_y,z-4.12),(x+4.84,deck_y,z-3.12),(x+6.04,deck_y,z-1.75),
          (x+6.25,deck_y,z+.28),(x+6.25,y,z+14.1)]
    for path in (west,east):
        for index,(start,end) in enumerate(zip(path,path[1:])):
            # Offset the overlapping slate courses so their faces render cleanly.
            course=[(px,py+index*.012,pz) for px,py,pz in (start,end)]
            route(walk,"Frostglass slate ramp",course,4.75,"9BA8B6",surface=SLATE,
                  stone_footings=False,railings=False,join_overlap=.49)
        for side in (-1,1):
            edge=path_edge(path,side*2.18)
            for start,end in zip(edge,edge[1:]):
                if start[1]==end[1] and min(start[2],end[2])<z-2.45:
                    continue
                for height in (.60,1.32):
                    beam(walk,"Blue cedar ramp rail",(start[0],start[1]+height,start[2]),
                         (end[0],end[1]+height,end[2]),.24,"496F85",collide=True)
                for t in (.16,.58,.90):
                    px,py,pz=(u+(v-u)*t for u,v in zip(start,end))
                    part(walk,"Frostglass cedar post",(px,py+.67,pz),(.32,1.39,.32),"577486")
                    part(walk,"Frostglass post cap",(px,py+1.38,pz),(.46,.16,.46),"BDC9D1",collide=False)
                if abs(end[1]-start[1])>.9:
                    px,py,pz=tuple((u+v)/2 for u,v in zip(start,end))
                    part(walk,"Split slate ramp footing",(px,(py+y-.45)/2,pz),(1.42,py-y+.45,1.48),
                         "83909D",material=SLATE,collide=False)

    cx,cz=x-.45,z-4.35
    part(walk,"Frostglass terrace foundation",(cx,y+2.0,cz),(12.9,4.0,8.4),"778696",material=SLATE)
    part(walk,"Frostglass terrace paving",(cx,deck_y-.27,cz),(13.2,.68,8.64),"C0CAD1",material=LIMESTONE)
    for index in range(9):
        px=cx+(index-4)*1.34
        part(walk,"Frosted facing stone",(px,y+.62+(index%3)*.32,cz+4.26),(1.39,1.31,.70),
             ("A2ADBC","929FAC","9BA9B8")[index%3],material=SLATE,yaw=(index%3-1)*5,collide=False)
    for (ax,az),(bx,bz) in (((-6.31,-4.04),(6.31,-4.04)),((-6.31,-4.04),(-6.31,.80)),
                           ((6.31,-4.04),(6.31,-2.12)),((-3.06,4.08),(3.69,4.08))):
        for height in (.60,1.36):
            beam(walk,"Glacier terrace rail",(cx+ax,deck_y+height,cz+az),(cx+bx,deck_y+height,cz+bz),
                 .24,"4A7086",collide=True)
        for t in (0,.5,1):
            px,pz=cx+ax+(bx-ax)*t,cz+az+(bz-az)*t
            part(walk,"Terrace railing post",(px,deck_y+.71,pz),(.39,1.43,.40),"597888")
    for px,pz in ((cx-2.96,cz-3.38),(cx+2.96,cz-3.38)):
        part(walk,"Pavilion carved cedar post",(px,deck_y+2.27,pz),(.47,4.54,.52),"557688")
        part(walk,"Pavilion granite foot",(px,deck_y+.25,pz),(.82,.50,.86),"A1AFB9",material=SLATE)
        lamp(walk,px,deck_y+2.92,pz+.47,scale=.58,light=True)
    swept_roof(walk,cx,deck_y+4.60,cz-2.28,8.45,5.29,2.02,fine_tiles=False)
    sign(walk,"FROSTGLASS WALK",x-8.53,y+2.33,z+18.02,5.58,1.1,tint="436781")
    part(walk,"Trail sign post",(x-8.53,y+1.10,z+17.73),(.24,2.21,.33),"557588",collide=False)
    sign(walk,"POND TERRACE",cx,deck_y+1.86,cz+4.12,5.84,1.07,tint="496D83")

    for rx,rz,scale,yaw in ((-3.44,3.9,.26,31),(3.58,3.82,.24,54),(-2.77,13.0,.17,73),(3.44,11.4,.18,115)):
        garden_prop(walk,"bankRock",(x+rx,y+.04,z+rz),scale,yaw,"A5B8C8")
        garden_prop(walk,"meadowCover",(x+rx+.23,y+.15,z+rz-.31),.16,yaw,"D0D9E4")
        for index in (-1,0,1):
            height=1.06+(1-abs(index))*.82
            part(walk,"Blue ice outcrop",(x+rx+index*.55,y+height/2+.12,z+rz-.36),
                 (.72,height,.96),("AFD9EB","84B8D5","B2C7EB")[index%3],
                 yaw=yaw+index*13,roll=index*11,material=GLASS,transparency=.11,collide=False,class_name="WedgePart")


def frostglass_high_walk(parent):
    walk=item(parent,"Model","Frostglass High Walk")
    prop(walk,"token","ModelStreamingMode",1)
    prop(walk,"token","LevelOfDetail",4)
    upper,lower=21.53,14.062
    x,turn_z,descent_z,foot_z=-168.25,-183.57,-171.95,-151.30
    ascent=[(-184.38,18.701,turn_z),(-182.70,18.701,turn_z),
            (-170.78,upper,turn_z),(-168.77,upper,turn_z)]
    descent=[(x,upper,descent_z),(x,lower,foot_z)]
    for name,path,width,tint in (
            ("Pond Terrace upper ramp",ascent,4.86,"A8AEBC"),
            ("Mistline upper descent",descent,5.24,"A4AEBD")):
        route(walk,name,path,width,tint,surface=SLATE,stone_footings=False,
              railings=False,join_overlap=.23)
        for a,b in zip(path,path[1:]):
            dx,dy,dz=(q-p for p,q in zip(a,b))
            length=hypot(dx,dz)
            rows=round(length/2.33)
            slope=atan2(dy,length)
            for index in range(1,rows):
                px,py,pz=(p+(q-p)*index/rows for p,q in zip(a,b))
                joint=part(walk,"Frostglass inset stone joint",(px,py+.25*(1/cos(slope)-1)+.009,pz),
                           (width-.29,.016,.056),"8995A8",yaw=degrees(atan2(dx,dz)),
                           pitch=-degrees(slope),collide=False)
                prop(joint,"bool","CastShadow",False)
    for label,center,size in (
            ("Upper turn landing",(x,upper-.245,turn_z),(5.32,.52,5.30)),
            ("High walk stone deck",(x,upper-.24,(turn_z+descent_z)/2),(5.32,.48,descent_z-turn_z+.12)),
            ("Meltwater balcony",(-163.93,upper-.254,-174.62),(3.38,.54,4.94)),
            ("Frostglass lower landing",(-167.10,lower-.22,foot_z+.19),(7.63,.48,3.77))):
        floor=part(walk,label,center,size,"B6BDC8",material=LIMESTONE)
        prop(floor,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)

    def rail(a,b):
        length=dist(a,b)
        for lift,gauge in ((.58,.19),(1.43,.23)):
            beam(walk,"Blue cedar high walk rail",(a[0],a[1]+lift,a[2]),
                 (b[0],b[1]+lift,b[2]),gauge,"4B677D",collide=True)
        post_count=max(1,ceil(length/3.02))
        for index in range(post_count):
            px,py,pz=(p+(q-p)*index/post_count for p,q in zip(a,b))
            part(walk,"Blue cedar high walk newel",(px,py+.74,pz),(.36,1.51,.36),"5E7184",
                 material=WOOD_PLANK)
            part(walk,"Warm high walk finial",(px,py+1.54,pz),(.45,.15,.46),"C9A06D",collide=False)

    for path,offset in ((ascent[1:3],2.24),(descent,2.42)):
        for side in (-1,1):
            start,end=path_edge(path,side*offset)
            if path[0]==ascent[1] and start[2]>turn_z:
                # Leave the existing east ramp's entrance clear at the fork.
                start=tuple(a+(b-a)*.15 for a,b in zip(start,end))
            rail(start,end)
            beam(walk,"Blue cedar ramp fascia",(start[0],start[1]-.21,start[2]),
                 (end[0],end[1]-.21,end[2]),.34,"647187")
    west,east=x-2.42,x+2.42
    north=turn_z-2.42
    for ax,az,bx,bz in (
            (west,north,east,north),(west,turn_z+2.25,ascent[2][0],turn_z+2.25),
            (west,descent_z,west,turn_z+2.25),(east,north,east,-176.87),
            (east,-176.87,-162.43,-176.87),
            (-162.43,-172.34,east,-172.34),(east,-172.34,east,descent_z)):
        if hypot(bx-ax,bz-az)>.32:
            rail((ax,upper,az),(bx,upper,bz))
    rail((-170.52,lower,foot_z+1.84),(-163.47,lower,foot_z+1.84))

    for px,pz,top in ((-178.10,turn_z,19.79),(-173.14,turn_z,20.96),
                      (x,-185.16,upper),(x,-172.93,upper),(x,-165.27,19.00),
                      (x,-158.53,16.66)):
        pier_height=top-.56-lower
        part(walk,"Granite pier footing",(px,lower+.20,pz),(1.93,.39,1.83),"9DA4B0",material=SLATE)
        part(walk,"Tall dressed granite pier",(px,lower+pier_height/2,pz),(1.35,pier_height,1.37),
             "748698",material=SLATE)
        part(walk,"Frost-cut pier capital",(px,top-.57,pz),(2.12,.47,2.06),
             "A2ADB8",material=LIMESTONE,collide=False)
    for side in (-1,1):
        line=x+side*1.43
        beam(walk,"Cedar girder above Mistline",(line,upper-.56,-184.94),
             (line,upper-.56,-172.68),.38,"526174")
    for px,pz,y in ((-170.50,-185.82,upper),(-162.53,-172.74,upper),(-170.60,-151.42,lower)):
        festival_lantern(walk,px,y+1.75,pz,.49,light=False,tint="FFC17D")

    part(walk,"Meltwater viewing bench",(-163.93,upper+.56,-176.40),(.65,.21,1.86),
         "89645B",material=WOOD_PLANK,yaw=90,collide=False)
    for px in (-164.50,-163.35):
        part(walk,"Granite bench foot",(px,upper+.25,-176.40),(.51,.52,.36),
             "8C9FAD",material=SLATE,yaw=90,collide=False)
    sign(walk,"FROSTGLASS HIGH WALK",-181.85,20.75,-186.22,4.64,.88,-51,"4A6F81")
    sign(walk,"MELTWATER VIEW", -164.05,upper+1.02,-177.08,3.96,.70,180,"4D6D80")
    sign(walk,"FROSTGLASS HIGH WALK",-169.95,lower+2.14,-149.54,5.39,.92,37,"4A6F81")
    sign(walk,"MISTLINE VISTA  ←",-164.67,lower+1.72,-149.62,4.55,.82,180,"5C6C82")
    for index,(px,py,pz) in enumerate(((-177.36,lower,-185.39),(-170.97,lower,-173.86),
            (-165.35,lower,-167.73),(-170.87,lower,-156.00),(-166.74,lower,-150.03))):
        garden_prop(walk,"bankRock",(px,py,pz),.13,16+index*42,"A7ACBD")
        garden_prop(walk,"mossFlowers",(px+.62,py+.075,pz+.38),.12,53+index*24,"CBC8E4")
        garden_prop(walk,"meadowCover",(px-.22,py+.06,pz-.36),.10,23+index*64,"B1BEA1")


mistline_vista_climb=[(-162.6,14.051,-155.80),(-156.80,14.051,-155.80),
                     (-138.08,19.667,-155.70)]
mistline_vista_return=[(-130.40,19.665,-160.10),(-130.40,19.665,-162.80),
                      (-134.30,19.20,-166.14),(-151.64,14.051,-170.20),
                      (-157.90,14.051,-170.20),(-163.80,14.051,-170.20)]


def mistline_vista(parent):
    vista=item(parent,"Model","Mistline Vista")
    prop(vista,"token","ModelStreamingMode",1)
    prop(vista,"token","LevelOfDetail",4)
    deck_y=19.657
    cx,cz=-131.65,-155.08
    width,depth=12.98,10.17
    xmin,xmax=cx-width/2,cx+width/2
    zmin,zmax=cz-depth/2,cz+depth/2
    part(vista,"Pale stone vista floor",(cx,deck_y-.28,cz),(width,.56,depth),
         "B6A8AE",material=LIMESTONE)
    part(vista,"Vista cedar fascia",(cx,deck_y-.42,zmax+.035),(width+.14,.26,.14),
         "685469",material=WOOD_PLANK,collide=False)

    def pier(label,x,z,top,width,depth,tint):
        bottom=-5.32
        part(vista,label,(x,(top+bottom)/2,z),(width,top-bottom,depth),
             tint,material=SLATE,collide=False)

    for x in (-136.22,-127.21):
        for z in (-158.96,-150.99):
            pier("Vista slate pier",x,z,deck_y-.78,1.67,1.63,"81788A")
            part(vista,"Dressed vista pier capital",(x,deck_y-.69,z),(1.88,.31,1.87),
                 "A699A7",material=SLATE,collide=False)

    def railing(start,end):
        for lift in (.57,1.40):
            beam(vista,"Blue cedar vista rail",(start[0],start[1]+lift,start[2]),
                 (end[0],end[1]+lift,end[2]),.23,"53677E",collide=True)
        length=hypot(end[0]-start[0],end[2]-start[2])
        posts=max(1,round(length/2.5))
        for index in range(posts+1):
            if index==posts and length>5:
                continue
            x,y,z=(a+(b-a)*index/posts for a,b in zip(start,end))
            part(vista,"Vista rail post",(x,y+.70,z),(.27,1.45,.29),"596479")
            part(vista,"Vista rail cap",(x,y+1.43,z),(.38,.14,.40),"B79972",collide=False)

    for path,first_guard,last_guard in ((mistline_vista_climb,1,2),(mistline_vista_return,0,4)):
        left,right=(path_edge(path,side*2.76) for side in (-1,1))
        for a,b,c,d in zip(left,left[1:],right[1:],right):
            corners=[(x,y-.22,z) for x,y,z in (a,b,c,d)]
            for i,j,k in ((0,1,2),(0,2,3)):
                triangle(vista,corners[i],corners[j],corners[k],"A49BA8",
                         name="Frostglass vista ramp",thickness=.44,material=SLATE,collide=True)
        for side in (-1,1):
            edge=path_edge(path,side*2.59)
            for i in range(first_guard,last_guard):
                railing(edge[i],edge[i+1])
        for a,b in zip(path,path[1:]):
            if abs(a[1]-b[1])>.5:
                for t in (.23,.65,.89):
                    x,y,z=(u+(v-u)*t for u,v in zip(a,b))
                    pier("Slate ramp stone support",x,z,y-.40,1.21,1.52,"8F8490")

    # Open the west climb, north return and east Glacier Lantern Walk junctions.
    for (ax,az),(bx,bz) in (((xmin+.15,zmax-.13),(xmax-.15,zmax-.13)),
                           ((xmax-.15,zmax-.13),(xmax-.15,-152.35)),
                           ((xmax-.15,-157.81),(xmax-.15,zmin+.13)),
                           ((xmin+.15,zmin+.13),(-133.19,zmin+.13)),
                           ((-127.59,zmin+.13),(xmax-.15,zmin+.13)),
                           ((xmin+.15,zmax-.13),(xmin+.15,-152.95)),
                           ((xmin+.15,-158.55),(xmin+.15,zmin+.13))):
        railing((ax,deck_y,az),(bx,deck_y,bz))
    for x in (-135.88,-126.83):
        for z in (-157.70,-151.49):
            part(vista,"Vista cedar pavilion column",(x,deck_y+2.76,z),(.59,5.53,.62),
                 "63536E",material=WOOD_PLANK)
            part(vista,"Vista granite column shoe",(x,deck_y+.30,z),(.93,.60,.96),
                 "A095A6",material=SLATE,collide=False)
        festival_lantern(vista,x,deck_y+3.78,-151.03,.53,light=False,tint="F7B975")
    swept_roof(vista,cx,deck_y+5.59,cz,12.18,8.82,2.12,fine_tiles=False)
    sign(vista,"MISTLINE VISTA",cx,deck_y+4.83,-150.57,7.36,1.13,tint="53647D")
    part(vista,"Vista cedar bench",(-131.70,deck_y+.63,-151.30),(3.07,.23,.72),
         "A47863",material=WOOD_PLANK,collide=False)
    for x in (-132.82,-130.61):
        part(vista,"Vista bench granite leg",(x,deck_y+.27,-151.30),(.38,.53,.57),
             "958797",material=SLATE,collide=False)
    for index,(x,z) in enumerate(((-157.08,-152.05),(-151.32,-158.56),(-146.22,-166.01),(-156.53,-173.74))):
        floor=14.06
        pier("Vista planter foundation",x,z,floor+.02,1.23,1.11,"8B8192")
        garden_shelf(vista,x,floor+.40,z,2.52,1.66,.42,"8D8598",SLATE,collide=False)
        garden_prop(vista,"bankRock",(x-.29,floor+.31,z+.08),.16,37*index,"9E9AB1")
        garden_prop(vista,"mossFlowers",(x+.29,floor+.39,z-.33),.13,73*index,"BFB7D5")
        garden_prop(vista,"meadowCover",(x+.46,floor+.37,z+.24),.11,23*index,"B8C9A8")
    for x,z in ((-161.37,-152.84),(-162.07,-167.03)):
        part(vista,"Vista sign post",(x,15.52,z),(.29,2.99,.29),"594F62",collide=False)
        sign(vista,"MISTLINE VISTA  →",x-.18,16.58,z+.14,4.76,.89,-55,"516980")
    pier("Crossing sign pier",-143.95,-172.51,17.94,.34,.34,"63586E")
    sign(vista,"MISTLINE CROSSING  →",-143.73,17.92,-172.45,6.68,.92,68,"657087")


def frostglass_escarpment(parent):
    slope=item(parent,"Model","Frostglass east escarpment")
    prop(slope,"token","ModelStreamingMode",1)
    prop(slope,"token","LevelOfDetail",4)
    for index,(z,length,offset,crest) in enumerate(((-174.42,7.50,-.21,11.88),
            (-168.31,8.05,.34,13.20),(-162.10,7.83,.67,12.31),
            (-155.70,8.36,-.41,13.42),(-149.68,7.36,.33,11.94))):
        for x,top,width,depth,thickness,tint in (
                (-153.78,3.03,15.35,length+2.11,8.28,"7F778C"),
                (-154.67,6.72,13.40,length+1.35,4.84,"898195"),
                (-156.37,crest-2.83,10.75,length+.73,4.12,"948899"),
                (-158.11,crest,6.86,length,3.34,"A49BAA")):
            garden_shelf(slope,x+offset,top,z,width,depth,thickness,tint,SLATE,collide=False)
        part(slope,"Slanted glacial rock face",(-151.34+offset,3.54,z-.41),
             (length*.82,10.85,6.85),"80788B",yaw=-90+(-1)**index*11,
             material=SLATE,collide=False,class_name="WedgePart")
        bed_x=-154.58+offset
        bed_y=crest-2.67
        garden_shelf(slope,bed_x,bed_y,z-.42,4.24,length*.62,.31,"687D62",GRASS_MAT,collide=False)
        garden_prop(slope,"bankRock",(bed_x-.87,bed_y-.20,z+.24),.28,29+index*21,"AD9FAF")
        garden_prop(slope,"meadowCover",(bed_x+.34,bed_y-.07,z-.98),.16,32+index*29,"B2C2A6")
        garden_prop(slope,"mossFlowers",(bed_x+.05,bed_y-.04,z+.76),.13,57+index*41,"D1C7E3")
        garden_prop(slope,"rockVine",(bed_x+.83,bed_y-2.10,z-.19),.31,90,"7D9C75")
        for leaf,(dx,dz,diameter) in enumerate(((-.24,-1.22,1.21),(.67,-.46,1.08),(.43,.18,.84))):
            part(slope,"Frostglass ledge shrub",(bed_x+dx,bed_y+.12,z+dz),
                 (diameter,.64,diameter*.75),("6B836C","819174","99A47D")[leaf],
                 material=GRASS_MAT,shape=0,collide=False)


def harbor_overlook(parent, x, y, z):
    terrace=item(parent,"Model","Beacon Terrace")
    prop(terrace,"token","ModelStreamingMode",1)
    prop(terrace,"token","LevelOfDetail",4)
    approach=[(x+26,y+.027,z+1.7),(x+42,y+4.2,z+.2),(x+61.88,y+8.025,z-1.23),(x+64,y+8.025,z-1.4)]
    route(terrace,"Beacon boardwalk",approach,7.2,"89624D",surface=WOOD_PLANK,stone_footings=False,
          join_overlap=.43,railings=False)
    for start,end in zip(approach,approach[1:]):
        dx,dy,dz=(b-a for a,b in zip(start,end))
        level_length=hypot(dx,dz)
        board_count=round(level_length/.87)
        for index in range(board_count):
            t=(index+.5)/board_count
            position=(start[0]+dx*t,start[1]+dy*t+.018,start[2]+dz*t)
            part(terrace,"Cedar boardwalk plank",position,(7.05,.055,hypot(level_length,dy)/board_count-.035),
                 ("A87B5D","B48564","A1795D","AD8161")[index%4],
                 yaw=degrees(atan2(dx,dz)),pitch=-degrees(atan2(dy,level_length)),material=WOOD_PLANK,collide=False)
        for side in (-1,1):
            rail_z=side*3.35
            for height,width in ((.68,.19),(1.43,.25)):
                beam(terrace,"Boardwalk cedar railing",(start[0],start[1]+height,start[2]+rail_z),
                     (end[0],end[1]+height,end[2]+rail_z),width,"356B70",collide=True)
            for t in (.16,.43,.70,.93):
                px,py,pz=start[0]+dx*t,start[1]+dy*t,start[2]+dz*t+rail_z
                part(terrace,"Cedar railing post",(px,py+.73,pz),(.34,1.49,.34),"426B69",collide=True)
                part(terrace,"Boardwalk foundation pile",(px,(py-3)/2,pz),(.74,py+3,.79),"736355",collide=False)
                part(terrace,"Boardwalk post cap",(px,py+1.50,pz),(.48,.15,.45),"CA995D",collide=False)

    deck_x,deck_y,deck_z=x+70.6,y+8,z-1.4
    part(terrace,"Beacon slate support",(deck_x,deck_y-2.13,deck_z),(17.3,3.9,16.3),"7B727D",material=SLATE)
    part(terrace,"Beacon viewing deck",(deck_x,deck_y-.39,deck_z),(17.1,.78,16.1),"B28B6A",material=WOOD_PLANK)
    for ox,oz in ((-7,-6),(-7,6),(7,-6),(7,6)):
        part(terrace,"Terrace stone footing",(deck_x+ox,(deck_y-3)/2,deck_z+oz),
             (2.1,deck_y+3,2.1),"716C73",material=SLATE,collide=False)
    north_left,north_right=(edge-deck_x for edge in TIDEWATCH_BEACON_OPENING)
    east_north,east_south=(point[2]-deck_z for point in SKY_PIER_BEACON_GUARDS)
    for start,end in (((-8.13,-7.77),(north_left,-7.77)),((north_right,-7.77),(8.13,-7.77)),
                      ((8.13,-7.77),(8.13,east_north)),((8.13,east_south),(8.13,7.77)),
                      ((8.13,7.77),(5.85,7.77)),((-2.0,7.77),(-8.13,7.77)),((-8.13,-7.77),(-8.13,-3.45)),
                      ((-8.13,3.45),(-8.13,7.77))):
        for height in (.68,1.43):
            beam(terrace,"Terrace cedar railing",(deck_x+start[0],deck_y+height,deck_z+start[1]),
                 (deck_x+end[0],deck_y+height,deck_z+end[1]),.26,"356B70",collide=True)
        for t in (0,1) if dist(start,end)<1.8 else (0,.50,1):
            px,pz=deck_x+start[0]+(end[0]-start[0])*t,deck_z+start[1]+(end[1]-start[1])*t
            part(terrace,"Terrace railing post",(px,deck_y+.75,pz),(.35,1.50,.35),"426B69",collide=True)
    for offset in (-6.47,6.47):
        lamp(terrace,deck_x+7.29,deck_y+.98,deck_z+offset,scale=.64,light=True)
    for offset in (-3.35,3.35):
        lamp(terrace,x+42,y+5.93,z+.2+offset,scale=.50)
    for dx,dz,yaw in ((-6.30,5.75,25),(-1.30,6.32,73),(-4.8,-5.30,56)):
        garden_prop(terrace,"bankRock",(deck_x+dx,deck_y,deck_z+dz),.19,yaw,"8E888B")
        garden_prop(terrace,"meadowCover",(deck_x+dx-.43,deck_y+.09,deck_z+dz+.28),.12,yaw,"9BA962")

    bx,bz=deck_x-1.08,deck_z-4.65
    for elevation,height,diameter,tint in ((.26,.52,4.69,"887A82"),(.73,.45,4.28,"A0938B"),
                                           (2.68,3.66,3.85,"D5B79D"),(4.59,.36,4.15,"637D79"),
                                           (5.03,.40,4.32,"466B71"),(7.50,.44,4.45,"8A6D52")):
        part(terrace,"Beacon stone drum",(bx,deck_y+elevation,bz),(height,diameter,diameter),
             tint,roll=90,shape=2,material=SLATE)
    for angle in range(0,360,60):
        a=radians(angle)
        part(terrace,"Beacon lens frame",(bx+sin(a)*1.93,deck_y+6.23,bz+cos(a)*1.93),
             (.24,2.15,.24),"507778",collide=False)
    lens=part(terrace,"Amber harbor beacon",(bx,deck_y+6.25,bz),(2.83,1.65,2.83),"FFBA6F",
              shape=0,material=NEON,collide=False)
    lantern_light(lens,1.18)
    swept_roof(terrace,bx,deck_y+7.69,bz,6.37,5.86,2.83,fine_tiles=False)
    sign(terrace,"BEACON TERRACE",x+24.85,y+3.26,z+5.35,7.14,1.27,-90,"386D72")
    post_x,post_z=deck_x-7.65,deck_z+5.44
    for dz in (-1.64,1.64):
        part(terrace,"Wayfinding cedar support",(post_x,deck_y+1.16,post_z+dz),(.29,2.32,.24),"685148",collide=False)
    sign(terrace,"BEACON TERRACE",post_x-.19,deck_y+2.40,post_z,5.46,1.21,-90,"386D72")
    sign(terrace,"QUAY & CINDER ROAD",post_x+.19,deck_y+2.40,post_z,5.46,1.21,90,"386D72")


def lantern_quay(parent):
    quay=item(parent,"Model","Lantern Quay")
    prop(quay,"token","ModelStreamingMode",1)
    prop(quay,"token","LevelOfDetail",4)
    path=[(265.30,4.535,39.55),(272.20,4.535,39.55),(276.08,5.52,37.47),
          (281.31,7.25,33.65),(286.00,9.10,30.05),(289.70,10.43,27.17),
          (291.10,11.015,25.35),(293.70,11.015,21.97)]
    route(quay,"Lantern Quay rising boardwalk",path,5.95,"A17759",surface=WOOD_PLANK,
          stone_footings=False,join_overlap=.43,railings=False)
    railing="386A6A"
    for side in (-2.72,2.72):
        edge=path_edge(path,side)
        for index,(a,b) in enumerate(zip(edge,edge[1:])):
            sky_pier_opening=side<0 and index==3
            if index==0:
                if side<0:
                    continue
                a=tuple(u+(v-u)*.56 for u,v in zip(a,b))
            if not sky_pier_opening:
                for lift in (.59,1.38):
                    beam(quay,"Quay teal railing",(a[0],a[1]+lift,a[2]),(b[0],b[1]+lift,b[2]),
                         .22,railing,collide=True)
            for t in (.25,.78):
                x,y,z=(u+(v-u)*t for u,v in zip(a,b))
                if not sky_pier_opening:
                    part(quay,"Quay rail newel",(x,y+.73,z),(.34,1.48,.34),railing)
                    part(quay,"Quay brass post cap",(x,y+1.48,z),(.44,.15,.46),"BF9257",collide=False)
                if index>0 and t==.78:
                    base=-3.78
                    underside=y-.34
                    part(quay,"Weathered harbor piling",(x,(base+underside)/2,z),(1.06,underside-base,1.06),
                         "765B53",material=WOOD_PLANK,collide=False)
                    part(quay,"Piling waterline stone",(x,.66,z),(1.59,1.66,1.60),"918584",
                         material=SLATE,collide=False)
                    if index in (2,4,6):
                        lamp(quay,x,y+1.84,z,scale=.48,light=False)
    for a,b in zip(path,path[1:]):
        dx,dy,dz=(v-u for u,v in zip(a,b))
        length=hypot(dx,dz)
        plank_count=round(length/.9)
        for n in range(plank_count):
            t=(n+.5)/plank_count
            x,y,z=(u+(v-u)*t for u,v in zip(a,b))
            part(quay,"Tide-worn cedar plank",(x,y+.023,z),(5.78,.031,.76),
                 ("AA7D5E","A67456","BB906D")[n%3],yaw=degrees(atan2(dx,dz)),
                 pitch=-degrees(atan2(dy,length)),material=WOOD_PLANK,collide=False)

    west,east,north,south=267.72,278.18,41.15,49.86
    fx,fz=(west+east)/2,(north+south)/2
    top=4.585
    part(quay,"Mooring Rest deck",(fx,top-.33,fz),(east-west,.66,south-north),"B38A6B",material=WOOD_PLANK)
    for x in (west+.54,east-.54):
        for z in (43.4,south-.63):
            part(quay,"Mooring pier footing",(x,.20,z),(1.58,7.80,1.58),"7A6C70",material=SLATE,collide=False)
    for u,v in (((west+.22,north+.20),(west+.22,south-.20)),
                ((west+.22,south-.20),(east-.22,south-.20)),((east-.22,south-.20),(east-.22,north+.20)),
                ((east-.22,north+.20),(273.02,north+.20))):
        for lift in (.58,1.30):
            beam(quay,"Mooring Rest rail",(u[0],top+lift,u[1]),(v[0],top+lift,v[1]),.22,railing,collide=True)
        for t in (0,.5,1):
            x,z=(a+(b-a)*t for a,b in zip(u,v))
            part(quay,"Mooring Rest post",(x,top+.70,z),(.35,1.43,.35),railing)
    for x in (269.30,276.47):
        for z in (45.40,48.81):
            part(quay,"Mooring Rest shelter column",(x,top+2.77,z),(.47,5.54,.48),"774B39",material=WOOD_PLANK)
        festival_lantern(quay,x,top+4.57,45.55,.63,light=False,tint="FFD08E")
    swept_roof(quay,272.88,top+5.52,47.05,9.70,5.27,1.43,fine_tiles=False)
    sign(quay,"MOORING REST",272.88,top+4.85,44.40,5.89,.86,180,"386866")
    part(quay,"Waterfront cedar bench",(272.78,top+.64,48.37),(4.12,.35,.92),"98694D",material=WOOD_PLANK)
    for x in (271.32,274.24):
        part(quay,"Bench stone support",(x,top+.27,48.37),(.52,.54,.68),"8A7782",material=SLATE)
    for x,z,yaw in ((268.43,45.65,19),(277.33,47.07,77),(275.86,43.00,133)):
        part(quay,"Quay cedar planter",(x,top+.21,z),(1.15,.42,1.10),"A27350",material=WOOD_PLANK)
        garden_prop(quay,"mossFlowers",(x,top+.42,z),.122,yaw,"EBC0BE")
        garden_prop(quay,"meadowGrass",(x+.10,top+.43,z+.12),.108,yaw+35,"9EAF6E")
        garden_prop(quay,"meadowFlowers",(x-.17,top+.45,z+.09),.205,yaw+63,"EEBC88")
    for index,(x,z) in enumerate(((277.94,46.3),(282.7,38.8),(287.78,30.7))):
        garden_shelf(quay,x,1.85,z,4.0,3.61,1.38,"887A82",SLATE,collide=False)
        garden_prop(quay,"bankRock",(x,1.46,z+.13),.30,54+index*33,"908486")
        garden_prop(quay,"cattails",(x+.58,1.55,z+.38),.28,34+index*59)
        garden_prop(quay,"meadowCover",(x-.43,1.83,z-.37),.124,51+index*33,"92A469")
    for x,y,z,yaw,label in ((225.5,6.16,36.85,175,"LANTERN QUAY  ←"),
                            (272.9,7.49,34.99,-82,"BEACON TERRACE"),
                            (297.62,13.69,21.42,-104,"LANTERN QUAY  ↓")):
        part(quay,"Quay wayfinding post",(x,y-1.52,z),(.35,3.10,.34),railing,collide=False)
        sign(quay,label,x,y,z,6.48,.97,yaw,"386866")


def moored_skiff(parent,x,z,yaw,hull):
    boat=item(parent,"Model","Moored harbor skiff")
    prop(boat,"token","ModelStreamingMode",1)
    angle=radians(yaw)
    def point(dx,y,dz):
        return (x+dx*cos(angle)+dz*sin(angle),y,z-dx*sin(angle)+dz*cos(angle))
    stations=((.25,-3.6),(1.12,-2.40),(1.43,-.72),(1.45,1.22),(1.09,2.68))
    for side in (-1,1):
        for (width,start),(next_width,end) in zip(stations,stations[1:]):
            a,b=point(side*width,2.22,start),point(side*next_width,2.22,end)
            c,d=point(side*next_width*.65,1.11,end),point(side*width*.65,1.11,start)
            triangle(boat,a,b,c,hull,thickness=.16,material=WOOD_PLANK,name="Painted skiff hull")
            triangle(boat,a,c,d,hull,thickness=.16,material=WOOD_PLANK,name="Painted skiff hull")
            beam(boat,"Honey cedar gunwale",a,b,.16,"C99760")
    part(boat,"Skiff floor",point(0,1.59,-.40),(1.48,.19,4.30),"986C51",yaw=yaw,material=WOOD_PLANK,collide=False)
    for dz in (-1.12,.56,1.69):
        part(boat,"Cedar cross seat",point(0,1.96,dz),(2.32,.17,.50),"CB9C66",yaw=yaw,material=WOOD_PLANK,collide=False)
    part(boat,"Skiff stern board",point(0,1.75,2.62),(2.07,.87,.18),hull,yaw=yaw,material=WOOD_PLANK,collide=False)


def sunken_pirate_galleon(parent):
    arena=item(parent,"Model","Sunken Pirate Galleon")
    prop(arena,"token","ModelStreamingMode",1)
    prop(arena,"token","LevelOfDetail",4)
    z=63.1
    deck_y=5.62
    mat_y=6.34
    teal,cedar,brass="346C72","805A4F","CB9A61"
    course=[(218.3,3.046,44.3),(218.3,3.046,47.45),(218.3,4.31,54.6),
            (223.9,4.78,61.7),(230.1,4.97,z),(246.8,5.08,z),(265.62,deck_y,z)]
    landing=item(arena,"Model","Galleon boardwalk")
    left,right=(path_edge(course,side) for side in (-3.16,3.16))
    for index,(a,b) in enumerate(zip(course,course[1:])):
        dx,dy,dz=(q-p for p,q in zip(a,b))
        length=dist(a,b)
        level=hypot(dx,dz)
        yaw=degrees(atan2(dx,dz))
        pitch=-degrees(atan2(dy,level))
        floor=[(px,py-.22,pz) for px,py,pz in (left[index],right[index],right[index+1],left[index+1])]
        for i,j,k in ((0,1,2),(0,2,3)):
            triangle(landing,floor[i],floor[j],floor[k],"A97F64",name="Galleon boardwalk deck",
                     material=WOOD_PLANK,thickness=.44,collide=True,shadow=False)
        if index<2:
            continue
        board_count=max(1,round(level/1.12))
        for i in range(board_count):
            t=(i+.5)/board_count
            px,py,pz=(p+(q-p)*t for p,q in zip(a,b))
            plank=part(landing,"Tide-worn gangway plank",(px,py+.015,pz),(6.09,.022,length/board_count-.045),
                       ("BA9073","B2886D","AC8065")[i%3],yaw=yaw,pitch=pitch,material=WOOD_PLANK,collide=False)
            prop(plank,"bool","CastShadow",False)

    def harbor_rail(model,a,b,*,fixtures=False):
        span=dist(a,b)
        segments=max(1,ceil(span/4.35))
        for lift,width in ((.56,.20),(1.33,.255)):
            beam(model,"Galleon teal rail",(a[0],a[1]+lift,a[2]),(b[0],b[1]+lift,b[2]),
                 width,teal,collide=True)
        for i in range(segments):
            px,py,pz=(u+(v-u)*i/segments for u,v in zip(a,b))
            part(model,"Galleon cedar rail post",(px,py+.69,pz),(.33,1.43,.34),teal)
            part(model,"Galleon brass rail shoe",(px,py+1.37,pz),(.47,.15,.47),brass,collide=False)
            if fixtures and i%2==0:
                lamp(model,px,py+1.93,pz,scale=.42)

    for side in (-2.88,2.88):
        edge=path_edge(course,side)
        for index,(a,b) in enumerate(zip(edge,edge[1:])):
            if index==0:
                continue
            harbor_rail(landing,a,b,fixtures=index>2)
            if index>=2:
                x,y,pz=b
                part(landing,"Gangway mooring pile",(x,(y-4.55)/2,pz),(.72,y+4.01,.74),
                     "705A58",material=WOOD_PLANK,collide=False)
                part(landing,"Gangway piling collar",(x,1.18,pz),(1.12,1.25,1.12),
                     "9C8C91",material=SLATE,collide=False)
    for x,z0,yaw in ((214.8,49.7,19),(222.25,48.9,76)):
        garden_shelf(landing,x,2.12,z0,4.85,4.28,1.48,"8B8187",SLATE,collide=False)
        garden_prop(landing,"bankRock",(x-.69,1.96,z0-.42),.27,yaw,"A69792")
        garden_prop(landing,"mossFlowers",(x+.64,2.14,z0+.62),.15,yaw+28,"DCA8AE")
        garden_prop(landing,"meadowCover",(x+.20,2.13,z0-.52),.17,yaw+43,"99AD7C")
        garden_prop(landing,"grassBlade",(x-.53,2.12,z0+.35),.34,yaw+19,"B5B188")
    for x in (214.92,221.68):
        part(landing,"Galleon gate stone foot",(x,3.51,48.05),(1.04,1.07,1.08),"8C7A80",material=SLATE)
        part(landing,"Galleon gate cedar post",(x,6.13,48.05),(.59,5.10,.6),cedar)
        festival_lantern(landing,x,7.42,47.78,.49,light=False)
    beam(landing,"Galleon gate crosspiece",(214.53,8.70,48.05),(222.07,8.70,48.05),.58,teal)
    swept_roof(landing,218.3,8.92,48.05,8.73,2.69,1.26,fine_tiles=False)
    sign(landing,"GALLEON ARENA",218.3,8.18,47.63,6.5,1.01,180,teal)
    sign(landing,"TIDEHARBOR SQUARE",218.3,8.18,48.47,6.5,1.01,0,teal)
    part(landing,"Harbor arena sign post",(214.0,4.00,21.82),(.29,1.94,.29),cedar,collide=False)
    sign(landing,"GALLEON ARENA  →",213.79,5.12,21.82,6.0,.83,-90,teal)

    hull=item(arena,"Model","Galleon hull and deck")
    # The visible ribs widen from the salvaged stern into the middle fighting deck.
    stations=((265.2,5.35),(272.5,12.30),(282.0,15.4),(299.5,15.62),
              (311.2,14.79),(322.3,9.80),(329.1,2.10))
    for index,((x,w),(end,next_w)) in enumerate(zip(stations,stations[1:])):
        a,b,c,d=((px,deck_y-.21,pz) for px,pz in
                 ((x,z-w),(end,z-next_w),(end,z+next_w),(x,z+w)))
        for face in ((a,b,c),(a,c,d)):
            triangle(hull,*face,("AC8067","B6896E")[index%2],name="Galleon walking deck",
                     material=WOOD_PLANK,thickness=.42,collide=True,shadow=False)
        plank_count=max(1,round((end-x)/1.45))
        for i in range(plank_count):
            t=(i+.5)/plank_count
            width=w+(next_w-w)*t
            board=part(hull,"Salvaged cedar deck plank",(x+(end-x)*t,deck_y+.009,z),
                       ((end-x)/plank_count-.035,.017,width*2-.20),
                       ("B68D72","AA7D64","BD9378")[i%3],material=WOOD_PLANK,collide=False)
            prop(board,"bool","CastShadow",False)
        for side in (-1,1):
            for row,((lo,low_scale),(hi,high_scale)) in enumerate(zip(
                ((-.31,.69),(1.42,.87),(3.36,1.02)),((1.42,.87),(3.36,1.02),(deck_y-.09,1))
            )):
                p,q=(x,lo,z+side*w*low_scale),(end,lo,z+side*next_w*low_scale)
                r,s=(end,hi,z+side*next_w*high_scale),(x,hi,z+side*w*high_scale)
                for face in ((p,q,r),(p,r,s)):
                    triangle(hull,*face,("493D4B","53747B","73534E")[row],name="Weathered galleon hull",
                             material=WOOD_PLANK,thickness=.24,shadow=False)
            for y,widen,color_name,trim in ((3.43,1.025,"Brass hull belt",brass),
                                             (deck_y-.08,1.004,"Cedar gunwale","805852")):
                beam(hull,color_name,(x,y,z+side*w*widen),(end,y,z+side*next_w*widen),.22,trim)
            harbor_rail(hull,(x,deck_y,z+side*(w-.19)),(end,deck_y,z+side*(next_w-.19)),fixtures=index in (1,4))
    for sign_z in (z-3.98,z+3.98):
        part(hull,"Stern entrance jamb",(265.33,deck_y+.82,sign_z),(.53,1.68,.53),teal)
        lamp(hull,265.33,deck_y+2.06,sign_z,scale=.46)
    for a,b in (((265.39,deck_y,z-5.12),(265.39,deck_y,z-3.92)),
                ((265.39,deck_y,z+3.92),(265.39,deck_y,z+5.12)),
                ((328.91,deck_y,z-2.01),(328.91,deck_y,z+2.01))):
        harbor_rail(hull,a,b)

    ring=item(arena,"Model","Tideharbor practice ring")
    mat_x=293.0
    part(ring,"Galleon ring platform",(mat_x,mat_y-.36,z),(24.3,.72,18.8),"635150",material=WOOD_PLANK)
    mat=part(ring,"Woven maritime mat",(mat_x,mat_y+.012,z),(23.92,.022,18.36),"438588",
             material=FABRIC,collide=False)
    prop(mat,"bool","CastShadow",False)
    for x in (282.1,303.9):
        part(ring,"Ring mat end binding",(x,mat_y+.03,z),(.17,.02,16.7),brass,collide=False)
    for pz in (z-8.34,z+8.34):
        part(ring,"Ring mat side binding",(mat_x,mat_y+.03,pz),(21.8,.02,.17),brass,collide=False)
    for i in range(3):
        rise=(i+1)*.24
        part(ring,"Galleon boarding tread",(278.72+i*.85,deck_y+rise/2,z),(.88,rise,6.74),
             "B28769",material=WOOD_PLANK)
    for x in (281.68,304.34):
        for pz in (z-8.70,z+8.70):
            part(ring,"Galleon practice corner",(x,mat_y+1.35,pz),(.59,2.70,.59),"7D4D47",material=WOOD_PLANK)
            part(ring,"Ring corner brass collar",(x,mat_y+2.66,pz),(.72,.18,.72),brass,collide=False)
    for y in (.55,1.24,1.99):
        for a,b in (((281.68,z-8.70),(304.34,z-8.70)),((281.68,z+8.70),(304.34,z+8.70)),
                    ((304.34,z-8.70),(304.34,z+8.70)),((281.68,z-8.70),(281.68,z-3.48)),
                    ((281.68,z+3.48),(281.68,z+8.70))):
            beam(ring,"Oxblood arena rope",(a[0],mat_y+y,a[1]),(b[0],mat_y+y,b[1]),.16,"9B4D4E",collide=True)
    sign(ring,"SUNKEN PIRATE GALLEON",280.21,deck_y+4.66,z-7.84,8.52,1.06,-90,teal)
    part(ring,"Arena sign post",(280.52,deck_y+2.37,z-7.84),(.49,4.74,.46),cedar,material=WOOD_PLANK)
    sign(ring,"TIDEHARBOR PRACTICE RING",280.14,deck_y+3.60,z-7.84,6.62,.79,-90,teal)

    target=item(arena,"Model","Practice Target")
    part(target,"Galleon target footing",(301.14,mat_y+.19,z),(1.46,.38,1.75),"6F4E4C",material=WOOD_PLANK)
    part(target,"Galleon target stanchion",(301.14,mat_y+1.38,z),(.35,2.46,.37),cedar,material=WOOD_PLANK)
    part(target,"Galleon woven target",(300.94,mat_y+2.25,z),(.36,2.34,2.34),"B68062",shape=2,
         material=FABRIC,collide=False)
    part(target,"Galleon target gold binding",(300.74,mat_y+2.25,z),(.09,1.53,1.53),brass,shape=2,collide=False)
    part(target,"Target pad",(300.68,mat_y+2.25,z),(.08,.80,.80),"93574C",shape=2,collide=False)
    socket=part(target,"TargetPrompt",(300.28,mat_y+1.75,z),(.22,.22,.22),CREAM,collide=False,transparency=1)
    prompt=item(socket,"ProximityPrompt","PracticePrompt")
    prop(prompt,"string","ActionText","Strike target")
    prop(prompt,"string","ObjectText","Galleon practice")
    prop(prompt,"float","MaxActivationDistance",7)
    prop(prompt,"bool","RequiresLineOfSight",False)

    stern=item(arena,"Model","Galleon stern viewing deck")
    upper=8.10
    part(stern,"Stern viewing floor",(274.3,upper-.25,z+11.05),(8.41,.5,4.74),"A47860",material=WOOD_PLANK)
    stairs=[(275.75,deck_y,z+1.64),(275.75,upper,z+9.18)]
    route(stern,"Stern viewing ramp",stairs,3.98,"A07864",surface=WOOD_PLANK,stone_footings=False,
          join_overlap=.16,railings=False)
    for side in (-1.86,1.86):
        harbor_rail(stern,*path_edge(stairs,side))
    for a,b in (((270.29,z+8.87),(273.89,z+8.87)),((277.61,z+8.87),(278.48,z+8.87)),
                ((270.29,z+13.25),(278.48,z+13.25)),((270.29,z+8.87),(270.29,z+13.25)),
                ((278.48,z+8.87),(278.48,z+13.25))):
        harbor_rail(stern,(a[0],upper,a[1]),(b[0],upper,b[1]))
    for x in (272.45,275.45):
        part(stern,"Quarterdeck knee support",(x,(upper+deck_y)/2-.17,z+10.50),
             (.49,upper-deck_y-.33,.55),cedar,material=WOOD_PLANK,collide=False)
        part(stern,"Quarterdeck bench foot",(x,upper+.24,z+12.66),(.46,.49,.64),cedar,collide=False)
    part(stern,"Quarterdeck bench",(273.95,upper+.54,z+12.66),(4.08,.21,.83),"C39470",
         material=WOOD_PLANK,collide=False)
    sign(stern,"STERN VIEW",277.79,deck_y+2.28,z+2.04,3.55,.78,180,teal)

    rigging=item(arena,"Model","Harbor rigging and sails")
    for mx,mz,height,radius in ((273.55,z-5.1,18.8,7.44),(314.3,z+.38,16.3,6.5)):
        base=deck_y
        part(rigging,"Weathered cedar mast",(mx,base+height/2,mz),(.83,height,.83),"6F524D",material=WOOD_PLANK)
        part(rigging,"Mast brass cap",(mx,base+height+.07,mz),(.99,.23,.98),brass,collide=False)
        beam(rigging,"Mast sail yard",(mx-radius,base+height-2.55,mz),
             (mx+radius,base+height-2.55,mz),.23,"694F4C")
        for i in range(8):
            a,b=i/8,(i+1)/8
            def sail(t,bottom=False):
                bulge=(1-(2*t-1)**2)*1.33
                if bottom:
                    height_shift=4.0+(1-(2*t-1)**2)*.82+(.28 if i%3==1 else 0)
                    return mx+(2*t-1)*radius*.85,base+height-2.6-height_shift,mz+.41+bulge
                return mx+(2*t-1)*radius*.96,base+height-2.61,mz+.075
            p,q,r,s=sail(a),sail(b),sail(b,True),sail(a,True)
            for face in ((p,q,r),(p,r,s)):
                triangle(rigging,*face,("DEC5A0","CCAD8A","E0CCAB")[i%3],
                         material=FABRIC,name="Salt-faded galleon canvas",thickness=.11,shadow=False)
        for offset in (-4.9,4.9):
            beam(rigging,"Salt-dark sail stay",(mx,base+height-1.35,mz),
                 (mx+offset,base+.17,mz+6.6),.067,"5B4A4B")
        triangle(rigging,(mx,base+height-.63,mz),(mx,base+height+.93,mz),
                 (mx+3.12,base+height+.27,mz+.27),"A55556",material=FABRIC,
                 name="Galleon crimson mast pennant",thickness=.095,shadow=False)


def skywalk_bridge(parent,name,entry,exit):
    bridge=item(parent,"Model","Skywalk cedar bridge")
    prop(bridge,"token","ModelStreamingMode",1)
    route(bridge,name,[entry,exit],13,"976759",surface=WOOD_PLANK,stone_footings=False)
    x=entry[0]
    south_z,north_z=entry[2],exit[2]
    pitch=degrees(atan2(exit[1]-entry[1],south_z-north_z))
    for board in range(23):
        progress=(board+.5)/23
        y=entry[1]+(exit[1]-entry[1])*progress
        z=south_z+(north_z-south_z)*progress
        part(bridge,"Cedar decking board",(x,y+.027,z),(12.7,.055,1.91),
             ("A06D57","A8765E","996D5F")[board%3],pitch=pitch,material=WOOD_PLANK,collide=False)
    for side in (-1,1):
        px=x+side*6.03
        for index in range(9):
            progress=index/8
            y=entry[1]+(exit[1]-entry[1])*progress
            z=south_z+(north_z-south_z)*progress
            part(bridge,"Bridge railing pillar",(px,y+.86,z),(.42,1.73,.44),"874E41",collide=False)
            part(bridge,"Bridge brass post cap",(px,y+1.76,z),(.59,.16,.60),"C89258",collide=False)
            if index in (1,4,7):
                lamp(bridge,px,y+2.31,z,scale=.57)
        for lift,width,tint in ((-.46,.50,"754B42"),(.49,.18,"794C41"),(1.46,.24,"A45F46")):
            beam(bridge,"Bridge cedar rail",(px,entry[1]+lift,south_z),(px,exit[1]+lift,north_z),width,tint,collide=lift>0)
        for progress in (.16,.59,.86):
            y=entry[1]+(exit[1]-entry[1])*progress
            z=south_z+(north_z-south_z)*progress
            part(bridge,"Dressed bridge pier",(px,(y-5)/2-.25,z),(2.68,y+4.5,2.80),"796F7D",material=SLATE)
            part(bridge,"Bridge pier capital",(px,y-.58,z),(3.20,.62,3.13),"9A8490",material=SLATE)
    creek=item(landscape,"Model","Skywalk creek")
    prop(creek,"token","ModelStreamingMode",1)
    part(creek,"Creek water bounds",(13,-4.53,-172),(64,2.7,14),"4B8994",transparency=1,collide=False)
    part(creek,"Creek edit preview",(13,-3.19,-172),(64,.08,14),"499093",
         material=GLASS,transparency=.19,collide=False)
    for index,(rx,rz,scale) in enumerate(((-10,-165,.56),(-1,-179,.52),(8,-167,.71),(36,-179,.68),(41,-166,.58))):
        garden_prop(creek,"bankRock",(rx,-4.95,rz),scale,index*41,"869397")
        garden_prop(creek,"cattails",(rx+1.27,-4.35,rz+.82),.36,25+index*33)


roads=item(scene,"Folder","Connecting roads")
routes=[
    ("Tideharbor causeway",[(76,.15,12),(112,.15,12),(157,1.5,17),(193,3,17)],"A98C78"),
    ("Cinder workshop road",[(74,.15,-56),(96,.65,-87),(128,3.5,-113),(148,10,-160)],"986F62"),
    ("Skywalk ascent",[(22,.15,-70),(22,.15,-111),(22,8.2,-155),(22,17,-200),(22,25,-234),(22,25,-240)],"B6A49C"),
    ("Frostglass garden climb",[(-77,.15,-44),(-115,.8,-87),(-150,6,-119),(-180,14,-147.3),(-185,14,-153)],"A9A8B4"),
    ("Lantern Circuit road",[(-82,.15,28),(-117,.15,27),(-154,3.1,26),(-193,6,27)],"8D7893"),
]
for (label,points,tone),(destination,paint) in zip(routes,[
    ("TIDEHARBOR COAST","315B65"),("CINDER TERRACES","804137"),("SKYWALK PEAKS","4E4972"),
    ("FROSTGLASS GARDENS","476A7B"),("LANTERN CIRCUIT","61447A"),
]):
    road=item(roads,"Folder",label)
    if label=="Skywalk ascent":
        route(road,label,points[:3],13,tone)
        skywalk_bridge(road,label,points[2],points[3])
        route(road,label,points[3:],13,tone)
    elif label=="Tideharbor causeway":
        # The first span crosses the existing plaza flagstones.
        route(road,label,[(x,y+.032,z) for x,y,z in points[:2]],13,tone)
        route(road,label,points[1:],13,tone)
    elif label=="Lantern Circuit road":
        route(road,label,points[:3],13,tone)
        route(road,label,points[-2:],13,tone,railings=False)
        a,b=points[-2:]
        dx,dz=b[0]-a[0],b[2]-a[2]
        length=hypot(dx,dz)
        def lantern_rail_point(fraction, side):
            x,y,z=(start+(end-start)*fraction for start,end in zip(a,b))
            return x+side*6.5*dz/length,y+1.05,z-side*6.5*dx/length
        beam(road,"Elevated route rail",lantern_rail_point(0,1),lantern_rail_point(1,1),
             .20,DARK,collide=True)
        first,last=((x-lantern_rail_point(0,-1)[0])/dx for x in reversed(ORCHARD_ROAD_OPENING))
        for start,end in ((0,first),(last,1)):
            beam(road,"Elevated route rail",lantern_rail_point(start,-1),
                 lantern_rail_point(end,-1),.20,DARK,collide=True)
    else:
        route(road,label,points,13,tone)
    if label=="Cinder workshop road":
        # Reach the square's grade before either edge of the road meets the retaining shelf.
        entry=item(road,"Model","Cinder square road transition")
        prop(entry,"token","ModelStreamingMode",1)
        start,end=points[-2:]
        joins=[]
        for z,y in ((-147.75,None),(-154.08,10.05),(-160.28,10.05)):
            t=(z-start[2])/(end[2]-start[2])
            x=start[0]+t*(end[0]-start[0])
            joins.append((x,start[1]+t*(end[1]-start[1])+.028 if y is None else y,z))
        left,right=(path_edge(joins,offset) for offset in (-6.36,6.36))
        for (a,d),(b,c) in zip(zip(left,left[1:]),zip(right,right[1:])):
            for corners in ((a,b,c),(a,c,d)):
                face=[(x,y-.16,z) for x,y,z in corners]
                support=[(x,y-.60,z) for x,y,z in corners]
                triangle(entry,*face,"A38275",name="Cinder upper road stone",material=LIMESTONE,
                         thickness=.34,collide=True,shadow=False)
                triangle(entry,*support,"93766E",name="Cinder upper road fascia",material=LIMESTONE,
                         thickness=.84,shadow=False)
        for facet in entry.findall('Item'):
            prop(facet,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
    road_sign(road,points[0],points[1],destination,paint)
    road_sign(road,points[-1],points[-2],"GRAND DOJO",paint,width=7,
              reverse_label="HARBOR SQUARE ↑" if label=="Tideharbor causeway" else None)
    for a,b in zip(points,points[1:]):
        span=dist(a,b)
        for i in range(1,int(span//18)+1):
            t=i/(int(span//18)+1)
            x,y,z=tuple(u+(v-u)*t for u,v in zip(a,b))
            dx,dz=b[0]-a[0],b[2]-a[2]
            length=hypot(dx,dz)
            x,z=x+5.8*dz/length,z-5.8*dx/length
            part(road,"Road lantern foundation",(x,y+.21,z),(.85,.40,.85),STONE,collide=False)
            lamp(road,x,y+1.08,z,scale=.55)

build_kiln_ridge_walk(roads,routes[1][1][1:3],item=item,prop=prop,part=part,beam=beam,
                     triangle=triangle,path_edge=path_edge,sign=sign,swept_roof=swept_roof,
                     festival_lantern=festival_lantern,garden_shelf=garden_shelf,
                     garden_prop=garden_prop,showcase_tree=showcase_tree,sandstone=SANDSTONE,
                     cedar=WOOD_PLANK,grass=GRASS_MAT,brass=METAL,stone_variant=CINDER_STONE,
                     wood_variant=ARENA_CEDAR,variant_field=MATERIAL_VARIANT_FIELD)

def saltwind_lookout(parent,causeway):
    walk=item(parent,"Model","Saltwind Lookout")
    prop(walk,"token","ModelStreamingMode",1)
    prop(walk,"token","LevelOfDetail",4)

    def road_join(x,offset):
        a,b=next((start,end) for start,end in zip(causeway,causeway[1:]) if start[0]<=x<=end[0])
        fraction=(x-a[0])/(b[0]-a[0])
        return x,a[1]+(b[1]-a[1])*fraction+.048,a[2]+(b[2]-a[2])*fraction+offset

    top=9.55
    west,east,north,south=151.30,166.05,42.85,52.55
    approach=[road_join(129.35,3.05),(130.38,.746,23.30),(132.60,1.18,25.12),
              (137.40,2.74,27.65),(146.65,5.58,33.50),(150.34,7.02,36.08),
              (153.05,8.42,39.75),(154.65,top,north)]
    descent=[(east,top+.023,47.13),(169.56,top+.023,47.13),(174.58,7.61,42.87),
             (179.36,5.43,36.83),(184.28,3.59,30.21),(185.80,2.77,25.06),
             road_join(185.80,2.68)]
    railing="367173"
    rail_posts=set()

    def rail(a,b):
        for lift,width in ((.55,.21),(1.39,.26)):
            beam(walk,"Saltwind teal guardrail",(a[0],a[1]+lift,a[2]),
                 (b[0],b[1]+lift,b[2]),width,railing,collide=True)
        posts=max(1,ceil(dist(a,b)/3.8))
        for index in range(posts+1):
            x,y,z=(u+(v-u)*index/posts for u,v in zip(a,b))
            position=tuple(round(value,3) for value in (x,y,z))
            if position in rail_posts:
                continue
            rail_posts.add(position)
            part(walk,"Saltwind cedar newel",(x,y+.72,z),(.31,1.50,.31),"426A67")
            part(walk,"Saltwind brass newel cap",(x,y+1.48,z),(.43,.15,.43),"C89C61",collide=False)

    for path,title in ((approach,"Saltwind uphill walk"),(descent,"Saltwind harbor descent")):
        first_piece=len(walk)
        left,right=(path_edge(path,side*3.20) for side in (-1,1))
        for (left_a,left_b),(right_a,right_b) in zip(zip(left,left[1:]),zip(right,right[1:])):
            a,b,c,d=((x,y-.17,z) for x,y,z in (left_a,right_a,right_b,left_b))
            triangle(walk,a,b,c,"A89A93",name=title,material=LIMESTONE,thickness=.36,collide=True)
            triangle(walk,a,c,d,"AD9B93",name=title,material=LIMESTONE,thickness=.36,collide=True)
        for surface in list(walk)[first_piece:]:
            prop(surface,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
        for a,b in zip(path,path[1:]):
            if max(a[1],b[1])<=5:
                x,y,z=tuple((u+v)/2 for u,v in zip(a,b))
                part(walk,"Saltwind lower ramp footing",(x,(y-5.36)/2,z),(2.33,y+4.46,2.56),
                     "8F8281",material=SLATE)
        for side in (-1,1):
            shoulder=path_edge(path,side*2.96)
            for index,(a,b) in enumerate(zip(shoulder,shoulder[1:])):
                if (path is approach and index==0) or (path is descent and index==len(shoulder)-2):
                    continue
                rail(a,b)
                if max(a[1],b[1])>5:
                    x,y,z=tuple((u+v)/2 for u,v in zip(a,b))
                    part(walk,"Saltwind slate ramp pier",(x,(y-3.3)/2,z),(1.17,max(1,y+2.56),1.17),
                         "7E767E",material=SLATE)
                    beam(walk,"Saltwind terrace fascia",(a[0],a[1]-.45,a[2]),
                         (b[0],b[1]-.45,b[2]),.50,"817477")

    part(walk,"Saltwind limestone landing",((west+east)/2,top-.32,(north+south)/2),
         (east-west,.64,south-north),"AC9A91",material=LIMESTONE)
    for row in range(3):
        for column in range(6):
            x=west+(column+.5)*(east-west)/6
            z=north+(row+.5)*(south-north)/3
            paving=part(walk,"Saltwind inset paving",(x,top+.010,z),
                        ((east-west)/6-.044,.018,(south-north)/3-.055),
                        ("B8AA9B","AA9D94","C0AFA2")[(row+column)%3],material=LIMESTONE,collide=False)
            prop(paving,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
            prop(paving,"bool","CastShadow",False)
    for x in (152.85,158.08,164.57):
        for z in (44.2,51.1):
            part(walk,"Saltwind terrace pier",(x,2.69,z),(1.85,12.91,1.85),"8D8285",material=SLATE)
            part(walk,"Saltwind pier capital",(x,8.83,z),(2.35,.75,2.29),"A49A93",material=SLATE)
    low_opening, high_opening = SALTWIND_OPENING
    for ax,az,bx,bz in ((157.61,north+.26,east-.23,north+.26),
                        (west+.23,south-.26,east-.23,south-.26),
                        (west+.23,north+.26,west+.23,low_opening),
                        (west+.23,high_opening,west+.23,south-.26),
                        (east-.23,north+.26,east-.23,44.17),
                        (east-.23,50.13,east-.23,south-.26)):
        rail((ax,top,az),(bx,top,bz))

    for x in (155.9,162.1):
        for z in (48.92,51.23):
            part(walk,"Saltwind shelter column",(x,top+2.58,z),(.58,5.16,.60),"46767A",
                 material=WOOD_PLANK)
            part(walk,"Saltwind column brass band",(x,top+4.73,z),(.73,.18,.75),"CAA66B",collide=False)
        festival_lantern(walk,x,top+4.32,48.72,.62,light=False)
    swept_roof(walk,159.0,top+5.26,50.06,8.79,5.55,2.21,fine_tiles=False)
    sign(walk,"SALTWIND LOOKOUT",159.0,top+4.72,48.50,6.77,.91,180,"386A6B",face_only=True)
    for x in (157.23,160.87):
        part(walk,"Saltwind bench plinth",(x,top+.29,51.11),(.62,.58,.64),"8F8187",material=SLATE)
    part(walk,"Saltwind cedar bench",(159.05,top+.65,51.12),(4.66,.19,.96),"A47D5D",
         material=WOOD_PLANK)
    part(walk,"Saltwind bench back",(159.05,top+1.08,51.50),(4.66,.43,.16),"A47D5D",
         material=WOOD_PLANK)
    air_effect(walk,"Saltwind lantern motes",(158.95,top+2.84,48.1),(9.6,2.2,1.3),14302399641,
               tint="FFD6A0",rate=2,lifetime=(2.5,4.2),speed=(.06,.24),
               size=(.08,.19),opacity=.49,drift=(.74,.035,-.19),glow=.56)

    for index,(x,z,base,high,width,length,yaw) in enumerate((
        (134.83,35.44,-3.5,2.24,9.9,8.9,27),(141.83,46.82,-1.9,5.64,10.2,11.7,72),
        (151.93,53.27,-2.9,6.24,12.0,10.0,43),(162.16,54.14,-3.4,4.5,9.94,10.38,108),
        (172.83,45.99,-4.0,3.29,8.54,8.21,49),
    )):
        shoreline_slate(walk,x,z,base,width,length,high-base,yaw)
        garden_shelf(walk,x+.12,high-.22,z+.22,width*.67,length*.62,.39,"788C5C",
                     GRASS_MAT,collide=False)
        garden_prop(walk,"bankRock",(x-.72,high-.42,z+.25),.23,yaw,"8E858D")
        garden_prop(walk,"mossFlowers",(x+.77,high-.27,z-.49),.18,yaw,"E2ADB0")
        garden_prop(walk,"meadowCover",(x+.43,high-.22,z+.72),.19,yaw+30,"A4B675")
        garden_prop(walk,"grassBlade",(x+1.05,high-.16,z+.38),.52,yaw+51,"D7B675")
        if index in (1,2,4):
            garden_prop(walk,"meadowFlowers",(x-.34,high-.20,z-1.22),.38,yaw+67,"F4CB86")
    for x,y,z,yaw,title,reverse_label in (
        (124.31,.699,19.44,-84,"SALTWIND LOOKOUT",None),
        (190.21,2.904,21.21,91,"SALTWIND LOOKOUT","SALTWIND LOOKOUT →"),
        (163.84,top,43.42,0,"TIDEHARBOR COAST  →",None),
    ):
        part(walk,"Saltwind wayfinding post",(x,y+1.48,z),(.35,2.97,.38),"724F3E",
             material=WOOD_PLANK,collide=False)
        sign(walk,title,x,y+2.74,z,6.37,.98,yaw,"3E6C69",reverse_label=reverse_label)
    for path,side,posts in ((approach,-2.96,(1,3,5)),(descent,2.96,(1,3,5))):
        shoulder=path_edge(path,side)
        for index in posts:
            x,y,z=shoulder[index]
            lamp(walk,x,y+1.99,z,scale=.44,light=False)
    return descent


saltwind_descent=saltwind_lookout(scene,routes[0][1])
build_saltwind_high_walk(scene, item=item, prop=prop, part=part, beam=beam,
                        triangle=triangle, path_edge=path_edge, sign=sign,
                        festival_lantern=festival_lantern, garden_shelf=garden_shelf,
                        garden_prop=garden_prop, stone=LIMESTONE, slate=SLATE,
                        cedar=WOOD_PLANK, brass=METAL, grass=GRASS_MAT,
                        stone_variant=PROMENADE_STONE, variant_field=MATERIAL_VARIANT_FIELD)
build_orchard_high_walk(scene,*routes[4][1][-2:],item=item,prop=prop,part=part,beam=beam,
                        path_edge=path_edge,triangle=triangle,sign=sign,swept_roof=swept_roof,
                        festival_lantern=festival_lantern,shoreline_slate=shoreline_slate,
                        garden_shelf=garden_shelf,garden_prop=garden_prop,showcase_tree=showcase_tree,slate=SLATE,
                        limestone=LIMESTONE,cedar=WOOD_PLANK,grass=GRASS_MAT,brass=METAL,
                        paving_variant=PROMENADE_STONE,variant_field=MATERIAL_VARIANT_FIELD)


rest=item(scene,"Model","Skywalk rest terrace")
prop(rest,"token","ModelStreamingMode",1)
rest_y=7.45
junction_y=.15+(8.2-.15)*(30/44)
route(rest,"Wind Rest approach",[(28.3,junction_y,-141),(38,junction_y,-141),(44.4,rest_y,-141),(47,rest_y,-141)],
      6.6,"AAA3AA",join_overlap=.35)
route(rest,"Skywalk creek path",[(53,rest_y,-146.6),(54.5,3.85,-158),(56,-.35,-170),(56,-4.65,-182)],
      5.0,"918793",join_overlap=.45)
part(rest,"Wind Rest terrace footing",(52,(rest_y-5)/2-.26,-141),(15.1,rest_y+4.48,12),"7C7480",material=SLATE)
part(rest,"Wind Rest stone deck",(52,rest_y-.20,-141),(15.1,.4,12),"ACA1A4",material=SANDSTONE)
part(rest,"Wind Rest signpost",(31.3,1.02,-135.55),(.45,12.04,.45),"885D50",collide=False)
sign(rest,"WIND REST  →",31.3,6.59,-135.2,6.7,1.04,0,"514564")
for side in (-1,1):
    x=52+side*5.75
    for z in (-138.6,-135.96):
        part(rest,"Wind Rest cedar pillar",(x,rest_y+2.65,z),(.61,5.30,.61),"925D47")
        part(rest,"Wind Rest pillar base",(x,rest_y+.27,z),(.84,.54,.88),"8C818C",material=SLATE)
    lamp(rest,x-side*.72,rest_y+3.72,-138.85,scale=.75,light=True)
    rock_x,rock_z=(x,-144.24) if side<0 else (56.12,-145.90)
    garden_prop(rest,"bankRock",(rock_x,rest_y,rock_z),.25 if side<0 else .18,67+side*12,"8F838B")
    garden_prop(rest,"meadowFlowers",(rock_x+side*.29,rest_y,rock_z+.46),.44,53,"DCC196")
roof(rest,52,rest_y+5.2,-137.15,14.8,5.9)
part(rest,"Wind Rest bench",(52,rest_y+.58,-136.45),(6.65,.34,1.2),"A47459",material=WOOD_PLANK)
sign(rest,"WIND REST",52,rest_y+4.38,-139.85,5.9,1.16,180,"514564")
sign(rest,"CREEK  →",57.65,rest_y+2.18,-146.30,3.58,.84,0,"514564")
wind_low,wind_high=WIND_OPENING
for a,b in (((44.65,-135.22),(59.28,-135.22)),((59.28,-135.22),(59.28,wind_high)),
            ((59.28,wind_low),(59.28,-146.68)),
            ((44.65,-146.68),(50.0,-146.68)),((56.25,-146.68),(59.28,-146.68))):
    beam(rest,"Wind Rest terrace rail",(a[0],rest_y+1.03,a[1]),(b[0],rest_y+1.03,b[1]),.24,"8D6355",collide=True)
build_kiln_pass(scene,item=item,prop=prop,part=part,beam=beam,triangle=triangle,path_edge=path_edge,
                sign=sign,festival_lantern=festival_lantern,garden_shelf=garden_shelf,
                garden_prop=garden_prop,sandstone=SANDSTONE,slate=SLATE,cedar=WOOD_PLANK,
                metal=METAL,grass=GRASS_MAT,stone_variant=CINDER_STONE,
                variant_field=MATERIAL_VARIANT_FIELD)

def build_wind_court(parent,x,y,z):
    court=item(parent,"Model","Wind Court")
    prop(court,"token","ModelStreamingMode",1)
    prop(court,"token","LevelOfDetail",4)
    square,deck=y+.027,y+3.987
    roof_z=z-19.83
    part(court,"Raised temple foundation",(x,(y+deck-.44)/2,roof_z),(21.82,deck-y-.44,15.06),
         "847785",material=SLATE)
    floor=part(court,"Pale Wind Court deck",(x,deck-.22,roof_z),(21.62,.44,15.04),
               "B9A6A5",material=LIMESTONE)
    prop(floor,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
    for index in range(9):
        top=square+(deck-square)*(index+1)/9
        step_z=z-4.63-index*.94
        part(court,"Wind Court slate stair",(x,(square+top)/2,step_z),(10.37,top-square,.994),
             "948891",material=SLATE)
        part(court,"Wind Court pale stair nose",(x,top-.054,step_z+.43),(10.40,.077,.091),
             "B4A3A7",material=LIMESTONE,collide=False)
    for side in (-1,1):
        sx=x+side*5.49
        beam(court,"Climbing stone coping",(sx,square+.38,z-4.31),(sx,deck+.32,z-12.30),.39,"AD9DA3")
        for px,pz,bank in ((x+side*7.77,z-7.24,y+.48),(x+side*8.49,z-11.14,y+.93)):
            garden_shelf(court,px,bank,pz,4.82,3.92,bank-y+.05,"928491",SLATE,collide=False)
            garden_shelf(court,px,bank+.13,pz+side*.13,4.31,3.39,.23,"657554",GRASS_MAT,collide=False)
            garden_prop(court,"bankRock",(px+side*.59,bank-.03,pz-.44),.24,47*side,"938499")
            garden_prop(court,"mossFlowers",(px-.48,bank+.14,pz+.63),.125,31*side,"C7A8C4")
            garden_prop(court,"meadowCover",(px+.51,bank+.13,pz-.55),.139,54,"A4AC73")
            garden_prop(court,"meadowFlowers",(px-.09,bank+.16,pz+.56),.26,76*side,"E5BEB5")
            garden_prop(court,"grassBlade",(px+side*.42,bank+.14,pz+.63),.37,51*side,"CEA976")
        for pz in (z-13.08,z-19.28,z-25.95):
            px=x+side*9.62
            part(court,"Wind Court slate column shoe",(px,deck+.34,pz),(1.43,.68,1.46),
                 "948291",material=SLATE)
            part(court,"Tall Wind Court cedar column",(px,deck+5.11,pz),(1.13,9.50,1.16),
                 "A85840",material=WOOD_PLANK)
            part(court,"Wind Court bronze column collar",(px,deck+1.19,pz),(1.27,.25,1.30),
                 "C49561",collide=False)
        part(court,"Wind Court side screen",(x+side*10.48,deck+5.01,roof_z-1.50),(.49,9.86,12.16),
             "A36957",material=WOOD_PLANK)
        part(court,"Golden temple fascia",(x+side*10.02,deck+9.87,roof_z),(.78,.44,15.42),
             "C29665",collide=False)
        lantern_window(court,x+side*7.86,deck+5.22,z-26.72,3.84,6.13)
        festival_lantern(court,x+side*7.27,deck+6.42,z-12.81,.87,light=True)
        banner(court,x+side*9.68,deck+4.75,z-12.24,scale=.98)
    part(court,"Wind Court back plaster",(x,deck+5.00,z-27.05),(21.22,10.0,.61),"AE7463",material=WOOD_PLANK)
    part(court,"Carved Wind Court lintel",(x,deck+8.84,z-12.15),(20.11,.78,1.05),
         "8A443A",material=WOOD_PLANK,collide=False)
    swept_roof(court,x,deck+10.08,roof_z,26.2,20.8,4.48)
    crown_z=roof_z-.54
    part(court,"Upper prayer chamber",(x,deck+15.61,crown_z),(14.92,6.40,11.38),"A65440",collide=False)
    for dx in (-5.12,0,5.12):
        lantern_window(court,x+dx,deck+15.60,crown_z+5.78,3.01,3.72)
    swept_roof(court,x,deck+19.02,crown_z,19.72,15.1,4.08,fine_tiles=False)
    sign(court,"WIND COURT",x,deck+8.77,z-11.57,12.13,2.1,tint="5F536B")
    sign(court,"RING REED, CLOUD, THEN SUMMIT",x,deck+6.19,z-26.63,12.91,.86,tint="584968")
    part(court,"Braced cedar chime beam",(x,deck+7.35,z-24.43),(21.04,.64,1.69),
         "874A37",material=WOOD_PLANK,collide=False)
    for side in (-1,1):
        beam(court,"Chime beam corbel",(x+side*10.11,deck+6.58,z-24.43),
             (x+side*8.04,deck+7.37,z-24.43),.49,"A46D4E")
    threshold_light(court,x,deck+9.41,z-22.1,reach=12.0,spread=99,brightness=.79)

    chimes=item(court,"Folder","Wind chimes")
    for label,offset,flavor,tint,speed in (
        ("Reed",-5.71,1.34,"C8A368",.84),("Cloud",5.71,1.21,"C4B4D3",1),("Summit",0,1.56,"DEA468",1.18),
    ):
        px=x+offset
        pz=z-(23.86 if offset else 24.41)
        beam(chimes,"Braided chime cord",(px,deck+7.20,pz),(px,deck+5.44,pz),.105,"C89459")
        for lift,diameter,shade,depth in ((.018,2.68,"6E5F66",.036),(.036,2.46,tint,.020),
                                         (.05,2.18,"82747D",.023)):
            medallion=part(chimes,"Chime standing medallion",(px,deck+lift,z-20.98),(depth,diameter,diameter),
                           shade,shape=2,roll=90,material=SLATE,collide=False)
            prop(medallion,"bool","CastShadow",False)
        for lift,height,width in ((5.25,.42,1.22),(4.75,.60,1.31),(4.32,.33,1.72),(4.11,.15,1.80)):
            bell=part(chimes,"Cast Wind Court chime",(px,deck+lift,pz),(height,width*flavor,width*flavor),tint,
                      shape=2,roll=90,material=METAL,collide=False)
            prop(bell,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
        anchor=part(chimes,label,(px,deck+2.65,pz+.94),(.22,.22,.22),CREAM,collide=False,transparency=1)
        prompt=item(anchor,"ProximityPrompt","ChimePrompt")
        prop(prompt,"string","ActionText","Ring chime")
        prop(prompt,"string","ObjectText",label)
        prop(prompt,"float","MaxActivationDistance",5.25)
        prop(prompt,"bool","RequiresLineOfSight",False)
        sound=item(anchor,"Sound","Note")
        asset(sound,"SoundId","rbxassetid://158050602")
        prop(sound,"float","Volume",.33)
        prop(sound,"float","PlaybackSpeed",speed)
        prop(sound,"float","RollOffMinDistance",4)
        prop(sound,"float","RollOffMaxDistance",25)
        sign(chimes,label.upper(),px,deck+1.61,pz+.49,3.27,.74,tint="66566D")
    build_wind_court_architecture(court,x,z,deck,item=item,prop=prop,part=part,
                                  wood=WOOD_PLANK,slate=SLATE,metal=METAL,fabric=FABRIC,neon=NEON,
                                  wood_variant=LANDMARK_CEDAR,brass_variant=ORNAMENT_BRASS,
                                  variant_field=MATERIAL_VARIANT_FIELD)
    build_wind_court_ramp(court,x,z,square,deck,item=item,prop=prop,part=part,
                         route=route,beam=beam,sign=sign,festival_lantern=festival_lantern,
                         slate=SLATE,limestone=LIMESTONE,wood=WOOD_PLANK,metal=METAL,
                         stone_variant=PROMENADE_STONE,variant_field=MATERIAL_VARIANT_FIELD)
    build_wind_court_guardians(court,x,z,square,item=item,part=part,prop=prop,vector=vector,asset=asset,
                              slate=SLATE,stone_variant=PROMENADE_MORTAR,variant_field=MATERIAL_VARIANT_FIELD)


def cinder_hillside(parent,x,y,z):
    hill=item(parent,"Model","Cinder sandstone hillside")
    prop(hill,"token","ModelStreamingMode",1)
    prop(hill,"token","LevelOfDetail",4)
    rings=hillside_rings(x,y,z)
    for (a,b,c),tone in hillside_faces(rings):
        triangle(hill,a,c,b,tone,name="Layered Cinder sandstone",
                 material=SANDSTONE,shadow=False,thickness=.20)
    for face in hill.findall('Item'):
        prop(face,"string",MATERIAL_VARIANT_FIELD,CINDER_STONE)

    for i,level,width,depth in ((6,4,5.7,4.4),(8,3,5.6,5.3),(10,4,6.9,5.2),
                                 (12,4,6.8,5.0),(16,4,6.7,4.8),(18,5,6.2,5.4)):
        u,v=CINDER_OUTLINE[i]
        px,py,pz=rings[level][i]
        px,pz=px+u*.47,pz+v*.46
        shelf=item(hill,"Model","Cinder planted seam")
        garden_shelf(shelf,px,py+.05,pz,width,depth,1.17,"A27C6C",SANDSTONE,collide=False)
        garden_shelf(shelf,px-u*.07,py+.18,pz-v*.07,width*.82,depth*.78,.26,"7B8B59",GRASS_MAT,collide=False)
        for key,dx,dz,scale,tint in (
            ("bankRock",.49,.11,.19,"A1887D"),
            ("rockVine",.60*u,.74*v,.43,"88985A"),
            ("mossFlowers",-.50,.18,.15,"DAA891"),
            ("meadowCover",.18,-.47,.19,"9EAB62"),
            ("meadowGrass",-.31,.60,.14,"B8BB77"),
        ):
            base=py-.51 if key=="rockVine" else py+.16
            garden_prop(shelf,key,(px+dx,base,pz+dz),scale,(i*41)%360,tint)


def cinder_flue(works,x,y,z,height,radius):
    """Tapered firebrick with an octagonal copper crown and a recessed throat."""
    flue=item(works,"Model","Cinder kiln flue")
    profile=((4.54,1.21),(5.41,1.0),(height-2.25,.77),(height-.51,.79),(height,.99))

    def ring(lift,scale):
        return [(x+radius*scale*cos((index+.5)*tau/8), y+lift,
                 z+radius*scale*sin((index+.5)*tau/8)) for index in range(8)]

    bands=[ring(lift,scale) for lift,scale in profile]
    clay=("925847","A4644F","AD7055","B87B5F","A66551","925748","885044","8F5948")
    copper=("77564A","9C6F51","B7845B","C19664","AB7955","95694F","79574A","7E5347")
    for course,(bottom,top) in enumerate(zip(bands,bands[1:])):
        fired=course<2
        palette=clay if fired else copper
        for index,tint in enumerate(palette):
            following=(index+1)%8
            a,b,c,d=bottom[index],bottom[following],top[following],top[index]
            for face in ((a,b,c),(a,c,d)):
                triangle(flue,*face,tint,name="Firebrick shaft" if fired else "Copper flue crown",
                         material=BRICK if fired else METAL,thickness=.12,shadow=False)

    for lift,factor,thickness,tint in ((5.40,1.025,.24,"80594B"),
                                       (height-2.24,.815,.16,"BC8A5A"),
                                       (height-.54,.835,.23,"CD9D68")):
        collar=part(flue,"Hammered copper collar",(x,y+lift,z),
                    (thickness,radius*factor*2,radius*factor*2),tint,
                    shape=2,roll=90,material=METAL,collide=False)
        prop(collar,"bool","CastShadow",False)

    inner=ring(height,.63)
    for index,outer in enumerate(bands[-1]):
        following=(index+1)%8
        a,b=inner[index],inner[following]
        triangle(flue,outer,a,b,"CEA472",name="Copper rim cap",material=METAL,thickness=.17,shadow=False)
        triangle(flue,outer,b,bands[-1][following],"BA8C5E",name="Copper rim cap",
                 material=METAL,thickness=.17,shadow=False)
    throat=part(flue,"Recessed flue throat",(x,y+height-.28,z),(.14,radius*1.66,radius*1.66),
                "593937",shape=2,roll=90,material=SLATE,collide=False)
    prop(throat,"bool","CastShadow",False)

    vent_y=y+height-1.40
    front=z+radius*.745
    for offset in (-.36,0,.36):
        px=x+radius*offset
        part(flue,"Blackened vent frame",(px,vent_y,front),(.27,.92,.095),"704D40",
             material=METAL,collide=False)
        glow=part(flue,"Amber vent inlay",(px,vent_y-.04,front+.056),(.088,.62,.038),"F09D58",
                  material=NEON,collide=False)
        prop(glow,"bool","CastShadow",False)
    for stone in flue.findall('Item'):
        if stone.findtext("Properties/token[@name='Material']")==str(BRICK):
            prop(stone,"string",MATERIAL_VARIANT_FIELD,CINDER_BRICK)


# Each center has a walkable deck, a distinct skyline, and a labeled entry.
towns=[
    ("Tideharbor Coast",220,3,17,90,"326F79","859A91","TIDEHARBOR COAST"),
    ("Cinder Terraces",150,10,-188,0,"934A39","956F66","CINDER TERRACES"),
    ("Skywalk Peaks",22,25,-265,0,"5E668A","A69BA5","SKYWALK PEAKS"),
    ("Frostglass Gardens",-189,14,-179,0,"618B9A","9BABB5","FROSTGLASS GARDENS"),
    ("Lantern Circuit",-221,6,27,-90,"68477E","8E7890","LANTERN CIRCUIT"),
]
outer=item(scene,"Folder","Connected districts")
for index,(name,x,y,z,yaw,accent,paving,sign_name) in enumerate(towns):
    town=item(outer,"Model",name)
    part(district_markers,name,(x,y,z),(.25,.25,.25),STONE,collide=False,transparency=1)
    part(town,"District retaining shelf",(x,y/2-1.1,z),
         (60,y+2.2,62),paving,material=SLATE)
    terrain_tone=("8FA49B","A17467","A596AC","B2C2CB","A08BA5")[index]
    for k in (-1,0,1):
        part(town,"Stone terrace edge",(x+k*19,y-.56,z+30.8),(19,.96,1.34),
             terrain_tone,material=SLATE,collide=False)
    # Separate paving from the equally high retaining shelf so neither surface flickers.
    part(town,"District courtyard",(x,y-.093,z),(59,.24,61),paving,material=LIMESTONE)
    map_x,map_z,map_yaw=((7.5,4.8,0),(9.6,22.1,0),(-7.7,15.1,0),(14.8,23.5,0),(3.4,18.5,65))[index]
    district_map_post(town,name,x+map_x,y+.027,z+map_z,map_yaw)
    if name=="Lantern Circuit":
        build_lantern_town_gate(town,x+27,y,z,item=item,prop=prop,part=part,beam=beam,gate=gate,sign=sign,
                                 swept_roof=swept_roof,curved_plaque=curved_plaque,marquee_title=marquee_title,
                                 festival_lantern=festival_lantern,banner=banner,slate=SLATE,wood=WOOD_PLANK,
                                 brass=METAL,wood_variant=LANDMARK_CEDAR,variant_field=MATERIAL_VARIANT_FIELD)
    elif name=="Tideharbor Coast":
        build_tideharbor_town_gate(town,x-27,y,z,item=item,prop=prop,part=part,beam=beam,
                                  gate=gate,sign=sign,swept_roof=swept_roof,curved_plaque=curved_plaque,
                                  marquee_title=marquee_title,festival_lantern=festival_lantern,
                                  slate=SLATE,wood=WOOD_PLANK,metal=METAL,neon=NEON,cedar_variant=LANDMARK_CEDAR,
                                  variant_field=MATERIAL_VARIANT_FIELD)
    elif name=="Skywalk Peaks":
        build_skywalk_gatehouse(town,x,y,z+25,item=item,prop=prop,part=part,beam=beam,gate=gate,sign=sign,
                               swept_roof=swept_roof,curved_plaque=curved_plaque,marquee_title=marquee_title,
                               festival_lantern=festival_lantern,standing_lantern=store_standing_lantern,
                               banner=banner,garden_prop=garden_prop,slate=SLATE,limestone=LIMESTONE,
                               wood=WOOD_PLANK,metal=METAL,neon=NEON,cedar_variant=LANDMARK_CEDAR,
                               stone_variant=PROMENADE_STONE,variant_field=MATERIAL_VARIANT_FIELD)
    elif yaw:
        gate(town,x-27*(1 if yaw>0 else -1),z,-yaw,span=15,label=sign_name,trim=accent,y=y)
    else:
        gate(town,x,z+25,span=18,label=sign_name,trim=accent,y=y)
    build_district_gateway(town, name, (x, y, z), yaw, item=item, prop=prop, part=part,
                           festival_lantern=festival_lantern, garden_prop=garden_prop,
                           slate=SLATE, wood=WOOD_PLANK)

    quarter=item(town,"Model","District buildings")
    prop(quarter,"token","LevelOfDetail",4)
    for dx,dz,wide,deep,height in [(-18,-10,13,13,9),(17,-11,13,14,11),
                                   (-15,12,11,11,8),(16,11,12,12,9)]:
        plot=quarter
        if name=="Frostglass Gardens" and dx>0:
            if dz<0:
                plot=item(quarter,"Model","Frostglass north pavilion")
                dx,dz=18.10,-18.60
            else:
                plot=item(quarter,"Model","Frostglass lantern house")
                dx,dz,wide,deep,height=13.94,11.25,6.15,11.30,10.20
        house(plot,x+dx,z+dz,wide,deep,height)
    if index!=2:
        house(quarter,x,z-19,21,15,13,
              ["HARBOR HOUSE","KILN HALL","WIND COURT","ICE GARDEN","NIGHT MARKET"][index])
    for n in quarter.iter("Item"):
        if n.findtext("Properties/string[@name='Name']") in ("Front cedar post","Rear cedar post","Cedar fascia"):
            n.find("Properties/Color3uint8").text=str(0xFF000000+int(accent,16))
    raise_geometry(quarter,y)
    if index==0:
        build_tideharbor_waterfront(town,item=item,prop=prop,part=part,beam=beam,slate=SLATE,
                                   limestone=LIMESTONE,wood=WOOD_PLANK,clay=CLAY_ROOF,metal=METAL,
                                   neon=NEON,cedar_variant=LANDMARK_CEDAR,
                                   stone_variant=PROMENADE_MORTAR,roof_variant=INDIGO_TILE,
                                   variant_field=MATERIAL_VARIANT_FIELD)
        build_harbor_arrival_hall(town,x,y,z,item=item,prop=prop,part=part,beam=beam,
                                  swept_roof=swept_roof,festival_lantern=festival_lantern,
                                  slate=SLATE,wood=WOOD_PLANK,metal=METAL,neon=NEON,
                                  cedar_variant=LANDMARK_CEDAR,variant_field=MATERIAL_VARIANT_FIELD)
        build_clay_lantern_shore(town,item=item,prop=prop,part=part,vector=vector,asset=asset,
                                 garden_prop=garden_prop,shoreline_slate=shoreline_slate,
                                 rock=ROCK,cedar=WOOD_PLANK,grass=GRASS_MAT,
                                 bank_variant=BANK_STONE,variant_field=MATERIAL_VARIANT_FIELD)
        offshore=build_tideharbor_offshore(town,item=item,prop=prop,part=part,triangle=triangle,
                                          garden_shelf=garden_shelf,garden_prop=garden_prop,
                                          sign=sign,beam=beam,slate=SLATE,grass=GRASS_MAT,wood=WOOD_PLANK)
        build_coastal_horizon(offshore,item=item,prop=prop,part=part,triangle=triangle,slate=SLATE,smooth=SMOOTH)
        build_tideharbor_sea_stacks(offshore,item=item,part=part,prop=prop,vector=vector,asset=asset,
                                   variant_field=MATERIAL_VARIANT_FIELD)
        build_south_channel_arch(offshore,item=item,prop=prop,part=part,triangle=triangle,
                                 horizontal_water_beam=horizontal_water_beam,
                                 slate=SLATE,grass=GRASS_MAT,wood=WOOD_PLANK)
    if index==2:
        build_wind_court(town,x,y,z)
        build_pinecrest_trail(town,item=item,prop=prop,part=part,triangle=triangle,path_edge=path_edge,
                              beam=beam,sign=sign,swept_roof=swept_roof,festival_lantern=festival_lantern,
                              garden_shelf=garden_shelf,garden_prop=garden_prop,showcase_tree=showcase_tree,
                              slate=SLATE,limestone=LIMESTONE,wood=WOOD_PLANK,rock=ROCK,grass=GRASS_MAT,
                              stone_variant=PROMENADE_STONE,rock_variant=VALLEY_ROCK,
                              material_variant_field=MATERIAL_VARIANT_FIELD)
        cloudbreak=build_cloudbreak_course(town, item=item, prop=prop, asset=asset, part=part, beam=beam,
                                           sign=sign, festival_lantern=festival_lantern,
                                           slate=SLATE, limestone=LIMESTONE, wood=WOOD_PLANK,
                                           metal=METAL, neon=NEON)
        build_cloudbreak_scenery(cloudbreak, item=item, prop=prop, part=part, beam=beam, triangle=triangle,
                                 swept_roof=swept_roof, festival_lantern=festival_lantern, slate=SLATE,
                                 rock=ROCK, wood=WOOD_PLANK, metal=METAL, fabric=FABRIC, neon=NEON)
    for fx,fz in [(-23,17),(24,18),(-12,-16),(12,-14)]:
        planting=item(town,"Folder","District planting")
        tree(planting,x+fx,z+fz,pink=index in (2,4),scale=.88)
        raise_geometry(planting,y)
    for dx,dz,h in [(-25,-25,3),(25,-25,4),(-25,22,2),(25,22,3)]:
        if index==0 and dx>0 and dz>0:
            continue
        if index==2 and dx>0 and dz>0:
            dz=14  # Leave the Cloudstep entrance clear from the courtyard.
        part(town,"Backlot stone facet",(x+dx,y+h/2-.4,z+dz),(5,h,5),terrain_tone,
             yaw=(dx+dz)*2,collide=False,class_name="WedgePart")
    if index==0:
        parcel_station(town,"Parcel Receiving",222.2,3,23.80,-110,
                       "HARBOR RECEIVING","Deliver parcel","Tideharbor Coast","346B75")
        build_tideharbor_loading_bay(town,item=item,prop=prop,part=part,beam=beam,vector=vector,asset=asset,
                                    slate=SLATE,cedar=WOOD_PLANK,metal=METAL,cedar_variant=LANDMARK_CEDAR,
                                    variant_field=MATERIAL_VARIANT_FIELD)
        dock=item(town,"Model","Harbor pier")
        prop(dock,"token","ModelStreamingMode",1)
        pier_z=z+23
        part(dock,"Harbor pier deck",(x+35,y+.75,pier_z),(29,1.5,8),WOOD,material=WOOD_PLANK)
        for leg_x in (x+23,x+31,x+39,x+47):
            for sz in (-1,1):
                part(dock,"Harbor timber post",(leg_x,y-1.15,pier_z+sz*3.65),(1.04,7.1,1.04),DARK)
                lamp(dock,leg_x,y+2.72,pier_z+sz*3.65,scale=.6)
        route(dock,"Pier approach",[(x+15,y+.027,pier_z),(x+20.3,y+1.52,pier_z)],7,WOOD,
              join_overlap=.36)
        route(dock,"Pier approach landing",[(x+20.3,y+1.52,pier_z),(x+22,y+1.52,pier_z)],7,WOOD,
              join_overlap=.14)
        route(dock,"Shore return ramp",[(x+42,y+1.5,pier_z-3.6),(x+42,y-2.4,pier_z-17.5)],6,WOOD)
        for side in (-1,1):
            beam(dock,"Harbor handrail",(x+22,y+2.24,pier_z+side*3.6),
                 (x+(38 if side<0 else 47),y+2.24,pier_z+side*3.6),.23,RED,collide=True)
        sign(dock,"HARBOR PIER",x+18,y+2.5,pier_z-3,6.5,1.15,90,accent)
        part(dock,"Pier ladder",(x+45,y-1.25,pier_z-4.1),(2,6,2),WOOD,
             class_name="TrussPart",material=WOOD_PLANK)
        marker=part(dock,"WaterReturn",(x+42,y-1.55,pier_z-17.5),(.2,.2,.2),CREAM,
                    collide=False,transparency=1)
        prompt=item(marker,"ProximityPrompt","ReturnPrompt")
        prop(prompt,"string","ActionText","Return to pier")
        prop(prompt,"string","ObjectText","Tideharbor Coast")
        prop(prompt,"float","MaxActivationDistance",12)
        prop(prompt,"bool","RequiresLineOfSight",False)
        part(dock,"PierLanding",(x+36,y+4.2,pier_z),(.2,.2,.2),CREAM,
             collide=False,transparency=1)
        for j,(dx,dz) in enumerate([(32,13),(34,6),(36,0),(35,-13),(38,-25),(32,29)]):
            garden_prop(dock,"bankRock",(x+dx,y-3.0,z+dz),.33+j%3*.07,j*43,"9D9E8B")
            garden_prop(dock,"cattails",(x+dx+.9,y-2.55,z+dz+2),.27,j*27)
            garden_prop(dock,"lilyPads",(x+dx+2,y-1.46,z+dz-1.4),.58,j*58)
        harbor_overlook(town,x,y,z)
        build_tidewatch_walk(town,item=item,prop=prop,part=part,beam=beam,triangle=triangle,
                             path_edge=path_edge,sign=sign,swept_roof=swept_roof,
                             festival_lantern=festival_lantern,shoreline_slate=shoreline_slate,
                             garden_shelf=garden_shelf,garden_prop=garden_prop,showcase_tree=showcase_tree,
                             slate=SLATE,limestone=LIMESTONE,cedar=WOOD_PLANK,grass=GRASS_MAT,brass=METAL,
                             paving_variant=PROMENADE_STONE,cedar_variant=ARENA_CEDAR,
                             variant_field=MATERIAL_VARIANT_FIELD)
        build_tidebank_landing(town,item=item,prop=prop,part=part,beam=beam,route=route,
                               sign=sign,shoreline_slate=shoreline_slate,garden_shelf=garden_shelf,
                               garden_prop=garden_prop,showcase_tree=showcase_tree,
                               festival_lantern=festival_lantern,slate=SLATE,limestone=LIMESTONE,
                               wood=WOOD_PLANK,grass=GRASS_MAT,paving_variant=PROMENADE_STONE,
                               variant_field=MATERIAL_VARIANT_FIELD)
        lantern_quay(town)
        build_harbor_roof_walk(town,item=item,prop=prop,part=part,beam=beam,triangle=triangle,
                               path_edge=path_edge,sign=sign,swept_roof=swept_roof,
                               festival_lantern=festival_lantern,garden_shelf=garden_shelf,
                               garden_prop=garden_prop,slate=SLATE,limestone=LIMESTONE,
                               cedar=WOOD_PLANK,grass=GRASS_MAT,brass=METAL,neon=NEON,
                               paving_variant=PROMENADE_STONE,cedar_variant=LANDMARK_CEDAR,
                               variant_field=MATERIAL_VARIANT_FIELD)
        moored_skiff(town,x+55,z+18,33,"447A78")
        moored_skiff(town,x+75,z-13,-38,"A65A43")
        sunken_pirate_galleon(town)
        build_harbor_cargo_hoist(town, item=item, prop=prop, part=part, beam=beam, triangle=triangle,
                                sign=sign, garden_prop=garden_prop, slate=SLATE, wood=WOOD_PLANK,
                                metal=METAL, cloth=FABRIC)
        build_harbor_goods(town,item=item,prop=prop,part=part,vector=vector,asset=asset,
                           beam=beam,triangle=triangle,fabric=FABRIC)
    elif index==1:
        cinder_hillside(town,x,y,z)
        build_cinder_ravine_terraces(town,item=item,prop=prop,part=part,triangle=triangle,vector=vector,asset=asset,
                                    garden_prop=garden_prop,stone=SANDSTONE,grass=GRASS_MAT,cedar=WOOD_PLANK,
                                    stone_variant=CINDER_STONE,variant_field=MATERIAL_VARIANT_FIELD)
        build_cinder_arrival_relief(town, x, y, z, item=item, prop=prop, triangle=triangle,
                                    sandstone=SANDSTONE, slate=SLATE, metal=METAL,
                                    material_variant_field=MATERIAL_VARIANT_FIELD,
                                    sandstone_variant=CINDER_STONE)
        build_cinder_workshop_hall(town,x,y,z,item=item,prop=prop,part=part,beam=beam,
                                  festival_lantern=festival_lantern,slate=SLATE,wood=WOOD_PLANK,
                                  metal=METAL,neon=NEON,cedar_variant=LANDMARK_CEDAR,
                                  variant_field=MATERIAL_VARIANT_FIELD,vector=vector,asset=asset)
        works=item(town,"Model","Copper kilns")
        prop(works,"token","LevelOfDetail",4)
        for i,(dx,dz,height,radius) in enumerate(((-17,-24,26.60,1.88),(17,-23,30.80,2.19),
                                                   (24,-24,19.85,1.68))):
            cx,cz=x+dx,z+dz
            for ky,h,size,tint in ((1.6,3.2,8.1,"975748"),(3.55,.70,7.72,"B87557"),
                                  (4.28,.89,6.5,"AB5C42")):
                part(works,"Round brick kiln",(cx,y+ky,cz),(h,size,size),tint,
                     shape=2,roll=90,material=SLATE,collide=False)
            cinder_flue(works,cx,y,cz,height,radius)
            part(works,"Kiln firebox surround",(cx,y+1.44,cz+3.9),(2.45,2.2,.31),"624039",collide=False)
            part(works,"Kiln ember grate",(cx,y+1.28,cz+4.1),(1.75,1.35,.16),"F8974C",material=NEON,collide=False)
            for bar in (-.48,0,.48):
                part(works,"Firebox iron bar",(cx+bar,y+1.29,cz+4.29),(.11,1.64,.13),DARK,collide=False)
            garden_prop(works,"bankRock",(cx+1.2,y,cz+5.9),.30,i*49,"AC806A")
            air_effect(works, "Kiln drifting embers", (cx, y+1.65, cz+4.58), (1.25, .4, .25), 6101261905,
                       tint="FF903E", rate=3, lifetime=(.85, 1.8), speed=(1.1, 2.8),
                       size=(.16, .075), opacity=.79, drift=(.65, 1.1, .38), glow=.8)
        scenic_walk(town,"Kiln overlook",(x-28,y,z+2),(x-28,y+4.8,z-22),"8D645A","784536",west_entry=True)
        potters_yard(town,x,y,z)
        build_cinder_kiln_walk(town,item=item,prop=prop,part=part,beam=beam,triangle=triangle,
                              path_edge=path_edge,sign=sign,swept_roof=swept_roof,
                              festival_lantern=festival_lantern,garden_shelf=garden_shelf,
                              garden_prop=garden_prop,slate=SLATE,sandstone=SANDSTONE,
                              cedar=WOOD_PLANK,grass=GRASS_MAT,brass=METAL,
                              sandstone_variant=CINDER_STONE,variant_field=MATERIAL_VARIANT_FIELD)
    elif index==2:
        cliff=item(town,"Model","Wind Court dressed cliff base")
        prop(cliff,"token","LevelOfDetail",4)
        front=z+31
        for side in (-1,1):
            center=x+side*17.8
            for idx,height in enumerate((6.7,12.65,18.15,22.38)):
                width=24.12-idx*.50
                depth=2.85-idx*.42
                part(cliff,"Split slate terrace course",(center,height,front+depth*.24),(width,.84,depth),
                     ("7F7382","8A7D8C","918291","A18E9B")[idx],material=SLATE,collide=False)
            for index,offset in enumerate((-8,0,8)):
                b=center+offset
                part(cliff,"Tapered slate buttress",(b,13.12,front+3.8),(3.3,20.7,10.6),
                     ("766B7B","817383","8F7C88")[index],yaw=180,material=SLATE,
                     class_name="WedgePart",collide=False)
                part(cliff,"Buttress top cap",(b,23.59,front+.52),(3.9,.52,2.25),"A28E9D",
                     material=SLATE,collide=False)
            garden_prop(cliff,"rockVine",(center+3*side,18.63,front+1.12),.68,180)
            garden_prop(cliff,"bankRock",(center,23.37,front+1.40),.27,48+side*27,"887C8F")
        wind=scenic_walk(town,"Wind lookout",(x-28.2,y,z+5),WIND_LOOKOUT_DECK,
                         "A18EAB",accent,rear_opening=RIDGE_WIDTH)
        bell_x,bell_z=x-24.49,z-26.82
        for dz in (-1.48,1.48):
            part(wind,"Wind bell post",(bell_x,y+7.95,bell_z+dz),(.39,4.9,.41),"625377",collide=False)
        part(wind,"Chime beam",(bell_x,y+10.35,bell_z),(.52,.44,3.48),"8B6482",collide=False)
        for idx,dz in enumerate((-1.03,-.34,.34,1.03)):
            length=1.12+idx*.23
            part(wind,"Brass wind chime",(bell_x,y+10.08-length/2,bell_z+dz),
                 (length,.34,.34),"F0C485",shape=2,roll=90,collide=False)
        for px,pz in ((x-19,z-24),(x+23,z-24),(x+22,z-4)):
            garden_prop(wind,"bankRock",(px,y,pz),.49,39,"9495BB")
        build_pinecrest_crossing(town,item=item,prop=prop,part=part,triangle=triangle,path_edge=path_edge,
                                 beam=beam,sign=sign,swept_roof=swept_roof,festival_lantern=festival_lantern,
                                 garden_shelf=garden_shelf,garden_prop=garden_prop,slate=SLATE,cedar=WOOD_PLANK,
                                 rock=ROCK,grass=GRASS_MAT,fabric=FABRIC,cedar_variant=LANDMARK_CEDAR,
                                 variant_field=MATERIAL_VARIANT_FIELD)
    elif index==3:
        build_frostglass_arrival_hall(town,x,y,z,item=item,prop=prop,part=part,beam=beam,
                                      swept_roof=swept_roof,festival_lantern=festival_lantern,
                                      garden_prop=garden_prop,slate=SLATE,wood=WOOD_PLANK,
                                      metal=METAL,neon=NEON,cedar_variant=LANDMARK_CEDAR,
                                      variant_field=MATERIAL_VARIANT_FIELD)
        build_frostglass_store_planting(town,item=item,prop=prop,part=part,vector=vector,asset=asset)
        build_frostglass_snow_ridges(town,item=item,prop=prop,part=part,vector=vector,asset=asset,color=color)
        ice=item(town,"Model","Frostglass reflecting garden")
        prop(ice,"token","LevelOfDetail",4)
        part(ice,"Frozen reflecting pond",(x,y+.041,z+9),(13,.08,10.5),"A0C9DE",collide=False,material=GLASS)
        for offset in (-4,-2,1.5,4):
            beam(ice,"Ice seam",(x+offset,y+.084,z+4.7),
                 (x+offset-1.8,y+.084,z+12.9),.040,"D7EDF4")
        for idx,(dx,dz) in enumerate(((-11,5),(12,4),(-10,-2),(11,-4),(-14,20),(13,22))):
            cx,cz=x+dx,z+dz
            part(ice,"Snow-stone cluster bed",(cx,y+.19,cz),(4.7,.35,3.1),"B4C2D2",collide=False,material=SLATE)
            for offset,height,tint in ((-1.44,1.76,"A3CADC"),(-.72,3.18,"9FBEDC"),(.20,3.95,"97AAD6"),(.83,1.82,"B6D4E3")):
                part(ice,"Frostglass prism",(cx+offset,y+height*.48,cz+offset*.37),(.80,height,.72),tint,
                     yaw=28+idx*11,roll=-offset*17,collide=False,class_name="WedgePart",material=GLASS,transparency=.15)
            garden_prop(ice,"meadowCover",(cx+1.26,y+.32,cz),.16,23,"D2DCE1")
            garden_prop(ice,"mossFlowers",(cx-.48,y+.32,cz+1.26),.26,33,"B8C8DC")
        for offset in (-6.4,6.4):
            lantern_window(ice,x+offset,y+7.87,z-10.89,3.8,3.85)
        for offset in (-9, 9):
            air_effect(ice, "Frostglass flurries", (x+offset, y+6.8, z+7), (12, 4, 14), 14302399641,
                       tint="E2F4FF", rate=7, lifetime=(2.5, 4.3), speed=(.65, 1.5),
                       size=(.22, .32), opacity=.67, drift=(.85, -.24, .26), down=True, glow=.39)
        frostglass_walk(town,x,y,z)
        frostglass_high_walk(town)
        build_frostglass_reflectors(town,item=item,prop=prop,part=part,beam=beam,sign=sign,vector=vector,color=color)
        mistline_vista(town)
        build_frostglass_glacier_walk(town,item=item,prop=prop,part=part,beam=beam,
                                       triangle=triangle,path_edge=path_edge,sign=sign,
                                       swept_roof=swept_roof,festival_lantern=festival_lantern,
                                       garden_shelf=garden_shelf,garden_prop=garden_prop,
                                       slate=SLATE,limestone=LIMESTONE,cedar=WOOD_PLANK,
                                       grass=GRASS_MAT,brass=METAL,paving_variant=PROMENADE_STONE,
                                       variant_field=MATERIAL_VARIANT_FIELD)
        frostglass_escarpment(town)
    else:
        market=item(town,"Model","Lantern Circuit night stalls")
        prop(market,"token","LevelOfDetail",4)
        for i in range(-2,3):
            part(town,"Festival path luminaire",(x+i*3,y+.09,z+7),(1.15,.18,3.9),
                 ("CF8DB8","B878BF","82BCBA")[i%3],collide=False,material=NEON)
        for i,dz in enumerate((13,0,-12)):
            for side in (-1,1):
                px,pz=x+side*10.1,z+dz
                paint=("A45471","79568B","4E8285")[i]
                for corner in (-1,1):
                    part(market,"Market cedar support",(px+corner*2.15,y+2.2,pz),(.43,4.4,.43),"664149",collide=False)
                part(market,"Dyed fabric awning",(px,y+4.4,pz+.40),(5.22,.14,3.18),paint,
                     pitch=9,material=FABRIC,collide=False)
                part(market,"Lantern vendor table",(px,y+1.14,pz+.66),(4.92,.46,1.91),"87524D",collide=False)
                for offset in (-1.26,0,1.26):
                    lamp(market,px+offset,y+2.04,pz+.78,scale=.40,light=offset==0)
        scenic_walk(town,"Lantern gallery",(x-28.2,y,z+11),(x-28.2,y+4.8,z-14),"806F94","764C75",rear_entry=True)
        lantern_market_terrace(town,x,y,z)
        build_lantern_market_frontage(town, x, y, z, item=item, prop=prop, part=part, beam=beam,
                                      swept_roof=swept_roof, festival_lantern=festival_lantern,
                                      garden_shelf=garden_shelf, garden_prop=garden_prop, slate=SLATE,
                                      wood=WOOD_PLANK, cloth=FABRIC, metal=METAL, neon=NEON)
        build_lantern_market_goods(town, x, y, z, item=item, prop=prop, part=part,
                                   vector=vector, asset=asset)
        build_lantern_market_crossing(town, item=item, prop=prop, part=part, beam=beam,
                                      triangle=triangle, path_edge=path_edge, sign=sign,
                                      swept_roof=swept_roof, festival_lantern=festival_lantern,
                                      garden_shelf=garden_shelf, garden_prop=garden_prop, slate=SLATE,
                                      limestone=LIMESTONE, cedar=WOOD_PLANK, brass=METAL, grass=GRASS_MAT,
                                      stone_variant=PROMENADE_STONE, variant_field=MATERIAL_VARIANT_FIELD)
        build_lantern_arrival_relief(town, x, y, z, item=item, prop=prop, part=part, beam=beam,
                                     triangle=triangle, slate=SLATE, wood=WOOD_PLANK, cloth=FABRIC,
                                     metal=METAL, neon=NEON)
        build_lantern_court_shopfronts(town,x,y,z,item=item,prop=prop,part=part,slate=SLATE,
                                        wood=WOOD_PLANK,metal=METAL,neon=NEON,
                                        cedar_variant=LANDMARK_CEDAR,brass_variant=ORNAMENT_BRASS,
                                        variant_field=MATERIAL_VARIANT_FIELD)
        build_lanternmakers_overlook(
            town, item=item, prop=prop, part=part, beam=beam, route=route, sign=sign,
            swept_roof=swept_roof, festival_lantern=festival_lantern, garden_shelf=garden_shelf,
            garden_prop=garden_prop, slate=SLATE, limestone=LIMESTONE, cedar=WOOD_PLANK,
            grass=GRASS_MAT, metal=METAL,
        )
        build_lantern_guild_beacon(
            town, item=item, prop=prop, part=part, beam=beam, triangle=triangle, swept_roof=swept_roof,
            festival_lantern=festival_lantern, garden_prop=garden_prop, showcase_tree=showcase_tree,
            slate=SLATE, grass=GRASS_MAT, cedar=WOOD_PLANK, metal=METAL, neon=NEON,
            stone_variant=BANK_STONE, variant_field=MATERIAL_VARIANT_FIELD,
        )
        build_lantern_foothill_gardens(
            town, item=item, prop=prop, part=part, triangle=triangle, vector=vector, asset=asset, garden_prop=garden_prop,
            showcase_tree=showcase_tree, stone=ROCK, cedar=WOOD_PLANK, grass=LEAFY_GRASS,
            smooth=SMOOTH, stone_variant=BANK_STONE, variant_field=MATERIAL_VARIANT_FIELD,
        )

def meltwater_abutment(parent,point,length,yaw,road_t,outward):
    bank=item(parent,"Model","Meltwater slate abutment")
    bank_t=road_t+outward*.16
    _,grade,_=point(bank_t)
    outline=((-1,-.27),(-.74,-.83),(-.21,-1),(.53,-.91),(1,-.31),
             (.91,.53),(.31,.97),(-.58,.76))
    # Each weathered band reaches farther down the bank toward the creek.
    bands=[]
    for level,wide,reach,inset,shift in (
        (-5.20,15.60,13.45,.15,.18),(-2.22,15.15,12.63,.09,.42),
        (grade-4.19,11.94,8.79,-.68,.21),(grade-.72,6.38,5.68,-.86,-.32),
    ):
        ring=[]
        for index,(u,v) in enumerate(outline):
            x,_,z=point(bank_t+outward*(v*reach+inset)/length,u*wide+shift)
            ring.append((x,level+(0,.19,-.31,.14,-.17,.32,.09,-.22)[index],z))
        bands.append(ring)
    colors=(("746B7B","7E7380","847784"),("8D7F8E","988B98","8A7E8E"),
            ("A394A2","8D8495","9B8B98"))
    for level,(bottom,top) in enumerate(zip(bands,bands[1:])):
        for index in range(len(outline)):
            j=(index+1)%len(outline)
            for i,face in enumerate(((bottom[index],bottom[j],top[index]),(top[index],bottom[j],top[j]))):
                triangle(bank,*face,colors[level][(index+i)%3],name="Layered Meltwater slate",
                         material=ROCK,thickness=.24,collide=True,shadow=False)
                if level==1 and i==1 and index in (0,1,4,5,6):
                    # Keep the moss inside the rock face and offset it past the slate skin.
                    spot_a,spot_b,spot_c=face
                    center=point(bank_t)
                    moss=[]
                    for wa,wb,wc in ((.43,.06,.51),(.14,.27,.59),(.12,.56,.32),(.38,.40,.22)):
                        x,y,z=(wa*p+wb*q+wc*r for p,q,r in zip(spot_a,spot_b,spot_c))
                        distance=hypot(x-center[0],z-center[2])
                        moss.append((x+.21*(x-center[0])/distance,y,z+.21*(z-center[2])/distance))
                    for a,b,c in ((0,1,2),(0,2,3)):
                        triangle(bank,moss[a],moss[b],moss[c],("677E72","748D7B","7C907D")[index%3],
                                 name="Meltwater moss band",material=GRASS_MAT,thickness=.08,shadow=False)
    crest=bands[-1]
    for a,b in zip(crest[1:-1],crest[2:]):
        triangle(bank,crest[0],a,b,"AA9CA5",name="Weathered abutment crest",material=ROCK,
                 thickness=.24,collide=True,shadow=False)
    for slab in bank.findall("Item"):
        if slab.findtext("Properties/token[@name='Material']")==str(ROCK):
            prop(slab,"string",MATERIAL_VARIANT_FIELD,VALLEY_ROCK)

    x,y,z=point(road_t+outward*.033)
    part(bank,"Meltwater bridge bearing", (x,(y-5.69)/2,z),(8.6,y+4.5,2.39),
         "8F818B",yaw=yaw,material=SLATE,collide=False)
    part(bank,"Dressed bearing cap",(x,y-.63,z),(9.32,.44,3.04),
         "B09EA5",yaw=yaw,material=SLATE,collide=False)
    for index,(offset,relative,drop,width) in enumerate((
        (-9.88,-.22,3.88,4.88),(10.54,-.20,4.15,4.61),(9.28,.68,3.63,4.48),
    )):
        px,_,pz=point(bank_t+outward*relative*.25,offset)
        top=grade-drop
        garden_shelf(bank,px,top,pz,width,3.31,1.09,"918594",SLATE,collide=False)
        garden_shelf(bank,px+.12,top+.10,pz+.13,width*.84,2.80,.23,"778E79",GRASS_MAT,collide=False)
        garden_prop(bank,"bankRock",(px+offset*.066,top-.17,pz-.26),.22,33+index*38,"ADB0BE")
        garden_prop(bank,"mossFlowers",(px-.19,top+.08,pz+.54),.135,72-index*17,"D9B4CD")
        garden_prop(bank,"meadowCover",(px-.82,top+.10,pz-.37),.15,47+index*13,"9DAE96")
        garden_prop(bank,"grassBlade",(px+.46,top+.10,pz+.31),.42,42+index*36,"AEB89C")
        if index==0:
            showcase_tree(bank,px+.22,pz-.51,False,.31 if outward<0 else .37,29*outward,top+.08,compact=True)


def frostglass_bridge(parent,entry,exit):
    bridge=item(parent,"Model","Frostglass Lantern Bridge")
    prop(bridge,"token","ModelStreamingMode",1)
    prop(bridge,"token","LevelOfDetail",4)
    dx,dy,dz=(b-a for a,b in zip(entry,exit))
    length=hypot(dx,dz)
    yaw=degrees(atan2(dx,dz))
    pitch=-degrees(atan2(dy,length))
    deck_tint="9D7A71"
    rail_tint="7C555F"

    def point(t,side=0,lift=0):
        return entry[0]+t*dx-side*dz/length,entry[1]+t*dy+lift,entry[2]+t*dz+side*dx/length

    route(bridge,"Frostglass cedar bridge deck",[entry,exit],12,deck_tint,
          surface=WOOD_PLANK,stone_footings=False,railings=False,join_overlap=.56)
    board_count=21
    for index in range(board_count):
        position=point((index+.5)/board_count,0,.039)
        part(bridge,"Frostglass cedar deck board",position,(11.89,.056,length/board_count-.085),
             ("9B756F","AD8578","98766E")[index%3],yaw=yaw,pitch=pitch,material=WOOD_PLANK,collide=False)
    bay_opening=4.55/length
    for side in (-1,1):
        offset=side*5.65
        beam(bridge,"Slate bridge apron",point(0,offset,-.54),point(1,offset,-.54),.59,"716671")
        segments=((0,1),) if side<0 else ((0,.5-bay_opening),(.5+bay_opening,1))
        for a,b in segments:
            for lift in (.57,1.46):
                beam(bridge,"Frostglass bridge rail",point(a,offset,lift),point(b,offset,lift),
                     .245,rail_tint,collide=True)
        for t in (0,.15,.30,.5-bay_opening,.5+bay_opening,.70,.85,1):
            part(bridge,"Snow-capped bridge post",point(t,offset,.76),(.42,1.54,.42),
                 rail_tint,yaw=yaw,collide=False)
            part(bridge,"Pale stone post cap",point(t,offset,1.52),(.56,.14,.56),
                 "D0BCC6",yaw=yaw,collide=False)
        for t in (.15,.85):
            px,py,pz=point(t,offset)
            part(bridge,"Creek bridge pier",(px,(py-5.25)/2,pz),(2.54,py+4.75,2.93),
                 "797684",yaw=yaw,material=SLATE)
            part(bridge,"Bridge pier capital",point(t,offset,-.51),(2.93,.54,3.16),
                 "A99BA7",yaw=yaw,material=SLATE,collide=False)
            lamp(bridge,*point(t,offset,2.28),scale=.60,light=side<0)

    for t in (.055,.945):
        for side in (-1,1):
            offset=side*6.08
            part(bridge,"Frostglass gate column",point(t,offset,2.97),(.57,5.94,.64),
                 "854F60",yaw=yaw,material=WOOD_PLANK)
            beam(bridge,"Frostglass gate bracket",point(t,offset,4.78),
                 point(t,offset-side*1.23,5.91),.27,"A37A5F")
            festival_lantern(bridge,*point(t,offset-side*1.29,5.27),.54,light=False)
        beam(bridge,"Frostglass gateway crosspiece",point(t,-6.76,6.03),
             point(t,6.76,6.03),.62,"825267")
        for side in (-1,1):
            beam(bridge,"Frostglass swept brass cap",point(t,side*5.08,6.38),
                 point(t,side*6.91,6.72),.24,"DBA977")
        beam(bridge,"Frostglass eave ridge",point(t,-5.10,6.38),
             point(t,5.10,6.38),.23,"AD7A65")
    sx,sy,sz=point(.055-.73/length,0,6.02)
    sign(bridge,"FROSTGLASS BRIDGE",sx,sy,sz,6.13,.77,yaw+180,"516779")
    nx,ny,nz=point(.945+.73/length,0,6.02)
    sign(bridge,"LANTERN CIRCUIT",nx,ny,nz,6.13,.77,yaw,"60506D")

    side_near,side_far=5.24,14.08
    near_t,far_t=.5-bay_opening,.5+bay_opening
    px,py,pz=point(.5,(side_near+side_far)/2)
    part(bridge,"Creek lookout deck",(px,py-.221,pz),(side_far-side_near,.50,9.18),"A59498",
         yaw=yaw,pitch=pitch,material=LIMESTONE)
    for a,b in (((near_t,side_near),(near_t,side_far)),
                ((near_t,side_far),(far_t,side_far)),((far_t,side_far),(far_t,side_near))):
        for lift in (.57,1.45):
            beam(bridge,"Creek lookout rail",point(*a,lift),point(*b,lift),.245,rail_tint,collide=True)
    for t in (near_t,.5,far_t):
        part(bridge,"Creek lookout capstone",point(t,side_far,1.40),(.49,.21,.49),"C0A9B2",yaw=yaw,collide=False)
        part(bridge,"Creek lookout pillar",point(t,side_far,.76),(.37,1.52,.37),rail_tint,yaw=yaw)
    for t in (.39,.61):
        for side in (7.31,13.18):
            post_x,post_y,post_z=point(t,side)
            part(bridge,"Lookout roof cedar post",(post_x,post_y+2.97,post_z),(.56,5.94,.56),
                 "80535E",material=WOOD_PLANK)
            if side>10:
                part(bridge,"Lookout dressed stone footing",(post_x,(post_y-5.40)/2,post_z),
                     (1.65,post_y+4.72,1.65),"8E8291",material=SLATE,collide=False)
    roof_x,roof_y,roof_z=point(.5,10.25,6.03)
    swept_roof(bridge,roof_x,roof_y,roof_z,8.75,9.51,2.15,fine_tiles=False)
    bench_x,bench_y,bench_z=point(.5,12.91,.71)
    part(bridge,"Creek lookout cedar bench",(bench_x,bench_y,bench_z),(1.24,.35,3.71),
         "AD806B",yaw=yaw,pitch=pitch,material=WOOD_PLANK)
    fx,fy,fz=point(.36,10.26,3.83)
    sign(bridge,"MELTWATER LOOKOUT",fx,fy,fz+.03,4.37,.65,yaw+180,"556877")
    for t in (.379,.621):
        gx,gy,gz=point(t,12.0)
        part(bridge,"Frostglass lookout planter",(gx,gy+.19,gz),(1.36,.32,1.17),"948794",
             yaw=yaw,material=SLATE)
        garden_prop(bridge,"mossFlowers",(gx,gy+.34,gz),.095,43,"C7B5DB")
        garden_prop(bridge,"meadowGrass",(gx+.19,gy+.34,gz+.08),.088,26,"A5ADA2")

    creek=item(landscape,"Model","Frostglass meltwater")
    prop(creek,"token","ModelStreamingMode",1)
    prop(creek,"token","LevelOfDetail",4)
    mx,_,mz=point(.5)
    part(creek,"Creek water bounds",(mx,-3.57,mz),(66,2.54,15.3),"4F8492",transparency=1,collide=False)
    part(creek,"Creek edit preview",(mx,-2.30,mz),(66,.084,15.3),"4D8C9D",material=GLASS,
         transparency=.19,collide=False)
    for t,outward in ((0,-1),(1,1)):
        meltwater_abutment(creek,point,length,yaw,t,outward)
        bank_t=t+outward*.13
        for side in (-1,1):
            gx,gy,gz=point(bank_t,side*7.1,-2.0)
            garden_prop(creek,"bankRock",(gx,gy-.36,gz),.35,121+side*19,"A49EAE")
            garden_prop(creek,"meadowCover",(gx+.16,gy+.01,gz+.33),.175,57+side*31,"A8B3A7")
            span=(t+outward*.355,t)
            beam(bridge,"Approach safety rail",point(span[0],side*5.65,1.06),
                 point(span[1],side*5.65,1.06),.22,rail_tint,collide=True)
    for side in (-1,1):
        for index in range(6):
            shore_z=mz+side*(7.95+(.42,-.36,.19)[index%3])
            garden_shelf(creek,mx+(index-2.5)*10.63,-2.11+(.04,.13,.07)[index%3],shore_z,
                         11.56,3.52,.98,("82838F","8E9297","9E9FA8")[index%3],SLATE,collide=False)
    for index,(ox,oz,height,width) in enumerate(((-26,-7.59,-.43,10.5),(-17,-8.6,.24,9.4),(-10.9,7.37,-.86,8.65),
                                                 (10.25,-7.25,-.67,7.92),(18.25,7.91,.02,8.44),(26.20,-8.1,-.43,8.33))):
        x,z=mx+ox,mz+oz
        garden_shelf(creek,x,height,z,width,5.05,3.75,"797889",SLATE,collide=False)
        garden_shelf(creek,x,height+.08,z,width*.86,4.59,.24,"A0A1AE",SLATE,collide=False)
        garden_prop(creek,"bankRock",(x-.84,height-.41,z),.41,30+index*27,"A3A6B6")
        garden_prop(creek,"meadowCover",(x+.48,height+.09,z-.44),.15,18+index*19,"9EAF9F")
        garden_prop(creek,"cattails",(x+1.27,height-.40,z+.38),.24,31*index,"A5BAAB")
    escape_x=mx+24.1
    for side in (-1,1):
        route(creek,"Meltwater bank exit",[(escape_x,-4.56,mz+side*4.42),
              (escape_x,-1.93,mz+side*9.4),(escape_x,-4.9,mz+side*19.1)],4.88,"9391A0",
              surface=SLATE,stone_footings=False,railings=False,join_overlap=.40)


def meltwater_junction_guard(parent,start,end,opening):
    dx,dz=end[0]-start[0],end[2]-start[2]
    length=hypot(dx,dz)
    for side in (-1,1):
        offset=(side*6*dz/length,1.05,-side*6*dx/length)
        a,b=(tuple(p+o for p,o in zip(spot,offset)) for spot in (start,end))
        spans=((0,1),)
        if side>0:
            first,last=sorted(max(0,min(1,(z-a[2])/(b[2]-a[2]))) for z in opening)
            spans=((0,first),(last,1))
        for t,u in spans:
            if u-t>.005:
                from_point,to_point=(tuple(p+(q-p)*fraction for p,q in zip(a,b)) for fraction in (t,u))
                beam(parent,"Elevated route rail",from_point,to_point,.20,DARK,collide=True)


def lower_meltwater_walk(parent):
    walk=item(parent,"Model","Lower Meltwater Walk")
    prop(walk,"token","ModelStreamingMode",1)
    prop(walk,"token","LevelOfDetail",4)

    south=[(-223.85,6.967,-50.80),(-230.25,6.967,-50.80),(-236.95,5.38,-55.25),
           (-242.18,3.49,-63.05),(-242.03,1.42,-71.82),(-236.10,.78,-71.92),
           (-232.32,.78,-72.15),(-232.32,.78,-74.38)]
    north=[(-232.32,.78,-89.24),(-232.32,.78,-90.99),(-237.33,1.45,-91.96),(-242.03,2.66,-95.25),(-240.70,4.36,-102.25),
           (-236.40,6.38,-108.20),(-230.65,8.23,-112.62),(-222.78,10.33,-113.85),
           (-217.65,10.58,-113.85)]
    half=2.72
    rail_tint="526D72"
    masonry=("988C9A","A1969D","A59BA4")

    def rail(a,b,*,bridge=False):
        for lift,width in ((.48,.19),(1.30,.24)):
            beam(walk,"Meltwater cedar rail",(a[0],a[1]+lift,a[2]),(b[0],b[1]+lift,b[2]),
                 width,rail_tint,collide=True)
        count=max(1,ceil(dist(a,b)/3.5))
        for index in range(count):
            x,y,z=(v+(w-v)*index/count for v,w in zip(a,b))
            part(walk,"Meltwater rail post",(x,y+.65,z),(.28,1.37,.28),rail_tint)
            part(walk,"Meltwater brass post cap",(x,y+1.32,z),(.37,.11,.37),"B99462",
                 material=METAL,collide=False)
            if bridge and index%2==0:
                lamp(walk,x,y+1.57,z,scale=.31)

    for path,label in ((south,"Lantern Circuit descent"),(north,"Frostglass ascent")):
        left,right=(path_edge(path,offset) for offset in (-half,half))
        for index,(a,b,c,d) in enumerate(zip(left,left[1:],right[1:],right)):
            start=len(walk)
            corners=[(x,y-.245,z) for x,y,z in (a,b,c,d)]
            for i,j,k in ((0,1,2),(0,2,3)):
                triangle(walk,corners[i],corners[j],corners[k],masonry[index%3],name=label,
                         thickness=.49,material=LIMESTONE,collide=True,shadow=False)
            for stone in list(walk)[start:]:
                prop(stone,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
            x,y,z=(sum(vertex[i] for vertex in (a,b,c,d))/4 for i in range(3))
            if y>2.1:
                part(walk,"Meltwater bank pier",(x,(y-5.25)/2,z),(1.13,y+4.76,1.16),
                     "8F8490",material=SLATE,collide=False)
                part(walk,"Meltwater pier cap",(x,y-.57,z),(1.66,.38,1.61),
                     "AA98A0",material=SLATE,collide=False)
        for side in (-1,1):
            shoulder=path_edge(path,side*(half-.18))
            for index,(a,b) in enumerate(zip(shoulder,shoulder[1:])):
                if (path is south and index==0) or (path is north and index==len(path)-2):
                    continue
                rail(a,b)

    x,y,start_z=south[-1]
    end_z=north[0][2]
    span=start_z-end_z
    part(walk,"Meltwater footbridge deck",(x,y-.235,(start_z+end_z)/2),(5.54,.47,span+.12),
         "896963",material=WOOD_PLANK)
    for i in range(17):
        plank=part(walk,"Meltwater cedar board",(x,y+.009,start_z-span*(i+.5)/17),
                   (5.46,.020,span/17-.056),("AA8174","9C756A","B38D80")[i%3],
                   material=WOOD_PLANK,collide=False)
        prop(plank,"bool","CastShadow",False)
    for side in (-1,1):
        edge=x+side*2.57
        beam(walk,"Meltwater footbridge fascia",(edge,y-.29,start_z),(edge,y-.29,end_z),.43,"6E5961")
        for z in (-75.5,-86.0):
            part(walk,"Creek cedar pile",(edge,(y-5.08)/2,z),(.64,y+4.58,.66),
                 "745C65",material=WOOD_PLANK,collide=False)
    rail((x+2.57,y,start_z),(x+2.57,y,end_z),bridge=True)
    rest_north,rest_south=-84.22,-77.52
    west=x-6.97
    rail((x-2.57,y,start_z),(x-2.57,y,rest_south),bridge=True)
    rail((x-2.57,y,rest_north),(x-2.57,y,end_z),bridge=True)
    part(walk,"Creekside seating deck",((west+x-2.61)/2,y-.245,(rest_north+rest_south)/2),
         (x-2.61-west,.49,rest_south-rest_north),"9F7B72",material=WOOD_PLANK)
    for a,b in (((x-2.57,rest_south),(west+.16,rest_south)),((west+.16,rest_south),(west+.16,rest_north)),
                ((west+.16,rest_north),(x-2.57,rest_north))):
        rail((a[0],y,a[1]),(b[0],y,b[1]))
    bench_z=(rest_north+rest_south)/2
    seat=part(walk,"Meltwater creekside seat",(west+1.05,y+.48,bench_z),(3.20,.25,1.02),
              "AE826A",yaw=-90,material=WOOD_PLANK,class_name="Seat")
    seat.find("Properties/bool[@name='CanTouch']").text="true"
    part(walk,"Meltwater seat back",(west+.59,y+.83,bench_z),(.18,.53,3.20),
         "8E695F",material=WOOD_PLANK,collide=False)

    for rock_x,rock_z,top,width in ((-242.2,-67.0,.8,4.8),(-234.9,-73.9,-.53,3.55),
                                  (-237.7,-88.8,-.05,4.6),(-239.7,-97.0,1.34,4.2),
                                  (-242.6,-103.8,2.95,4.5)):
        garden_shelf(walk,rock_x,top,rock_z,width,3.34,1.23,"92909E",SLATE,collide=False)
        garden_shelf(walk,rock_x-.11,top+.10,rock_z,width*.79,2.77,.23,"788C82",GRASS_MAT,collide=False)
        garden_prop(walk,"bankRock",(rock_x-.48,top-.12,rock_z-.34),.27,32,"A4A1AD")
        garden_prop(walk,"meadowCover",(rock_x+.51,top+.08,rock_z+.54),.17,81,"A2B09B")
        garden_prop(walk,"mossFlowers",(rock_x+.66,top+.09,rock_z-.66),.15,45,"D7B7DA")
        garden_prop(walk,"grassBlade",(rock_x-.56,top+.06,rock_z+.56),.34,-46,"B0BD9C")

    for x,z,width,depth,height,yaw in ((-252.05,-63.3,12.9,16.1,9.73,-7),
                                     (-251.1,-104.35,12.67,18.72,12.62,8)):
        shoreline_slate(walk,x,z,-5,width,depth,height,yaw,shadow=False)
        top=-5+height*.90
        garden_shelf(walk,x,top-.03,z+.24,width*.59,depth*.56,.48,"758D81",GRASS_MAT,collide=False)
        garden_prop(walk,"meadowCover",(x+.55,top-.02,z+.13),.24,55,"9AAA9A")
        garden_prop(walk,"mossFlowers",(x+1.18,top-.02,z+.61),.22,91,"D9C0D7")
        showcase_tree(walk,x-.94,z-1.29,False,.40,yaw,top,compact=True)

    for sx,sy,sz,yaw,label in (
        (-227.65,6.96,-48.33,0,"LOWER MELTWATER WALK  ←"),
        (-220.87,10.58,-116.56,180,"LOWER MELTWATER WALK  →"),
        (-237.50,y,-81.05,90,"CREEKSIDE SEAT"),
    ):
        plinth=.91 if label=="CREEKSIDE SEAT" else 2.37
        post=part(walk,"Meltwater wayfinding post",(sx,sy+plinth/2,sz),(.26,plinth,.26),
                  "775C61",material=WOOD_PLANK,collide=False)
        prop(post,"bool","CastShadow",False)
        sign(walk,label,sx,sy+plinth,sz,3.15 if plinth<1 else 6.85,.71,yaw,"4D6871")


def cloudstep_ravine(parent):
    terraces=item(parent,"Model","Cloudstep ravine terraces")
    prop(terraces,"token","LevelOfDetail",4)
    outline=((-1,-.34),(-.52,-1),(.58,-.83),(1,-.08),(.51,1),(-.58,.72))
    stone_tints=(("655F6B","756A77","877782","96818B","7F7080","706773"),
                 ("817580","8F7D8A","AA9295","AC999B","97818B","817482"))

    def cedar_piece(grove,label,center,size,tint,**properties):
        needle=part(grove,label,center,size,tint,collide=False,**properties)
        prop(needle,"bool","CastShadow",False)

    garden_shelf(terraces,75.70,1.20,-243.57,21.4,10.2,7.12,"6C6472",ROCK,collide=False)
    garden_shelf(terraces,65.05,3.46,-248.84,18.6,10.7,9.39,"746977",ROCK,collide=False)

    for index,(x,z,base,top,width,depth,yaw,pine,green) in enumerate((
        (86.05,-216.40,-5.8,15.04,12.1,8.70,-18,.29,"7E8652"),
        (75.15,-218.80,-5.8,17.60,15.3,8.50,-29,.37,"778F58"),
        (64.80,-224.30,-5.8,13.90,12.5,8.50,14,.34,"758958"),
        (77.40,-213.80,11.4,23.22,10.4,7.50,19,.37,"788751"),
        (80.10,-239.20,-6.6,6.90,17.6,13.30,17,.46,"708659"),
        (69.70,-246.05,-6.4,9.80,17.0,13.20,-14,0,"677D54"),
        (58.60,-248.50,-6.2,13.00,15.3,12.70,21,.44,"697F56"),
    )):
        ledge=item(terraces,"Model","Planted Cloudstep shelf")
        c,s=cos(radians(yaw)),sin(radians(yaw))
        levels=[]
        for progress,scale,lean in ((0,1,0),(.48,.89,.28),(1,.68,1)):
            ring=[]
            for i,(u,v) in enumerate(outline):
                px,pz=u*width*scale/2,v*depth*scale/2
                dy=(.20 if i%2 else -.10)*(1-progress)
                ring.append((x+px*c+pz*s+.62*lean,base+(top-base)*progress+dy,
                             z-px*s+pz*c+.58*lean))
            levels.append(ring)
        for course,(lower,upper) in enumerate(zip(levels,levels[1:])):
            for i,shade in enumerate(stone_tints[course]):
                j=(i+1)%len(outline)
                for face in ((lower[i],lower[j],upper[i]),(lower[j],upper[j],upper[i])):
                    triangle(ledge,*face,shade,name="Cloudstep slate strata",material=ROCK,
                             thickness=.21,shadow=False)
        crest=levels[-1]
        for a,b in zip(crest[1:-1],crest[2:]):
            triangle(ledge,crest[0],a,b,"A18B8F",name="Cloudstep slate crest",material=ROCK,
                     thickness=.17,shadow=False)
        for facet in ledge.findall('Item'):
            prop(facet,"string",MATERIAL_VARIANT_FIELD,VALLEY_ROCK)

        px,pz=x+.60,z+.60
        garden_shelf(ledge,px,top+.13,pz,width*.48,depth*.42,.27,green,GRASS_MAT,collide=False)
        for key,dx,dz,scale,tint in (("bankRock",-.95,.53,.19,"98878C"),
                                     ("meadowCover",.83,.41,.17,"9BA865"),
                                     ("meadowGrass",-.48,.83,.18,"B1B577"),
                                     ("mossFlowers",.47,-.42,.16,"C69EAC")):
            garden_prop(ledge,key,(px+dx,top+.08,pz+dz),scale,index*51,tint)
        if pine and index in (0,3):
            showcase_tree(ledge,px-.14,pz-.39,False,pine,yaw+27,top+.13,compact=True)
        elif pine:
            hillside_cedar(cedar_piece,ledge,px-.14,top+.13,pz-.39,pine*1.36,index)


def cloudstep_pass(parent, points):
    crossing=item(parent,"Model","Cloudstep Pass")
    prop(crossing,"token","ModelStreamingMode",1)
    prop(crossing,"token","LevelOfDetail",4)
    half=CLOUDSTEP_WIDTH/2
    west,east=(path_edge(points,side*half) for side in (-1,1))
    for index,(a,b,c,d) in enumerate(zip(west,west[1:],east[1:],east)):
        # Shared mitered edges avoid steps and gaps through the switchbacks.
        corners=[(x,y-.24,z) for x,y,z in (a,b,c,d)]
        tint=("A2929C","9E8E98","A697A1")[index%3]
        for i,j,k in ((0,1,2),(0,2,3)):
            triangle(crossing,corners[i],corners[j],corners[k],tint,name="Cloudstep slate walk",
                     thickness=.48,material=SLATE,collide=True)
    lookout_span=4
    for side in (-1,1):
        rim=path_edge(points,side*(half-.09))
        for index,(start,end) in enumerate(zip(rim,rim[1:])):
            if side==1 and index==lookout_span:
                continue
            for lift in (.55,1.37):
                beam(crossing,"Cloudstep cedar guardrail",(start[0],start[1]+lift,start[2]),
                     (end[0],end[1]+lift,end[2]),.24,"795567",collide=True)
            for t in (.08,.53):
                x,y,z=(a+(b-a)*t for a,b in zip(start,end))
                part(crossing,"Cloudstep rail newel",(x,y+.69,z),(.42,1.45,.42),
                     "755664",material=WOOD_PLANK,collide=False)
                part(crossing,"Newel bronze cap",(x,y+1.46,z),(.56,.13,.56),"C99361",collide=False)

    planted_edge=path_edge(points,half+1.78)
    opposite_edge=path_edge(points,-half-1.78)
    for index,(x,y,z) in enumerate(points[1:-2]):
        base=item(crossing,"Model","Layered pass abutment")
        part(base,"Skywalk masonry pier",(x,(y-4.9)/2,z),(3.27,y+4.1,4.18),"776B78",material=SLATE)
        for width,depth,drop,thickness,tint in (
            (9.7,6.7,.57,2.11,"94818B"),(11.25,8.26,2.47,3.38,"7B6C7D"),(13.8,10.9,4.92,4.26,"6B6270"),
        ):
            garden_shelf(base,x+.46,y-drop,z+.22,width,depth,thickness,tint,SLATE,collide=False)
        edge=opposite_edge if index+1 in (lookout_span,lookout_span+1) else planted_edge
        bx,by,bz=edge[index+1]
        garden_prop(base,"bankRock",(bx,by-.84,bz),.18+index%3*.045,43+index*29,"97848D")
        garden_prop(base,"mossFlowers",(bx-.22,by-.42,bz+.31),.18,38+index*57,"D39EAA")
        garden_prop(base,"meadowCover",(bx-.66,by-.48,bz-.38),.165,109+index*17,"8A9A72")
        garden_prop(base,"grassBlade",(bx+.39,by-.44,bz+.11),.43,75-index*31,"C1B799")
        lamp(crossing,bx+.17,by+.26,bz+.35,scale=.54)

    banks=item(crossing,"Model","Cloudstep rock shoulders")
    for index,(x,z,top) in enumerate(((87.3,-221.8,12.6),(76.2,-229.6,13.55),(63.9,-236.74,14.2))):
        for width,depth,lift,thickness,tint in (
            (30.0,20.8,-8.4,10.2,"6D626E"),(23.4,16.4,-4.6,5.7,"81707B"),(16.8,13.6,0,5.5,"93818B"),
        ):
            garden_shelf(banks,x+.08*lift,top+lift,z+.20*lift,width,depth,thickness,tint,SLATE)
        garden_prop(banks,"bankRock",(x+4.44,top-.11,z+.6),.42,55+index*23,"8C7B87")
        garden_prop(banks,"meadowGrass",(x+3.80,top+.015,z+.42),.25,80+index*17,"92986A")
    cloudstep_ravine(crossing)

    a,b=points[lookout_span:lookout_span+2]
    dx,_,dz=(v-u for u,v in zip(a,b))
    run=hypot(dx,dz)
    yaw=degrees(atan2(dx,dz))

    def point(t,side=0,lift=0):
        return a[0]+t*dx+side*dz/run,a[1]+lift,a[2]+t*dz-side*dx/run

    shelter=item(crossing,"Model","Cloudstep Lookout")
    inner=half-.23
    outer_edge=9.05
    mid=(inner+outer_edge)/2
    deck=part(shelter,"Lookout floor",point(.5,mid,-.223),(outer_edge-inner,.48,run+.40),
         "AEA3A9",yaw=yaw,material=LIMESTONE)
    prop(deck,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
    cx,cy,cz=point(.5,mid)
    garden_shelf(shelter,cx,cy-.49,cz,9.2,7.2,3.5,"8B7884",SLATE,collide=False)
    for t in (.18,.82):
        x,y,z=point(t,7.85)
        part(shelter,"Lookout abutment post",(x,(y-4.8)/2,z),
             (1.71,y+4.0,1.75),"796B7A",yaw=yaw,material=SLATE)
    for (start,end) in (((.0,inner),(.0,outer_edge-.12)),((.0,outer_edge-.12),(1,outer_edge-.12)),
                        ((1,outer_edge-.12),(1,inner))):
        for lift in (.55,1.37):
            beam(shelter,"Cloudstep Lookout guardrail",point(*start,lift),point(*end,lift),.24,"795567",collide=True)
    for t in (.09,.91):
        for side in (inner+.18,outer_edge-.28):
            part(shelter,"Lookout cedar pillar",point(t,side,2.88),(.51,5.76,.51),
                 "915744",material=WOOD_PLANK)
            part(shelter,"Lookout pillar plinth",point(t,side,.23),(.78,.46,.77),"A28C90",material=SLATE)
        festival_lantern(shelter,*point(t,mid,4.62),.59,light=False)
    roof(shelter,cx,cy+5.88,cz,9.89,8.64)
    part(shelter,"Valley-facing cedar bench",point(.53,7.69,.58),(1.12,.30,3.55),
         "AE7963",yaw=yaw,material=WOOD_PLANK)
    for t in (.36,.70):
        part(shelter,"Lookout bench foot",point(t,7.69,.23),(.64,.46,.54),
             "8F7987",yaw=yaw,material=SLATE)
    sign(shelter,"CLOUDSTEP LOOKOUT",*point(.50,8.94,3.80),7.18,.86,180,"684D62")

    for start,end,destination,tint in (
        (points[1],points[0],"SKYWALK PEAKS","785460"),
        (points[-2],points[-1],"CINDER TERRACES","854F44"),
    ):
        x,y,z=start
        ax,az=end[0]-x,end[2]-z
        heading=degrees(atan2(ax,az))
        c,s=cos(radians(heading)),sin(radians(heading))
        def gate_point(side,lift,front=0):
            return x+side*c+front*s,y+lift,z-side*s+front*c
        for side in (-1,1):
            dx=side*(half+.18)
            part(crossing,"Pass slate gate footing",gate_point(dx,.42),(.83,.84,.83),
                 "8B7A86",yaw=heading,material=SLATE,collide=False)
            part(crossing,"Pass cedar gate pillar",gate_point(dx,3.12),(.56,5.79,.56),
                 "9D503D",yaw=heading,material=WOOD_PLANK,collide=False)
            beam(crossing,"Pass gate bracket",gate_point(dx,4.94),
                 gate_point(dx-side*1.20,6.0),.31,"AF7654")
            festival_lantern(crossing,*gate_point(dx-side*.53,5.18,.46),.46,light=False)
        part(crossing,"Pass lintel",gate_point(0,6.39),(7.18,.54,.83),tint,yaw=heading,collide=False)
        part(crossing,"Pass ridge clasp",gate_point(0,6.78),(.52,.38,.49),
             "4B4964",yaw=heading,collide=False)
        for side in (-1,1):
            beam(crossing,"Upturned pass roof",gate_point(side*.09,6.78),
                 gate_point(side*4.08,7.30),.44,"41435D")
            part(crossing,"Pass roof bronze cap",gate_point(side*3.93,7.27),(.66,.26,.54),
                 "C99163",yaw=heading,collide=False)
        sign(crossing,destination,*gate_point(0,6.24,.49),6.38,.88,heading,tint,face_only=True)
    return point(.78,4.82,.017)


def mistline_crossing(parent, west_path, east_path):
    crossing=item(parent,"Folder","Mistline Crossing")
    west=item(crossing,"Model","Frostglass viaduct")
    bridge=item(crossing,"Model","Mistline cedar span")
    east=item(crossing,"Model","Skywalk landing")
    for section in (west,bridge,east):
        prop(section,"token","ModelStreamingMode",1)
        prop(section,"token","LevelOfDetail",4)

    approach_width=8.70
    rail_tint="526877"
    # Separate the first paving course from the matching courtyard surface.
    west_paving=[(x,y+.032 if i<2 else y,z) for i,(x,y,z) in enumerate(west_path)]
    for section,path in ((west,west_paving),(east,east_path)):
        left,right=(path_edge(path,side*approach_width/2) for side in (-1,1))
        for a,b,c,d in zip(left,left[1:],right[1:],right):
            corners=[(x,y-.24,z) for x,y,z in (a,b,c,d)]
            for i,j,k in ((0,1,2),(0,2,3)):
                triangle(section,corners[i],corners[j],corners[k],"9E9DA8",
                         name="Mistline slate approach",thickness=.48,material=SLATE,collide=True)
        for side in (-1,1):
            rim=path_edge(path,side*(approach_width/2-.20))
            for index,(start,end) in enumerate(zip(rim,rim[1:])):
                # Leave the junctions within the two courtyards open.
                if (section is west and index==0) or (section is east and index==len(path)-2):
                    continue
                spans = ((start, end),)
                if section is west and side == 1 and index == MISTLINE_SEGMENT:
                    rail_offset = approach_width / 2 - .20
                    opening_start = mistline_junction(path, rail_offset, path_edge, -MISTLINE_OPENING)
                    opening_end = mistline_junction(path, rail_offset, path_edge, MISTLINE_OPENING)
                    spans = ((start, opening_start), (opening_end, end))
                for a, b in spans:
                    for height in (.58,1.44):
                        beam(section,"Mistline approach rail",(a[0],a[1]+height,a[2]),
                             (b[0],b[1]+height,b[2]),.24,rail_tint,collide=True)
                    posts=max(1,round(hypot(b[0]-a[0],b[2]-a[2])/4.70))
                    for post_index in range(posts):
                        t=(post_index+.16)/posts
                        x,y,z=(u+(v-u)*t for u,v in zip(a,b))
                        part(section,"Mistline approach newel",(x,y+.73,z),(.34,1.46,.34),rail_tint,
                             material=WOOD_PLANK,collide=False)
                        part(section,"Weathered brass rail cap",(x,y+1.48,z),(.43,.13,.43),
                             "C5A267",collide=False)

    for index,(section,(x,y,z)) in enumerate(((west,west_path[1]),(west,west_path[2]),
                                              (west,west_path[3]),(west,west_path[4]),
                                              (west,west_path[-1]),(east,east_path[0]))):
        foundation=item(section,"Model","Mistline layered abutment")
        part(foundation,"Mistline slate pier",(x,(y-5.9)/2,z),(4.30,y+4.4,5.85),
             "7B7888",material=SLATE)
        for width,depth,drop,thickness,tint in ((11.1,9.4,.50,2.9,"A197A5"),
                                                (14.0,12.7,2.74,3.9,"8B8291"),
                                                (18.6,16.0,6.36,7.7,"777585")):
            garden_shelf(foundation,x+.17*drop,y-drop,z-.32*drop,width,depth,thickness,tint,SLATE,
                         collide=False)
        bank_z=z+4.66
        garden_shelf(foundation,x-.38,y-.71,bank_z,6.45,3.94,1.28,"898896",SLATE,collide=False)
        garden_shelf(foundation,x-.29,y-.57,bank_z+.13,5.86,3.41,.31,"869666",GRASS_MAT,collide=False)
        garden_prop(foundation,"bankRock",(x+.92,y-.81,bank_z+.19),.30,39+index*37,"A7A4B1")
        garden_prop(foundation,"mossFlowers",(x-.55,y-.59,bank_z+.63),.18,67+index*27,"C8B8D7")
        garden_prop(foundation,"meadowCover",(x+.17,y-.60,bank_z-.08),.19,32+index*31,"9DAE76")
        garden_prop(foundation,"grassBlade",(x-1.22,y-.54,bank_z+.57),.48,81+index*43,"D9C598")

    a,b=west_path[-1],east_path[0]
    dx,dy,dz=(v-u for u,v in zip(a,b))
    length=hypot(dx,dz)
    yaw=degrees(atan2(dx,dz))
    sections=12

    def at(t,lateral=0,lift=0):
        sag=3.18*4*t*(1-t)
        return (a[0]+dx*t+lateral*dz/length,a[1]+dy*t-sag+lift,a[2]+dz*t-lateral*dx/length)

    deck=[at(index/sections) for index in range(sections+1)]
    route(bridge,"Mistline cedar deck",deck,8.74,"95634E",surface=WOOD_PLANK,
          stone_footings=False,join_overlap=.19,railings=False)
    part(bridge,"Mistline slate threshold",at(1,0,-.12),(8.70,.24,1.30),"9E9DA8",
         yaw=yaw,material=SLATE)
    boards=sections*5
    for index in range(boards):
        t=(index+.5)/boards
        left=int(t*sections)
        start,end=deck[left:left+2]
        height=start[1]+(end[1]-start[1])*(t*sections-left)
        x,_,z=at(t)
        pitch=-degrees(atan2(end[1]-start[1],length/sections))
        part(bridge,"Mistline fitted cedar board",(x,height+.020,z),(8.64,.049,length/boards-.044),
             ("A36E55","B0795E","A46C52","9B6651")[index%4],yaw=yaw,pitch=pitch,
             material=WOOD_PLANK,collide=False)

    for side in (-1,1):
        rail=side*4.13
        rope=side*4.57
        for index in range(sections):
            start,end=index/sections,(index+1)/sections
            for lift in (.57,1.42):
                beam(bridge,"Mistline cedar guardrail",at(start,rail,lift),at(end,rail,lift),.24,
                     "855A4B",collide=True)
            low=2.38+3.65*(1-4*start*(1-start))
            high=2.38+3.65*(1-4*end*(1-end))
            beam(bridge,"Braided suspension rope",at(start,rope,low),at(end,rope,high),.21,"AA8865")
            beam(bridge,"Suspension drop rope",at(start,rope,-.23),at(start,rope,low),.096,"A78B67")
            beam(bridge,"Cedar deck fascia",at(start,side*4.38,-.28),at(end,side*4.38,-.28),.23,"654638")
            part(bridge,"Cedar bridge baluster",at(start,rail,.77),(.31,1.54,.34),"765649",
                 yaw=yaw,material=WOOD_PLANK,collide=False)
            part(bridge,"Cedar bridge cap",at(start,rail,1.56),(.39,.12,.39),"C79966",yaw=yaw,collide=False)
        beam(bridge,"Suspension drop rope",at(1,rope,-.23),at(1,rope,6.03),.096,"A78B67")

    for t,heading,paint,label in ((0,yaw+180,"567685","SKYWALK PEAKS"),
                                  (1,yaw,"625E7C","FROSTGLASS GARDENS")):
        x,y,z=at(t)
        gate(bridge,x,z,heading,span=10.90,label=label,trim=paint,y=y,lanterns=False)
        for side in (-1,1):
            festival_lantern(bridge,*at(t,side*3.38,6.42),.61,light=False)
    gate(west,-157.35,-179.12,-80,span=9.70,label="MISTLINE CROSSING",trim="567685",y=14.312,lanterns=False)
    gate(east,-5.4,-239.87,87,span=9.72,label="MISTLINE CROSSING",trim="625E7C",y=25.027,lanterns=False)
    for i in range(5):
        part(west,"Frostglass trail marker",(-161.8,14.059,-158.7-i*4.10),(.66,.043,.66),
             "92B8C1",yaw=45,material=LIMESTONE,collide=False)
    for x,z in ((7.8,-237.00),(12.50,-236.30),(17.2,-236.28)):
        part(east,"Skywalk trail marker",(x,25.061,z),(.66,.043,.66),
             "B8A4AF",yaw=45,material=LIMESTONE,collide=False)
    return deck


def glaze_vessel(parent, x, y, z, height, width, pigments, waist, mouth):
    glaze, trim, clay = pigments
    part(parent,"Wheel-thrown clay body",(x,y+height*.45,z),
         (width,height*.78,width),glaze,shape=0,collide=False)
    for label,lift,thickness,breadth,tint in (
        ("Ceramic foot",.065,.13,.58,clay),
        ("Painted glaze band",.47,.042,1.004,trim),
        ("Ceramic neck",.79,.21,waist,glaze),
        ("Ceramic lip",.909,.076,mouth,trim),
        ("Jar mouth shadow",.952,.024,mouth*.77,"4C3C41"),
    ):
        part(parent,label,(x,y+height*lift,z),(height*thickness,width*breadth,width*breadth),
             tint,roll=90,shape=2,collide=False)


def glaze_terrace(parent, road_start, road_end):
    terrace=item(parent,"Model","Glaze Terrace")
    prop(terrace,"token","ModelStreamingMode",1)
    prop(terrace,"token","LevelOfDetail",4)
    center_lane=.42
    dx,dz=road_end[0]-road_start[0],road_end[2]-road_start[2]
    length=hypot(dx,dz)

    def road_point(t, offset, lift=0):
        x,y,z=(a+(b-a)*t for a,b in zip(road_start,road_end))
        return x+dz/length*offset,y+lift,z-dx/length*offset

    for side,spans in ((1,((0,1),)),(-1,((0,.25),(.57,1)))):
        for start,end in spans:
            beam(terrace,"Cinder approach road rail",road_point(start,side*6,1.05),
                 road_point(end,side*6,1.05),.20,DARK,collide=True)

    top=15.8
    west,east,front,back=189.65,202.25,-169.20,-188.10
    join=road_point(center_lane,-3.3,.055)
    approach=[join,(179.1,7.62,join[2]),(185.8,9.55,-144.20),
              (190.65,11.52,-150.10),(194.85,13.42,-157.80),(194.85,top,front)]
    descent=[(194.85,top+.023,back),(194.85,top+.023,-190.80),(191.60,top+.023,-194.70),
             (187.60,14.46,-194.50),(182.85,12.36,-192.65),(176.50,10.075,-187.85),
             (171.75,10.075,-187.85)]
    rail_tint="8B4A40"
    posts=set()

    def guardrail(a,b):
        for rise,width in ((.56,.18),(1.37,.23)):
            beam(terrace,"Glaze cedar guardrail",(a[0],a[1]+rise,a[2]),(b[0],b[1]+rise,b[2]),
                 width,rail_tint,collide=True)
        count=max(1,ceil(dist(a,b)/4.1))
        for index in range(count+1):
            point=tuple(round(u+(v-u)*index/count,3) for u,v in zip(a,b))
            if point in posts:
                continue
            posts.add(point)
            x,y,z=point
            part(terrace,"Glaze railing newel",(x,y+.73,z),(.31,1.49,.31),rail_tint)
            part(terrace,"Glaze copper newel cap",(x,y+1.51,z),(.42,.12,.41),"BF855D",collide=False)

    for path,label in ((approach,"Harbor ascent to Glaze Terrace"),(descent,"Glaze Terrace descent")):
        left,right=(path_edge(path,offset) for offset in (-2.96,2.96))
        first=len(terrace)
        for (a,d),(b,c) in zip(zip(left,left[1:]),zip(right,right[1:])):
            a,b,c,d=((x,y-.16,z) for x,y,z in (a,b,c,d))
            triangle(terrace,a,b,c,"AD8E7A",name=label,thickness=.34,material=LIMESTONE,collide=True)
            triangle(terrace,a,c,d,"B49983",name=label,thickness=.34,material=LIMESTONE,collide=True)
        for surface in list(terrace)[first:]:
            prop(surface,"string",MATERIAL_VARIANT_FIELD,PROMENADE_STONE)
        for side in (-1,1):
            edge=path_edge(path,side*2.73)
            for index,(a,b) in enumerate(zip(edge,edge[1:])):
                if (path is approach and index==0) or (path is descent and index==len(edge)-2):
                    continue
                kiln_opening = path is descent and side == -1 and index == 1
                if kiln_opening:
                    ends = [tuple(u+(v-u)*t for u,v in zip(a,b)) for t in GLAZE_RAIL_OPENING]
                    guardrail(a,ends[0])
                    guardrail(ends[1],b)
                else:
                    guardrail(a,b)
                px,py,pz=tuple((u+v)*.5 for u,v in zip(a,b))
                part(terrace,"Glaze ramp stone pier",(px,(py-3.2)*.5-.24,pz),
                     (1.24,py+2.72,1.31),"877078",material=SLATE,collide=False)
                beam(terrace,"Glaze span fascia",(a[0],a[1]-.38,a[2]),(b[0],b[1]-.38,b[2]),.46,"886F70")
                if index%2:
                    lamp_x,lamp_z = (ends[0][0]+.20,ends[0][2]+.15) if kiln_opening else (px,pz)
                    lamp(terrace,lamp_x,py+1.90,lamp_z,scale=.44)

    part(terrace,"Glaze Terrace deck",((west+east)/2,top-.32,(front+back)/2),
         (east-west,.64,front-back),"AE9380",material=LIMESTONE)
    for left,near,right,far in ((west+.24,front-.19,191.90,front-.19),(197.80,front-.19,east-.24,front-.19),
                                (west+.24,back+.20,191.90,back+.20),(197.80,back+.20,east-.24,back+.20),
                                (west+.24,back+.20,west+.24,front-.19),(east-.24,back+.20,east-.24,front-.19)):
        guardrail((left,top,near),(right,top,far))
    for x,z in ((191.10,-171.0),(200.82,-171.0),(191.10,-186.58),(200.82,-186.58)):
        y=(top-3.9)*.5
        part(terrace,"Glaze terrace buttress",(x,y-.48,z),(2.08,top+2.94,2.12),"816871",material=SLATE)
        part(terrace,"Glaze upper footing",(x,top-.79,z),(2.80,.92,2.74),"9D7974",material=SLATE)
    for x,z,upper,w,d in ((200.6,-176.1,9.48,12.4,13.6),(199.8,-180.7,12.52,12.8,12.4),
                           (189.7,-168.3,6.91,8.5,9.3),(200.5,-186.7,5.63,11.8,8.2)):
        rock=item(terrace,"Model","Planted clay outcrop")
        garden_shelf(rock,x,upper,z,w,d,upper+3.65,"876D6E",SLATE,collide=False)
        garden_shelf(rock,x+.32,upper+.18,z-.19,w*.82,d*.80,.29,"859358",GRASS_MAT,collide=False)
        for offset,mirror in ((-.27,1),(.26,-1)):
            px,pz=x+w*offset,z+mirror*d*.19
            garden_prop(rock,"bankRock",(px,upper+.12,pz),.22,49*mirror,"98796C")
            garden_prop(rock,"mossFlowers",(px+.42,upper+.19,pz-.21),.13,72*mirror,"DEA78F")
            garden_prop(rock,"meadowCover",(px-.26,upper+.17,pz+.61),.15,31*mirror,"ABB466")
            garden_prop(rock,"grassBlade",(px+.49,upper+.19,pz+.28),.44,81*mirror,"D5BA78")

    for x in (197.52,201.12):
        for z in (-174.15,-183.20):
            part(terrace,"Glaze shelter stone plinth",(x,top+.23,z),(.75,.45,.76),"99817D",material=SLATE)
            part(terrace,"Glaze shelter cedar post",(x,top+3.19,z),(.56,6.22,.55),"915641",material=WOOD_PLANK)
            part(terrace,"Glaze post copper collar",(x,top+5.88,z),(.65,.27,.66),"C08B62",collide=False)
    swept_roof(terrace,199.28,top+6.30,-178.65,6.71,11.86,2.35,fine_tiles=False)
    sign(terrace,"GLAZE TERRACE",199.25,top+5.78,-172.95,6.66,1.14,tint="7C433D")
    for z in (-175.02,-182.30):
        festival_lantern(terrace,198.12,top+5.32,z,.60,light=False)
    part(terrace,"Glaze drying counter",(199.92,top+1.32,-178.55),(1.51,.28,6.18),"A26C50",material=WOOD_PLANK)
    for z in (-180.88,-176.18):
        part(terrace,"Drying counter slate foot",(199.92,top+.59,z),(1.19,1.24,.61),"80615B",material=SLATE)
    display=item(terrace,"Folder","Glaze sample display")
    for offset,height,width,pigments,waist,mouth in (
        (-2.14,1.48,.88,("A65C49","DBA676","7E5043"),.43,.54),
        (-.76,.79,1.06,("C98057","EDB785","986547"),.80,.92),
        (.64,1.32,.79,("608D87","ACB99E","527674"),.39,.51),
        (1.96,.94,.92,("B99074","E0BE93","9A6E57"),.66,.74),
    ):
        glaze_vessel(display,199.95,top+1.46,-178.55+offset,height,width,pigments,waist,mouth)
    for z in (-180.37,-176.71):
        part(display,"Ceramic display cedar upright",(201.20,top+1.86,z),(.17,3.72,.18),
             "875B4D",material=WOOD_PLANK,collide=False)
    part(display,"Ceramic display cedar header",(201.20,top+3.64,-178.54),(.21,.18,4.21),
         "A77958",material=WOOD_PLANK,collide=False)
    sign(display,"GLAZE SAMPLES",200.97,top+3.31,-178.54,4.21,.78,-90,"805144")
    for z,tint in ((-175.79,"9E7164"),(-181.30,"C79676")):
        part(display,"Potter tile rack",(200.08,top+1.58,z),(1.18,.23,.66),"79564D",
             material=WOOD_PLANK,collide=False)
        for lane,sample in enumerate((tint,"798B7C","CC976B")):
            swatch=part(display,"Fired glaze swatch",(199.70+.27*lane,top+1.74,z),
                        (.22,.10,.44),sample,pitch=16,collide=False)
            prop(swatch,"bool","CastShadow",False)

    rest=item(terrace,"Folder","Glaze bench and planters")
    for z in (-177.75,-174.31):
        part(rest,"Glaze bench slate foot",(191.08,top+.31,z),(.85,.62,.49),
             "927776",material=SLATE,collide=False)
    part(rest,"Glaze cedar seat",(191.08,top+.70,-176.03),(1.18,.24,4.18),
         "A67857",material=WOOD_PLANK,collide=False)
    part(rest,"Glaze cedar seat back",(190.59,top+1.13,-176.03),(.18,.43,4.18),
         "9E6750",material=WOOD_PLANK,collide=False)
    for x,z,pigments,angle in (
        (190.76,-171.71,("8B5144","C59372","76554C"),38),
        (200.58,-185.65,("577E71","9EB195","44635F"),107),
    ):
        glaze_vessel(rest,x,top,z,.79,1.24,pigments,.92,.98)
        garden_prop(rest,"grassBlade",(x,top+.74,z),.26,angle,"A7AF66")
        garden_prop(rest,"mossFlowers",(x+.10,top+.73,z-.19),.085,angle+19,"DAA394")
    for x,y,z,heading,title in ((180.38,7.86,-144.64,0,"GLAZE TERRACE  →"),
                                (173.91,10.027,-184.88,-90,"←  GLAZE TERRACE"),
                                (192.22,top,-185.87,0,"CINDER SQUARE  ↑")):
        part(terrace,"Glaze wayfinding post",(x,y+1.53,z),(.36,3.06,.36),"7A5346",material=WOOD_PLANK,collide=False)
        sign(terrace,title,x,y+2.82,z,5.62,1.02,heading,"814B43")


# Cross-town roads let players circle the valley through the outer districts.
crossroads=[
    ("Harbor to Cinder road",[(210,3,-12),(195,3.5,-74),(179,5.7,-127),(163,10,-159)],"9D8178",
     "CINDER TERRACES","TIDEHARBOR COAST","854F46"),
    ("Lantern to Frostglass road",[(-223,6,-4),(-223,7,-53),(-216,10,-108),(-202,14,-149)],"A28DA2",
     "FROSTGLASS GARDENS","LANTERN CIRCUIT","645875"),
]
for name,points,tone,leaving,returning,paint in crossroads:
    if name=="Lantern to Frostglass road":
        a,b=points[1:3]
        start,end=[tuple(x+(y-x)*fraction for x,y in zip(a,b)) for fraction in (.21,.79)]
        approaches=item(roads,"Folder","Meltwater bridge approaches")
        route(roads,name,points[:2],12,tone,railings=False)
        route(approaches,name,[a,start],12,tone,railings=False)
        frostglass_bridge(roads,start,end)
        build_meltwater_bridge_art(roads,start,end,item=item,part=part,prop=prop,
                                   slate=SLATE,wood=WOOD_PLANK,metal=METAL,
                                   wood_variant=LANDMARK_CEDAR,variant_field=MATERIAL_VARIANT_FIELD)
        route(approaches,name,[end,b],12,tone,railings=False)
        route(roads,name,points[2:],12,tone,railings=False)
        guards=item(roads,"Folder","Meltwater road junction guards")
        meltwater_junction_guard(guards,*points[:2],(-53.68,-47.92))
        meltwater_junction_guard(guards,*points[-2:],(-116.79,-110.91))
        lower_meltwater_walk(roads)
        build_frostglass_approach_planting(
            roads,item=item,prop=prop,part=part,vector=vector,asset=asset,triangle=triangle,
            garden_prop=garden_prop,rock=ROCK,snow=SNOW,rock_variant=VALLEY_ROCK,
            variant_field=MATERIAL_VARIANT_FIELD,
        )
    elif name=="Harbor to Cinder road":
        route(roads,name,points[:2],12,tone,railings=False)
        a,b=points[:2]
        dx,dz=b[0]-a[0],b[2]-a[2]
        length=hypot(dx,dz)

        def harbor_rail_point(fraction,side):
            x,y,z=(start+(end-start)*fraction for start,end in zip(a,b))
            return x+side*6*dz/length,y+1.05,z-side*6*dx/length

        # The northbound road retains its deck. Open only the east rail beside the new walk.
        first,last=((z-harbor_rail_point(0,-1)[2])/dz for z in reversed(TIDEWATCH_CINDER_OPENING))
        for start,end in ((0,first),(last,1)):
            beam(roads,"Elevated route rail",harbor_rail_point(start,-1),
                 harbor_rail_point(end,-1),.20,DARK,collide=True)
        beam(roads,"Elevated route rail",harbor_rail_point(0,1),harbor_rail_point(1,1),.20,DARK,collide=True)
        route(roads,name,points[1:-1],12,tone,railings=False)
        span,_,middle_grade,middle_point=clay_lantern_road_coordinates(*points[1:3])
        beam(roads,"Elevated route rail",middle_point(0,-6,middle_grade(0)+1.05),
             middle_point(span,-6,middle_grade(span)+1.05),.20,DARK,collide=True)
        build_clay_lantern_walk(roads,*points[1:3],item=item,prop=prop,part=part,beam=beam,
                                 triangle=triangle,path_edge=path_edge,sign=sign,swept_roof=swept_roof,
                                 festival_lantern=festival_lantern,garden_prop=garden_prop,
                                 vector=vector,asset=asset,
                                 cedar=WOOD_PLANK,slate=SLATE,limestone=LIMESTONE,brass=METAL,
                                 cedar_variant=LANDMARK_CEDAR,stone_variant=PROMENADE_STONE,
                                 variant_field=MATERIAL_VARIANT_FIELD)
        route(roads,name,points[-2:],12,tone,railings=False)
        glaze_terrace(roads,*points[-2:])
        build_cinder_harbor_road_relief(roads,points[2],points[1],item=item,prop=prop,
                                       part=part,triangle=triangle,garden_prop=garden_prop,
                                       rock=ROCK,sandstone=SANDSTONE,grass=GRASS_MAT,wood=WOOD_PLANK,
                                       rock_variant=VALLEY_ROCK,sandstone_variant=CINDER_STONE,
                                       variant_field=MATERIAL_VARIANT_FIELD)
    else:
        route(roads,name,points,12,tone)
    for index in range(0,len(points)-1):
        a,b=points[index:index+2]
        for t in (.28,.57,.83):
            px,py,pz=tuple(u+(v-u)*t for u,v in zip(a,b))
            lamp(roads,px+5.1,py+.93,pz,scale=.48)
    road_sign(roads,points[0],points[1],leaving,paint)
    road_sign(roads,points[-1],points[-2],returning,paint)

cloudstep_points=[
    (93.72,18.287,-212+CLOUDSTEP_CINDER_OFFSET),(90.2,18.287,-212+CLOUDSTEP_CINDER_OFFSET),
    (86.30,19.10,-221.65),(80.40,20.12,-229.5),(72.55,21.22,-233.50),(65.20,21.22,-235.10),
    (58.20,23.41,-237.1),(53.30,25.013,-239.20),(49.7,25.013,-239.20),(45.03,25.013,-239.20),
]
cloudstep_keeper=cloudstep_pass(roads,cloudstep_points)
mistline_west=[(-173.90,14.027,-178.80),(-159.10,14.027,-178.80),(-142.60,16.74,-181.80),
               (-121.50,19.52,-190.20),(-102.80,22.05,-202.00),(-83.04,25.08,-222.98),
               (-76.80,25.08,-224.50)]
mistline_east=[(-16.20,25.13,-239.30),(-9.90,25.046,-239.46),(-3.35,25.027,-240.05),
               (3.65,25.027,-240.36)]
mistline_deck=mistline_crossing(roads,mistline_west,mistline_east)
snowbell_path=build_snowbell_ridge(roads,mistline_west,item=item,prop=prop,part=part,beam=beam,
                                  triangle=triangle,path_edge=path_edge,sign=sign,festival_lantern=festival_lantern,
                                  vector=vector,asset=asset,cedar=WOOD_PLANK,slate=SLATE,rock=ROCK,
                                  snow=SNOW,brass=METAL,cedar_variant=LANDMARK_CEDAR,rock_variant=VALLEY_ROCK,
                                  variant_field=MATERIAL_VARIANT_FIELD)
build_snowbell_hollow(roads,item=item,prop=prop,part=part,triangle=triangle,garden_prop=garden_prop,
                      vector=vector,asset=asset,rock=ROCK,snow=SNOW,grass=LEAFY_GRASS,
                      rock_variant=VALLEY_ROCK,variant_field=MATERIAL_VARIANT_FIELD)
map_districts={"Grand Dojo City":(0,0,0), **{town[0]:tuple(town[1:4]) for town in towns}}
map_paths=[(name,[(0,0,0),*points,map_districts[town[0]]],False)
           for (name,points,_),town in zip(routes,towns)]
map_centers={name.upper():point for name,point in map_districts.items()}
map_paths.extend((name,[map_centers[returning],*points,map_centers[leaving]],True)
                 for name,points,_,leaving,returning,_ in crossroads)
map_paths.append(("Cloudstep Pass",[map_districts["Cinder Terraces"],(122,10,-186),(122,14.8,-212),
                                   (107.5,18.3,-212),(101.8,18.3,-209.55),*cloudstep_points,
                                   (34,25.027,-244.1),(22,25.027,-246),map_districts["Skywalk Peaks"]],True))
map_paths.append(("Mistline Crossing",[map_districts["Frostglass Gardens"],*mistline_west,*mistline_east,
                                      (22,25.027,-240.4),map_districts["Skywalk Peaks"]],True))
map_paths.append((SNOWBELL_RIDGE,[map_districts["Frostglass Gardens"],(-189,14.027,-164.90),
                                 (-182.75,14.036,-164.90),(-182.75,18.636,-178.72),
                                 (-182.96,18.624,-180.75),(-184.16,18.612,-182.12),
                                 (-184.38,18.701,-183.57),(-182.70,18.701,-183.57),
                                 (-170.78,21.53,-183.57),(-168.25,21.53,-183.57),
                                 (-168.25,21.53,-174.62),BALCONY_JOIN,*GLACIER_ASCENT,GLACIER_PAVILION,
                                 *snowbell_path,*mistline_west[MISTLINE_SEGMENT+1:],
                                 *mistline_deck[1:-1],*mistline_east,
                                 (22,25.027,-240.4),map_districts["Skywalk Peaks"]],True))
map_paths.append((ORCHARD_WALK,[map_districts["Grand Dojo City"],routes[4][1][0],
                               *ORCHARD_ASCENT,*ORCHARD_DESCENT,routes[4][1][-1],
                               map_districts["Lantern Circuit"]],True))
build_plum_lantern_walk(roads,item=item,prop=prop,part=part,triangle=triangle,beam=beam,
                        path_edge=path_edge,sign=sign,swept_roof=swept_roof,
                        festival_lantern=festival_lantern,garden_shelf=garden_shelf,
                        garden_prop=garden_prop,showcase_tree=showcase_tree,cedar=WOOD_PLANK,
                        slate=SLATE,stone=LIMESTONE,brass=METAL,grass=LEAFY_GRASS,
                        variant_field=MATERIAL_VARIANT_FIELD,cedar_variant=LANDMARK_CEDAR,
                        stone_variant=PROMENADE_STONE)
map_paths.append((SALTWIND_WALK,[map_districts["Grand Dojo City"],*CEDARBANK_PATH,
                                *SALTWIND_WALK_POINTS,*saltwind_descent,routes[0][1][-1],
                                map_districts["Tideharbor Coast"]],True))
map_paths.append((KILN_PASS,[map_districts["Cinder Terraces"],*reversed(routes[1][1][-2:]),
                            *KILN_RIDGE_PATH[:4],*KILN_PASS_POINTS,(47.9,rest_y,-142.50),
                            (46.9,rest_y,-141),(44.4,rest_y,-141),
                            (38,junction_y,-141),(22,junction_y,-141),*routes[2][1][2:],
                            map_districts["Skywalk Peaks"]],True))
build_crown_crossing(roads, item=item, prop=prop, part=part, beam=beam, triangle=triangle,
                     path_edge=path_edge, sign=sign, festival_lantern=festival_lantern,
                     garden_shelf=garden_shelf, garden_prop=garden_prop, sandstone=SANDSTONE,
                     slate=SLATE, cedar=WOOD_PLANK, grass=GRASS_MAT, metal=METAL,
                     paving_variant=SUNSET_FLAGSTONE, variant_field=MATERIAL_VARIANT_FIELD)
build_crown_crossing_markers(roads,item=item,prop=prop,part=part,beam=beam,
                             sign=sign,cedar=WOOD_PLANK,slate=SLATE,brass=METAL)
map_paths.append((CROWN_CROSSING,[map_districts["Grand Dojo City"],(42,.15,-16.4),
                                 (51.55,8.85,-45.08),(62.02,21.20,-52.4),
                                 (83.60,26.0,-49.62),(83.60,34.40,-78),
                                 *CROWN_CROSSING_POINTS,*CROWN_KILN_JOIN,*KILN_RIDGE_PATH[7:],*routes[1][1][2:],
                                 map_districts["Cinder Terraces"]],True))
build_meltwater_high_walk(roads,item=item,prop=prop,part=part,beam=beam,triangle=triangle,
                          path_edge=path_edge,sign=sign,swept_roof=swept_roof,
                          festival_lantern=festival_lantern,garden_shelf=garden_shelf,
                          garden_prop=garden_prop,showcase_tree=showcase_tree,
                          limestone=LIMESTONE,slate=SLATE,cedar=WOOD_PLANK,brass=METAL,
                          grass=GRASS_MAT,stone_variant=PROMENADE_STONE,
                          variant_field=MATERIAL_VARIANT_FIELD)
map_paths.append((MELTWATER_HIGH_WALK,[map_districts["Lantern Circuit"],
                                     (-249.20,6,38),(-249.20,10.80,13),(-249.20,13.27,-3.1),
                                     *MELTWATER_HIGH_POINTS,(-207,14.027,-151),
                                     map_districts["Frostglass Gardens"]],True))
map_paths.append((PLUM_LANTERN_WALK,[map_districts["Grand Dojo City"],routes[4][1][0],
                                    *PLUM_LANTERN_PATH,*routes[4][1][-2:],
                                    map_districts["Lantern Circuit"]],True))
city_map_board(plaza,map_districts,map_paths)
build_south_boundary(plaza, item=item, prop=prop, part=part, beam=beam, route=route,
                     swept_roof=swept_roof, festival_lantern=festival_lantern, sign=sign,
                     garden_shelf=garden_shelf, garden_prop=garden_prop, slate=SLATE,
                     wood=WOOD_PLANK, limestone=LIMESTONE, grass=GRASS_MAT, tree=tree)
build_south_ridge_trail(plaza, item=item, prop=prop, part=part, beam=beam,
                        path_edge=path_edge, triangle=triangle, sign=sign, swept_roof=swept_roof,
                        festival_lantern=festival_lantern, garden_shelf=garden_shelf,
                        garden_prop=garden_prop, tree=tree, slate=SLATE, limestone=LIMESTONE,
                        cedar=WOOD_PLANK, grass=GRASS_MAT, brass=METAL, rock=ROCK)

residents=item(scene,"Folder","City residents")
townsfolk=item(scene,"Folder","Ambient townsfolk")


def townsperson(parent,name,x,y,z,fur,coat,ears,yaw=0,*,species="bear",scale=1,guard=False,satchel=None,
               training_gloves=None):
    model=item(parent,"Model",name)
    prop(model,"token","ModelStreamingMode",1)
    parts=[
        ("Body",(0,1.92,0),(1.39,1.49,1.04),coat,0),
        ("Collar",(0,2.44,-.18),(.82,.27,.91),"EBC092",0),
        ("Hip wrap",(0,1.34,0),(1.17,.44,.94),coat,1),
        ("Hem",(0,1.47,-.45),(1.15,.16,.12),"C0894B",1),
        ("Head",(0,2.99,-.04),(1.30,1.13,1.05),fur,0),
        ("Muzzle",(0,2.82,-.55),(.82,.46,.51),CREAM,0),
        ("Nose",(0,2.94,-.78),(.24,.17,.11),INK,0),
    ]
    if guard:
        parts.extend([
            ("Training headband",(0,3.25,-.13),(1.20,.19,1.08),coat,0),
            ("Training belt",(0,1.52,0),(1.34,.22,1.11),"E2A75B",0),
        ])
    if satchel:
        parts.extend([
            ("Canvas satchel",(0,1.92,.66),(.80,.96,.51),satchel,1),
            ("Folded satchel flap",(0,2.31,.75),(.88,.22,.61),"A57654",1),
            ("Satchel brass clasp",(0,2.13,.933),(.22,.17,.081),GOLD,1),
        ])
        for side in (-1,1):
            parts.append(("Canvas shoulder strap",(side*.31,2.01,-.463),(.135,.87,.115),"B18F63",1))
    if species=="tortoise":
        parts.extend([("Shell",(0,1.93,.45),(1.55,1.48,.94),"586A38",0),
                      ("Shell ridge",(0,1.95,.85),(.75,1.07,.22),"9E9250",0)])
    elif species in ("fox","otter","red panda"):
        length=.92 if species=="otter" else .72
        parts.extend([("Tail",(.48,.87,.60),(.63,.62,length),fur,0),
                      ("Tail tip",(.66,.82,.91),(.51,.42,.63),CREAM,0)])
    guard_size=(.69,.70,.73) if training_gloves else (.58,.60,.60)
    for side,prefix in ((-1,"Left"),(1,"Right")):
        sleeve=(side*.61,2.07,-.24) if guard else (side*.67,1.94,-.003)
        paw=(side*.53,2.35,-.59) if guard else (side*.77,1.66,-.10)
        parts.extend([
            (f"{prefix} Sleeve",sleeve,(.43,.76,.52),coat,0),
            (f"{prefix} Paw",paw,guard_size if guard else (.42,.53,.5),
             (training_gloves or coat) if guard else fur,0),
            (f"{prefix} Shin",(side*.33,.84,0),(1.04,.43,.48),coat,2),
            (f"{prefix} Foot",(side*.33,.31,-.12),(.56,.61,.76),fur,0),
            (f"{prefix} Eye",(side*.28,3.16,-.51),(.12,.187,.11),INK,0),
            (f"{prefix} Eye glint",(side*.28-.018,3.20,-.56),(.039,.052,.02),CREAM,0),
        ])
        if species in ("hare","fox"):
            ear_x=side*.40
            ear_y=3.36+ears*.39
            parts.extend([("Ear",(ear_x,ear_y,-.03),(ears,.37,.32),fur,2),
                          ("Ear tip",(ear_x,ear_y+ears*.47,-.03),(.37,.35,.32),fur,0),
                          ("Ear inset",(ear_x,ear_y+.04,-.179),(ears*.72,.18,.065),"CC927B",2)])
        elif species!="tortoise":
            parts.extend([("Ear",(side*.45,3.36+ears*.13,-.03),(.44,ears,.38),fur,0),
                          ("Ear inset",(side*.45,3.36+ears*.13,-.205),(.24,.24,.082),"CC927B",0)])
        if species=="red panda":
            parts.append(("Cheek",(side*.45,2.99,-.48),(.46,.38,.21),"F4D0A7",0))
    anchor=part(model,"PoseOrigin",(x,y,z),(.20,.20,.20),STONE,yaw=yaw,collide=False,transparency=1)
    prop(model,"Ref","PrimaryPart",anchor.get("referent"))
    c,s=cos(radians(yaw)),sin(radians(yaw))
    for label,(dx,dy,dz),size,tint,shape in parts:
        part(model,label,(x+(dx*c+dz*s)*scale,y+dy*scale,z+(-dx*s+dz*c)*scale),
             tuple(v*scale for v in size),tint,yaw=yaw,roll=90 if shape==2 else 0,
             shape=shape,collide=False)
    return model


def resident(name,greeting,x,y,z,fur,coat,ears,yaw=0,*,species="bear"):
    model=townsperson(residents,name,x,y,z,fur,coat,ears,yaw,species=species)
    speaker=part(model,"GreetingAnchor",(x,y+2.7,z),(.23,.23,.23),STONE,collide=False,transparency=1)
    prompt=item(speaker,"ProximityPrompt","Talk")
    prop(prompt,"string","ActionText","Say hello")
    prop(prompt,"string","ObjectText",name)
    prop(prompt,"float","MaxActivationDistance",9)
    prop(prompt,"bool","RequiresLineOfSight",False)
    line=item(model,"StringValue","Greeting")
    prop(line,"string","Value",greeting)


resident("Reed Market Guide","The road east leads from Reed Market to Tideharbor Coast.",
         17,.15,38,"A87A56","4B756B",.39,158,species="otter")
resident("Lantern Tender","The gold trail marks the relay. Follow jade stones toward Trophy Hall after the finish.",
         -48,.15,28,"BD936F","773E63",1.02,177,species="hare")
resident("Lantern Gardener","The garden walk climbs to Garden Lookout. Follow the lower stones toward the red bridge and Lantern Relay.",
         *GARDENER,"A77B57","69794D",.49,7,species="red panda")
resident("Tower Keeper","You can watch the relay gates from here. Take the cedar ramp or the stairs back to Garden Lookout.",
         -55.55,tower_deck,22.71,"BC744E","745879",.48,170,species="red panda")
resident("Orchard Keeper","The lower road leads to Grand Dojo. Take the west ramp and follow the lanterns to Lantern Circuit.",
         *ORCHARD_KEEPER,"B57D64","705884",.48,180,species="red panda")
resident("Tidewatch Keeper","The west ramp meets the Cinder road. Go east to Beacon Terrace for Harbor Sky Pier and the loop down to Lantern Quay.",
         *TIDEWATCH_KEEPER,"AA805E","3F7773",.40,173,species="otter")
resident("Ring Steward","Climb the steps to the ring. Try three strikes on the practice target.",
         49.2+ring_offset,ring_floor,15.5,"8C736D","3F535E",.40,109)
resident("Trophy Archivist","The center pedestal is yours. Finish an official Lantern Relay to light it.",
         -10,3.61,-40,"91A16C","6B6540",.3,180,species="tortoise")
resident("Gallery Curator","Look down to see your Lantern Keeper trophy. Finish an official relay to earn it.",
         5.36,10.17,-53.27,"C09165","7F536D",.43,175,species="red panda")
resident("Cascade Lookout Keeper","Take the cedar ramp to Reedfall Crown, or head down to Reedfall Gallery for the plaza and the Cinder road.",
         *cascade_keeper,"9F785E","416D60",.52,145,species="otter")
resident("Reed Market Merchant","Follow the jade sign east to Weavers’ Walk. Its far ramp meets the Tideharbor road.",
         70,.15,-21,"AE684A","783745",.69,175,species="red panda")
resident("Reed Weaver","I weave the colored banners here. The east ramp takes you down to the Tideharbor road.",
         101.49,7.395,-32.56,"BD956D","3D8072",.79,158,species="hare")
resident("Wind Rest Host","The cedar bridge leads up to Wind Court. Take Kiln Pass east to Kiln Ridge and the Cinder road, or follow the lower path down to the creek.",
         56.1,rest_y,-139.43,"AAB0B0","676180",.47,189,species="bear")
for (name,x,y,z,yaw,accent,paving,sign_name),(title,line,fur,ears) in zip(towns,[
    ("Harbor Steward","Follow the Beacon boardwalk up to Harbor Sky Pier. Lantern Quay loops back to the pier. Take the north road for Cinder Terraces.","90634C",.36),
    ("Kiln Steward","Head west to Potters’ Yard. Copper Kiln Walk climbs above the workshops to Glaze Terrace, and Cloudstep Pass leads to Skywalk Peaks.","A96651",.51),
    ("Wind Court Keeper","Ring Reed, Cloud, then Summit at Wind Court. Cloudstep Pass leads to Cinder, and Mistline Crossing leads to Frostglass.","CEA67C",.65),
    ("Garden Keeper","Climb above Pond Terrace to Glacier Lantern Pavilion. Take Snowbell Ridge to Mistline Crossing for Skywalk Peaks, or follow the ramp down to Mistline Vista.","ADAEB2",.51),
    ("Night Market Steward","Follow Lantern Gallery to the upper stalls. Lantern Skyline Walk loops back by the Overlook ramp. Take the north road for Frostglass Gardens.","AD805C",.83),
]):
    resident(title,line,x+6,y,z+2,fur,accent,ears,180)
resident("Quay Ropekeeper","The lanterns lead uphill to the beacon. Take the far boardwalk back to the square.",
         275.46,4.585,46.85,"9E795B","367C79",.52,177,species="otter")
resident("Lantern Maker","Turn south at the Frostglass High Walk fork for Lantern Skyline Walk. The pavilion path leads back to the street.",
         -237.6,13.27,-8.1,"C78E61","763F70",.49,170,species="red panda")
resident("Lantern Calligrapher","The market strings are below us. Follow this ramp down to the shops or the road back to the Grand Dojo.",
         *CALLIGRAPHER,"BA896B","75546E",.52,185,species="hare")
resident("Cloudstep Guide","The steps and gardens below belong to Cinder. Follow the upper rail to Wind Court.",
         *cloudstep_keeper,"AD997A","5A687D",.55,153,species="otter")
resident("Glaze Potter","Clay from these hills turns copper-red in the kiln. The back ramp forks to Copper Kiln Walk and Cinder Square. The front slope leads toward Tideharbor.",
         197.16,15.8,-182.00,"AE7758","675A6E",.52,93,species="red panda")


def roaming_townsperson(name,points,fur,coat,ears,species,speed,phase,scale=1,*,return_walk=False,satchel=None):
    yaw=180
    if return_walk:
        dx=points[1][0]-points[0][0]
        dz=points[1][2]-points[0][2]
        yaw=degrees(atan2(-dx,-dz))
        points=[*points,*points[-2:0:-1]]
    model=townsperson(townsfolk,name,*points[0],fur,coat,ears,yaw,species=species,scale=scale,satchel=satchel)
    route_folder=item(model,"Folder","Walk route")
    for index,point in enumerate(points,1):
        marker=item(route_folder,"Vector3Value",f"{index:02}")
        vector(marker,"Vector3","Value",("X","Y","Z"),point)
    for name,value in (("Pace",speed),("Phase",phase)):
        setting=item(route_folder,"NumberValue",name)
        prop(setting,"double","Value",value)
    if return_walk:
        prop(item(route_folder,"NumberValue","Pass-through pause"),"double","Value",.065)


roaming_townsperson("Festival Traveler",[(4,.15,45),(5,.15,31),(1,.15,22),(-4,.15,32),(-5,.15,49),(-.8,.15,58.6)],
                   "B57749","357D76",.60,"fox",5.8,2,1.13)
roaming_townsperson("Canal Gardener",[(-7,.15,34),(-8,.15,23),(-7.8,.15,12),(-3.8,.15,19),(-2,.15,31)],
                   "89945D","B77552",.35,"tortoise",4.4,8,1)
roaming_townsperson("Festival Visitor",[(-28,.15,26),(-28,.15,15),(-30,.15,4),(-34,.15,12),(-32,.15,25)],
                   "D0A37A","954F71",1.17,"hare",5.0,4,1.02)
roaming_townsperson("Lantern Courier",canal_bridge_walk[::-1],"D5AA71","3A827A",.58,"fox",4.4,1.7,.99,
                   return_walk=True,satchel="9A573D")
roaming_townsperson("Gallery Attendant",[(11.79,10.186,-40.25),(11.79,10.186,-47.78),
                   (11.79,10.17,-51.71),(1.26,10.17,-51.71),(-10.25,10.17,-51.71)],
                   "BC805B","755B81",.46,"red panda",4.0,2.5,.97,return_walk=True,satchel="71604E")
roaming_townsperson("Mistline Messenger",mistline_deck[-2:0:-1],"D2AF8D","526C8A",.91,"hare",4.9,3.1,1.05,
                   return_walk=True,satchel="785D4E")
roaming_townsperson("Market Porter",[(68,.15,-12),(67,.15,-24),(70,.15,-39),(71.4,.15,-28),(70.2,.15,-17)],
                   "933F37","69967C",.55,"red panda",5.2,5,1.02)
for name,x,z,yaw,fur,coat,gloves,ears,species,scale,phase in (
    ("Copper Court Trainee",36.60,14.45,-66.32,"DC935D","C26943","E37A39",.52,"red panda",1.26,0),
    ("Jade Court Trainee",41.30,12.39,113.68,"BFC8C9","377D7D","63BBB0",.48,"bear",1.30,3.4),
):
    trainee=townsperson(townsfolk,name,x+ring_offset,ring_floor,z,fur,coat,ears,yaw,
                        species=species,scale=scale,guard=True,training_gloves=gloves)
    offset=item(trainee,"NumberValue","Drill phase")
    prop(offset,"double","Value",phase)
roaming_townsperson("Harbor Boatkeeper",[(219,3,17),(223,3,31),(228,3,40),(234,3,40),(226,3,37),(215,3,36)],
                   "A87654","428478",.38,"otter",5,3,1.1)
for (name,x,y,z,yaw,accent,paving,sign_name),(title,fur,ears,species,phase) in zip(towns[1:],[
    ("Kiln Apprentice","AD8D55",.3,"tortoise",1),
    ("Wind Court Student","E5B288",1.01,"hare",9),
    ("Garden Walker","BDADB0",.53,"fox",4),
    ("Festival Courier","BC794C",.69,"red panda",8),
]):
    turns=((-1.65,14.4),(2.42,11),(2.40,3),(.20,.8),(-1.48,7.0)) if title=="Garden Walker" else (
        (-4,13),(2,9),(4,2),(0,-4),(-5,2))
    roaming_townsperson(title,[(x+dx,y,z+dz) for dx,dz in turns],
                       fur,accent,ears,species,4.7,phase,1.07)

storage=item(root,"ReplicatedStorage","ReplicatedStorage")
item(storage,"RemoteEvent","GrandDojoAction")
item(storage,"RemoteEvent","GrandDojoSparring")
server_storage=item(root,"ServerStorage","ServerStorage")
townsperson(server_storage,"Juniper Tortoise",spar_x+ring_offset,ring_floor,-2.2,
           "AAB272","397569",0,species="tortoise",scale=1.36,guard=True)
map_canvas(storage,map_districts,map_paths)
city_route_data(storage,map_districts,map_paths)

opening=item(root,"ReplicatedFirst","ReplicatedFirst")
splash_art=item(opening,"StringValue","SplashArtwork")
prop(splash_art,"string","Value","rbxassetid://128322278825644")
splash_gate=item(opening,"Model","Splash Gate")
# A small version of the portal made from early-replicated native geometry.
part(splash_gate,"Slate courtyard", (0,.02,-1.1), (23,.65,10), "63546A",collide=False)
part(splash_gate,"Sandstone threshold",(0,.48,-.63),(20.8,.38,7.1),"9A7780",collide=False)
for step in range(4):
    part(splash_gate,"Slate entrance tread",(0,.13+step*.17,4.50-step*.78),
         (11.9-step*.48,.23+step*.33,.86),("745E6D","887184")[step%2],collide=False)
for side in (-1,1):
    x=side*7.7
    for label,y,size,tint in (
        ("Slate pier",1.35,(3.40,1.65,3.0),"71657E"),
        ("Sandstone cap",2.20,(3.8,.36,3.3),"A58A94"),
        ("Lacquered column",5.24,(2.10,5.90,2.0),"9A3B32"),
        ("Lacquer face",5.28,(1.31,5.61,.13),"BA5239"),
        ("Gilded collar",2.55,(2.36,.29,2.28),"D69850"),
        ("Cedar corbel",8.15,(3.15,.60,3.0),"71372F"),
    ):
        part(splash_gate,label,(x,y,1.03 if label=="Lacquer face" else 0),size,tint,collide=False)
    beam(splash_gate,"Cedar brace",(x,7.0,.55),(x-side*2.30,8.65,.55),.43,"853F30")
    festival_lantern(splash_gate,x-side*1.87,6.48,1.12,.93,light=False,tint="FFD382")
part(splash_gate,"Lacquer crest plaque",(0,8.38,.73),(15.2,2.42,1.22),"813632",collide=False)
part(splash_gate,"Milled gold trim",(0,7.15,1.1),(15.6,.21,.32),"DA9B55",collide=False)
reed_mark(splash_gate,0,8.30,1.36,1.02)
for left,right in zip((-10.5,-8.8,-6.3,-3.25,0,3.25,6.3,8.8),(-8.8,-6.3,-3.25,0,3.25,6.3,8.8,10.5)):
    a=10.02+1.30*(abs(left)/10.5)**3
    b=10.02+1.30*(abs(right)/10.5)**3
    angle=degrees(atan2(b-a,right-left))
    midpoint=(left+right)/2
    part(splash_gate,"Indigo roof tile course",(midpoint,(a+b)/2,-.58),
         (hypot(right-left,b-a)+.16,.58,4.95),"335184",roll=angle,collide=False)
    part(splash_gate,"Gold roof edge",(midpoint,(a+b)/2-.21,1.92),
         (hypot(right-left,b-a)+.12,.15,.14),"CE8D4B",roll=angle,collide=False)
for x in (-10.15,10.15):
    part(splash_gate,"Bronze roof tip",(x,11.13,-.48),(.72,.44,5.03),
         "D69753",roll=18 if x>0 else -18,collide=False)

prize=item(storage,"Model","LanternKeeperTrophy")
part(prize,"Walnut base",(0,.32,0),(2.7,.64,2.7),DARK,material=WOOD_PLANK,collide=False)
part(prize,"Brass plate",(0,.35,1.37),(1.7,.33,.09),GOLD,collide=False)
part(prize,"Gold pedestal",(0,.79,0),(1.9,.31,1.9),GOLD,collide=False)
part(prize,"Golden lantern",(0,1.66,0),(1.38,1.48,1.38),"FFCB66",material=NEON,collide=False)
for x in (-.71,.71):
    for z in (-.71,.71):
        part(prize,"Brass frame",(x,1.66,z),(.15,1.57,.15),GOLD,collide=False)
part(prize,"Trophy cap",(0,2.42,0),(1.86,.28,1.86),GOLD,collide=False)
part(prize,"Trophy finial",(0,2.66,0),(.51,.39,.51),AMBER,shape=0,collide=False)

starter=item(root,"StarterPlayer","StarterPlayer")
prop(starter,"bool","LoadCharacterAppearance",False)
prop(starter,"float","CharacterWalkSpeed",17)
prop(starter,"float","CameraMinZoomDistance",7)
prop(starter,"float","CameraMaxZoomDistance",23)
scripts=item(starter,"StarterPlayerScripts","StarterPlayerScripts")
rig_file=ROOT/"design/fighters/boxing-kangaroo/ReedguardKangaroo_Prototype.rbxmx"
rig=copy.deepcopy(ET.parse(rig_file).getroot().find("Item"))
rig.find("Properties/string[@name='Name']").text="StarterCharacter"
parts_by_ref={p.attrib["referent"]:p for p in rig.findall("Item[@class='Part']")}
outfit_colors={
    "Belt":"7E332C", "Belt knot":"B0553A", "Belt end A":"8B372F", "Belt end B":"A54A36",
    "Reed shoulder guard":"385A51", "Reed brace 1":"C59C64", "Reed brace 2":"CEAB78", "Reed brace 3":"C59C64",
}
for side in ("Left","Right"):
    outfit_colors[f"{side} cuff"]="78382E"
    outfit_colors[f"{side} wrapped fist"]="943F32"
    outfit_colors[f"{side} wrap stripe"]="BB6447"
for body in parts_by_ref.values():
    properties=body.find("Properties")
    name=properties.find("string[@name='Name']").text
    for property_name in ("Anchored", "CanCollide"):
        old_property=properties.find(f"bool[@name='{property_name}']")
        if old_property is not None:
            properties.remove(old_property)
    prop(body,"bool","Anchored",False)
    prop(body,"bool","CanCollide",name in {"Torso", "Head"})
    if name=="HumanoidRootPart":
        massless=properties.find("bool[@name='Massless']")
        if massless is not None:
            massless.text="false"
    if name in outfit_colors:
        properties.find("Color3uint8[@name='Color3uint8']").text=str(0xFF000000+int(outfit_colors[name],16))
for motor in rig.findall("Item[@class='Motor6D']"):
    parent_ref=motor.find("Properties/Ref[@name='Part0']").text
    hip_side={"Left Hip":-1,"Right Hip":1}.get(motor.findtext("Properties/string[@name='Name']"))
    if hip_side:
        # Stock R6 clips expect opposite 90-degree yaw on the hips. Rotate
        # both joint frames together so the prototype keeps its rest pose.
        for joint_frame in motor.findall("Properties/CoordinateFrame"):
            for row in range(3):
                across=joint_frame.find(f"R{row}0")
                forward=joint_frame.find(f"R{row}2")
                old_across=float(across.text)
                across.text=f"{-hip_side*float(forward.text):.7g}"
                forward.text=f"{hip_side*old_across:.7g}"
    rig.remove(motor)
    parts_by_ref[parent_ref].append(motor)
rig_parts={p.findtext("Properties/string[@name='Name']"):p for p in parts_by_ref.values()}


def rig_detail(parent_name, name, xyz, size, tint, *, roll=0, shape=1, material=FABRIC, variant=None):
    detail=part(rig,name,xyz,size,tint,roll=roll,shape=shape,
                material=material,collide=False,anchored=False)
    prop(detail,"bool","Massless",True)
    prop(detail,"bool","CastShadow",min(size)>=.14)
    if variant:
        prop(detail,"string",MATERIAL_VARIANT_FIELD,variant)
    weld=item(detail,"WeldConstraint","Outfit weld")
    prop(weld,"Ref","Part0",rig_parts[parent_name].get("referent"))
    prop(weld,"Ref","Part1",detail.get("referent"))


rig_detail("Torso","Walnut training overskirt",(0,1.49,.04),(1.69,.62,1.20),"50342E",variant=ARENA_WEAVE)
rig_detail("Torso","Layered waist sash",(0,1.82,.34),(1.69,.23,.68),"84333B",variant=ARENA_WEAVE)
rig_detail("Torso","Warm waist seam",(0,1.91,.686),(1.60,.036,.033),"AD6852")
rig_detail("Torso","Cross-body woven harness",(.044,2.65,.602),(1.82,.365,.20),"8D6847",
           roll=38,variant=ARENA_WEAVE)
sash_angle=radians(38)
for tangent in (-.154,.154):
    rig_detail("Torso","Harness edge binding",(.044-sin(sash_angle)*tangent,2.65+cos(sash_angle)*tangent,.714),
               (1.81,.047,.055),"B78A57",roll=38)
for index in range(10):
    position=-.78+index*.171
    rig_detail("Torso","Woven harness stitch",
               (.044+position*cos(sash_angle),2.65+position*sin(sash_angle),.717),
               (.091,.280,.070),("CE9A63","D7AB75","C4925D")[index%3],roll=34+8*(index%2),shape=0)

for side,sign in (("Left",-1),("Right",1)):
    x=sign*.39
    rig_detail("Torso","Split vermilion tabard",(x,1.486,.674),(.61,.86,.115),"7B2B34",
               roll=sign*5,variant=ARENA_WEAVE)
    rig_detail("Torso","Tabard hem",(x+.03*sign,1.083,.740),(.581,.061,.034),"C18F62",roll=sign*5)
    rig_detail("Torso","Tabard edge stitching",(x+sign*.238,1.491,.741),(.037,.75,.028),"A55E51",roll=sign*5)
    for dx,dy,height,lean in ((-.10,.016,.39,-29),(.009,.066,.41,-35),(.109,.032,.30,-43)):
        rig_detail("Torso","Gold reed embroidery",(x+dx,1.428+dy,.750),(.049,height,.031),
                   "DDB780",roll=lean,shape=0)

    shoulder_x=sign*1.015
    rig_detail(f"{side} Arm","Rounded shoulder padding",(shoulder_x,3.155,.034),(.89,.60,.73),
               "C08750",roll=-sign*9,shape=0,material=SMOOTH)
    fist=rig_parts[f"{side} wrapped fist"]
    coords=fist.find("Properties/CoordinateFrame[@name='CFrame']")
    x,y,z=(float(coords.findtext(k)) for k in ("X","Y","Z"))
    rig_detail(f"{side} Arm","Padded boxing wrap",(x+sign*.039,y,z),(.96,.72,.91),"8B3632",
               shape=0,variant=ARENA_WEAVE)
    for row,dy in enumerate((-.205,-.058,.093,.233)):
        rig_detail(f"{side} Arm","Overlapping knuckle wrap",(x+sign*.036,y+dy,z),(.942,.111,.876),
                   ("9B4438","A64A3B","954038","AA5140")[row],roll=sign*(3+row%2*2),variant=ARENA_WEAVE)
    for index in range(3):
        rig_detail(f"{side} Leg","Tied ankle wrap",(sign*.57,.54+index*.086,-.093),(.538,.078,.591),
                   ("8E4936","A35A42","B57653")[index],roll=-sign*4,shape=0)
    rig_detail(f"{side} Leg","Ankle wrap knot",(sign*.806,.62,-.121),(.135,.122,.170),"B7754D",shape=0)

for index in range(6):
    x=.797+index*.117
    rig_detail("Right Arm","Woven shoulder reed",(x,3.429+(x-1.10)*.12,.086),(.084,.111,.715),
               ("C99D67","DAB07B")[index%2],roll=7,shape=0,material=SMOOTH)
rig_detail("Right Arm","Shoulder guard leather binding",(1.103,3.284,.478),(.825,.083,.094),
           "8D684D",roll=7)
rig_detail("Head","Short ear woven tie",(-.357,4.724,.040),(.350,.089,.272),
           "AC7147",roll=25,shape=0)
for transform in rig.iter("CoordinateFrame"):
    for axis in ("X","Y","Z"):
        coordinate=transform.find(axis)
        coordinate.text=f"{float(coordinate.text)*.82:.7g}"
for size in rig.iter("Vector3"):
    if size.attrib.get("name","").lower()=="size":
        for axis in ("X","Y","Z"):
            coordinate=size.find(axis)
            coordinate.text=f"{float(coordinate.text)*.82:.7g}"
humanoid=rig.find("Item[@class='Humanoid']")
prop(humanoid,"float","HipHeight",.14)
humanoid.find("Properties/float[@name='WalkSpeed']").text="17"
starter.append(rig)
brass_details={"Gold canopy fascia","Rope post tip","Rope binding","Ring marquee brass trim",
               "Porch brass collar","Marquee brass casting","Cup rolled rim","Beveled gold cup",
               "Rounded champion cup handle","Brass ridge binding","Brass ridge shoe","Gilded ridge finial"}
cedar_details={"Portal cedar column","Lacquer face panel","Lacquered pavilion pillar","Pillar inset panel",
               "Portico vermilion column","Portico column inset","Cedar pillar inset","Tall balcony pier"}
for landmark in (ring,hall,relay_portal,relay_skyline):
    for detail in landmark.iter("Item"):
        props=detail.find("Properties")
        name=props.findtext("string[@name='Name']")
        if name in brass_details:
            props.find("token[@name='Material']").text=str(METAL)
            prop(detail,"string",MATERIAL_VARIANT_FIELD,ORNAMENT_BRASS)
        if name in cedar_details:
            material=props.find("token[@name='Material']")
            assert material.text==str(WOOD_PLANK) or props.findtext("bool[@name='CanCollide']")=="false"
            material.text=str(WOOD_PLANK)
            prop(detail,"string",MATERIAL_VARIANT_FIELD,LANDMARK_CEDAR)
server=item(root,"ServerScriptService","ServerScriptService")
item(server,"BindableEvent","SparringWon")
for parent,class_name,name,file in [(server,"Script","GrandDojoServer","GrandDojo.server.luau"),
                                    (server,"Script","GrandDojoSparring","GrandDojoSparring.server.luau"),
                                    (server,"Script","CloudbreakTrial","CloudbreakTrial.server.luau"),
                                    (server,"Script","FrostglassReflectorLogic","FrostglassReflectors.server.luau"),
                                    (server,"ModuleScript","SparringRound","SparringRound.luau"),
                                    (server,"ModuleScript","PlayerProfiles","PlayerProfiles.luau"),
                                    (storage,"ModuleScript","MusicPlaylist","MusicPlaylist.luau"),
                                    (storage,"ModuleScript","TrophyJournal","TrophyJournal.luau"),
                                    (storage,"ModuleScript","EagleEye","EagleEye.luau"),
                                    (opening,"LocalScript","GrandDojoSplash","GrandDojoSplash.client.luau"),
                                    (scripts,"LocalScript","GrandDojoClient","GrandDojo.client.luau"),
                                    (scripts,"LocalScript","GrandDojoMusic","GrandDojoMusic.client.luau"),
                                    (scripts,"LocalScript","FrostglassReflectorDisplay","FrostglassReflectors.client.luau"),
                                    (scripts,"LocalScript","GrandDojoTownLife","GrandDojoTownLife.client.luau"),
                                    (scripts,"LocalScript","SouthRidgeBirds","SouthRidgeBirds.client.luau"),
                                    (scripts,"LocalScript","GrandDojoFireworks","GrandDojoFireworks.client.luau")]:
    script=item(parent,class_name,name)
    prop(script,"ProtectedString","Source",(HERE/file).read_text())
ET.indent(root, space="  ")
ET.ElementTree(root).write(OUTPUT, encoding="utf-8", xml_declaration=True)
print(f"{OUTPUT.name}: {sum(1 for _ in root.iter('Item'))} Roblox instances")
