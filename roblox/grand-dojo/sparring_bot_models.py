"""Mount the original, Studio-imported Blender shells for each resident bot."""

from pathlib import Path

from starter_fighter_assets import build_fighter_visual_models, load_starter_fighter_assets

HERE = Path(__file__).resolve().parent
ART = HERE.parents[1] / "design/fighters/sparring-bots/assets"
MANIFEST = HERE / "sparring_bot_assets.json"
BOTS = {
    "Juniper Tortoise": "Juniper_Tortoise",
    "Bracken Boar": "Bracken_Boar",
    "Sablecrest Lynx": "Sablecrest_Lynx",
    "Granite Rhino": "Granite_Rhino",
}


def build_sparring_bot_models(parent, *, item, prop, part, asset, vector):
    models = load_starter_fighter_assets(MANIFEST, art=ART, stems=BOTS)
    library = item(parent, "Folder", "Resident Dojo Bots")
    build_fighter_visual_models(library, models, item=item, prop=prop, part=part, asset=asset, vector=vector)
    for model in library.findall("Item"):
        origin = part(model, "PoseOrigin", (0, 0, 0), (.2, .2, .2), "FFFFFF", collide=False, transparency=1)
        prop(origin, "bool", "CastShadow", False)
        prop(model, "Ref", "PrimaryPart", origin.get("referent"))
