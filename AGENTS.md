# Beast Dojo Agent Handoff

Read [README.md](README.md), [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md), and the relevant phase in [docs/ROADMAP.md](docs/ROADMAP.md) before editing. Read the [game design](docs/GAME_DESIGN.md) for the complete v1 scope. Start from the Studio checkpoint recorded in [releases/current.json](releases/current.json).

## Working rules

- Preserve the Grand Dojo-centered, six-district open world and existing routes. V1 has four combat rings, 24 fighters, three forms, four match modes, permanent trophies, and every supported Roblox device family including VR. Treat readiness for each device as a separate test.
- Use the [approved ring plan](docs/IMPLEMENTATION.md#four-ring-progression-plan). Grand Dojo opens at Level 1 with Juniper and is the sole PvP venue for Duel, Tag Team and Brawl. Cinder Level 3 has Bracken, Cloud-Top Temple Level 5 has Sablecrest, and the Galleon Level 7 has Granite. The satellites are Bot Spar venues. Unlock permanently for the account when any fighter meets the threshold. Keep district activities and co-op boss raids separately accessible under their own rules.
- Keep one Roblox Studio window. When delegating, assign independent files and give one agent control of Studio. Integrate and test the final built place.
- Show matched Studio screenshots when changing art or UI. Label offline renders, browser previews, Studio simulation and hardware checks accurately.
- Edit the Python builders, Luau runtime, and original art sources. Rebuild the generated place. Use [the source map](docs/IMPLEMENTATION.md#source-map) to find entry points.
- Preserve server authority for combat, progression and grants. Use DataStoreService for published saves, with safe session ownership, idempotency, migrations and recovery. Never replace a failed load with defaults. Studio uses temporary state. Keep the optional VPS off gameplay's critical path.
- Keep competitive rank distinct from earned, account-bound trophies. Preserve the approved Mild target for cartoon fighting and assess the final content before choosing actual Roblox audience labels.
- Use asset IDs and record creator, terms and release dependencies. Check Store assets detached in Studio first. Screen for scripts, confirm referenced assets load, and keep purchased models within the permissions that came with them.
- If the owner-private Site checkout exists at `sites/beast-dojo-production/`, read the current Sites skill before editing it. After a meaningful package, update its evidence, decisions and changelog and regenerate and publish the same owner-private site. The public portable roadmap and handoff remain usable from a clone without that Site. The owner copy of the full workspace history is in `docs/local/AGENTS.owner.md` when available.
- After a verified work package, stage related files only. Check the staged diff for sensitive data and large generated files, update the portable handoff, commit, and push to `origin/main` with an authorized account. Review any upstream changes and preserve history. This cadence follows completed work packages.
