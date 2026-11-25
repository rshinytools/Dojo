"""Original wayfinding and encounter props on the city's existing walkable floors."""

import json
from math import atan2, cos, degrees, radians, sin
from pathlib import Path


_WORLD_CONTENT = Path(__file__).resolve().parents[2] / "design" / "world-content.json"
_BRASS = "C49A60"
_STONE = "80717C"
# Lacquer, carved-panel accent and small light inset for each district.
_PALETTES = {
    "valley": ("365953", "71947D", "E8BC78"),
    "coast": ("315A65", "649A9C", "AEE2DF"),
    "cinder": ("744738", "B26848", "F7A365"),
    "sky": ("504E77", "8983AC", "D5D1F9"),
    "frost": ("466474", "8AABBE", "CEF0F7"),
    "circuit": ("624968", "A7718B", "F2ABD3"),
}

# Activity identity comes from the ordered activities in world-content.json.
# Standing plaques mark puzzle/timing inputs. Route and delivery checkpoints
# use smaller painted pavement markers to preserve the walking sightline.
_POST_ACTIVITIES = {"valley": 2, "cinder": 1, "sky": 2, "frost": 2, "circuit": 2}

_LAYOUT = {
    # District plazas, side walks and established ramps. A checkpoint is
    # (x, pavement elevation, z) and a notice board also has a facing yaw.
    "valley": {
        "mentor": (-5.5, .15, 35, 22),
        "survey": ((-7, .15, 22), (1.4, .15, 45.4), (13.2, .15, 44.3)),
        "seals": (
            ((-9.4, .15, 43.5), "Look along the bank east of the festival bridge."),
            ((17.6, .15, 58.8), "Follow the southern stones past the city map."),
            ((0.3, .15, 16.5), "Check the paved approach below Trophy Hall."),
        ),
        "treasure": ((10.4, .15, 22.8), "Look between the lantern practice and the ring stairs."),
        "activity": (
            ((-2.0, .15, 47.8, 15), ((-3.4, .15, 53), (2.5, .15, 58.1), (9.3, .15, 63.4), (14.7, .15, 59.5))),
            ((-1.2, .15, 27.0, 22), ((-4.0, .15, 20.8), (2.4, .15, 19.5), (5.9, .15, 27.1))),
        ),
    },
    "coast": {
        "mentor": (212.5, 3.027, 20.5, 54),
        "survey": ((199.8, 3.027, 19.5), (216, 3.027, 27.5), (254, 4.5, 39.4)),
        "seals": (
            ((211, 3.027, 10.15), "Look behind the seaward end of Harbor House."),
            ((228.9, 3.027, 35.4), "The loading cranes hide a mark by the market wall."),
            ((260, 4.5, 38.4), "Search the outer edge of Harbor Pier."),
        ),
        "treasure": ((214, 3.027, 34.5), "Follow the waterfront toward Lantern Quay."),
        "activity": (
            ((197.4, 3.027, 16.25, 80), ((203.8, 3.027, 17.45), (212, 3.027, 15.0), (218.4, 3.027, 18.5), (227.4, 3.027, 16.2))),
            ((217.1, 3.027, 36.2, 35), ((224.5, 3.027, 39.1), (233.1, 3.027, 40.0), (239.3, 4.248, 40.0), (252.8, 4.5, 41.0))),
        ),
    },
    "cinder": {
        "mentor": (153.1, 10.027, -175.3, -23),
        "survey": ((139.1, 10.027, -190), (155, 10.027, -195.1), (166.3, 10.027, -189.1)),
        "seals": (
            ((136.7, 10.027, -186.4), "The bellows overlook the first courtyard seal."),
            ((170.5, 10.085, -188.5), "Follow the courtyard behind the eastern shop."),
            ((156.2, 27.05, -241.8), "Check Copper Kiln Pavilion above the climb."),
        ),
        "treasure": ((158.2, 27.05, -236.7), "Reach the top of Copper Kiln Walk."),
        "activity": (
            ((145.6, 10.027, -194, 0), ((143.0, 10.027, -198.4), (151.5, 10.027, -196), (158.2, 10.027, -192.3))),
            ((108.75, 18.36, -222.3, 142), ((115, 19.80, -228.2), (123.6, 21.790, -233.7), (134.5, 23.88, -237), (146.25, 26.58, -239.42))),
        ),
    },
    "sky": {
        "mentor": (29, 25.027, -242.7, 15),
        "survey": ((20, 25.027, -240.3), (29, 25.027, -252.1), (28, 25.027, -268)),
        "seals": (
            ((13, 25.027, -244), "A seal rests west of the wind court map."),
            ((45.6, 25.027, -264.2), "Look along the stones east of the open court."),
            ((18, 25.027, -239), "Look along the west shoulder of the gatehouse."),
        ),
        "treasure": ((43, 25.027, -266), "Search the sheltered east edge of Wind Court."),
        "activity": (
            ((20, 20.06, -213.0, 0), ((22, 22.18, -222), (22, 24.06, -230), (22, 25.027, -238), (22, 25.027, -247))),
            ((31, 25.027, -249, -80), ((29.4, 25.027, -257.7), (33.5, 25.027, -265), (39.15, 25.027, -267.8))),
        ),
    },
    "frost": {
        "mentor": (-197.3, 14.027, -159.25, 22),
        "survey": ((-215, 14.027, -170.5), (-197.2, 14.027, -178.7), (-180.8, 14.027, -161.5)),
        "seals": (
            ((-210.9, 14.027, -160.3), "Look near the old stones west of the garden."),
            ((-188.9, 18.67, -184.3), "Search the pavilion above Pond Terrace."),
            ((-177.3, 14.027, -177.8), "Search the snowy path east of the reflecting pond."),
        ),
        "treasure": ((-189.6, 18.67, -181.5), "Climb Frostglass Walk to the upper pond garden."),
        "activity": (
            ((-190, 14.027, -160.3, 180), ((-188.6, 14.027, -164.6), (-189.2, 14.08, -169.1), (-187.45, 14.08, -173.9), (-186.1, 14.027, -176.4))),
            ((-210.9, 14.027, -171.5, 0), ((-214.2, 14.027, -175.1), (-207.4, 14.027, -176.5), (-201.0, 14.027, -175.1))),
        ),
    },
    "circuit": {
        "mentor": (-212.5, 6.027, 42.5, -145),
        "survey": ((-235.9, 6.027, 27.8), (-218.2, 6.027, 24.2), (-210.1, 6.027, 25.7)),
        "seals": (
            ((-231.25, 6.027, 20.15), "Search beside the covered lantern tables."),
            ((-243.1, 13.27, -7.4), "Look through the windows at Upper Lantern Market."),
            ((-263.5, 19.37, 35.2), "Check the lantern pavilion on Skyline Walk."),
        ),
        "treasure": ((-259.5, 19.37, 37.0), "The skyline pavilion holds a market cache."),
        "activity": (
            ((-247.2, 13.27, -3.9, -48), ((-253.5, 13.573, -5.8), (-257.45, 13.70, -1.5), (-260.8, 15.27, 8.7), (-261.8, 17.57, 18.0), (-261.8, 19.37, 29.7))),
            ((-225.55, 6.027, 42.5, 10), ((-224.4, 6.027, 37.2), (-218.3, 6.027, 34.2), (-215.25, 6.027, 37.7))),
        ),
    },
}

_FESTIVAL = (6.3, .15, 59.6, -50)
_GRAND_TREASURE = ((5.9, .15, 13.7), "Search the approach to Trophy Hall after opening all six district caches.")


def build_city_adventure_scenery(city, *, item, part, prop, sign, cedar, slate, metal, neon):
    """Build the server's named adventure anchors and nearby landmark art."""
    districts = json.loads(_WORLD_CONTENT.read_text(encoding="utf-8"))["districts"]
    if {district["id"] for district in districts} != set(_LAYOUT):
        raise ValueError("City Adventure placements must cover the six design districts")

    root = item(city, "Folder", "City Adventure")

    def piece(parent, name, position, size, tint, material, **options):
        node = part(parent, name, position, size, tint, material=material, collide=False, **options)
        prop(node, "bool", "CastShadow", False)
        return node

    def anchored(parent, name, location, height):
        x, y, z = location[:3]
        return piece(parent, name, (x, y + height, z), (.25, .25, .25), _BRASS, metal,
                     transparency=1)

    def words(parent, title, location, width, height, yaw, tint, distance):
        plaque = sign(parent, title.upper(), *location, width, height, yaw, tint, face_only=True)
        prop(plaque, "bool", "CastShadow", False)
        prop(plaque.find("Item"), "float", "MaxDistance", distance)

    def front(location, across, lift, ahead):
        x, y, z, yaw = location
        sine, cosine = sin(radians(yaw)), cos(radians(yaw))
        return x + across * cosine + ahead * sine, y + lift, z - across * sine + ahead * cosine

    def board(parent, location, title, subtitle, palette, tall=False):
        enamel, insert, lamp = palette
        yaw, height = location[3], 2.26 if tall else 1.75
        width = 4.0 if tall else 3.65
        for dx in (.25 - width / 2, width / 2 - .25):
            piece(parent, "Slate socket", front(location, dx, .12, 0),
                  (.60, .24, .61), _STONE, slate, yaw=yaw)
            piece(parent, "Lacquered cedar upright", front(location, dx, height * .57, 0),
                  (.23, height * 1.14, .28), enamel, cedar, yaw=yaw)
        piece(parent, "Painted board back", front(location, 0, height, -.10),
              (width + .12, 1.15, .36), enamel, cedar, yaw=yaw)
        piece(parent, "Carved top cornice", front(location, 0, height + .59, 0),
              (width + .32, .14, .52), insert, cedar, yaw=yaw)
        piece(parent, "Brass apron", front(location, 0, height - .59, .03),
              (width + .08, .07, .46), _BRASS, metal, yaw=yaw)
        for side in (-1, 1):
            piece(parent, "Enamel nail head", front(location, side * (width / 2 - .17), height + .58, .28),
                  (.15, .12, .070), lamp, metal, yaw=yaw)
        words(parent, title, front(location, 0, height + .15, -.16), width, .47, yaw, enamel, 58)
        if subtitle:
            words(parent, subtitle, front(location, 0, height - .31, -.16), width - .11, .34, yaw, enamel, 38)

    def survey(parent, name, location, palette):
        enamel, insert, lamp = palette
        x, y, z = location
        node = anchored(parent, name, location, 1.24)
        piece(node, "Fitted stone foot", (x, y + .11, z), (.72, .22, .72), _STONE, slate)
        piece(node, "Inlaid standing marker", (x, y + .62, z), (.32, .93, .32), enamel, cedar)
        piece(node, "Brass crown", (x, y + 1.11, z), (.58, .10, .58), _BRASS, metal)
        piece(node, "Glazed square seal", (x, y + 1.28, z), (.37, .37, .37), insert, metal, yaw=45)
        piece(node, "Lit glazing", (x, y + 1.49, z), (.24, .07, .24), lamp, neon, yaw=45)

    def write_clue(node, clue):
        note = item(node, "StringValue", "Clue")
        prop(note, "string", "Value", clue)

    def seal(parent, name, location, clue, palette):
        enamel, insert, lamp = palette
        node = anchored(parent, name, location, .69)
        x, y, z = location
        piece(node, "Recessed seal plinth", (x, y + .19, z), (.66, .36, .61), enamel, slate, yaw=23)
        piece(node, "Engraved bronze seal", (x, y + .40, z), (.51, .11, .46), _BRASS, metal, yaw=23)
        piece(node, "Seal centerpiece", (x, y + .47, z), (.23, .04, .23), insert, metal, yaw=45)
        piece(node, "Colored center", (x, y + .495, z), (.09, .025, .09), lamp, neon, yaw=45)
        write_clue(node, clue)

    def chest(parent, name, location, clue, palette, scale=1):
        enamel, insert, lamp = palette
        node = anchored(parent, name, location, .91 * scale)
        x, y, z = location
        yaw = -18
        chest_location = (x, y, z, yaw)

        def detail(label, across, lift, ahead, size, tint, material):
            return piece(node, label, front(chest_location, across * scale, lift * scale, ahead * scale),
                         tuple(axis * scale for axis in size), tint, material, yaw=yaw)

        detail("Stone chest stand", 0, .10, 0, (1.91, .20, 1.40), _STONE, slate)
        detail("Lacquered chest", 0, .48, 0, (1.61, .62, 1.12), enamel, cedar)
        detail("Carved cedar lid", 0, .86, 0, (1.70, .23, 1.20), insert, cedar)
        detail("Raised lid rim", 0, .773, 0, (1.75, .11, 1.21), _BRASS, metal)
        for dx in (-.57, .57):
            detail("Bronze reinforcement", dx, .46, .58, (.12, .59, .046), _BRASS, metal)
            detail("Bronze lid strap", dx, .988, 0, (.12, .037, 1.05), _BRASS, metal)
        detail("Lock backplate", 0, .62, .613, (.33, .35, .11), _BRASS, metal)
        detail("Glazed clasp", 0, .635, .677, (.16, .14, .039), lamp, neon)
        write_clue(node, clue)

    def checkpoint(parent, index, location, afterward, palette, is_post):
        enamel, insert, lamp = palette
        x, y, z = location
        dx, dz = afterward[0] - x, afterward[2] - z
        yaw = degrees(atan2(dx, dz))
        checkpoint_location = (x, y, z, yaw)
        if is_post:
            node = anchored(parent, str(index), location, 1.12)
            piece(node, "Slate checkpoint foot", (x, y + .13, z), (.62, .26, .62), _STONE, slate)
            piece(node, "Activity cedar stalk", (x, y + .61, z), (.25, .92, .25), enamel, cedar)
            piece(node, "Colored checkpoint bead", (x, y + 1.32, z), (.42, .42, .42), lamp, neon, yaw=45)
            piece(node, "Number plate", front(checkpoint_location, 0, .98, -.20),
                  (.57, .45, .12), enamel, metal, yaw=yaw)
            words(node, str(index), front(checkpoint_location, 0, .98, -.016), .52, .41, yaw + 180, enamel, 30)
        else:
            # The route target lives at the medallion center, slightly above the local walking floor.
            node = piece(parent, str(index), (x, y + .047, z), (.135, 1.25, 1.25), insert, slate,
                         shape=2, roll=90)
            piece(node, "Brass route inset", (x, y + .126, z), (.035, .97, .97), _BRASS, metal,
                  shape=2, roll=90)
            piece(node, "Glazed route center", (x, y + .149, z), (.027, .72, .72), enamel, slate,
                  shape=2, roll=90)
            for side in (-1, 1):
                piece(node, "Route arrow", front(checkpoint_location, side * .096, .169, .012),
                      (.075, .018, .26), lamp, neon, yaw=yaw - 40 * side)

    festival = anchored(root, "Festival", _FESTIVAL, 1.64)
    board(festival, _FESTIVAL, "Training Festival", "City challenges", _PALETTES["valley"], tall=True)
    location, clue = _GRAND_TREASURE
    chest(root, "Grand Treasure", location, clue, _PALETTES["valley"], scale=1.25)

    for district in districts:
        district_id = district["id"]
        layout, palette = _LAYOUT[district_id], _PALETTES[district_id]
        chapter = item(root, "Model", district_id)
        mentor = item(chapter, "Model", "Mentor")
        prop(mentor, "token", "ModelStreamingMode", 1)
        anchored(mentor, "Interaction", layout["mentor"], 1.52)
        board(mentor, layout["mentor"], district["mentor"], district["chapter"], palette, tall=True)
        for index, location in enumerate(layout["survey"], start=1):
            survey(chapter, f"Survey-{index}", location, palette)
        for index, (location, clue) in enumerate(layout["seals"], start=1):
            seal(chapter, f"Seal-{index}", location, clue, palette)
        location, clue = layout["treasure"]
        chest(chapter, "Treasure", location, clue, palette)

        for index, (start, stops) in enumerate(layout["activity"], start=1):
            activity = item(chapter, "Model", f"Activity-{index}")
            launch = anchored(activity, "Start", start, 1.28)
            board(launch, start, district["activities"][index - 1], None, palette)
            is_post = _POST_ACTIVITIES.get(district_id) == index
            for number, location in enumerate(stops, start=1):
                if number < len(stops):
                    after = stops[number]
                else:
                    previous = stops[number - 2]
                    after = tuple(2 * here - there for here, there in zip(location, previous))
                checkpoint(activity, number, location, after, palette, is_post)
    return root
