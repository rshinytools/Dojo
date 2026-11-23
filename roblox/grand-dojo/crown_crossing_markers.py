"""Destination markers mounted outside the Crown Crossing rails."""

from math import atan2, degrees, hypot

from crown_crossing import POINTS, WIDTH


def build_crown_crossing_markers(parent, *, item, prop, part, beam, sign, cedar, slate, brass):
    markers = item(parent, "Model", "Crown Crossing destination markers")
    prop(markers, "token", "ModelStreamingMode", 1)
    prop(markers, "token", "LevelOfDetail", 4)

    for index, direction, side, fraction, destination, route, tint in (
        (1, 1, 1, .48, "CINDER TERRACES", "VIA KILN RIDGE", "794336"),
        (9, -1, 1, .53, "GRAND DOJO CITY", "VIA REEDFALL CROWN", "3D5366"),
    ):
        start, finish = POINTS[index:index + 2]
        x, y, z = (a + fraction * (b - a) for a, b in zip(start, finish))
        dx, dz = finish[0] - start[0], finish[2] - start[2]
        length = hypot(dx, dz)
        tx, tz = dx / length, dz / length
        nx, nz = -tz * side, tx * side
        # Turn the printed face toward the approaching player.
        face_x, face_z = -tx * direction, -tz * direction
        yaw = degrees(atan2(face_x, face_z))
        rail = WIDTH / 2 - .08
        center = WIDTH / 2 + 2.37

        def position(across, height, face=0):
            return x + nx * across + face_x * face, y + height, z + nz * across + face_z * face

        def piece(name, across, height, depth, size, color, material):
            return part(markers, name, position(across, height, depth), size,
                        color, material=material, yaw=yaw, collide=False)

        piece("Route marker slate shoe", rail + .39, .22, 0, (.6, .44, .62), "95848B", slate)
        piece("Route marker cedar newel", rail + .39, 1.83, 0, (.35, 2.95, .37), "89523E", cedar)
        piece("Route marker brass collar", rail + .39, 3.20, 0, (.51, .13, .51), "C89863", brass)
        piece("Route marker post cap", rail + .39, 3.40, 0, (.42, .25, .43), "A96F4A", cedar)
        beam(markers, "Route marker cedar hanger", position(rail + .39, 3.29),
             position(center + 2.02, 3.29), .21, "A47453")
        beam(markers, "Route marker cedar bracket", position(rail + .39, 1.33),
             position(center + .51, 2.05), .22, "855B4B")
        piece("Route marker slate sill", center, 2.05, 0, (4.48, .16, .52), "A28A87", slate)
        piece("Route marker bronze frame", center, 2.65, 0, (4.31, 1.20, .26), "CF9E65", brass)
        piece("Route marker lacquer", center, 2.65, .14, (4.15, 1.04, .10), tint, cedar)
        piece("Route marker bronze rule", center, 2.56, .20, (4.06, .036, .045), "C49868", brass)
        # The transparent sign part is half a stud thick. Recess its center
        # so the printed face sits just beyond the lacquer instead of floating.
        sign(markers, destination, *position(center, 2.85, -.034),
             4.06, .52, yaw, tint, face_only=True)
        sign(markers, route, *position(center, 2.34, -.034),
             4.06, .37, yaw, tint, face_only=True)

    for detail in markers.findall("Item"):
        prop(detail, "bool", "CastShadow", False)
