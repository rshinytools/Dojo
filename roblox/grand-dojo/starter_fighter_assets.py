"""Build the published MeshPart library for the four closed-alpha fighters.

Capture each imported part in Stud units with its CFrame relative to the shared
art floor, Y up and -Z forward. Capture MeshSize and Size independently. The
manifest records observed Roblox IDs, never session-local EditableMesh content.
Use --source-reference to print the authored GLB checksums, pivots and bounds.
"""

from hashlib import sha256
from math import isclose, isfinite
from pathlib import Path
import json
import re
import struct


HERE = Path(__file__).resolve().parent
ART = HERE.parents[1] / "design/fighters/starter-fighters/assets"
MANIFEST = HERE / "starter_fighter_assets.json"
FIGHTERS = {
    "reedguard-kangaroo": "Reedguard_Kangaroo",
    "penguin-brawler": "Penguin_Brawler",
    "silverback-gorilla": "Silverback_Gorilla",
    "fire-salamander": "Fire_Salamander",
}
BODY_GROUPS = {"Torso", "Head", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}
VEC3 = ("X", "Y", "Z")
FRAME = (*VEC3, "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22")


def _values(value, length, label, *, positive=False):
    if not isinstance(value, (list, tuple)) or len(value) != length or not all(
        isinstance(n, (int, float)) and not isinstance(n, bool) and isfinite(n)
        and (not positive or n > 0) for n in value
    ):
        raise ValueError(f"{label} requires {length} finite {'positive ' if positive else ''}numbers")
    return tuple(value)


def _exact_keys(mapping, expected, label):
    if not isinstance(mapping, dict) or set(mapping) != set(expected):
        raise ValueError(f"{label} must contain exactly {', '.join(sorted(expected))}")


def _object(value, label):
    if not isinstance(value, dict):
        raise ValueError(f"{label} requires a JSON object")
    return value


def _asset_uri(value, label):
    if type(value) is int and value > 0:
        return f"rbxassetid://{value}"
    if isinstance(value, str) and (match := re.fullmatch(r"(?:rbxassetid://)?([1-9]\d*)", value, re.ASCII)):
        return f"rbxassetid://{match[1]}"
    raise ValueError(f"{label} requires a published Roblox asset ID")


def _glb_json(data, path):
    if len(data) < 20:
        raise ValueError(f"Invalid GLB header in {path}")
    magic, version, total, length, chunk = struct.unpack_from("<4sIII4s", data)
    if (magic, version, total, chunk) != (b"glTF", 2, len(data), b"JSON") or length + 20 > total:
        raise ValueError(f"Invalid GLB header in {path}")
    return json.loads(data[20:20 + length])


def _bounds_match(actual, expected, label, tolerance):
    if any(not isclose(a, b, abs_tol=tolerance, rel_tol=0) for a, b in zip(actual, expected)):
        raise ValueError(f"{label} {actual} does not match the authored source {expected}")


def source_reference(art=ART, stems=FIGHTERS):
    """Read both portable sources and verify the per-group export coordinates."""
    fighters = {}
    for fighter_id, stem in stems.items():
        glb_path = art / f"{stem}.glb"
        payload = glb_path.read_bytes()
        glb = _glb_json(payload, glb_path)
        bindings = json.loads((art / f"{stem}_bindings.json").read_text(encoding="utf-8"))
        bound_groups = bindings["groups"]
        if not BODY_GROUPS <= bound_groups.keys() <= BODY_GROUPS | {"Tail"}:
            raise ValueError(f"{fighter_id} has incomplete or unexpected source body groups")
        if bindings["asset"] != glb_path.name or len(glb["images"]) != 1 or "bufferView" not in glb["images"][0]:
            raise ValueError(f"{fighter_id} must reference its own GLB and a single embedded color atlas")
        nodes = [glb["nodes"][i] for i in glb["scenes"][glb.get("scene", 0)]["nodes"]]
        by_name = {node["name"]: node for node in nodes}
        _exact_keys(by_name, {entry["node"] for entry in bound_groups.values()}, f"{fighter_id} GLB nodes")
        if len(nodes) != len(by_name) or len(glb["meshes"]) != len(by_name):
            raise ValueError(f"{fighter_id} must export one root mesh per body group")

        groups = {}
        for group_name, binding in bound_groups.items():
            path = f"{fighter_id}.{group_name}"
            node = by_name[binding["node"]]
            if {"matrix", "rotation", "scale", "children"}.intersection(node):
                raise ValueError(f"{path} must preserve the source floor axes and a translation-only pivot")
            pivot = _values(node.get("translation", (0, 0, 0)), 3, f"{path} pivot")
            _bounds_match(pivot, _values(binding["gltf_pivot_xyz"], 3, f"{path} binding pivot"), path, .001)
            primitives = glb["meshes"][node["mesh"]]["primitives"]
            if len(primitives) != 1 or primitives[0].get("mode", 4) != 4:
                raise ValueError(f"{path} must export one triangle primitive")
            primitive = primitives[0]
            if "TEXCOORD_0" not in primitive["attributes"]:
                raise ValueError(f"{path} is missing the authored atlas UVs")
            count = glb["accessors"][primitive["indices"]]["count"]
            if count <= 0 or count % 3 or count // 3 != binding["triangles"]:
                raise ValueError(f"{path} triangles do not match the source bindings")
            bounds = glb["accessors"][primitive["attributes"]["POSITION"]]
            low, high = (_values(bounds[key], 3, f"{path} {key} bounds") for key in ("min", "max"))
            world_low = tuple(a + b for a, b in zip(pivot, low))
            world_high = tuple(a + b for a, b in zip(pivot, high))
            for key, values in (("min", world_low), ("max", world_high)):
                x, y, z = binding[f"blender_bounds_{key}_xyz"]
                _bounds_match(values, (x, z, y), f"{path} {key}", .001)
            groups[group_name] = {
                "node": node["name"],
                "pivot": pivot,
                "center": tuple((a + b) / 2 for a, b in zip(world_low, world_high)),
                "size": tuple(b - a for a, b in zip(low, high)),
                "triangles": count // 3,
            }
        if sum(group["triangles"] for group in groups.values()) != bindings["triangles"]:
            raise ValueError(f"{fighter_id} triangles do not match its complete art binding")
        fighters[fighter_id] = {"asset": glb_path.name, "glb_sha256": sha256(payload).hexdigest(), "groups": groups}
    return fighters


def _rigid_frame(value, label):
    frame = _values(value, 12, label)
    x, y, z = (frame[i:i + 3] for i in (3, 6, 9))
    for row in (x, y, z):
        if not isclose(sum(n * n for n in row), 1, abs_tol=.001):
            raise ValueError(f"{label} has a scaled rotation basis")
    cross = (x[1] * y[2] - x[2] * y[1], x[2] * y[0] - x[0] * y[2], x[0] * y[1] - x[1] * y[0])
    _bounds_match(cross, z, f"{label} right-handed rotation", .001)
    return frame


def _local_pivot(part_frame, floor_pivot):
    """Return the anatomical attachment frame in the observed MeshPart basis."""
    delta = tuple(a - b for a, b in zip(floor_pivot, part_frame[:3]))
    transpose = tuple(part_frame[3 + row * 3 + column] for column in range(3) for row in range(3))
    position = tuple(sum(a * b for a, b in zip(transpose[i:i + 3], delta)) for i in (0, 3, 6))
    return (*position, *transpose)


def load_starter_fighter_assets(manifest_path=MANIFEST, *, art=ART, stems=FIGHTERS):
    """Validate exact source coverage before mutating any place XML."""
    manifest_path = Path(manifest_path)
    if not manifest_path.is_file():
        raise FileNotFoundError(f"Missing {manifest_path}. Import and publish every starter GLB with its color atlas, "
                                "then record the observed Roblox mesh, texture and floor-frame data.")
    manifest = _object(json.loads(manifest_path.read_text(encoding="utf-8")), str(manifest_path))
    if type(manifest.get("schema_version")) is not int or manifest["schema_version"] != 1:
        raise ValueError(f"{manifest_path} requires schema_version 1")
    fighters = manifest.get("fighters")
    _exact_keys(fighters, stems, "Fighter asset IDs")
    reference = source_reference(art, stems)
    visual_assets = {}
    for fighter_id, source in reference.items():
        observed = _object(fighters[fighter_id], fighter_id)
        if observed.get("glb_sha256") != source["glb_sha256"]:
            raise ValueError(f"{fighter_id} requires an upload from {source['asset']} with the current GLB checksum")
        groups = observed.get("groups")
        _exact_keys(groups, source["groups"], f"{fighter_id} body groups")
        visual_assets[fighter_id] = {}
        for group_name, expected in source["groups"].items():
            prefix = f"{fighter_id}.{group_name}"
            raw = _object(groups[group_name], prefix)
            mesh_id = _asset_uri(raw.get("mesh_id"), f"{prefix} mesh_id")
            texture_id = _asset_uri(raw.get("texture_id"), f"{prefix} texture_id")
            texture_channel = raw.get("texture_channel", "texture")
            if texture_channel not in ("texture", "color_map"):
                raise ValueError(f"{prefix} texture_channel must be texture or color_map")
            size = _values(raw.get("size"), 3, f"{prefix} size", positive=True)
            mesh_size = _values(raw.get("mesh_size"), 3, f"{prefix} mesh_size", positive=True)
            cframe = _rigid_frame(raw.get("cframe"), f"{prefix} cframe")
            _bounds_match(cframe[:3], expected["center"], f"{prefix} floor-relative center", .055)
            floor_size = tuple(sum(abs(cframe[i + j]) * size[j] for j in range(3)) for i in (3, 6, 9))
            _bounds_match(floor_size, expected["size"], f"{prefix} Stud-unit size", .055)
            visual_assets[fighter_id][group_name] = (mesh_id, texture_id, texture_channel, size, mesh_size,
                                                      cframe, _local_pivot(cframe, expected["pivot"]))
    return visual_assets


def build_starter_fighter_visuals(storage, *, item, part, prop, asset, vector, manifest_path=MANIFEST):
    """Emit a folder of floor-aligned, textured fighter Models under ReplicatedStorage."""
    library = item(storage, "Folder", "StarterFighterVisuals")
    build_fighter_visual_models(library, load_starter_fighter_assets(manifest_path),
                                item=item, part=part, prop=prop, asset=asset, vector=vector)
    return library


def build_fighter_visual_models(library, visual_assets, *, item, part, prop, asset, vector):
    """Write validated, floor-aligned rigid shells with anatomical attachments."""
    for fighter_id, groups in visual_assets.items():
        model = item(library, "Model", fighter_id)
        for name, (mesh_id, texture_id, channel, size, mesh_size, cframe, pivot) in groups.items():
            if fighter_id == "reedguard-kangaroo" and name == "Tail":
                # Shorten the tail from its attachment while retaining its fitted thickness.
                scales = (.48, .48, .39)
                scaled_pivot = tuple(value * scale for value, scale in zip(pivot[:3], scales))
                center = tuple(cframe[i] + sum(cframe[3 + 3 * i + j] * (pivot[j] - scaled_pivot[j])
                                               for j in range(3)) for i in range(3))
                cframe = (*center, *cframe[3:])
                size = tuple(value * scale for value, scale in zip(size, scales))
                pivot = (*scaled_pivot, *pivot[3:])
            group = part(model, name, cframe[:3], size, "FFFFFF", class_name="MeshPart", collide=False)
            frame_property = group.find("Properties/CoordinateFrame[@name='CFrame']")
            group.find("Properties").remove(frame_property)
            vector(group, "CoordinateFrame", "CFrame", FRAME, cframe)
            vector(group, "Vector3", "InitialSize", VEC3, mesh_size)
            prop(group, "bool", "Massless", True)
            asset(group, "MeshContent", mesh_id)
            if channel == "color_map":
                appearance = item(group, "SurfaceAppearance", "Baked color atlas")
                asset(appearance, "ColorMapContent", texture_id)
            else:
                asset(group, "TextureContent", texture_id)
            anchor = item(group, "Attachment", "ArtPivot")
            vector(anchor, "CoordinateFrame", "CFrame", FRAME, pivot)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-reference", action="store_true", help="print the four source group inventories")
    parser.add_argument("--manifest", type=Path, default=MANIFEST, help="validate this observed Roblox import manifest")
    options = parser.parse_args()
    if options.source_reference:
        print(json.dumps(source_reference(), indent=2))
    else:
        fighters = load_starter_fighter_assets(options.manifest)
        print(f"Validated {len(fighters)} starter fighters and {sum(map(len, fighters.values()))} mesh groups.")
