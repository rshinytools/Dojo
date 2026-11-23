"""Decorative cedar fascia and slate seats for the main Festival Canal bridge."""

from math import atan2, degrees, hypot


def build_festival_bridge_details(parent, *, samples, z, canal_x, canal_width, item,
                                  prop, part, triangle, beam, slate, wood, metal,
                                  variant_field, stone_variant):
    """Follow the deck profile with an arched fascia and grounded stone seats."""
    finish = item(parent, "Model", "Festival bridge millwork and stone seats")
    landing = min(y for _, y in samples)
    rise = max(y for _, y in samples) - landing

    def fascia_top(y):
        return y - .075

    def fascia_bottom(y):
        # A narrower section at the crest exposes the opening below the span.
        return fascia_top(y) - (.880 - .265 * (y - landing) / rise)

    segments = tuple(zip(samples, samples[1:]))
    cedar_tints = ("A04A34", "A95037", "A54D37", "A54E35")
    for side in (-1, 1):
        face_z = z + side * 3.695
        for index, ((ax, ay), (bx, by)) in enumerate(segments):
            top_a = (ax, fascia_top(ay), face_z)
            top_b = (bx, fascia_top(by), face_z)
            low_a = (ax, fascia_bottom(ay), face_z)
            low_b = (bx, fascia_bottom(by), face_z)
            tint = cedar_tints[index % len(cedar_tints)]
            for a, b, c in ((top_a, low_a, low_b), (top_a, low_b, top_b)):
                triangle(finish, a, b, c, tint, name="Deep lacquered bridge fascia",
                         thickness=.31, material=wood, shadow=False)

            # A slim warm rail edge and a darker laminated return give the
            # fascia thickness when seen at water level or from either bank.
            span = hypot(bx - ax, by - ay)
            pitch = degrees(atan2(by - ay, bx - ax))
            part(finish, "Muted tan bridge edge trim", ((ax + bx) / 2,
                 (top_a[1] + top_b[1]) / 2 - .152, face_z + side * .155),
                 (span + .04, .080, .096), "BD9164", roll=pitch, material=wood, collide=False)
            beam(finish, "Dark cedar lower arch lamination",
                 (ax, low_a[1] + .069, face_z + side * .09),
                 (bx, low_b[1] + .069, face_z + side * .09), .188, "753C31", collide=False)

    footings = item(finish, "Model", "Stepped bridge springing stones")
    for bank in (-1, 1):
        spring_x = canal_x + bank * canal_width / 2
        for (ax, ay), (bx, by) in segments:
            if ax <= spring_x <= bx:
                edge_y = ay + (by - ay) * (spring_x - ax) / (bx - ax)
                break
        seat_top = fascia_bottom(edge_y) + .085
        for side in (-1, 1):
            px = spring_x + bank * .28
            pz = z + side * 3.74
            part(footings, "Submerged slate springing base", (px, -.46, pz),
                 (1.81, .77, 1.16), "776875", material=slate, collide=False)

            low_left = (px - .77, -.09, pz)
            low_right = (px + .77, -.09, pz)
            high_left = (px - .54 + bank * .06, seat_top - .21, pz)
            high_right = (px + .54 + bank * .06, seat_top - .21, pz)
            for a, b, c in ((low_left, low_right, high_right), (low_left, high_right, high_left)):
                triangle(footings, a, b, c, "94818A", name="Battered slate bridge seat",
                         thickness=.98, material=slate, shadow=False)

            part(footings, "Slate bridge seat shadow course", (px + bank * .06, seat_top - .175, pz),
                 (1.15, .112, 1.01), "7D6A75", material=slate, collide=False)
            part(footings, "Honed slate bridge seat cap", (px + bank * .06, seat_top - .080, pz),
                 (1.28, .16, 1.19), "AC9794", material=slate, collide=False)
            part(finish, "Bronze fascia springing pin",
                 (spring_x, fascia_top(edge_y) - .32, z + side * 3.861),
                 (.115, .115, .069), "B68955", shape=0, material=metal, collide=False)

    for piece in finish.iter("Item"):
        if piece.get("class") not in ("Part", "WedgePart"):
            continue
        properties = piece.find("Properties")
        if properties.find("bool[@name='CastShadow']") is None:
            prop(piece, "bool", "CastShadow", False)
        if properties.findtext("token[@name='Material']") == str(slate):
            prop(piece, "string", variant_field, stone_variant)
