"""Authored flagstone layout shared by the Studio and Blender builders."""
from math import ceil, hypot
import random

PROMENADE_BOUNDS=(-12,18,-8,82)
PROMENADE_GRADE=.15
ORIGINAL_SOUTH_EDGE=70
INLET_EDGE, INLET_NORTH, INLET_SOUTH = -4, 48, 60
# Preserve the established hand-cut pattern when the shoreline moves.
FLAGSTONE_PATTERN_EDGE = -8
ARRIVAL_LAMPS=((-10.57,71.16),(14.63,71.84))
LANTERN_SPILL=((-8,42,7.9,10.7),(11,37,8.5,11.1),(-8.9,33.7,5.4,8.6),(9.6,61.8,7.4,9.5),
               *((x,z,7.8,10.0) for x,z in ARRIVAL_LAMPS))
DAMP_POOLS = ((-1.7, 52.7, 7.3, 5.5), (9.4, 58.9, 7.2, 6.0), (8.1, 42.5, 5.3, 8.5))


def promenade_sections(bounds=PROMENADE_BOUNDS):
    left,right,north,south=bounds
    return ((INLET_EDGE,right,north,south),
            (left,INLET_EDGE,north,INLET_NORTH),
            (left,INLET_EDGE,INLET_SOUTH,south))


def clip_polygon(poly, distance):
    if not poly:
        return poly
    result=[]
    before=poly[-1]
    d_before=distance(before)
    for current in poly:
        d_current=distance(current)
        if (d_before<=0)!=(d_current<=0):
            t=d_before/(d_before-d_current)
            result.append(tuple(a+(b-a)*t for a,b in zip(before,current)))
        if d_current<=0:
            result.append(current)
        before,d_before=current,d_current
    return result


def trim_inlet(poly, edge=INLET_EDGE):
    if (min(x for x,_ in poly)>=edge or max(z for _,z in poly)<=INLET_NORTH
        or min(z for _,z in poly)>=INLET_SOUTH):
        return [poly]
    west=clip_polygon(poly,lambda point:point[0]-edge)
    return [clip_polygon(poly,lambda point:edge-point[0]),
            clip_polygon(west,lambda point:point[1]-INLET_NORTH),
            clip_polygon(west,lambda point:INLET_SOUTH-point[1])]


def smooth_falloff(value):
    """Ease a blend across a lit or shaded band."""
    weight=max(0,min(1,value))
    return weight*weight*(3-2*weight)


def promenade_dampness(point):
    x, z = point
    return max(smooth_falloff(1 - hypot((x - cx) / rx, (z - cz) / rz))
               for cx, cz, rx, rz in DAMP_POOLS)


def stone_pigment(pigment, point):
    x,z=point
    amber=max(smooth_falloff(1-hypot((x-lx)/reach_x,(z-lz)/reach_z))
              for lx,lz,reach_x,reach_z in LANTERN_SPILL)
    sunset=smooth_falloff((x+4+(z-48)*.09)/17)
    inlet=smooth_falloff((z-INLET_NORTH+2)/4)*smooth_falloff((INLET_SOUTH+2-z)/4)
    bank=-12+(INLET_EDGE+12)*inlet
    canal=smooth_falloff(1-abs(x-bank)/9)*smooth_falloff((66-z)/6)
    # Broad light between the buildings and softer contact color by the garden edges.
    arrival=smooth_falloff((z-27)/17)
    golden_lane=arrival*smooth_falloff(1-abs(x-3.2+(z-52)*.15)/9.5)
    garden_shadow=arrival*max(smooth_falloff((x-9.0)/6.6),
                              smooth_falloff((bank+3.3-x)/3.6))
    damp = promenade_dampness(point)
    glint = damp * smooth_falloff(1 - abs(x - 8.9 - (z - 53) * .12) / 3.8)
    channels=(int(pigment[i:i+2],16) for i in (0,2,4))
    tints=(base+rose+sunset*sun+amber*warm+canal*cool+golden_lane*glow-garden_shadow*shade
           -damp*wet+glint*gleam for base,rose,sun,warm,cool,glow,shade,wet,gleam in zip(
               channels,(8,-4,4),(16,4,-6),(59,25,-16),(-12,-7,14),(14,12,6),(21,17,11),
               (25,28,24),(26,17,8)))
    return "".join(f"{round(min(255,max(0,value))):02X}" for value in tints)


def polygon_area(region):
    return abs(sum(x * nz - z * nx for (x, z), (nx, nz) in zip(region, region[1:] + region[:1]))) * .5


def split_arrival_stone(region, area, source):
    """Break oversize arrival slabs along an off-center, slightly skewed joint."""
    cx, cz = (sum(point[axis] for point in region) / len(region) for axis in (0, 1))
    if not (-10.4 < cx < 16.8 and 35 < cz < 77 and area >= 10.4):
        return [region]
    reach_x, reach_z = (max(coords) - min(coords) for coords in zip(*region))
    slant = source.uniform(-.40, .40)
    # Cut across the longer span, with the smaller component setting the angle.
    nx, nz = (1, slant) if reach_x >= reach_z else (slant, 1)
    bias = source.uniform(-.17, .17)

    def cut(point):
        return (point[0] - cx) * nx + (point[1] - cz) * nz - bias

    pieces = [clip_polygon(region, cut), clip_polygon(region, lambda point: -cut(point))]
    if any(polygon_area(piece) < area * .32 for piece in pieces):
        return [region]
    return pieces


def flagstones(bounds=PROMENADE_BOUNDS):
    """Yield the color, outer shoulder and inset face of each sandstone block."""
    x_min,x_max,z_min,z_max=bounds
    source=random.Random(645)
    arrival_source=random.Random(773)
    split_source=random.Random(1581)
    palettes=("C19B93","BA9695","AA8D91","BB9389","CCA795","AE9194","B59591","BD9D95")
    bounds=[(x_min,z_min),(x_max,z_min),(x_max,z_max),(x_min,z_max)]
    across=8
    rows=19
    step_x=(x_max-x_min)/across
    south_edge=min(ORIGINAL_SOUTH_EDGE,z_max)
    step_z=(south_edge-z_min)/rows
    added_rows=ceil((z_max-south_edge)/step_z)
    centers=[]
    for row in range(rows+added_rows):
        placement=source if row<rows else arrival_source
        for column in range(across):
            x=x_min+(column+.5+(.20 if row%2 else -.20))*step_x
            z=z_min+(row+.5)*step_z
            centers.append((x+placement.uniform(-.24,.24)*step_x,z+placement.uniform(-.31,.31)*step_z))

    def clip(poly, center, neighbor):
        # Keep the side of the perpendicular bisector closest to this stone.
        dx,dz=(b-a for a,b in zip(center,neighbor))
        cross=((center[0]+neighbor[0])*dx+(center[1]+neighbor[1])*dz)/2
        return clip_polygon(poly,lambda point:point[0]*dx+point[1]*dz-cross)

    for center in centers:
        poly=bounds
        for neighbor in centers:
            if center!=neighbor:
                poly=clip(poly,center,neighbor)
        trim=source.uniform(.956,.979)
        height=PROMENADE_GRADE+source.uniform(.040,.068)
        pigment=source.choice(palettes)
        for region in trim_inlet(poly, FLAGSTONE_PATTERN_EDGE):
            area=polygon_area(region)
            if area<.12:
                continue
            pieces=split_arrival_stone(region,area,split_source)
            split=len(pieces)==2
            shoulder_scale=.978 if split else trim
            face_scale=shoulder_scale*(.977 if split else .954)
            for index,piece in enumerate(pieces):
                offset=(index*2-1) if split else 0
                color="".join(f"{int(pigment[i:i+2],16)+offset*delta:02X}"
                              for i,delta in ((0,3),(2,2),(4,2)))
                for exposed in trim_inlet(piece):
                    if polygon_area(exposed)<.12:
                        continue
                    ox,oz=(sum(point[axis] for point in exposed)/len(exposed) for axis in (0,1))
                    shoulder=[(ox+(x-ox)*shoulder_scale,PROMENADE_GRADE+.014,oz+(z-oz)*shoulder_scale)
                              for x,z in exposed]
                    face=[(ox+(x-ox)*face_scale,height+offset*.004,oz+(z-oz)*face_scale) for x,z in exposed]
                    yield color,shoulder,face
