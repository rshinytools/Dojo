"""Grand Dojo's Brawl entry, lantern court and breakaway floor."""

from math import atan2, cos, degrees, pi, sin


def build_dojo_brawl(ring, *, item, part, prop, sign, showcase_tree, garden_prop, wood, slate, metal, neon):
    entry = item(ring, "Model", "Brawl Entry")
    board_x, board_z = 47.75, 34.3
    for dx in (-2.12, 2.12):
        part(entry, "Brawl sign foot", (board_x + dx, .64, board_z),
             (.58, .45, .62), "7D6672", material=slate, collide=False)
        part(entry, "Brawl sign post", (board_x + dx, 1.82, board_z),
             (.23, 2.45, .29), "704135", material=wood, collide=False)
    sign(entry, "DOJO BRAWL", board_x, 2.81, board_z + .14, 4.72, .81,
         tint="795043", single_line=True)
    sign(entry, "LAST FIGHTER STANDING", board_x, 2.03, board_z + .14, 4.54, .48,
         tint="3C555B", single_line=True)
    gate = part(entry, "Brawl Queue", (board_x, 2.48, board_z + .69),
                (.2, .2, .2), "FFF0C5", collide=False, transparency=1)
    prompt = item(gate, "ProximityPrompt", "JoinBrawlPrompt")
    prop(prompt, "string", "ActionText", "Join or leave queue")
    prop(prompt, "string", "ObjectText", "Grand Dojo Brawl")
    prop(prompt, "float", "MaxActivationDistance", 7.25)
    prop(prompt, "bool", "RequiresLineOfSight", False)
    prop(prompt, "float", "HoldDuration", .20)
    part(entry, "Brawl Return", (board_x, 2.75, board_z + 4.25), (.2, .2, .2),
         "FFF0C5", collide=False, transparency=1)

    # The entry stays at the Grand Dojo. Its breakaway floor is on a separate
    # mountain terrace so the public pavilion stays open during the match.
    court = item(ring, "Model", "Brawl Court")
    prop(court, "token", "ModelStreamingMode", 1)
    cx, floor, cz = -980, 70, 420
    pitch = 5

    def detail(parent, name, x, y, z, size, color, *, material=None, collide=False, transparency=0, yaw=0):
        node = part(parent, name, (cx + x, floor + y, cz + z), size, color,
                    material=slate if material is None else material, collide=collide,
                    transparency=transparency, yaw=yaw)
        prop(node, "bool", "CastShadow", False)
        return node

    detail(court, "Bounds", 0, 2.4, 0, (45, 12, 45), "F4BC75", transparency=1)
    detail(court, "Floor Origin", 0, 0, 0, (.2, .2, .2), "F4BC75", transparency=1)
    spawns = item(court, "Folder", "Spawn Marks")
    for seat in range(8):
        angle = 2 * pi * seat / 8
        x, z = 17 * cos(angle), 17 * sin(angle)
        yaw = degrees(atan2(x, z))
        detail(spawns, f"Seat {seat + 1}", x, 2.30, z, (.2, .2, .2),
               "FCB46B", transparency=1, yaw=yaw)

    tiles = item(court, "Folder", "Tiles")
    bands = [item(tiles, "Folder", name) for name in ("Outer", "Middle", "Inner", "Final")]
    tones = (("51777E", "5D8185"), ("536A78", "647886"),
             ("855A57", "976960"), ("BD9269", "C9A574"))
    for row in range(-4, 5):
        for col in range(-4, 5):
            band = min(4 - max(abs(row), abs(col)), 3)
            tint = tones[band][(row + col) % 2]
            detail(bands[band], f"Tile {row + 5}-{col + 5}", col * pitch, -.48, row * pitch,
                   (pitch - .025, .96, pitch - .025), tint, material=slate, collide=True)

    detail(court, "Lower basin", 0, -7.9, 0, (69, .55, 72), "415B64", material=slate)
    detail(court, "Pine terrace base", 0, -10.2, 0, (118, 2.0, 116), "756575", material=slate)
    for x, z, width, depth in ((-49, -5, 19, 92), (47, 5, 24, 89), (1, -48, 85, 17), (-2, 48, 83, 17)):
        detail(court, "High terrace moss", x, -8.8, z, (width, .8, depth), "78856C")
    for index, (x, z, scale) in enumerate(((-47, -34, 1.65), (46, -35, 1.85), (47, 28, 1.45), (-50, 31, 1.55))):
        showcase_tree(court, cx + x, cz + z, False, scale, 26 + 45 * index, floor - 8.4, compact=True)
        garden_prop(court, "bankRock", (cx + x * .93, floor - 8.4, cz + z * .83), 2.4,
                    19 + 39 * index, "8E7989")
    for side in (-1, 1):
        for x, z, yaw in ((side * 26, 0, 90), (0, side * 26, 0)):
            detail(court, "Recessed basin coping", x, -5.95, z, (51, 1.3, 2.5),
                   "716274", material=slate, yaw=yaw)
            detail(court, "Basin reed seam", x, -5.24, z, (50, .11, .30),
                   "C0976B", material=metal, yaw=yaw)
        for z_side in (-1, 1):
            x, z = side * 25.4, z_side * 25.4
            detail(court, "Lantern buttress", x, -2.38, z, (3, 7.1, 3), "635B68", material=slate)
            detail(court, "Lantern crown", x, 1.28, z, (2.15, .24, 2.15), "8C5647", material=wood)
            detail(court, "Amber paper", x, 2.16, z, (1.43, 1.54, 1.43), "FFCC7E", material=neon)
            detail(court, "Lantern cap", x, 3.00, z, (2.10, .22, 2.10), "583944", material=wood)
        for x, z, yaw in ((side * 37.5, 0, 90), (0, side * 41.6, 0)):
            detail(court, "Slate terrace backdrop", x, -2.35, z, (78, 12.4, 2.1), "635667", material=slate, yaw=yaw)
            detail(court, "Dressed terrace cap", x, 3.85, z, (78, .68, 2.5), "8A6972", material=slate, yaw=yaw)
        for along in (-24, -8, 8, 24):
            for x, z, yaw in ((side * 36.2, along, 90), (along, side * 40.3, 0)):
                detail(court, "Terrace cedar pilaster", x, 1.75, z, (.75, 5.1, .8), "594450", material=wood, yaw=yaw)
                detail(court, "Terrace bronze belt", x, 3.58, z, (.99, .20, .98), "C19363", material=metal, yaw=yaw)

    detail(court, "Spectator deck", 0, 1.88, 33, (28, 1.24, 9), "93685A", material=wood, collide=True)
    detail(court, "Spectator Return", 0, 4.82, 32.6, (.2, .2, .2), "FFF0C5", transparency=1)
    for x, z, length, yaw in ((0, 28.65, 28, 0), (0, 37.35, 28, 0), (-13.8, 33, 8.7, 90), (13.8, 33, 8.7, 90)):
        detail(court, "Viewing guardrail", x, 3.48, z, (length, .24, .27), "8E5243", material=wood, yaw=yaw)
        detail(court, "Viewing safety panel", x, 5.35, z, (length, 5.7, .24),
               "FFF0C5", yaw=yaw, transparency=1, collide=True)
    for x in (-13.3, -7.7, 0, 7.7, 13.3):
        detail(court, "Spectator cedar post", x, 3.28, 28.65, (.35, 1.9, .35), "704438", material=wood)
    sign(court, "DOJO BRAWL", cx, floor + 5.19, cz + 37.27, 8.9, .9,
         tint="795043", single_line=True)
