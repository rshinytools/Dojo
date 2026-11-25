# Beast Dojo

Beast Dojo is a Roblox martial-arts adventure centered on the Dojo Ring. Players travel between six districts, train with animal fighters, and earn trophies through matches, exploration, and festival activities.

**Current Roblox checkpoint** v0.339. See [what is playable and what remains](docs/IMPLEMENTATION.md), the [game design](docs/GAME_DESIGN.md), and the [16-phase roadmap](docs/ROADMAP.md). Read [AGENTS.md](AGENTS.md) before handing the project to an AI coding agent.

## Play the Roblox checkpoint

Download [Beast_Dojo_Grand_Dojo_v0.339.zip](releases/Beast_Dojo_Grand_Dojo_v0.339.zip), extract it and open `Beast_Dojo_Grand_Dojo.rbxlx` in Roblox Studio. Use **Play**, preview the four starter fighters, and confirm who to play. Use Fighter Select on the east side of Festival Plaza to switch later. The highest level reached by any fighter unlocks Karate Frog at Level 2, River Otter at Level 3, Rooster Kickboxer at Level 4, Sugar Glider at Level 5, Desert Scorpion at Level 6, Pistol Shrimp at Level 7, Walrus Sumo at Level 8 and Snapping Tortoise at Level 9, and Armadillo Striker, Komodo Dragon, Electric Owl, Bighorn Ram, Honey Badger, Emerald Saber-Tooth, Great White Shark, Abyssal Kraken, Magma Grizzly Bear, Obsidian Hellhound, Golden Eagle and Celestial Storm Dragon at Level 10. Each fighter brings their own moves to every unlocked Bot Spar ring. Fight Juniper at Grand Dojo, Bracken at Cinder Terraces from Level 3, Sablecrest at Cloud-Top Temple from Level 5, and Granite at the Galleon Ring from Level 7. Two players sharing a server can choose **Casual**, **Best of 3**, or **Ranked** at the Grand Dojo Duel sign. Four players in one server can choose backup fighters at the **2v2 Tag Team** sign and join a team fight. Eight players sharing a server can join **Dojo Brawl** by the pavilion stairs. Four players can queue for co-op boss fights at **Kilnback Raid** in Cinder Terraces, **Abyssal Raid** in Tideharbor Coast, or **Solar Raid** in Lantern Circuit. Take Cedar Foothill Walk off the Skywalk approach, or climb Lantern Tower from Garden Lookout. The City Map on the east-side walk can plot a route to another district. Choose **Eagle Eye** on any district’s map to see the whole valley from above.

All twenty-four fighters have Warrior and Grandmaster outfits. Each fighter’s own XP unlocks them at Levels 5 and 10. Preview and equip either look at Fighter Select. The first successful evolution equip earns **A New Form** in the Trophy Journal.

The Reedguard–Juniper round was verified in desktop Studio and Galaxy A06 landscape simulation. The place refers to Roblox-hosted meshes, textures, and audio. Some need account or experience permissions. See [asset access](docs/IMPLEMENTATION.md#asset-access). Studio uses session data. Published data, purchases and physical devices have separate release tests.

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

With the standalone Luau runner installed, `python3 -B tools/verify_ranked_ledger.py luau` checks ranked rating writes, lost responses and reconnect recovery using the checked-in server modules.

## Continue with another AI coding agent

Clone the repository and open its root as the agent's workspace.

```sh
git clone https://github.com/rshinytools/Dojo.git
cd Dojo
python3 -B tools/verify_checkout.py --checkpoint
```

Give the agent a specific task and this starting brief.

> Read `AGENTS.md`, `docs/IMPLEMENTATION.md`, and the relevant phase in `docs/ROADMAP.md`. Use `releases/current.json` to identify the current verified Studio checkpoint. Find the source files for the requested change, rebuild the place, and record what you verified. Update the handoff when the checkpoint changes.

The checkout contains the source and design needed to continue. A collaborator who will push needs write access to the repository. Studio testing and publishing may also require access to the Roblox experience and its hosted assets. [Asset access and handoff details](docs/IMPLEMENTATION.md#asset-access)

## Project layout

| Location | Purpose |
| --- | --- |
| [roblox/grand-dojo](roblox/grand-dojo/) | Studio place generator, Luau runtime, geometry modules and original art pipeline |
| [browser-game](browser-game/) | Playable concept, rules sandbox and offline build |
| [design](design/) | Portable roster, district and trophy data, UI studies, fighter rig and authored assets |
| [docs](docs/) | Game design, implementation handoff, test evidence and release roadmap |
| [releases](releases/) | Verified playable Studio checkpoints in a compact ZIP |

## Commit and push

Use `main` as the handoff branch. After each verified work package, update the implementation notes or roadmap where relevant, commit the related files, and push to [rshinytools/Dojo](https://github.com/rshinytools/Dojo). Fetch `origin/main` and review incoming commits before integrating them. Stage the paths for that package, review `git diff --cached`, and use a descriptive commit message. After `git push origin main`, compare `git rev-parse HEAD` with the commit reported by `git ls-remote origin refs/heads/main`.

This is a public source repository. Use the portable docs for handoffs and keep private deployment credentials, inventory secrets, owner-only site files, local backups and unpublished third-party asset payloads outside Git. A public listing does not grant a software or asset license. [Third-party notices](THIRD_PARTY_NOTICES.txt)
