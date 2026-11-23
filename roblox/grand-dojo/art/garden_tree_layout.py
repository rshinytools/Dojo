"""Branch and crown shapes for the native garden trees and Blender export."""
from math import cos, radians, sin
import random

BARK = ("69463B", "79523D", "925F42")
BLOSSOMS = ("A65778", "C47893", "D88CA3", "E29CB0", "E7A6B6")
LEAVES = ("405633", "557340", "6E8947", "839750", "91A557")
# Lift only selected upper branches on the three plaza trees. Colliding
# lower trunks and the lower boughs that clear the entrances use the base shape.
ARRIVAL_BOUGH_LIFT = {False: (0, .42, .76, 0, .52), True: (0, .66, 0, 0, .78)}

TRUNK = (
    (0, -.05, 0, .73),
    (-.22, 2.05, .16, .56),
    (.29, 4.13, -.11, .42),
    (.46, 6.07, -.29, .23),
    (.22, 7.24, -.24, .09),
)
CROWNS = (
    # x, height, z, width and depth
    (-4.05, 6.68, .93, 5.03, 4.3),
    (-2.04, 7.91, -1.46, 5.56, 4.42),
    (.55, 9.26, -.11, 5.08, 4.46),
    (3.47, 7.30, .68, 5.33, 4.54),
    (2.14, 8.56, -2.34, 4.51, 3.80),
)
ROOTS = (
    (-1.75, -.02, .70, .10),
    (-.87, -.08, -1.23, .075),
    (.77, -.05, -1.16, .086),
    (1.38, -.04, .81, .105),
)

# Intersecting pads form each branch crown. The short sprays sit mostly
# inside the main volume and break up the outer silhouette.
PADS = (
    (-.10, -.29, .04, .91, 1.05, .84, 0),
    (-.24, -.06, .10, .78, 1.21, .79, 1),
    (.21, .02, -.12, .83, 1.14, .81, 2),
    (-.06, .19, .02, 1.01, 1.19, .88, 2),
    (-.19, .34, -.09, .76, .96, .72, 3),
    (.25, .27, .10, .70, .86, .62, 2),
)
FRINGE = (
    (-.13, .48, -.03, .40, .48, .37, 4),
    (-.52, -.04, .05, .30, .65, .31, 1),
    (-.37, .17, .35, .34, .56, .31, 2),
    (-.24, .24, -.39, .28, .59, .28, 2),
    (-.04, .26, .36, .36, .63, .29, 3),
    (.22, .06, .39, .31, .58, .30, 2),
    (.36, .22, -.35, .37, .58, .27, 2),
    (.50, .10, -.08, .30, .60, .30, 2),
)


def garden_tree(blossom, *, arrival=False):
    """Yield tapered branch segments and asymmetric layers of foliage."""
    palette = BLOSSOMS if blossom else LEAVES
    branches = [(a, b, BARK[index % 3]) for index, (a, b) in enumerate(zip(TRUNK, TRUNK[1:]))]
    root_collar=(-.065,.57,.045,.43)
    for index,root in enumerate(ROOTS):
        elbow=(root[0]*.57,.19,root[2]*.57,.21)
        branches.extend(((root_collar,elbow,BARK[0]),(elbow,root,BARK[index%2])))
    leaves = []
    rng = random.Random(831 if blossom else 148)
    for index, (x, y, z, width, depth) in enumerate(CROWNS):
        if blossom:
            x,z=x*.95+.21,z*.92-.17
            y+=(-.15,.15,.17,-.20,.30)[index]
        else:
            x,z=x*1.09,z*.90
            y+=(-.28,.07,.04,-.22,.03)[index]
        if arrival:
            y+=ARRIVAL_BOUGH_LIFT[blossom][index]
        mid = (x*.49+.24, y-1.86, z*.45-.13, .29)
        elbow = (x*.77+.09, y-.91, z*.76+.13, .165)
        tip = (x, y, z, .080)
        trunk = TRUNK[2 + index % 2]
        branches.extend(((trunk,mid,BARK[0]),(mid,elbow,BARK[1]),(elbow,tip,BARK[2])))
        branches.append((elbow,(x*.97,y+.24,z+.84,.049),BARK[1]))
        branches.append((elbow,(x*.89+.40,y+.37,z-.69,.038),BARK[2]))

        for detail, layers in ((False, PADS), (True, FRINGE)):
            for dx, dy, dz, ws, hs, ds, shade in layers:
                center = (x + dx*width + rng.uniform(-.10, .10), y + dy,
                          z + dz*depth + rng.uniform(-.10, .10))
                height = hs * (1.49 if blossom else 1.02)
                size = (width * ws, height, depth * ds)
                angles = (rng.uniform(-36, 36), (-1)**index * (3 + dz*9), dx*17)
                leaves.append((center, size, angles, palette[shade], detail))
    return branches, leaves


def garden_knuckles(branches):
    joints={}
    for a,b,pigment in branches:
        for point in (a,b):
            count,prior=joints.get(point,(0,pigment))
            joints[point]=(count+1,prior)
    return [(point,pigment) for point,(count,pigment) in joints.items() if count>1 and point[1]>1]


def rotate_garden_point(point, yaw):
    """Rotate around the trunk's vertical axis in Roblox coordinates."""
    x, y, z = point
    angle = radians(yaw)
    c, s = cos(angle), sin(angle)
    return x*c + z*s, y, -x*s + z*c


def rotate_garden_spray(point, angles):
    """Apply the same yaw, pitch and roll order as the native foliage part."""
    x,y,z=point
    yaw,pitch,roll=angles
    p,r=radians(pitch),radians(roll)
    x,y=x*cos(r)-y*sin(r),x*sin(r)+y*cos(r)
    y,z=y*cos(p)-z*sin(p),y*sin(p)+z*cos(p)
    return rotate_garden_point((x,y,z),yaw)
