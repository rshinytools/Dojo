# Beast Dojo Implementation Handoff

The v0.211 Studio checkpoint is the starting point for new work. This repository contains the editable native implementation, an offline browser concept, the full [game design](GAME_DESIGN.md), and the [16-phase release roadmap](ROADMAP.md). The roadmap's release gates are wider than the current Studio build.

## Start here

1. Rebuild and open the Studio place using the [root README](../README.md). Use the ZIP when you want the pinned checkpoint immediately.
2. Start **Play** in one Studio window. Find the Fighting Ring, run the Lantern Relay, and visit Trophy Hall. Open the City Map to see the six districts and 14 mapped links.
3. Walk to Skywalk Peaks, climb the Wind Court ramp or stairs, and activate **Reed**, **Cloud**, then **Summit**. Try the browser concept separately to review the planned progression loop.
4. Check the appropriate phase before deciding which functionality a task should change. Record evidence for the exact build you tested.

## Source map

| Work area | First files to inspect |
| --- | --- |
| Place generation and map links | [build_place.py](../roblox/grand-dojo/build_place.py), the corresponding geometry module, and the generated `CityRoutes` ModuleScript |
| Open world activities and grants | [GrandDojo.server.luau](../roblox/grand-dojo/GrandDojo.server.luau), [CloudbreakTrial.server.luau](../roblox/grand-dojo/CloudbreakTrial.server.luau), [FrostglassReflectors.server.luau](../roblox/grand-dojo/FrostglassReflectors.server.luau) |
| Starter fighter, practice, and bot match | [Reedguard rig](../design/fighters/boxing-kangaroo/ReedguardKangaroo_Prototype.rbxmx), [GrandDojoSparring.server.luau](../roblox/grand-dojo/GrandDojoSparring.server.luau), [SparringRound.luau](../roblox/grand-dojo/SparringRound.luau) |
| Progression and trophy state | [PlayerProfiles.luau](../roblox/grand-dojo/PlayerProfiles.luau), [TrophyJournal.luau](../roblox/grand-dojo/TrophyJournal.luau), [design data](../design/world-content.json) |
| HUD, loading, input and local effects | [GrandDojo.client.luau](../roblox/grand-dojo/GrandDojo.client.luau), [GrandDojoSplash.client.luau](../roblox/grand-dojo/GrandDojoSplash.client.luau), [Town Life](../roblox/grand-dojo/GrandDojoTownLife.client.luau) |
| District music | [GrandDojoMusic.client.luau](../roblox/grand-dojo/GrandDojoMusic.client.luau), [MusicPlaylist.luau](../roblox/grand-dojo/MusicPlaylist.luau) |
| Browser rules, UI and art | [engine.js](../browser-game/engine.js), [game.js](../browser-game/game.js), [art.js](../browser-game/art.js) |
| Original meshes, baked textures and art exporters | [Art directory](../roblox/grand-dojo/art/) and [Studio walkthrough](../roblox/grand-dojo/README.md) |

The Python builder embeds the Luau from disk. Change source and rebuild so the Studio place includes the change. Studio can be used to test a scratch copy. Keep the source files as the authoritative handoff.

## Verified checkpoint

| Area | Evidence |
| --- | --- |
| Lantern Circuit and western connections | v0.211 desktop Studio confirmed both gate signs and walked the west road, Orchard High Walk, and Upper Market link to Frostglass Gardens in both directions. Studio captures show the new gate, slope terraces, and lower market shopfronts. |
| Native world | Six districts and 14 mapped links. Desktop Studio checks include Crown Crossing in both directions and the routes through Frostglass and Tideharbor. Coverage varies by route. |
| Wind Court | v0.210 desktop Studio walked the new ramp and nearby bridge routes both ways, and climbed the original stairs. The three keyboard prompts counted one melody. The client loaded the Wind Court notes and Cloudbreak summit bell. |
| Relay and Trophy Hall | Earlier desktop Studio runs completed the official Lantern Relay and displayed Lantern Keeper in Trophy Hall using the local session profile. |
| Fighting Ring | Earlier desktop Studio verified practice strikes and a guided sparring loop. Production clips, ranked matchmaking, full mode coverage, and the final roster remain release work. |
| Profiles | `PlayerProfiles.luau` implements a ten-level Reedguard curve, starter XP grants, the Relay record, and the Lantern Keeper award. Studio runs with a temporary store. The published DataStore path still needs reconnect, failure recovery, and cross-server checks. |
| Device input | Desktop Studio and a Galaxy A06 landscape simulator have scoped evidence. The simulator verified the compact Music toggle clear of the joystick. Physical phones, tablets, consoles, Chromebooks and VR still need verification. |

Use the [Studio walkthrough](../roblox/grand-dojo/README.md) for feature-specific controls, locations and previous checks. The native checkpoint hash is recorded in [releases/current.json](../releases/current.json). Use `python3 -B tools/verify_checkout.py --checkpoint` to compare the rebuilt file with the packaged place. Clean-clone checks exercise the build path and content shape. Studio behavior and device performance need their own tests.

## Preserve the release scope

The full v1 design includes 24 fighters with three forms, six arenas, four match modes, three original bosses, 30 earned trophies and personal rooms, six dense districts, mentor quests, events, and supported-device coverage. The current native world is a substantial playable slice. The browser prototype exercises broader progression and matchmaking ideas with local state and simulated opponents.

Priorities remain production Reedguard combat, published persistence, additional trophy grants, cross-device onboarding and HUD, and isolated staging. Expand content, matchmaking, monetization and launch work through the acceptance gates in the [roadmap](ROADMAP.md). The target for the final cartoon fighting is Mild, pending review of the actual Roblox experience. The optional VPS supports telemetry and private operations. Roblox progression and gameplay should remain usable if the VPS is unavailable.

## Asset access

The numbers in [Creator Store prop manifests](../roblox/grand-dojo/art/creator-store-props.json) and the builders are Roblox asset references. An account other than the original owner may see missing assets until the experience has permission. Verify dependencies in a separate test experience before publishing. Use only the assets your creator or experience is permitted to use.

The art tree holds original GLBs, textures, layout definitions, and Blender exporters. For example, `bake_fighting_ring_gate.py` generates the authored gate, and the native builder can use its generated geometry and Roblox references without starting Blender. The native place uses Studio geometry where an imported asset is still an art study. These distinctions are documented in the [Studio walkthrough](../roblox/grand-dojo/README.md).

The handoff includes a pinned Studio ZIP because the raw generated XML exceeds GitHub's single-file regular Git limit. Keep the raw place ignored. To record a new verified checkpoint, package the built place with `python3 -m zipfile -c releases/Beast_Dojo_Grand_Dojo_vVERSION.zip roblox/grand-dojo/Beast_Dojo_Grand_Dojo.rbxlx` and set the version and the place's SHA-256 in [releases/current.json](../releases/current.json). Local backups, purchased asset payloads, private deployment files and account credentials stay with the owner.

## Keep the handoff current

Edit `design/world-content.json` and rebuild the browser runtime if the prototype data changes. The owner workspace can refresh the portable GDD and roadmap using `python3 -B tools/export_owner_handoff.py` after regenerating the private plan. Its optional `--refresh-browser-data` flag deliberately copies the owner plan's district descriptions and roster into the browser prototype. Review the diff before choosing it.

After each verified implementation package, update this guide and the roadmap where relevant, run the checks, stage the related changes, and commit and push to `origin/main`. Keep deployment metadata and the owner-private notebook out of that commit.
