"""Refresh the portable design snapshot from the trusted owner's local sources."""

import argparse
import json
from pathlib import Path
import re
from xml.etree import ElementTree as ET
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "Beast_Dojo_Master_GDD.docx"
PLAN = ROOT / "sites/beast-dojo-production/dist/plan.json"
WORD = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
PRIVATE_URL = re.compile(r"https?://[^\s<>()]*\.chatgpt\.site[^\s<>()]*")


def word_tag(local_name):
    return WORD + local_name


def paragraph_text(node):
    return "".join(
        element.text or "" if element.tag == word_tag("t") else "\n"
        for element in node.iter()
        if element.tag in (word_tag("t"), word_tag("br"))
    ).strip()


def portable(text):
    return PRIVATE_URL.sub("the owner-private production notebook", text)


def cell_text(cell):
    return "\n".join(paragraph_text(p) for p in cell.findall(word_tag("p")))


def markdown_cell(text):
    return portable(text).replace("|", "\\|").replace("\n", "<br>")


def markdown_table(rows):
    header, *body = rows
    lines = [header, ["---"] * len(header), *body]
    return "\n".join("| " + " | ".join(markdown_cell(cell) for cell in row) + " |" for row in lines)


def game_design(body):
    for child in body:
        if child.tag == word_tag("tbl"):
            rows = [[cell_text(cell) for cell in row.findall(word_tag("tc"))] for row in child.findall(word_tag("tr"))]
            if rows:
                yield markdown_table(rows)
        elif child.tag == word_tag("p"):
            text = paragraph_text(child)
            if not text:
                continue
            style = child.find(f'{word_tag("pPr")}/{word_tag("pStyle")}')
            kind = style.attrib.get(word_tag("val")) if style is not None else ""
            headings = {"Title": "# ", "Heading1": "## ", "Heading2": "### ", "Heading3": "#### "}
            yield headings.get(kind, "") + portable(text)


def roster_from_word(body):
    table = next(table for table in body.findall(word_tag("tbl")) if len(table.findall(word_tag("tr"))) == 25)
    for index, row in enumerate(table.findall(word_tag("tr"))[1:]):
        element, name, rarity, role, hp, attack, _knockback, speed, ultimate = (
            cell_text(cell) for cell in row.findall(word_tag("tc"))
        )
        yield dict(id=index, name=name, element=element, rarity=rarity, role=role,
                   hp=int(hp.replace(",", "")), attack=int(attack), speed=int(speed),
                   ultimate=ultimate.split(":")[0])


def implementation_plan(plan):
    yield "# Beast Dojo Release Roadmap"
    yield (
        f"Portable phase snapshot for Studio checkpoint {plan['version']}, updated {plan['updated']}. "
        "See [Implementation](IMPLEMENTATION.md) for code entry points, verified play and open work."
    )
    if ring_plan := plan.get("world", {}).get("ringPlan"):
        yield "## Four combat rings"
        rows = [["Ring", "Unlock level", "Resident bot", "Match access"]]
        rows.extend(
            [ring["name"], str(ring["level"]), ring["bot"], "Bot Spar and PvP" if ring["pvp"] else "Bot Spar"]
            for ring in ring_plan["rings"]
        )
        yield markdown_table(rows)
        yield portable(ring_plan["access"])
        yield portable(ring_plan["pvp"])
        yield portable(ring_plan["progression"])
    for phase in plan["phases"]:
        yield f"## {phase['id']} {phase['name']}"
        yield portable(phase["goal"])
        yield f"**Status** {phase['status']}"
        if phase["depends"]:
            yield "**Dependencies** " + ", ".join(phase["depends"])
        yield "**Release gate** " + portable(phase["gate"])
        rows = [["ID", "Work item", "Status", "Acceptance"]]
        rows += [[task["id"], task["name"], task["status"], task["acceptance"]] for task in phase["tasks"]]
        yield markdown_table(rows)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--refresh-browser-data", action="store_true",
                        help="Copy the local owner plan and GDD roster into the browser design data.")
    args = parser.parse_args()
    if not DOC.is_file() or not PLAN.is_file():
        raise SystemExit("The owner Word GDD and generated private roadmap plan are required to refresh this snapshot.")
    with ZipFile(DOC) as archive:
        body = ET.fromstring(archive.read("word/document.xml")).find(word_tag("body"))
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    (ROOT / "docs/GAME_DESIGN.md").write_text("\n\n".join(game_design(body)) + "\n", encoding="utf-8")
    (ROOT / "docs/ROADMAP.md").write_text("\n\n".join(implementation_plan(plan)) + "\n", encoding="utf-8")
    if args.refresh_browser_data:
        browser_data = ROOT / "design/world-content.json"
        previous = json.loads(browser_data.read_text(encoding="utf-8"))
        existing = {district["id"]: district for district in previous["districts"]}
        # Keep the six-area browser simulation playable until its combat and quest rules migrate.
        districts = [dict(district, arena=existing[district["id"]]["arena"],
                          steps=existing[district["id"]]["steps"]) for district in plan["world"]["districts"]]
        data = dict(districts=districts, trophies=plan["trophies"]["catalog"],
                    fighters=list(roster_from_word(body)))
        browser_data.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
        )


if __name__ == "__main__":
    main()
