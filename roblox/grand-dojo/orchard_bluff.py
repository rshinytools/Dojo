"""Folded slate and planted ledges north of Orchard High Walk."""
from math import cos, pi, radians, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height


CREST = (
    (-199.2, -.6, -47.9), (-192.1, 4.3, -46.6), (-184.9, 9.4, -43.7),
    (-178.3, 16.2, -44.8), (-171.9, 22.5, -42.7), (-165.5, 20.1, -45.1),
    (-159.0, 27.1, -44.1), (-153.4, 30.2, -40.8), (-149.3, 33.7, -41.6),
    (-143.7, 28.4, -44.2), (-137.6, 24.3, -45.5), (-132.7, 29.5, -45.6),
    (-126.7, 38.0, -43.2), (-122.8, 34.1, -42.5), (-116.2, 28.4, -44.6),
    (-109.8, 22.1, -43.6), (-104.2, 17.7, -44.8), (-101.4, 6.1, -42.9),
    (-94.5, -.5, -44.6),
)
BANDS = ((0, 1), (.18, .87), (.35, .65), (.51, .57), (.70, .33), (.84, .21), (1, 0))
SLATE = ("7D7181", "897886", "807784", "8D7C87", "897D89")
SAGE = ("797B72", "818278", "7C7F76", "898779", "838279")


def bluff_facets():
    for front in (False, True):
        contours = []
        for run, lift in BANDS:
            rim = sin(pi*run)
            contour = []
            for i, (x, y, z) in enumerate(CREST):
                toe = -21.2+1.37*cos(.73*i) if front else -68.8+1.8*sin(.81*i)
                back_tip_clearance = 1.8*rim*max(0, (i-15)/3) if not front else 0
                contour.append((x+1.30*rim*sin(.83*i+run*3),
                                y*lift-4.85*run+1.22*rim*cos(i*.91+run*6)-back_tip_clearance,
                                z+(toe-z)*run+1.42*rim*sin(.77*i+run*1.4)))
            contours.append(contour)
        for band, (higher, lower) in enumerate(zip(contours, contours[1:])):
            for index, (a, b, c, d) in enumerate(zip(higher, higher[1:], lower, lower[1:])):
                slate = band in (0, 2, 4) or (index//2+band)%5 == 0
                palette = SLATE if slate else SAGE
                tint = palette[(index//2+band*2)%len(palette)]
                faces = ((a,b,c),(b,d,c)) if (index+band)%2 else ((a,b,d),(a,d,c))
                for face in faces:
                    yield face, tint, slate


def build_orchard_bluff(parent, *, item, prop, part, triangle, garden_shelf, garden_prop,
                        slate, rock, grass, cedar, rock_variant, variant_field):
    bluff = item(parent, "Model", "North Orchard Bluff")
    prop(bluff, "token", "ModelStreamingMode", 1)
    prop(bluff, "token", "LevelOfDetail", 4)
    ground = item(bluff, "Folder", "Slate ribs and sage contours")
    surfaces = []
    for face, tint, stone in bluff_facets():
        surfaces.append(face)
        triangle(ground, *face, tint, name="Orchard bluff slate" if stone else "Orchard bluff sage stone",
                 material=rock, thickness=.14, shadow=False)
    for piece in ground.findall("Item"):
        prop(piece, "string", variant_field, rock_variant)

    ledges = item(bluff, "Folder", "Planted slate ledges")
    for i, (x, z, width, depth, yaw) in enumerate((
        (-153.1, -36.8, 5.8, 2.85, 18), (-147.0, -34.6, 5.4, 2.55, -23),
        (-137.8, -29.5, 6.4, 2.9, -31), (-132.8, -28.0, 5.75, 2.5, -44),
        (-121.3, -30.5, 6.3, 2.65, 17), (-118.4, -25.55, 5.95, 2.55, 25),
        (-111.8, -26.9, 5.4, 2.05, 33), (-108.6, -24.6, 4.35, 2.00, 26),
    )):
        y = ridge_surface_height(surfaces, x, z)
        dx, dz = cos(radians(yaw)), sin(radians(yaw))
        outline = ((-.50,-.16),(-.35,-.50),(.37,-.48),(.50,-.08),(.37,.47),(-.39,.43))
        rim = [(x+u*width*dx+v*depth*dz, y+.12, z-u*width*dz+v*depth*dx+.2)
               for u,v in outline]
        roots = [(px, min(y-.43, ridge_surface_height(surfaces, px, pz)-.26), pz)
                 for px,_,pz in rim]
        for j, (a,b) in enumerate(zip(rim,rim[1:]+rim[:1])):
            c, d = roots[j], roots[(j+1)%len(roots)]
            tint = ("91808E", "887987", "9F8993")[(i+j)%3]
            triangle(ledges, a,b,c,tint,name="Bluff shelf seated face",material=slate,shadow=False)
            triangle(ledges, b,d,c,tint,name="Bluff shelf seated face",material=slate,shadow=False)
        for a,b in zip(rim[1:-1],rim[2:]):
            triangle(ledges, rim[0],a,b,"A28F96",name="Bluff shelf stone cap",material=slate,shadow=False)
        garden_shelf(ledges, x+.16, y+.19, z+.25, width*.75, depth*.71,
                     .26, "728158", grass, collide=False)
        garden_prop(ledges, "bankRock", (x-.73, y+.085, z+.52), .18, yaw+25, "A28F9A")
        garden_prop(ledges, "rockVine", (x+.68, y-.69, z+depth*.42), .37, yaw+38)
        garden_prop(ledges, "mossFlowers", (x+.58, y+.19, z+.32), .19, yaw-18, "E3ACB8")
        garden_prop(ledges, "meadowFlowers", (x-.49, y+.18, z+.48), .23, yaw+41, "F2C2B6")

    trees = item(bluff, "Folder", "Orchard ridge cedar groves")

    def tree_part(group, name, position, size, tint, **pose):
        piece = part(group, name, position, size, tint,
                     material=cedar if name.endswith("trunk") else grass, collide=False, **pose)
        prop(piece, "bool", "CastShadow", False)

    for i, (x,z,scale) in enumerate((
        (-178.4,-40.8,.58), (-169.8,-37.2,.63),
        (-152.3,-37.5,.63), (-149.2,-35.9,.78), (-145.1,-35.4,.62),
        (-139.6,-32.7,.54), (-134.4,-29.6,.76), (-131.2,-27.7,.62),
        (-124.3,-32.2,.57), (-121.4,-27.8,.81), (-117.8,-24.8,.68),
        (-113.9,-29.3,.60), (-110.7,-26.1,.74), (-107.4,-23.8,.58),
    )):
        y = ridge_surface_height(surfaces, x, z)
        hillside_cedar(tree_part, trees, x, y-.48, z, scale, i%9)
