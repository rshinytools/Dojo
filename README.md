# Beast Dojo

Beast Dojo is a Roblox martial-arts adventure centered on the Grand Dojo Fighting Ring. Players travel between six districts, train with animal fighters, and earn trophies through matches, exploration, and festival activities.

**Current Roblox checkpoint** v0.211. See [what is playable and what remains](docs/IMPLEMENTATION.md), the [game design](docs/GAME_DESIGN.md), and the [16-phase roadmap](docs/ROADMAP.md). Read [AGENTS.md](AGENTS.md) before handing the project to an AI coding agent.

## Play the Roblox checkpoint

Download [Beast_Dojo_Grand_Dojo_v0.211.zip](releases/Beast_Dojo_Grand_Dojo_v0.211.zip), extract it and open `Beast_Dojo_Grand_Dojo.rbxlx` in Roblox Studio. Use **Play**. Start at the festival plaza and follow the signs for the Fighting Ring, Lantern Relay, or Trophy Hall. Follow the west road to the Lantern Circuit gate or travel to Skywalk Peaks and take the Wind Court ramp to play the three chimes.

The ZIP is the verified desktop Studio checkpoint. The place refers to Roblox-hosted meshes, textures, and audio. Some need account or experience permissions. See [asset access](docs/IMPLEMENTATION.md#asset-access). Studio uses session data. Published data, purchases and physical devices have separate release tests.

## Build from source

Install Python 3.10 or newer and Roblox Studio. Run these commands from the repository root.

```sh
python3 -B roblox/grand-dojo/build_place.py
python3 -B browser-game/build_content.py
python3 -B browser-game/package.py
```

Open `roblox/grand-dojo/Beast_Dojo_Grand_Dojo.rbxlx` in Roblox Studio. The builder embeds the checked-in Luau scripts and uses original art and Studio asset references. Blender is optional for rebuilding the place. The [art pipeline](docs/IMPLEMENTATION.md#asset-access) describes when Blender is useful.

Open `browser-game/Beast_Dojo.html` for the offline browser concept. It has a separate save format and simulated matches. [Browser controls and testing](browser-game/README.md)

Run `python3 -B tools/verify_checkout.py` for a clean-clone build check. Add `--checkpoint` to compare the rebuilt Studio file with the pinned ZIP and its recorded hash. The check runs locally with the Python standard library.

## Project layout

| Location | Purpose |
| --- | --- |
| [roblox/grand-dojo](roblox/grand-dojo/) | Studio place generator, Luau runtime, geometry modules and original art pipeline |
| [browser-game](browser-game/) | Playable concept, rules sandbox and offline build |
| [design](design/) | Portable roster, district and trophy data, UI studies, fighter rig and authored assets |
| [docs](docs/) | Game design, implementation handoff, test evidence and release roadmap |
| [releases](releases/) | Verified playable Studio checkpoints in a compact ZIP |

## Commit and push

Use `main` as the handoff branch. After each verified work package, update the implementation notes or roadmap where relevant, commit the related files, and push to [rshinytools/Dojo](https://github.com/rshinytools/Dojo). Review incoming commits and staged changes before pushing. Use descriptive messages and preserve the existing history.

This is a public source repository. Use the portable docs for handoffs and keep private deployment credentials, inventory secrets, owner-only site files, local backups and unpublished third-party asset payloads outside Git. A public listing does not grant a software or asset license. [Third-party notices](THIRD_PARTY_NOTICES.txt)
