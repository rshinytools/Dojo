"""Run City Adventure progression and live-profile transaction regressions with Luau."""
import argparse
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

from verify_cross_server_duel import as_local, source


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("luau", help="Path to a standalone Luau interpreter")
    args = parser.parse_args()
    names = ("FighterForms", "FighterTactics", "FighterLoadouts", "CityAdventureCatalog")
    progress = source("CityAdventureProgress").replace(
        "local Catalog = require(script.Parent.CityAdventureCatalog)", "local Catalog = CityAdventureCatalog", 1
    )
    profile = "local PlayerProfiles = {}" + source("PlayerProfiles").split("local PlayerProfiles = {}", 1)[1]
    program = "".join(as_local(name, source(name)) for name in names)
    program += as_local("CityAdventureProgress", progress) + as_local("PlayerProfiles", profile)
    program += Path(__file__).with_name("city_adventure_cases.luau").read_text()
    with TemporaryDirectory(prefix="beast-dojo-adventure-") as folder:
        fixture = Path(folder) / "verify.luau"
        fixture.write_text(program)
        subprocess.run([args.luau, fixture], check=True)


if __name__ == "__main__":
    main()
