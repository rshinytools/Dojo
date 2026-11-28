"""Run City Adventure progression and live-profile transaction regressions with Luau."""
import argparse
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory
from xml.etree import ElementTree as ET
from zipfile import ZipFile

from verify_cross_server_duel import as_local, source


def saved_profile_module(archive_path):
    with ZipFile(archive_path) as archive, archive.open("Beast_Dojo_Grand_Dojo.rbxlx") as place:
        for _, node in ET.iterparse(place, events=("end",)):
            if node.tag != "Item":
                continue
            if node.findtext("Properties/string[@name='Name']") == "PlayerProfiles":
                return node.findtext("Properties/ProtectedString[@name='Source']")
            node.clear()
    raise ValueError("Rollback archive has no PlayerProfiles module")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("luau", help="Path to a standalone Luau interpreter")
    parser.add_argument("--rollback", type=Path, help="Existing release archive to verify profile compatibility")
    args = parser.parse_args()
    names = ("FighterForms", "FighterTactics", "FighterLoadouts", "FighterLevelCurve", "CityAdventureCatalog", "QuickPlayCatalog")
    progress = source("CityAdventureProgress").replace(
        "local Catalog = require(script.Parent.CityAdventureCatalog)", "local Catalog = CityAdventureCatalog", 1
    ).replace('local QuickPlay = require(game:GetService("ReplicatedStorage").QuickPlayCatalog)', "local QuickPlay = QuickPlayCatalog", 1)
    profile = "local PlayerProfiles = {}" + source("PlayerProfiles").split("local PlayerProfiles = {}", 1)[1]
    program = "".join(as_local(name, source(name)) for name in names)
    program += as_local("CityAdventureProgress", progress) + as_local("PlayerProfiles", profile)
    ring_source = source("RingProgression").replace("local FighterLevelCurve = require(script.Parent.FighterLevelCurve)", "", 1)
    program += as_local("RingProgression", ring_source)
    program += as_local("StagingProgressionCases", Path(__file__).with_name("staging_progression_cases.luau").read_text())
    program += Path(__file__).with_name("city_adventure_cases.luau").read_text()
    if args.rollback:
        rollback = "local PlayerProfiles = {}" + saved_profile_module(args.rollback).split("local PlayerProfiles = {}", 1)[1]
        program += as_local("RollbackProfiles", rollback)
        program += """
do
    local store = PlayerProfiles.memoryStore()
    local current = PlayerProfiles.new(store, function() return now end, function() end)
    local rollback = RollbackProfiles.new(store, function() return now end, function() end)
    local tester = 8802
    StagingProgressionCases.seed(store, tester, now)
    StagingProgressionCases.migrate(current, tester, "new-version")
    StagingProgressionCases.rejoin(rollback, RollbackProfiles, RingProgression, tester, "rollback-version")
    StagingProgressionCases.rejoin(current, PlayerProfiles, RingProgression, tester, "new-version-again")
    print("Profile compatibility passed current build to archived rollback to current build.")
end
"""
    with TemporaryDirectory(prefix="beast-dojo-adventure-") as folder:
        fixture = Path(folder) / "verify.luau"
        fixture.write_text(program)
        subprocess.run([args.luau, fixture], check=True)


if __name__ == "__main__":
    main()
