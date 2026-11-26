"""Collision for the solid silhouettes and pedestrian rails in the city scene."""

from collections import defaultdict
from math import atan2, degrees, hypot


WALKING_RAILS = frozenset({
    "Blue cedar high walk rail", "Blue cedar vista rail", "Boardwalk cedar railing",
    "Cedar guard rail", "Cedarbank cedar railing", "Cloudstep Lookout guardrail",
    "Cloudstep cedar guardrail", "Copperwood lane rail", "Crown Crossing lacquered rail", "Elevated route rail",
    "Foothill overlook guardrail", "Galleon teal rail", "Gallery carved guardrail",
    "Gallery ramp rail", "Glacier Walk blue cedar rail", "Glaze cedar guardrail",
    "Kiln Ridge cedar guard", "Lantern Tower ramp guardrail", "Lantern Tower stair handrail",
    "Lantern garden cedar rail", "Lookout cedar guardrail", "Lookout rail", "Lookout rear rail",
    "Lookout side rail", "Lookout teal guardrail", "Lower red bridge rail",
    "Meltwater cedar rail", "Mistline approach rail", "Mistline cedar guardrail",
    "Orchard cedar guardrail", "Pinecrest cedar guardrail", "Plum Walk cedar guardrail",
    "Plum market rail", "Quay teal railing", "Saltwind teal guardrail",
    "Sky Pier teal railing", "Skybridge lacquered guardrail", "Skyline plum guardrail",
    "Snowbell cedar rail", "Terrace cedar guardrail", "Tidewatch teal guardrail",
    "Weavers’ ramp rail", "Wind Court ramp cedar rail", "Yard cedar guardrail",
})

# These raised overlooks have a drop immediately beyond their rails. Give the
# existing rail runs enough height to stop touch auto-jump as well as walking.
LOOKOUT_DROP_RAILS = frozenset({"Lookout rail", "Lookout rear rail", "Lookout side rail"})

SOLID_WALLS = frozenset({
    "Exchange side and rear walls", "Gallery side walls", "Harbor storehouse muted plaster",
    "Plum plaster panel", "Recessed cedar behind vendor counters", "Returning gallery shutter wall",
    "Setback vermilion gallery wall", "Upper wing rear gable", "Window bay vermilion wall",
})

SHALLOW_HILLSIDES = frozenset({
    "Coastal slate face", "Lanternwood slate face", "Lanternwood sage bench",
    "Orchard bluff sage stone", "Orchard bluff slate",
})

CONTACT_FACES = frozenset({
    "Arrival boulder face", "Coastal slate face", "Lanternwood slate face", "Lanternwood sage bench",
    "Orchard bluff sage stone", "Orchard bluff slate", "Pinecrest cliff face", "Reedfall rock face",
    "Reedfall rock ledge", "Slanted glacial rock face", "South Ridge exposed rock",
    "Split cliff shoulder", "Sunlit garden stone cap", "Weathered garden stone face",
})

# These display-only areas are beyond playable shoreline or are activity backdrops.
SCENIC_AREAS = frozenset({
    "Abyssal Raid Court", "Kilnback Raid Court", "Solar Raid Court",
    "Tideharbor offshore coast", "Cloudbreak Expert",
})


def shape(node, field, axes):
    data = node.find(f"Properties/*[@name='{field}']")
    return tuple(float(data.findtext(axis)) for axis in axes)


def make_solid(node):
    for property_name in ("CanCollide", "CanQuery"):
        node.find(f"Properties/bool[@name='{property_name}']").text = "true"


def add_world_collision(scene, *, part, prop, rock_material):
    """Use existing rock faces, inset mesh cores and contiguous low-rail guards."""
    rails = defaultdict(dict)

    def visit(container):
        for node in container.findall("Item"):
            cls = node.get("class")
            name = node.findtext("Properties/string[@name='Name']")
            if name in SCENIC_AREAS:
                continue
            if cls in {"Folder", "Model"}:
                visit(node)
                continue
            if cls == "Part" and name in SOLID_WALLS:
                make_solid(node)
                continue
            if cls == "WedgePart":
                # Distant painted ranges use SmoothPlastic. The slate facets near
                # the traversable valley use Rock; bound their physical footprint.
                is_ridge = (name in {"Mountain facet", "Western ridge slope"}
                            and node.findtext("Properties/token[@name='Material']") == str(rock_material))
                if name in CONTACT_FACES or is_ridge:
                    x, y, z = shape(node, "CFrame", "XYZ")
                    cutoff = 11 if is_ridge or name in SHALLOW_HILLSIDES else 52
                    north_harbor_road_edge = name == "Coastal slate face" and 194 <= x <= 209 and -69 <= z <= -44
                    if -420 <= x <= 410 and -6 <= y <= cutoff and -343 <= z <= 231 and not north_harbor_road_edge:
                        make_solid(node)
                continue
            if cls == "MeshPart" and name == "TS03_ENV_Rock_02_MossPatch":
                width, height, depth = shape(node, "size", "XYZ")
                if height < 1.05 or min(width, depth) < 1.4:
                    continue
                x, y, z = shape(node, "CFrame", "XYZ")
                r02, r22 = shape(node, "CFrame", ("R02", "R22"))
                core = part(container, "Bank boulder collision core", (x, y - .04 * height, z),
                            (width * .84, height * .94, depth * .84), "867C8C",
                            yaw=degrees(atan2(r02, r22)), shape=0, transparency=1)
                prop(core, "bool", "CastShadow", False)
                continue
            if cls != "Part" or name not in WALKING_RAILS:
                continue
            if name == "Elevated route rail" and node.findtext("Properties/bool[@name='CanCollide']") != "true":
                # Authored solid-rail routes already have a paired guard.
                continue
            # Almost all rails have upper/lower bars on the same endpoints. Use
            # the lowest one for a single continuous guard in that run.
            x, y, z, r02, r12, r22 = shape(node, "CFrame", ("X", "Y", "Z", "R02", "R12", "R22"))
            _, _, length = shape(node, "size", "XYZ")
            dx, dy, dz = (v * length / 2 for v in (r02, r12, r22))
            key = tuple(sorted(((round(x-dx, 2), round(z-dz, 2)), (round(x+dx, 2), round(z+dz, 2)))))
            if key not in rails[container] or y < rails[container][key][2]:
                rails[container][key] = (name, x, y, z, dx, dy, dz, length)

    visit(scene)
    for container, sections in rails.items():
        for name, x, y, z, dx, dy, dz, length in sections.values():
            # A handrail at 0.55–1.40 studs above the deck must still cover a
            # character's walking envelope below it. Leave gap endpoints open.
            height = 9.2 if name in LOOKOUT_DROP_RAILS else 3.15
            guard_y = y + .08 + (height - 3.15) / 2
            guard = part(container, f"Walkway guard · {name}", (x, guard_y, z),
                         (.30, height, length + .12), "875A4C",
                         yaw=degrees(atan2(dx, dz)), pitch=-degrees(atan2(dy, hypot(dx, dz))),
                         transparency=1)
            prop(guard, "bool", "CastShadow", False)
