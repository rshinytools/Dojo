"""Export a staging-only Casual Duel place from the current release checkpoint."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
from xml.sax.saxutils import escape
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
RELEASES = ROOT / "releases"
PLACE_NAME = "Beast_Dojo_Grand_Dojo.rbxlx"
CONFIG_FILE = ROOT / "roblox/grand-dojo/DuelTransportConfig.luau"
DISABLED = 'local Config = {Enabled = false, UniverseId = 0, PlaceId = 0, Protocol = "casual-v1"}'


def roblox_id(value):
    if not re.fullmatch(r"[1-9][0-9]{0,15}", value) or int(value) >= 2**53:
        raise argparse.ArgumentTypeError("expected a positive Roblox ID representable exactly in Luau")
    return int(value)


def staging_protocol(value):
    if not re.fullmatch(r"stage-[a-z0-9]+(?:-[a-z0-9]+)*", value) or len(value) > 24:
        raise argparse.ArgumentTypeError("use a unique stage- prefix and up to 24 lowercase letters, digits and hyphens")
    return value


def export(output, universe_id, place_id, protocol):
    if output.suffix != ".rbxlx" or output.is_relative_to(ROOT):
        raise ValueError("choose a new .rbxlx output outside the project checkout")

    checkpoint = json.loads((RELEASES / "current.json").read_text())
    with ZipFile(RELEASES / f"Beast_Dojo_Grand_Dojo_v{checkpoint['version']}.zip") as archive:
        place = archive.read(PLACE_NAME)
    source_digest = sha256(place).hexdigest()
    if source_digest != checkpoint["sha256"]:
        raise ValueError("the release archive does not match the checkpoint SHA-256")

    config = CONFIG_FILE.read_text(encoding="utf-8")
    if config.count(DISABLED) != 1:
        raise ValueError("the source must have exactly one default-disabled Casual Duel gate")
    enabled = (f'local Config = {{Enabled = true, UniverseId = {universe_id}, '
               f'PlaceId = {place_id}, Protocol = "{protocol}"}}')
    name = '<string name="Name">DuelTransportConfig</string>\n        '
    archived = f'{name}<ProtectedString name="Source">{escape(config)}</ProtectedString>'.encode()
    staged_config = config.replace(DISABLED, enabled, 1)
    staged = f'{name}<ProtectedString name="Source">{escape(staged_config)}</ProtectedString>'.encode()
    if place.count(archived) != 1:
        raise ValueError("the archived DuelTransportConfig differs from the checked-out source")
    result = place.replace(archived, staged, 1)

    with output.open("xb") as file:
        file.write(result)
    return {"version": checkpoint["version"], "source_sha256": source_digest, "staging_sha256": sha256(result).hexdigest(),
            "universe_id": universe_id, "place_id": place_id, "protocol": protocol, "output": str(output)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--universe-id", type=roblox_id, required=True, help="ID of the isolated private staging experience")
    parser.add_argument("--place-id", type=roblox_id, required=True, help="ID of the staging experience's start place")
    parser.add_argument("--protocol", type=staging_protocol, required=True, help="fresh stage- namespace for this drill")
    parser.add_argument("--output", type=Path, required=True, help="new .rbxlx file outside the checkout")
    args = parser.parse_args()
    try:
        receipt = export(args.output.resolve(), args.universe_id, args.place_id, args.protocol)
    except (OSError, ValueError) as error:
        parser.exit(1, f"{error}\n")
    print(json.dumps(receipt, indent=2))


if __name__ == "__main__":
    main()
