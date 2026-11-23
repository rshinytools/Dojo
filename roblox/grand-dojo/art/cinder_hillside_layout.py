"""Shared sandstone contours for the Cinder Square native and baked hillside."""

from math import cos, sin


CINDER_HILLSIDE_PIVOT = (150, 10, -188)
OUTLINE = ((-1,-1),(-.54,-1),(-.09,-1),(.31,-1),(.72,-1),(1,-1),
           (1,-.66),(1,-.28),(1,.13),(1,.54),(1,.81),(1,1),
           (.72,1),(.43,1),(.12,1),(-.23,1),(-.58,1),(-.82,1),(-1,1),
           (-1,.62),(-1,.16),(-1,-.31),(-1,-.73))
BANDS = ((.61,-.92),(1.52,-1.82),(2.72,-2.45),(4.19,-4.80),
         (6.02,-5.58),(8.24,-8.84),(12.88,-13.9))
PALETTE = (("AD8878","A38073","B6917E"),("8C695F","9B7468","A27D6D"),
           ("A87862","B48770","9E7464"),("997061","8E675F","A67B69"),
           ("926D62","9B7467","865F60"),("7A5C5E","856263","947267"))


def hillside_rings(x=0, y=0, z=0):
    rings = []
    for band, (width, lift) in enumerate(BANDS):
        ring = []
        for i, (u, v) in enumerate(OUTLINE):
            rib = sin(i*2.34+band*.66)*.42+cos(i*.83)*.27
            grow = width+rib*(.51+band*.18)
            relief = sin(i*1.47+band*.58)*(.21 if band==0 else .50)
            ring.append((x+u*(30+grow), y+lift+relief, z+v*(31+grow)))
        rings.append(ring)
    return rings


def hillside_faces(rings, bands=tuple(range(len(BANDS))), outline=tuple(range(len(OUTLINE)))):
    """Yield outward-facing triangles over the retained vertices of each contour."""
    for level, below in zip(bands, bands[1:]):
        pigments = PALETTE[level]
        for i, j in zip(outline, (*outline[1:], outline[0])):
            a, b, c, d = rings[level][i], rings[level][j], rings[below][i], rings[below][j]
            yield (a, b, c), pigments[(i+level)%3]
            yield (c, b, d), pigments[(i+level+1)%3]
