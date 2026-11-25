"""Build normalized defeat support samples from the original Blender exports."""

from math import cos, isfinite, pi, sin, sqrt
import json
import struct

from sparring_bot_models import ART as BOT_ART, BOTS, MANIFEST as BOT_MANIFEST
from starter_fighter_assets import ART, FIGHTERS, MANIFEST, _glb_json, load_starter_fighter_assets


SUPPORT_DIRECTIONS = 2048
TRAINING_ERROR = .008
VALIDATION_DIRECTIONS = 4096
MAXIMUM_ERROR = .025
POSITION = struct.Struct("<fff")
CHUNK_HEADER = struct.Struct("<I4s")


def _positions(document, binary, node):
    primitive, = document["meshes"][node["mesh"]]["primitives"]
    accessor = document["accessors"][primitive["attributes"]["POSITION"]]
    view = document["bufferViews"][accessor["bufferView"]]
    if (accessor["type"] != "VEC3" or accessor["componentType"] != 5126 or view["buffer"] != 0
            or "sparse" in accessor or accessor.get("normalized", False)):
        raise ValueError(f"{node['name']} needs a dense FLOAT VEC3 POSITION accessor")

    stride = view.get("byteStride", POSITION.size)
    count = accessor["count"]
    start = view.get("byteOffset", 0)
    first = start + accessor.get("byteOffset", 0)
    final = first + (count - 1) * stride + POSITION.size
    if (count < 1 or stride < POSITION.size or first < start or final > start + view["byteLength"]
            or final > len(binary)):
        raise ValueError(f"{node['name']} contains an invalid POSITION buffer range")

    if stride == POSITION.size:
        return POSITION.iter_unpack(binary[first:final])
    return (POSITION.unpack_from(binary, offset) for offset in range(first, final - POSITION.size + 1, stride))


def _mesh_local_vertices(positions, translation, frame):
    # GLB vertices use the authored floor axes. The published Roblox frame maps
    # MeshPart-local axes onto those axes, so transpose its rotation to recover local space.
    bx, by, bz = (tuple(frame[3 + row * 3 + column] for row in range(3)) for column in range(3))
    shift_x, shift_y, shift_z = (origin - center for origin, center in zip(translation, frame[:3]))
    local = set()
    for x, y, z in positions:
        x, y, z = x + shift_x, y + shift_y, z + shift_z
        if not (isfinite(x) and isfinite(y) and isfinite(z)):
            raise ValueError("Non-finite GLB vertex")
        local.add((bx[0] * x + bx[1] * y + bx[2] * z,
                   by[0] * x + by[1] * y + by[2] * z,
                   bz[0] * x + bz[1] * y + bz[2] * z))

    # Roblox displays the mesh in its current Size, even when a form or an art
    # fit scales it. Store unit-box coordinates around the original mesh center.
    low = tuple(map(min, zip(*local)))
    high = tuple(map(max, zip(*local)))
    center = tuple((a + b) * .5 for a, b in zip(low, high))
    width = tuple(b - a for a, b in zip(low, high))
    if min(width) <= 0:
        raise ValueError("Defeat support requires a three-dimensional body group")
    return tuple(sorted(tuple((v - c) / size for v, c, size in zip(point, center, width)) for point in local))


def _read_art(art, manifest, stems, skip=()):
    visuals = load_starter_fighter_assets(manifest, art=art, stems=stems)
    for fighter, stem in sorted(stems.items()):
        if fighter in skip:
            continue
        path = art / f"{stem}.glb"
        data = path.read_bytes()
        document = _glb_json(data, path)
        json_length, = struct.unpack_from("<I", data, 12)
        binary_header = 20 + json_length
        if binary_header + CHUNK_HEADER.size > len(data):
            raise ValueError(f"{path} has no binary mesh payload")
        length, kind = CHUNK_HEADER.unpack_from(data, binary_header)
        binary_offset = binary_header + CHUNK_HEADER.size
        if kind != b"BIN\0" or binary_offset + length > len(data):
            raise ValueError(f"{path} has an invalid binary mesh payload")
        binary = memoryview(data)[binary_offset:binary_offset + length]

        bindings = json.loads((art / f"{stem}_bindings.json").read_text(encoding="utf-8"))["groups"]
        scene = document["scenes"][document.get("scene", 0)]
        nodes = {document["nodes"][index]["name"]: document["nodes"][index] for index in scene["nodes"]}
        for group, binding in sorted(bindings.items()):
            node = nodes[binding["node"]]
            size, frame = visuals[fighter][group][3], visuals[fighter][group][5]
            points = _mesh_local_vertices(_positions(document, binary, node), node.get("translation", (0, 0, 0)), frame)
            yield fighter, group, size, points


def _mesh_groups():
    yield from _read_art(ART, MANIFEST, FIGHTERS, skip=("reedguard-kangaroo",))
    yield from _read_art(BOT_ART, BOT_MANIFEST, BOTS)


def _directions(count, phase=0):
    golden_angle = pi * (3 - sqrt(5))
    for axis in range(3):
        for sign in (-1, 1):
            yield tuple(sign if index == axis else 0 for index in range(3))
    for index in range(count):
        y = 1 - (index + .5) * 2 / count
        radius = sqrt(1 - y * y)
        azimuth = index * golden_angle + phase
        yield radius * cos(azimuth), y, radius * sin(azimuth)


def _extreme_index(points, direction):
    u, v, w = direction
    return max(range(len(points)), key=lambda i: points[i][0] * u + points[i][1] * v + points[i][2] * w)


def _compact_support(points, size):
    # Work in resized stud space so inaccuracies on a long axis get the
    # right weight. Start with the six axial extrema, then include the
    # actual vertex that improves the worst remaining sampled direction.
    scaled = tuple((x * size[0], y * size[1], z * size[2]) for x, y, z in points)
    directions = tuple(_directions(SUPPORT_DIRECTIONS))
    extreme_indices = tuple(_extreme_index(scaled, direction) for direction in directions)
    reference = tuple(sum(a * b for a, b in zip(scaled[i], direction))
                      for i, direction in zip(extreme_indices, directions))
    selected = set(extreme_indices[:6])
    approximation = [max(scaled[i][0] * u + scaled[i][1] * v + scaled[i][2] * w for i in selected)
                     for u, v, w in directions]
    while True:
        gaps = tuple(expected - observed for expected, observed in zip(reference, approximation))
        worst = max(range(len(gaps)), key=gaps.__getitem__)
        if gaps[worst] <= TRAINING_ERROR:
            break
        index = extreme_indices[worst]
        selected.add(index)
        x, y, z = scaled[index]
        approximation = [max(observed, x * u + y * v + z * w)
                         for observed, (u, v, w) in zip(approximation, directions)]
    return tuple(tuple(round(value, 6) for value in points[index]) for index in sorted(selected))


def _support_groups():
    for fighter, group, size, vertices in _mesh_groups():
        yield fighter, group, size, vertices, _compact_support(vertices, size)


def build_defeat_mesh_support():
    """Return a frozen Luau fighter/group map of normalized MeshPart-local support points."""
    entries = {}
    for fighter, group, _, _, support in _support_groups():
        entries.setdefault(fighter, {})[group] = support

    lines = ["-- Generated from original Blender POSITION vertices and published MeshPart frames.",
             "local point = Vector3.new", "return table.freeze({"]
    for fighter, groups in sorted(entries.items()):
        lines.append(f"    [{json.dumps(fighter)}] = table.freeze({{")
        for name, support in sorted(groups.items()):
            lines.append(f"        [{json.dumps(name)}] = table.freeze({{")
            for x, y, z in support:
                lines.append(f"            point({x:.6f}, {y:.6f}, {z:.6f}),")
            lines.append("        }),")
        lines.append("    }),")
    lines.append("})")
    return "\n".join(lines) + "\n"


def _maximum_error(vertices, support, size, directions):
    scaled = tuple((x * size[0], y * size[1], z * size[2]) for x, y, z in vertices)
    sampled = tuple((x * size[0], y * size[1], z * size[2]) for x, y, z in support)
    maximum = 0
    for u, v, w in directions:
        actual = max(x * u + y * v + z * w for x, y, z in scaled)
        approximate = max(x * u + y * v + z * w for x, y, z in sampled)
        maximum = max(maximum, actual - approximate)
    return maximum


def validate_defeat_mesh_support():
    """Check independent dense directions and return the worst gap and sample counts."""
    directions = tuple(_directions(VALIDATION_DIRECTIONS, phase=.19))
    worst, groups, points, counts = (0, "", ""), 0, 0, {}
    for fighter, group, size, vertices, support in _support_groups():
        maximum = _maximum_error(vertices, support, size, directions)
        worst = max(worst, (maximum, fighter, group))
        groups += 1
        points += len(support)
        counts[fighter] = counts.get(fighter, 0) + len(support)
    return worst, groups, points, counts


if __name__ == "__main__":
    (error, fighter, group), groups, points, counts = validate_defeat_mesh_support()
    for fighter_name, count in sorted(counts.items()):
        print(f"{fighter_name}: {count} support points")
    print(f"{groups} body groups, {points} normalized points, {VALIDATION_DIRECTIONS + 6} validation directions.")
    print(f"Worst error {error:.6f} studs at {fighter} / {group}.")
    if error >= MAXIMUM_ERROR:
        raise SystemExit(f"Defeat support must be within {MAXIMUM_ERROR:.3f} studs.")
