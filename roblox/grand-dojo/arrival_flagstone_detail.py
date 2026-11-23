"""Small worn edges on the first stretch of the hand-cut promenade."""

from math import dist
from random import Random

from art.promenade_layout import flagstones, stone_pigment


def blend(first, second, amount):
    return tuple(a + (b - a) * amount for a, b in zip(first, second))


def shade(tint, factors):
    channels = (int(tint[i:i + 2], 16) for i in (0, 2, 4))
    return "".join(f"{min(255, round(channel * factor)):02X}"
                   for channel, factor in zip(channels, factors))


def build_arrival_flagstone_detail(parent, *, item, prop, triangle, limestone):
    details = item(parent, "Model", "Weathered arrival flagstone")
    prop(details, "token", "ModelStreamingMode", 1)
    prop(details, "token", "LevelOfDetail", 4)
    rng = Random(7821)
    for pigment, _, face in flagstones():
        midpoint = tuple(sum(vertex[i] for vertex in face) / len(face) for i in range(3))
        x, height, z = midpoint
        if not (-7.9 <= x <= 13.0 and 45 <= z <= 76 and rng.random() < .77):
            continue
        edges = [(a, b) for a, b in zip(face, face[1:] + face[:1]) if dist(a, b) >= 1.05]
        if not edges:
            continue
        a, b = rng.choice(edges)
        span = dist(a, b)
        at = rng.uniform(.28, .72)
        width = rng.uniform(.23, .51) / span
        start = blend(a, b, at - width / 2)
        end = blend(a, b, at + width / 2)
        tip = blend(blend(start, end, rng.uniform(.28, .72)), midpoint, rng.uniform(.055, .105))
        rim = blend(tip, end, .35)

        def surface(point):
            return point[0], height + .018, point[2]

        tone = stone_pigment(pigment, (tip[0], tip[2]))
        triangle(details, surface(start), surface(end), surface(tip),
                 shade(tone, (.82, .80, .83)), name="Worn stone edge", thickness=.008,
                 material=limestone, shadow=False)
        highlight = (rim[0], height + .019, rim[2])
        triangle(details, surface(tip), highlight, surface(end),
                 shade(tone, (1.035, 1.025, 1.015)), name="Chipped stone lip", thickness=.008,
                 material=limestone, shadow=False)
