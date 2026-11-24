# Beast Dojo browser edition

Open `Beast_Dojo.html` in a browser for the portable build, or open `index.html` alongside the source files. The private production notebook also hosts the game. Progress belongs to the current browser and origin. Use the same entry point when continuing a save.

Start with Reedguard in Dojo Valley. Open the Journal and choose **Follow objective** if you need guidance. Each district offers a mentor chapter, two activities, three seals and an arena. Complete all six chapters, return to the Grand Dojo and win the graduation trial. Replay matches, event challenges and expert routes to finish all 30 trophies and unlock all 24 fighters. Trophies can be placed on six pedestals in a room you can walk around.

- Keyboard: WASD or arrow keys to move, E to interact, G to follow the objective, J to strike, K for the style skill, I for a charged signature, L to parry, Space to dash, R to tag and Escape to pause.
- Touch: tap paths and markers or drag the stick, then use the on-screen actions. Settings can show touch controls on any browser.
- Gamepad: use the left stick to move and A / Cross to interact. X / Square strikes, Y / Triangle triggers the style skill, RT / R2 uses the charged signature, B / Circle parries, LB / L1 dashes and RB / R1 tags. Menu opens the journal or pauses combat. The D-pad moves focus in menus.

## Finding the Dojo Ring and seeing the trophy room

Look for the gold **Dojo Ring** sign at the entrance to the red-trimmed platform. Click or tap the sign, or choose **Arena → Guide me to the Dojo Ring**. Follow the gold trail to the gate and choose **Start guided spar** when you're ready.

To try leveling right away, choose **Arena → Choose a bot → Fight Beginner bot**. A clean first win grants 105 XP, enough to reach Level 2. Check **Fighters** for XP to the next level. Each fighter has their own XP, with Warrior at Level 5 and Grandmaster at Level 10. Existing browser saves keep their XP and trophies.

Choose **Arena → Join casual queue** to see the simulated skill search widen. After eight seconds, you can keep waiting or switch to a practice bot. **Preview match found** demonstrates the accept or decline step in either queue. Ranked preview offers a human match simulation only. Browser matches never change competitive rank.

Choose **Arena → Boost preview** to activate free test boosts. Training XP doubles fighter XP for 15 minutes. PvE strength adds 15% damage for 10 minutes in guided sparring, bot practice and standard raids. Timers continue after closing the game. The browser has no Robux transactions.

Open **Trophies → My trophy room → Enter trophy room** to see your own six pedestals. Add `?showroom=1` to the game URL to see the same room with six sample awards. The sample uses separate in-memory state, so you can inspect it without unlocking trophies or affecting your adventure.

Roblox supports NPC mentors, training opponents and ambient characters. Use a native proximity prompt to give players a keyboard, gamepad or touch action at the arena gate and near mentors. [Roblox characters](https://create.roblox.com/docs/characters) · [Proximity prompts](https://create.roblox.com/docs/ui/proximity-prompts)

The browser edition uses a 2D camera, computer-controlled opponents and allies, achievement-based fighter unlocks, and local saves. Skills use shared action types with per-fighter tuning. Native Roblox multiplayer, trading, clan systems, real purchases, Roblox account saves and VR belong to the production roadmap.

## Roblox design references

- [Roblox Charts](https://www.roblox.com/charts) surfaced the popular examples below. Their documented systems suggest design patterns. The examples do not establish what caused their popularity.
- [Adopt Me! Journal update](https://www.playadopt.me/news/journal-update) documents collection categories and missing items. Beast Dojo uses original fighter portraits, element filters, earned and in-progress trophy entries, and requirements that players can track.
- [Blox Fruits](https://www.roblox.com/games/2753915549/Blox-Fruits) presents training, bosses, exploration and secrets together. Beast Dojo pairs visible district destinations with mentor chapters, an active objective, discoverable seals and raids.
- [Blade Ball](https://www.roblox.com/games/13772394625/Blade-Ball) describes a timing-centered challenge and controls for multiple input types. Beast Dojo keeps active combat controls visible, indicates incoming attacks and changes control prompts.
- [Roblox onboarding guidance](https://create.roblox.com/docs/production/game-design/onboarding) frames the first few minutes as a sequence of player actions. Beast Dojo puts one nearby mentor and an achievable trophy in the first minute, then opens up the world.

The art, maps, text, interface and generated sound cues are original to Beast Dojo. The game has no external runtime dependencies.

## Moving the concept into Roblox

`content.js` is generated from the portable roster, district and trophy data in `design/world-content.json`. Preserve stable district and trophy IDs when converting the design. `engine.js` holds simulation, quest stages, progression, fighters, modes and the save schema. Translate the rules to Luau and validate progression, rewards and inputs on the Roblox server. Store profiles through DataStoreService with session ownership and idempotent grants rather than migrating local browser saves.

Rebuild the terrain and visible markers using Roblox assets and native UI. `art.js` is a 2D art reference for silhouettes, frame composition and visual feedback. `game.js` demonstrates menus, input switching, onboarding and feedback. Implement shared action bindings, gamepad focus, safe areas and VR comfort with Roblox's input and UI systems. Use staging and physical hardware before claiming platform coverage.

Run `python3 -m http.server 8080` from this folder and open `http://localhost:8080` for development. `build_content.py` regenerates the runtime data with the Python standard library. `package.py` builds the portable single-file edition from the same runtime files.
