"""Rebuild the public checkout and check that its entry points are intact."""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
from xml.etree import ElementTree as ET
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
PLACE = ROOT / "roblox/grand-dojo/Beast_Dojo_Grand_Dojo.rbxlx"
RELEASES = ROOT / "releases"


def build(path):
    subprocess.run([sys.executable, "-B", str(ROOT / path)], cwd=ROOT, check=True)


def digest(stream):
    sha = hashlib.sha256()
    for block in iter(lambda: stream.read(1024 * 1024), b""):
        sha.update(block)
    return sha.hexdigest()


def verify_place():
    required = {"Grand Dojo City", "Fighting Ring", "Trophy Hall", "Lantern Relay",
                "Wind Court", "Wind Court side ramp", "CityRoutes", "PlayerProfiles", "GrandDojoSparring", "SparringBots",
                "CombatIntro", "CombatEffects", "CombatCueAssets", "CombatAudio", "CombatHealth", "ReedguardRound", "ReedguardFightMotion",
                "ChampionshipHud", "ChampionshipPortraits", "ChampionshipBotPortraits",
                "ReedguardCombatPoses", "JuniperCombatPoses",
                "PenguinCombatPoses", "BrackenCombatPoses", "SilverbackCombatPoses", "SablecrestCombatPoses",
                "FireSalamanderCombatPoses", "GraniteCombatPoses", "FrogCombatPoses", "OtterCombatPoses",
                "FighterChoreography", "RoosterCombatPoses", "GliderCombatPoses", "SkyFighterCombat",
                "ArenaFields", "ScorpionCombatPoses", "ShrimpCombatPoses", "EmberAquaCombat",
                "WalrusCombatPoses", "TortoiseCombatPoses", "HeavyFighterCombat", "RingRicochet",
                "ArmadilloStrikerCombatPoses", "KomodoCombatPoses", "MagmaFighterCombat", "armadillo-striker", "komodo-dragon",
                "ElectricOwlCombatPoses", "BighornRamCombatPoses", "ThunderFighterCombat", "electric-owl", "bighorn-ram",
                "HoneyBadgerCombatPoses", "EmeraldSaberToothCombatPoses", "ApexFighterCombat", "honey-badger", "emerald-saber-tooth",
                "GreatWhiteSharkCombatPoses", "AbyssalKrakenCombatPoses", "AbyssFighterCombat", "great-white-shark", "abyssal-kraken",
                "Juniper Tortoise", "Bracken Boar", "Sablecrest Lynx", "Granite Rhino", "SplashArtwork",
                "Fighter Select Station", "SwitchFighterPrompt", "Resident Dojo Bots",
                "Cinder Terraces Ring", "Cloud-Top Temple", "Tideharbor practice ring",
                "RingProgression", "GrandDojoRingTraining", "RingTrainingCompleted",
                "GrandDojoDuel", "DuelCombatRound", "DuelSeries", "DuelRankLedger", "DuelRankRules",
                "DuelFightMotion", "Duel Court", "JoinDuelPrompt",
                "GrandDojoBrawl", "GrandDojoBrawlClient", "BrawlCombatRound", "BrawlFightMotion",
                "Brawl Entry", "Brawl Court", "JoinBrawlPrompt", "Spectator Return",
                "GrandDojoTagTeam", "GrandDojoTagTeamClient", "TagCombatRound", "Tag Team Entry", "Tag Team Court", "JoinTagTeamPrompt",
                "KilnbackRaid", "KilnbackRaidClient", "KilnbackRaidRound", "KilnbackRaidVisuals", "DojoRaidCompleted",
                "Kilnback Raid Entry", "Kilnback Raid Court", "JoinKilnbackRaidPrompt", "Kilnback Custodian", "Core Hit",
                "DojoRaids", "AbyssalRaid", "AbyssalRaidVisuals", "Abyssal Raid Entry", "Abyssal Raid Court",
                "JoinAbyssalRaidPrompt", "Abyssal Kraken",
                "SolarRaid", "SolarRaidVisuals", "Solar Raid Entry", "Solar Raid Court", "JoinSolarRaidPrompt",
                "Solar Phoenix",
                "StarterFighterChoice", "StarterFighterCatalog", "StarterFighterVisuals",
                "StarterFighters", "StarterFighterSelect", "reedguard-kangaroo",
                "penguin-brawler", "silverback-gorilla", "fire-salamander", "karate-frog", "river-otter",
                "rooster-kickboxer", "sugar-glider",
                "desert-scorpion", "pistol-shrimp",
                "walrus-sumo", "snapping-tortoise",
                "Lantern Circuit arched gateway", "Lantern orchard road terraces", "Lantern Court shopfronts",
                "Lantern Guild Beacon", "Terraced guild bluff", "Lantern foothill gardens", "Foothill irrigation pools",
                "West Valley planted ridge bench", "Lodge stone apron cap",
                "Frostglass west snow ledges", "Frostglass east snow ledges",
                "Tideharbor cargo hoist", "Recessed harbor soffit", "Kiln Hall recessed portico",
                "Kiln Hall interior glaze display", "HARBOR SQUARE ↑", "SALTWIND LOOKOUT →",
                "Relay garden Sakura tree", "Trophy Hall upper timber bays",
                "Fighting Ring canvas tailoring", "Recessed cedar ceiling panels",
                "Reedfall switchback wayfinding", "Reedfall upper lip foam",
                "Tideharbor tidal arch", "Sea Lantern Lookout", "Batten-sail harbor boat",
                "Windcut sea arch", "Low slate reefs", "Horizon sea fills", "Trophy Hall front amber portal",
                "Projected cedar gallery soffit", "Raked cedar gallery support",
                "Rose horizon range", "Mauve saddle range", "Arrival plume bank",
                "Soft lantern reflections", "Moss seams and shore grasses",
                "Swept sandstone stair shoulders", "Continuous sandstone coping",
                "Plaza city map board", "Cedar garden direction fascia", "Lantern Tower cedar ramp",
                "Lantern Relay sandstone runner", "Lantern lane stepped gardens", "Relay music volume", "Cedar Foothill Walk", "Foothill overlook guardrail", "Skywalk road cedar banks",
                "Cinder ravine clay terraces", "Frostglass snowy foothills", "Trophy Hall west blossom grove", "Western skyline peaks", "Whitewater crest streak", "Raised eave brass cheek", "Plum Lantern Walk", "EagleEye",
                "Trophy Hall split stair", "Jade crossing hall ramp", "Snowbell Ridge", "Snowbell walkable surface"}
    seen = set()
    routes = None
    notes = 0
    for _, node in ET.iterparse(PLACE, events=("end",)):
        if node.tag != "Item":
            continue
        props = node.find("Properties")
        name = props.findtext("*[@name='Name']")
        if name in required:
            seen.add(name)
        if name == "CityRoutes":
            routes = props.findtext("ProtectedString[@name='Source']").count("{name =")
        if node.get("class") == "Sound" and name in ("Note", "Summit Bell Chime"):
            if props.findtext("Content[@name='SoundId']/url"):
                notes += 1
        node.clear()
    if seen != required or routes != 16 or notes < 4:
        raise SystemExit(f"Studio place is missing expected content: {required - seen}; {routes=} {notes=}")


def verify_browser():
    content = (ROOT / "browser-game/content.js").read_text(encoding="utf-8")
    data = json.loads(content.removeprefix("window.BEAST_CONTENT = ").removesuffix(";\n"))
    if tuple(len(data[key]) for key in ("districts", "trophies", "fighters")) != (6, 30, 24):
        raise SystemExit("Browser content must include the design's six districts, 30 trophies and 24 fighters.")
    portable = (ROOT / "browser-game/Beast_Dojo.html").read_text(encoding="utf-8")
    if 'window.BEAST_CONTENT = ' not in portable or 'src="content.js"' in portable:
        raise SystemExit("The browser build must embed its runtime content.")


def verify_checkpoint():
    checkpoint = json.loads((RELEASES / "current.json").read_text(encoding="utf-8"))
    version = checkpoint["version"]
    expected = checkpoint["sha256"]
    archive_path = RELEASES / f"Beast_Dojo_Grand_Dojo_v{version}.zip"
    with ZipFile(archive_path) as archive, archive.open(PLACE.name) as content:
        packaged = digest(content)
    if packaged != expected:
        raise SystemExit(f"The packaged v{version} place differs from its recorded SHA-256: {packaged} vs {expected}")
    with PLACE.open("rb") as current:
        actual = digest(current)
    if actual != expected:
        raise SystemExit(f"The rebuilt place differs from v{version}: {actual} vs {expected}")
    print(f"Studio v{version} checkpoint SHA-256 {actual}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--checkpoint", action="store_true", help="Compare against the current pinned Studio ZIP.")
    args = parser.parse_args()
    for path in ("roblox/grand-dojo/build_place.py", "browser-game/build_content.py", "browser-game/package.py"):
        build(path)
    verify_place()
    verify_browser()
    if args.checkpoint:
        verify_checkpoint()
    print("Studio and offline browser builds passed the checkout check.")


if __name__ == "__main__":
    main()
