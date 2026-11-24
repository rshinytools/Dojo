"""Build the standalone Blender review package for the four alpha fighters."""

import argparse
import importlib.util
from pathlib import Path
import sys


SOURCE = Path(__file__).resolve().parent
SHARED_BUILDER = SOURCE.parent / "sparring-bots/build_bots.py"
ROSTER = (
    ("reedguard", "Reedguard Kangaroo", "Reedguard_Kangaroo", "9C674A", 13),
    ("penguin", "Penguin Brawler", "Penguin_Brawler", "4F8395", -14),
    ("gorilla", "Silverback Gorilla", "Silverback_Gorilla", "857456", 9),
    ("salamander", "Fire Salamander", "Fire_Salamander", "A05A48", -19),
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=SOURCE / "assets")
    parser.add_argument("--fighter", choices=[entry[0] for entry in ROSTER])
    parser.add_argument("--lineup", action="store_true")
    parser.add_argument("--quick", action="store_true")
    parser.add_argument("--preview-only", action="store_true")
    args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:])
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    spec = importlib.util.spec_from_file_location("standalone_fighter_builder", SHARED_BUILDER)
    engine = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(engine)
    if not args.lineup:
        for fighter in ROSTER:
            if args.fighter is None or args.fighter == fighter[0]:
                pose = engine.p.art_pose if fighter[0] == "reedguard" else None
                engine.individual(fighter, out, args.quick, args.preview_only, source=SOURCE, preview_pose=pose)
    if args.lineup or (args.fighter is None and not args.preview_only):
        engine.lineup(out, args.quick, roster=ROSTER, filename="Dojo_Starter_Lineup")


if __name__ == "__main__":
    main()
