# Beast Dojo Master Game Design and Production Specification

Revision 0.5  Four-ring progression and solo production plan

Beast Dojo is a shared animal martial-arts adventure world centered on the Grand Dojo. Players explore connected districts, meet mentors, complete quests and activities, collect permanent trophies and enter arena fights. This specification defines the full v1 content baseline, progression, economy, all-device requirements and a gated path to production for one developer working with Codex. The optional VPS supports operations. See the implementation handoff for current play and release work.

| EXECUTIVE PRODUCTION BRIEF (FOR DEVELOPMENT TEAM)<br>• Target Release Scope: Full-scale, feature-complete v1.0 launch (24 custom-rigged animals, 3 evolution stages per fighter, 4 fighting rings, 4 game modes, Trading Plaza, Personal Trophy Rooms and Clan Dojos, and Battle Pass). The release also includes a shared six-district open world centered on the Grand Dojo, NPC mentor chapters, activities, secrets, permanent personal trophy collections and display rooms. Section 11 defines the content baseline.<br>• Tone & Roblox Compliance: Lighthearted, high-energy cartoon martial arts brawler (original animal fighters with independent martial arts styles, expressive poses and readable ring-out combat). Zero realistic blood, gore, or animal cruelty—use cartoon knockout stars, ragdoll knockouts, and comic-book VFX.<br>• Cross Platform Launch Requirement: Full compatibility with every device family currently supported by Roblox: iOS and Android phones/tablets, Windows and macOS computers, supported Chromebooks, Xbox, PlayStation, and supported VR headsets. Touch, keyboard/mouse, gamepad, and VR controls must support the complete core experience. Retain 3 active skills + Dash/Parry + Jump/Move; Tag-In is contextual in 2v2. Mobile usability is a baseline requirement for the shared design. |
| --- |

1. Core Gameplay Loop & Combat Mechanics

1.1 The World and Dojo Gameplay Loop

1. Explore and Choose: Enter the Grand Dojo grounds, restore your tracked goal and choose a mentor quest, district activity, secret hunt, social visit or arena match. Meet the mentor and earn a free starter on the first visit. Advanced trials and fast travel unlock through earned progress.

2. Adventure and Training: Walk into connected districts to follow mentor stories, solve puzzles, practice traversal, find permanent seals and enter marked encounters. The Grand Dojo Ring hosts Bot Spar and all competitive modes. Three district rings host local Bot Spar. Four-player boss raids use separate encounters.

3. Real-Time Physics Brawl (45–60s): Fast-paced arena combat where players deplete opponent HP or knock them outside the arena ring-out boundaries. Round endings use brief stylized ring-outs and neutral resets, without blood, injury detail, execution-like finishers or prolonged suffering. Target Mild for repeated mild cartoon violence, subject to actual content review.

4. Return and Grow: Earn server-validated Coins, Animal XP, world progress and permanent trophies. Return to the dojo to train, evolve fighters, customize a loadout, feature trophies in your personal room and choose the next adventure. Rank Points separately measure competitive standing.

1.2 Elemental Type System (4-Way Loop)

Adapted from strategic monster-battler mechanics into an intuitive, high-speed 4-element loop:

Elemental Advantage Cycle: Land (Green) beats Aquatic (Blue) → Aquatic (Blue) beats Magma (Red) → Magma (Red) beats Sky (Yellow) → Sky (Yellow) beats Land (Green).

Combat Multipliers: Super-Effective hits deal 1.25x Damage and 1.20x Knockback, displaying an oversized bright orange damage popup with a 'ELEMENT EDGE!' label with an original short percussion cue. Resisted hits deal 0.80x Damage and 0.85x Knockback.

1.3 Swappable 3-Button Loadouts & Class Passives

3-Slot Skill Architecture: Every animal uses 3 active buttons: Slot 1 (Basic Strike — 1.5s–2.5s CD), Slot 2 (Signature Tactical Move — 5s–8s CD), and Slot 3 (Ultimate Ability — charged via damage dealt/taken or 18s–24s CD), plus a universal Dash/Parry button (3s CD).

Loadout Customization: Each slot has 3 unlockable move variants (unlocked at Animal Levels 1, 10, and 20), giving 27 possible builds per animal while keeping the HUD restricted to 3 clean buttons.

Class Passives (Automatic): Heavy Class ('Unmovable': -30% knockback taken, light stagger immunity); Beast Class ('Enrage': below 30% HP, glows red and gains +25% Speed and +25% Knockback); Agile Class ('Slippery': -50% stun/freeze duration and +20% speed burst after dashing).

1.4 Viral Variants: Breeds, Mutations & 3-Stage Evolutions

Stat Breeds (Rolled on Hatch): Standard (Balanced), Giant (+15% Max HP, +15% model scale), Swift (+15% Move Speed, -10% Cooldowns), Fierce (+15% Damage & Knockback), Ironclad (+15% Knockback Resistance).

Visual Mutations (Rolled on Hatch): Normal (84.95%), Golden (10.0% — metallic gold shader + 1.1x Coin bonus), Neon (4.0% — glowing elemental outline), Prismatic (1.0% — rainbow shifting trail), Void (0.05% — dark matter particles + server-wide hatch announcement).

3-Stage Physical Evolution: Level 1–14: Rookie (base rig). Level 15–29: Warrior (gains elemental armor/wraps, glowing eyes, +10% size). Level 30: Grandmaster (gains championship belt/crown, animated elemental aura, +20% size).

2. Complete 24-Animal Launch Roster

All 24 launch fighters are distributed evenly across the 4 elements (6 per element) and 5 rarity tiers (8 Common, 8 Rare, 4 Epic, 2 Legendary, 2 Mythic).

| Element | Animal Fighter | Rarity | Class | Base HP | Base ATK | Base KB | Speed | Signature Ultimate Ability |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Land | Reedguard Kangaroo | Common | Agile | 1,000 | 100 | 105 | 18 | Reedstep Rising: pivoting body strike, opposite palm strike, then a short spring-rise launching strike; original choreography and sounds. |
| Land | Karate Frog | Common | Agile | 950 | 95 | 100 | 19 | Tadpole Tornado: Cyclone spin deflecting projectiles and whipping foes outward. |
| Land | Silverback Gorilla | Rare | Heavy | 1,350 | 115 | 125 | 15 | Seismic Chest-Pound: Ground slam creating a massive airborne shockwave ring. |
| Land | Snapping Tortoise | Rare | Heavy | 1,400 | 105 | 120 | 14 | Fortress Ricochet: Retracts into spiked shell and pinballs around ring for 4s. |
| Land | Honey Badger | Epic | Beast | 1,150 | 125 | 115 | 18 | Unstoppable Frenzy: 5s knockback/stun immunity with rapid cone slashes. |
| Land | Emerald Saber-Tooth | Legendary | Beast | 1,200 | 135 | 120 | 20 | Apex Pounce: Teleports to nearest foe with a claw slam that leaves a root zone. |
| Aquatic | Penguin Brawler | Common | Agile | 980 | 95 | 105 | 19 | Belly-Slide Blitz: High-speed icy slide bowling over all targets in path. |
| Aquatic | River Otter | Common | Agile | 960 | 100 | 100 | 19 | Pebble Barrage: Rapid-fire stone shotgun pushing enemies toward ring edge. |
| Aquatic | Pistol Shrimp | Rare | Agile | 940 | 120 | 135 | 18 | Cavitation Cannon: Full-arena sonic water blast with extreme horizontal KB. |
| Aquatic | Walrus Sumo | Rare | Heavy | 1,420 | 110 | 125 | 14 | Tidal Belly-Flop: High leap crash spawning a circular outward water wave. |
| Aquatic | Great White Shark | Epic | Beast | 1,180 | 130 | 120 | 19 | Jaws of the Deep: Dives invulnerable beneath floor and erupts under target. |
| Aquatic | Abyssal Kraken | Mythic | Heavy | 1,500 | 135 | 135 | 16 | Tentacle Cataclysm: Summons 4 giant tentacles slamming inward toward center. |
| Magma | Fire Salamander | Common | Agile | 960 | 105 | 95 | 19 | Magma Trail: Sprints in a circle leaving burning lava puddles that pop foes up. |
| Magma | Desert Scorpion | Common | Beast | 1,020 | 105 | 105 | 18 | Cinder Snare: Places three glowing ember nodes; after a visible warning, their triangular field briefly roots a foe for a follow-up strike. |
| Magma | Armadillo Striker | Rare | Heavy | 1,320 | 115 | 125 | 16 | Meteor Roll: Ignites into flaming boulder smashing shields and launching targets. |
| Magma | Komodo Dragon | Rare | Beast | 1,150 | 120 | 110 | 17 | Volcanic Breath: Sweeping flamethrower cone applying burn + steady pushback. |
| Magma | Magma Grizzly Bear | Epic | Heavy | 1,400 | 125 | 130 | 15 | Eruption Slam: Splits floor to erupt molten rock pillars in a forward line. |
| Magma | Obsidian Hellhound | Legendary | Beast | 1,180 | 140 | 120 | 20 | Hellfire Stampede: Summons 2 spectral fire clones charging full ring width. |
| Sky | Rooster Kickboxer | Common | Agile | 950 | 105 | 100 | 19 | Feather Flurry: Air vault into rapid bicycle-kick dive spiking targets down. |
| Sky | Sugar Glider | Common | Agile | 920 | 95 | 110 | 20 | Gust Vortex: Swoops overhead dropping a wind funnel that pulls then blasts out. |
| Sky | Electric Owl | Rare | Agile | 980 | 120 | 115 | 19 | Thunder Dive: Lightning blink into aerial dive strike with 1.2s stun shock. |
| Sky | Bighorn Ram | Rare | Heavy | 1,340 | 115 | 130 | 16 | Static Charge: Charging dash; longer travel distance scales explosion size. |
| Sky | Golden Eagle | Epic | Beast | 1,120 | 125 | 125 | 20 | Talon Drop: Grabs foe mid-air, carries toward ring edge for 1.5s, hurls down. |
| Sky | Celestial Storm Dragon | Mythic | Heavy | 1,480 | 140 | 135 | 17 | Tempest Roar: Hovers firing controllable lightning sky-beam + random thunder. |

3. Numerical Balance: Damage, Knockback & Level Scaling Spreadsheet

3.1 Core Combat Mathematical Formulas (Server-Authoritative)

| EXACT COMBAT FORMULAS FOR LUAU IMPLEMENTATION<br>• Level Scaling Multiplier (Levels 1 to 30): LevelMult = 1 + ((AnimalLevel - 1) * 0.04)  [Max 2.16x at Level 30]<br>• Rarity Stat Multiplier: Common = 1.00x \| Rare = 1.08x \| Epic = 1.16x \| Legendary = 1.24x \| Mythic = 1.32x<br>• Breed Stat Multiplier: +15% (1.15x) applied only to the Breed's specialized stat (Giant=HP, Fierce=ATK & KB, Swift=Speed).<br>• Final Damage Formula: FinalDamage = BaseSkillDamage * (AttackerATK / 100) * LevelMult * RarityMult * BreedMult * ElementMult * PassiveMult<br>• Server Knockback Impulse Formula: ImpulseVelocity (studs/sec) = (BaseSkillKB * (AttackerKB / 100) * (1 + ((1 - TargetCurrentHP / TargetMaxHP) * 1.45)) * ElementKBMult) / TargetWeightMult<br>• Weight Multipliers (TargetWeightMult): Agile Class = 0.90 \| Beast Class = 1.00 \| Heavy Class = 1.30 (includes Unmovable passive). |
| --- |

3.2 Skill Slot Coefficient & Cooldown Matrix

| Skill Slot | Move Archetype | Base Skill Damage | Base Skill KB | Cooldown (sec) | Hitbox Type | Notes / Hit-Stop |
| --- | --- | --- | --- | --- | --- | --- |
| Slot 1 (Basic) | 3-Hit Jab / Claw Combo | 65 / 75 / 95 | 35 / 40 / 60 | 1.6s | Forward Cone (8x6x8) | 3rd hit triggers 0.04s hit-stop |
| Slot 2 (Tactical A) | Gap-Closer / Dash Strike | 140 | 75 | 6.0s | Capsule Sweep (6x14) | Grants brief super-armor |
| Slot 2 (Tactical B) | Ranged Elemental Projectile | 125 | 70 | 5.5s | Linear Ray/Sphere (4r) | 85 studs/sec travel speed |
| Slot 2 (Tactical C) | AoE Ground Slam / Counter | 150 | 85 | 7.0s | Cylinder (14r x 6h) | Applies 0.8s micro-stun |
| Slot 3 (Ultimate) | Signature Ultimate Move | 280 – 340 | 130 – 160 | 20.0s (or Charge) | Custom Per Animal | 0.08s hit-stop + camera shake |
| Universal Dash | Evasive Roll / Air-Dash | 0 | 0 | 3.0s | Invulnerable 0.25s | Agile class gains +20% speed 1.5s |

3.3 Level 1–30 Progression, XP Curve & Stat Scaling Table

Reference progression table using a Standard Common Fighter (Base HP: 1,000 | Base ATK: 100 | Base KB: 100) versus a Mythic Fighter (Base HP: 1,500 | Base ATK: 140 | Base KB: 135). Ranked 1v1/2v2 modes apply a 'Competitive Normalization Cap' (clamping stats to Level 15 equivalent) while 8-Player Brawl, Boss Raids and Bot Spar use full uncapped stats.

| Level | Evolution Stage | XP to Next | Cumulative XP | Scale Mult | Common HP | Common ATK/KB | Mythic HP | Mythic ATK | Unlocks |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Rookie | 100 | 0 | 1.00x | 1,000 | 100 / 100 | 1,980 | 185 | Base 3-Move Kit |
| 3 | Rookie | 250 | 250 | 1.08x | 1,080 | 108 / 108 | 2,138 | 200 | Emote Slot 1 |
| 5 | Rookie | 450 | 850 | 1.16x | 1,160 | 116 / 116 | 2,297 | 214 | Slot 1 Alt Move B |
| 8 | Rookie | 850 | 2,650 | 1.28x | 1,280 | 128 / 128 | 2,534 | 237 | Elemental Trail VFX |
| 10 | Rookie | 1,200 | 4,650 | 1.36x | 1,360 | 136 / 136 | 2,693 | 251 | Slot 2 Alt Move B |
| 12 | Rookie | 1,650 | 7,450 | 1.44x | 1,440 | 144 / 144 | 2,851 | 266 | Stat Breed Boost +5% |
| 15 | WARRIOR EVO | 2,500 | 13,200 | 1.56x | 1,560 | 156 / 156 | 3,089 | 288 | Warrior Model + Armor + Slot 3 Move B |
| 18 | Warrior | 3,600 | 22,200 | 1.68x | 1,680 | 168 / 168 | 3,326 | 311 | Slot 1 Alt Move C |
| 20 | Warrior | 4,500 | 30,200 | 1.76x | 1,760 | 176 / 176 | 3,485 | 325 | Slot 2 Alt Move C |
| 22 | Warrior | 5,600 | 40,300 | 1.84x | 1,840 | 184 / 184 | 3,643 | 340 | Custom Victory Pose |
| 25 | Warrior | 7,500 | 59,500 | 1.96x | 1,960 | 196 / 196 | 3,881 | 362 | Slot 3 Alt Move C |
| 28 | Warrior | 10,000 | 85,500 | 2.08x | 2,080 | 208 / 208 | 4,118 | 384 | Mastery Badge |
| 30 | GRANDMASTER | MAX | 107,000 | 2.16x | 2,160 | 216 / 216 | 4,277 | 399 | Grandmaster Model + Aura + Crown |

3.4 Knockback Velocity & Ring-Out Calibration Table

Reference ring radius is 65 studs (from center spawn to ring-out drop). Engineers should calibrate LinearVelocity impulses against these target displacement benchmarks:

| Attack Scenario | Target HP % | Target Class | Element Matchup | Resulting Impulse | Est. Knockback Distance |
| --- | --- | --- | --- | --- | --- |
| Basic Jab (1st Hit) | 100% HP | Beast (1.0x) | Neutral (1.0x) | 35 studs/s | ~8 studs (micro-push) |
| Tactical Move (Slot 2) | 75% HP | Agile (0.9x) | Super Effective (1.2x) | 127 studs/s | ~28 studs (mid-ring launch) |
| Tactical Move (Slot 2) | 50% HP | Heavy (1.3x) | Resisted (0.85x) | 79 studs/s | ~16 studs (heavy anchor) |
| Signature Ultimate (Slot 3) | 50% HP | Beast (1.0x) | Neutral (1.0x) | 250 studs/s | ~55 studs (near-edge blast) |
| Signature Ultimate (Slot 3) | 25% HP | Agile (0.9x) | Super Effective (1.2x) | 403 studs/s | ~90+ studs (guaranteed ring-out) |

4. Game Modes, Arenas & Social Systems

4.1 Four Core Game Modes

1. 1v1 Ranked Duels at Grand Dojo (Best of 3 Rounds, 45s/round). Elo matchmaking across 6 divisions (Bronze, Silver, Gold, Diamond, Master, Dojo Champion). Uses Level 15 stat normalization so skill and elemental counter-picking decide winners.

2. 2v2 Tag-Team at Grand Dojo (90s Match). Each player brings a primary and backup animal. Pressing the 'Tag-In' button swaps fighters with a 12s cooldown and triggers an entry assist strike.

3. 8-Player King-of-the-Ring Brawl at Grand Dojo (60s Match). Chaotic free-for-all using full uncapped stats. Every 15 seconds, the outer ring tiles drop away, shrinking the safe platform until a final sudden-death showdown.

4. Co-op Boss Raids (4-Player PvE, Every 20 Mins) take place in separate raid encounters. Players team up against massive raid bosses (Kilnback Custodian, Abyssal Kraken, Solar Phoenix) with telegraphed AoE attacks to earn Raid Tokens and Mythic Capsule shards.

4.2 Four Fighting Rings and Their Unlocks

| Fighting Ring | Gate | Resident Bot | Play and Ring Features |
| --- | --- | --- | --- |
| Grand Dojo Ring<br>Grand Dojo City | Level 1<br>0 XP | Juniper Tortoise | Bot Spar and all PvP. Circular main ring. Competitive layouts use clear boundaries and readable perimeter bumpers. |
| Cinder Terraces Ring<br>Cinder Terraces | Level 3<br>180 XP | Bracken Boar | Bot Spar. Octagonal stone ring with clearly telegraphed geysers. |
| Cloud-Top Temple<br>Skywalk Peaks | Level 5<br>460 XP | Sablecrest Lynx | Bot Spar. Linked platforms with gust bridges and telegraphed lightning. |
| Galleon Ring<br>Tideharbor Coast | Level 7<br>830 XP | Granite Rhino | Bot Spar. Rectangular ship deck with a readable tilting mechanic. |

The server checks ring entry. When any fighter first reaches the required level, the ring unlock is saved to that player's account. Switching to a lower-level fighter keeps the ring open. Show the recommended fighter level alongside access status, and show how to earn XP when entry is locked. District roads, activities and spectator approaches remain open.

The XP totals above use the current ten-level Reedguard prototype curve. The first eligible Bot Spar win grants 60 XP and the first official Lantern Relay clear grants 80 XP. Each grant is available once per account. A proposed first completion of the Dojo Valley mentor's lantern-timing step adds 40 XP. Crediting all three to the same fighter reaches Level 3 at 180 XP. Later gates need several available XP paths from earlier bouts, mentor quests and activities.

4.3 Economy, Trading Plaza & Clan Dojos

Capsule / Egg Pricing & Drop Rates: Starter Capsule (100 Coins: 75% Common, 25% Rare); Grand Dojo Capsule (750 Coins: 60% Rare, 32% Epic, 8% Legendary); Mythic Shrine Capsule (3,500 Coins or 149 Robux: 65% Epic, 30% Legendary, 5% Mythic).

Dedicated Trading Plaza: Cross-server teleport hub featuring a 2-step confirmation trade window, 5-second anti-scam lock timer when items change, recent average value (RAP) tracker, and customizable showcase booths.

Clan Dojos: Up to 30 members per Dojo. Members donate Coins to upgrade Dojo Perks (+10% Coin gain, +10% XP gain, Dojo Banner cosmetics) and compete in weekly Dojo Wars leaderboards.

5. Technical Architecture & Engineering Standards

Server-Authoritative Combat & Anti-Cheat: All hitbox validation runs on the server via workspace:GetPartBoundsInBox / GetPartBoundsInRadius with generous ping compensation (120ms buffer). Never trust client damage claims.

Client-Predicted VFX & Hit-Stop: Clients play animations, particles, camera shake, and sound effects immediately on input for snappy responsiveness while awaiting server impulse confirmation.

Networking Optimization: Use ByteNet or BridgeNet2 to pack combat state updates and damage numbers into compact binary buffers, and profile frame time, memory, physics, and rendering on real target devices. Networking compression alone does not guarantee frame rate; apply the performance targets and acceptance tests below.

Data Persistence: Use Roblox DataStoreService as the authority for account progression across sessions, servers and devices. Implement versioned profiles, session ownership, idempotent reward/receipt grants, budget-aware checkpoints and recovery. Never overwrite a failed load with empty defaults. Evaluate and license any profile library before adoption. Multi-player trades require a durable journal and recovery protocol; two profile keys are not an atomic transaction.

Optional VPS Operations: Use HttpService for batched telemetry and a private read-only operations dashboard where useful. Prefer Roblox Configs for live tunables; any external configuration must be schema-validated, versioned, cached and activated between matches. Gameplay and progression saving must remain available during VPS outages. External community notifications are optional and authorized separately.

5.1 Cross Platform Controls and Interface

Shared actions: Use the Roblox Input Action System to bind movement, jump, three skills, Dash/Parry, interaction, menus, and contextual Tag-In across supported inputs. Adapt prompts and HUD visibility through UserInputService.PreferredInput and VR state, including when players connect or switch controllers during play. Combat rules, rewards, and account progression remain consistent across devices.

Complete access: Make queueing, loadouts, capsules, trading, clans, purchases, and settings usable with touch, keyboard/mouse, gamepad focus navigation, and VR interaction. Do not require hover, a mouse cursor, typing in chat, or an external link to complete core flows. Provide readable text, visible focus, confirm/back actions, and usable on-screen text entry where needed.

Adaptive presentation: Respect screen safe areas, notches, Roblox system UI, aspect ratios, window resizing, and supported orientations. Keep touch targets separated from movement/jump controls. Provide equivalent aim assistance and target selection where needed without changing damage rules. Use comfortable VR camera and readable VR menus; disable forced camera shake, camera snapping, and camera hit-stop in VR.

5.2 Performance Targets and Release Acceptance

Scalable rendering: Define Low, Medium, and High quality tiers with bounded particles, trails, dynamic lights, shadows, ragdoll lifetimes, and visible fighters. Preserve hazard warnings, hit feedback, and ring boundaries at every tier. Stream and preload assets as appropriate, pool effects, and measure memory and loading rather than assuming all 72 evolution models can remain resident.

Performance targets: Aim for a sustained 30 FPS or better on the selected low-end supported mobile/Chromebook test devices and 60 FPS on capable desktop/console hardware. VR must meet the current Roblox headset comfort/performance requirements. These are validation targets, not claims of achieved performance; record device models, quality settings, frame-time results, memory peaks, and known limits before release.

Release acceptance: Test actual phones/tablets, desktop, supported Chromebook, Xbox, PlayStation, and supported VR hardware, using Studio emulators as supplements. Run the full onboarding-to-match-to-reward flow, all four modes, full-player VFX stress cases, every menu, trade confirmations, input switching, safe-area/resizing cases, and interrupted connections. Verify publishing device settings for all supported categories. Any core-flow failure blocks launch on the affected device; all-device compatibility is not complete until every family passes.

Implementation references: Roblox Creator Hub cross-platform development https://create.roblox.com/docs/projects/cross-platform ; input https://create.roblox.com/docs/input ; VR guidelines https://create.roblox.com/docs/production/publishing/vr-guidelines . Recheck supported client/device requirements before release.

## 6 Solo Production Roadmap

Revision 0.5 defines solo production through acceptance evidence. The full v1 target includes a six-district world, permanent trophy collections, 24 fighters with three evolution stages, four fighting rings, four modes, trading, clans, reliable saving and all supported devices. Milestones replace fixed calendar promises.

The detailed implementation record is maintained at the owner-private production notebook Each phase below has explicit prerequisites, subphases and an exit gate. Optional VPS work can proceed alongside core work and does not gate launch.

### P0 Identity remediation and release boundaries

Remove identified references and establish original character and asset rules before scaling content.

Prerequisites: None

Subphases: P0.1 Naming and reference changes; P0.2 Original fighter and boss briefs; P0.3 Asset intake rules and register; P0.4 Scope and gameplay decisions.

Exit gate: Internal development may proceed after the documented substitutions are applied. Public promotion waits for P12 title and asset clearance.

### P1 Project setup and development safeguards

Make development reproducible and isolate production data.

Prerequisites: P0

Subphases: P1.1 Repository and Studio workflow; P1.2 Environment isolation; P1.3 Server and network contracts; P1.4 Build and rollback checks.

Exit gate: A clean checkout recreates the staging experience; development cannot modify live profiles or purchases.

### P2 One original fighter vertical slice

Make Reedguard Kangaroo enjoyable and controllable before producing the roster.

Prerequisites: P1

Subphases: P2.1 Inspection rig and design v2; P2.2 Movement and camera; P2.3 Original combat kit; P2.4 One arena and end-to-end loop.

Exit gate: One arena supports a complete playable match on touch, keyboard and controller, with a comfortable working VR baseline.

### P3 Persistent player progression

Implement safe saving before a persistent economy or trading.

Prerequisites: P2

Subphases: P3.1 Versioned account profile; P3.2 Session ownership and safe loading; P3.3 Idempotent rewards; P3.4 Autosave and recovery; P3.5 Player save feedback.

Exit gate: Committed progression survives reconnects, server changes and device changes; failure drills cannot wipe or duplicate profiles.

### P4 Native UI and all-device access

Translate the UI direction to Roblox while the feature set is still small.

Prerequisites: P2, P3

Subphases: P4.1 Native UI component library; P4.2 Input and safe-area layouts; P4.3 Onboarding and comfort; P4.4 Early physical-device checkpoint.

Exit gate: The core loop and menus work on every supported input family; untested hardware remains explicitly unverified.

### P4W Open-world foundation and Dojo Valley slice

Prove a shared explorable world with the Grand Dojo at its center before producing all districts.

Prerequisites: P3, P4

Subphases: P4W.1 World layout and traversal; P4W.2 Quest and activity framework; P4W.3 Streaming and server budgets; P4W.4 Shared-world rules and recovery.

Exit gate: Dojo grounds and one district support a complete mentor quest, two activities, three secrets, safe return and arena entry on target devices.

### P4T Permanent trophies and personal dojo

Give every player a saved achievement collection and a place to display it.

Prerequisites: P3, P4, P4W

Subphases: P4T.1 Trophy catalog and rank distinction; P4T.2 Authoritative awards and migration; P4T.3 Collection journal and goal tracking; P4T.4 Personal trophy room and visits.

Exit gate: Three original awards can be earned, committed, restored and displayed in an owner-controlled room; the complete 30-entry catalog has defined criteria.

### P5 Original asset pipeline and budgets

Prove one production-quality asset pipeline before creating 72 evolution representations.

Prerequisites: P2, P4

Subphases: P5.1 Originality and source review; P5.2 Production fighter asset; P5.3 Replacement boss pipeline; P5.4 Memory and effects budgets.

Exit gate: One fighter and the replacement boss have reviewed designs and a documented build/import/animation pipeline within measured budgets.

### P6 Four-fighter closed alpha

Validate fun, pacing and saving with a small complete game.

Prerequisites: P3, P4, P4W, P4T, P5

Subphases: P6.1 Four complete fighters; P6.2 Duel and brawl alpha; P6.3 Alpha playtests and measurement; P6.4 Alpha exit review.

Exit gate: External playtesters complete the Dojo Valley exploration/quest/trophy loop, matches, rewards and reconnects before full content production.

### P7 Complete roster and rich six-district world

Scale the proven fighter, world, quest and collection pipelines to full v1.

Prerequisites: P5, P6

Subphases: P7.1 Remaining twenty fighters; P7.2 Evolution, breeds and mutations; P7.3 Four fighting rings and original bosses; P7.4 Content balance and regression; P7.5 Six connected world districts; P7.6 Complete trophies and world events.

Exit gate: 24 fighters, three stages, six connected districts, four fighting rings, 18 mentor quest steps, 12 activity variants, 18 secrets, 30 trophies and two repeatable world events pass content checks.

### P8 Full multiplayer and social systems

Complete advanced modes, matchmaking and clans.

Prerequisites: P3, P6, P7

Subphases: P8.1 Ranked and matchmaking; P8.2 Tag-team and co-op raids; P8.3 Parties and clans; P8.4 Cross-server failure drills.

Exit gate: All four modes, parties and social progression work through disconnects, teleports and recovery.

### P9 Economy, purchases and safe trading

Add monetization and exchanges only after save correctness is demonstrated.

Prerequisites: P3, P4, P8

Subphases: P9.1 Progression economy and guaranteed cosmetics; P9.2 Random outcomes and eligibility; P9.3 Trading plaza transaction protocol; P9.4 Pass, season and rewarded ads.

Exit gate: Every economic grant is traceable and idempotent; restricted transactions are server-gated; crash drills cannot duplicate items.

### P10 Optional VPS operations

Use the existing VPS where it adds value beyond native Roblox services.

Prerequisites: P3 Optional infrastructure.

Subphases: P10.1 Telemetry and health; P10.2 Read-only support console; P10.3 Config, analysis and scheduling; P10.4 Optional community tools.

Exit gate: VPS outage does not prevent loading, playing, reward validation or saving; core release does not depend on this optional phase.

### P11 Full-content beta and reliability

Qualify the complete game with recorded functional and device evidence.

Prerequisites: P7, P8, P9

Subphases: P11.1 Full-content beta; P11.2 All-device release matrix; P11.3 Load and failure qualification; P11.4 Security and operational rehearsal.

Exit gate: Every mandatory device family and complete GDD core flow passes; critical data/economy/exploit defects block launch.

### P12 Final rights and Roblox release clearance

Review the actual release, not only its concept names.

Prerequisites: P0, P11

Subphases: P12.1 Title and brand clearance; P12.2 Complete asset and dependency audit; P12.3 Final expression and marketing review; P12.4 Roblox publishing and launch approval.

Exit gate: Final title, all production assets/dependencies, marketing and platform policies pass the documented release review.

### P13 Controlled production and maintenance

Launch gradually and maintain within solo capacity.

Prerequisites: P12

Subphases: P13.1 Staged launch; P13.2 Measure before optional marketing; P13.3 Sustainable updates; P13.4 Living implementation record.

Exit gate: The game is live with verified smoke tests, monitored progression/economy and a rehearsed rollback path.

7. Multi-Tier Monetization Architecture

| Product / Pass | Type | Price (Robux) | Player Value & Conversion Hook |
| --- | --- | --- | --- |
| Starter Champion Pack | One-Time Bundle | 199 Robux | Guaranteed Rare Fierce fighter + 2,500 Coins + 30-min 2x XP boost (shown after 2nd match). |
| Pro Dojo Bundle | One-Time Bundle | 799 Robux | Exclusive Cyber-Tiger skin + 15,000 Coins + 3 Mythic Capsules + Lightning Finisher. |
| VIP Dojo Membership | Gamepass | 399 Robux | Golden chat/overhead tag, +25% Coins forever, VIP Training Room, Cobalt Canopy wrap-and-belt cosmetic. |
| 2x Coins Forever | Gamepass | 249 Robux | Doubles all match, raid, and event Coin rewards (#1 high-volume seller). |
| 2x Animal XP Forever | Gamepass | 249 Robux | Doubles fighter XP to unlock Warrior (Lv.15) and Grandmaster (Lv.30) evolutions twice as fast. |
| Triple Hatch + Auto-Delete | Gamepass | 299 Robux | Opens 3 capsules simultaneously and auto-sells unwanted Common duplicates for Coins. |
| Season 1 Battle Pass | Seasonal Pass | 799 Robux | 50-tier reward track with exclusive Mythic skin, 3 finishers, emotes, and capsules (1,499 w/ +15 tiers). |
| Knockout Finisher Packs | Cosmetic Shop | 99–249 Robux | Custom ring-out explosions (Black Hole, Meteor Strike, Confetti Cannon, Comic 'POW!'). |
| Server-Wide 2x Luck / Boss | Dev Product | 99–199 Robux | Activates 15-min 2x Capsule Luck or spawns instant Raid Boss for entire server with global shoutout. |
| Rewarded Video Ads | Ad Kiosk (Free) | 0 Robux (Ad) | Optional lobby kiosk granting 1 Free Daily Spin or 15-min 2x Coins to monetize 100% of F2P players. |

## 8 Original Identity and Asset Requirements

Revision 0.4 applied the authorized IP remediation. The current title is Beast Dojo. The former shared subtitle and Kong-related boss are retired and appear only in archived research or revision history. These substitutions reduce known associations; final title and production-asset clearance remain release requirements.

### 8.1 Reedguard Kangaroo

A patient keeper of the reed training court who protects younger trainees by redirecting reckless challengers out of the ring.

One shorter tilted ear, broad planted feet, squared cloth-wrapped fists, an asymmetric reed forearm guard and a small shoulder pad. Cream abdomen patch; no pouch passenger.

Teal cloth wraps and a reed brace with cream bindings; plain dojo belt; no recognizable franchise costume or crest.

Reedstep Rising: pivoting body strike, opposite palm strike, then a short spring-rise launching strike. Independent animation timing and original impact sounds.

Revised native-Part inspection prototype exists. Final mesh, movement/attack clips and sound are not implemented or cleared.

### 8.2 Kilnback Custodian

Ceramic-and-brass tortoise automaton. Low quadruped with an octagonal segmented ceramic shell, four short brass legs, side-mounted bellows and a small reed-capped head.

An overzealous training-court maintenance machine that mistakes the raid party for debris.

Kiln Pulse: bellows vents flash before a slow radial steam pulse.

Tile Sweep: one shell plate tilts and sends a clearly marked rolling tile wave.

Cool-down Window: steam vents open, exposing a glowing ceramic core for a short damage phase.

The v0.281 Studio checkpoint implements the original native boss rig, chamber, attack animations and co-op encounter. The raid has a confirmed hit-and-revive reward loop in the Studio profile path. Final boss audio, published play and physical-device verification remain open.

### 8.3 Abyssal Kraken

The Abyssal Kraken rises from an old tide gauge in Tideharbor’s sunken Storm Basin. Its indigo mantle, pearl core and four articulated arms contrast with the pale stone hazard marks. Its silhouette and choreography are original to Beast Dojo.

Undertow builds a raised ring of surf. The inner circle and the far perimeter provide two routes out. Tentacle Cataclysm slams four cardinal lanes inward in sequence, leaving diagonal gaps. In Air Pocket, the Kraken spreads its front mantle and exposes its pearl core. At half health the surf widens and the slams arrive closer together.

An eligible first clear earns Deepwater Team. Final boss audio, published play and physical-device verification remain release work.

### 8.4 Production asset rules

Create independent silhouettes, costume details, lore, maps, UI art, voices, music, effects and choreography. Do not use ripped or near-recreated franchise assets. Changing only a name or color does not establish clearance.

Use original Element Edge feedback and percussion. The scorpion tactical presentation uses an ember-node trap rather than a chained spear. Species, broad martial-arts ideas and ring-outs remain general gameplay concepts.

Retain asset origin, creator, version, permitted uses, license evidence and attribution requirements. AI-generated concepts and upload moderation are not rights-clearance certificates. The original portrait atlas is a retired concept reference, not approved production art.

Before promotion, complete current-title and similar-mark searches in relevant registers and common-law sources. Before launch, review the final meshes, clips, audio, UI, code dependencies and marketing. Assess material patent questions where warranted. Seek qualified IP review when a formal commercial clearance opinion is required.

Source guidance: U.S. Copyright Office https://www.copyright.gov/register/tx-games.html ; USPTO https://www.uspto.gov/trademarks/search/comprehensive-clearance-search-similar-trademarks ; Roblox https://create.roblox.com/docs/production/publishing/ip-guidelines .

## 9 Launch Experience and Maturity Requirements

Approved direction: preserve the fighting game and target an accurately disclosed Mild rating. Minimal is no longer the target. Frequent cartoon strikes, knockback and boss encounters must be disclosed truthfully; a GDD or browser preview cannot establish the assigned rating.

### 9.1 Launch and first session

Load essential assets and the authoritative account profile before gameplay. On a load failure, retry safely; never overwrite existing progress with a blank profile. Roblox account sign-in stays in the Roblox app.

First visit: title, free Reedguard introduction, movement practice and a short mentor quest on the dojo grounds. Offer exploration, a guided fight and the first permanent achievement, followed by safe reward saving and personal-room discovery. Returning players restore their chosen quest or trophy goal in the world. Do not interrupt entry with a shop, ad or capsule offer.

Touch layouts require comfortable targets and safe-area spacing. Consoles require clear confirm/back prompts and reliable native focus navigation; prompts must match the active device. Desktop, tablet, supported Chromebook and VR remain required. The browser study does not establish physical-device support.

Results distinguish pending, saving, saved and unavailable. Only authoritative confirmation can label a reward saved. Production grants must be idempotent and recoverable. The current mockup uses fictional progress and scripted combat; no real saving or multiplayer is implemented.

### 9.2 Mild presentation and truthful review

No blood, wounds, dismemberment or realistic suffering.

Use short stylized impacts, brief ring-outs and neutral round-end resets; no execution or prolonged injury presentation.

Elemental effects remain abstract; no detailed burning, electrocution or drowning.

Review the most intense attacks, bosses, audio, camera, trailers and paid content before submitting truthful ratings answers.

Review current Kids/Select eligibility separately from the content label; account, audience, regional and parental restrictions still apply.

These presentation requirements govern all existing skill, hazard and ultimate descriptions: use abstract elemental effects and short cartoon reactions. Review the most intense content and frequency, including cinematics, audio, bosses, cosmetics and marketing, in the current questionnaire. Recheck after material content changes.

### 9.3 Audience access and publishing costs

The rating label does not itself grant under-16 access. Check the current Kids and Select requirements, including creator verification, 2FA, applicable fee or qualifying subscription, real qualifying plays and evaluation. Initial availability and actual audience status must be confirmed in Creator Hub. Regional and parental restrictions may apply.

Roblox provides game-server hosting. Current all-age publishing eligibility can still require a per-game fee or qualifying subscription; optional marketing is not necessarily the only platform cash expense. Confirm the exact current requirements for the owner account before spending or release. The existing VPS remains optional.

Source guidance: https://about.roblox.com/safety-faqs ; https://create.roblox.com/docs/production/promotion/content-ratings ; https://create.roblox.com/docs/production/publishing/kids-and-select

## 10 Player Acquisition and Growth Gates

The 1,000 to 2,000 CCU objective is ambitious and unproven. Track daily peak, daily average and minimum concurrency separately. Average CCU equals DAU multiplied by total active minutes per daily player, divided by 1,440. At an assumed 25 minutes, 1,000 to 2,000 average CCU requires 57,600 to 115,200 DAU. At an illustrative peak-to-average ratio of three, the same peak requires 19,200 to 38,400 DAU. These are arithmetic scenarios, not demand forecasts or Roblox benchmarks.

Create clear, truthful discovery assets. Show the real playable exploration, earned trophies and fighting loop, with accurate title, icon and thumbnail. Test hooks and first-session delivery together; do not advertise features that are not playable.

Publish manageable gameplay clips. Planning suggestion: record once and produce two or three short clips per week when capacity permits. Show a readable hook, payoff and invitation using actual gameplay, captions and a channel-specific Roblox share link. Choose age-appropriate channels; game participation must not depend on children joining off-platform services.

Work with relevant small creators and real play groups. Offer an authentic, easy-to-play demo with a distinct share link for each partnership. Prioritize audience fit and retained players over follower count. Schedule small play sessions to provide real match density; do not purchase or fabricate engagement.

Make returning with friends convenient. Support appropriate invitations, party continuity, rematches and visible progression. Evaluate intentional co-play and return days without coercive streak loss, spam prompts or inflated engagement.

Use small updates only at a sustainable cadence. Use player feedback and measured exits to select updates. Keep reliability and device support ahead of a promised weekly roster expansion.

Measure qualified play, onboarding, first-round completion, durably committed reward, rematch, D1/D7 return and intentional co-play by acquisition source and device. Compare repeated mature cohorts against available matched Creator Analytics benchmarks and record sample sizes. No universal retention threshold or guaranteed marketing budget is assumed.

Optional paid acquisition starts after access eligibility, stability and credible retention are demonstrated. Choose an affordable hard campaign cap; compare truthful creative and cost per retained player. Ads do not buy Recommended for You ranking. Stop expansion when saving, device quality or retention weakens. No campaign or creator outreach has been executed.

Discovery — Roblox Creator Hub https://create.roblox.com/docs/discovery

Acquisition — Roblox Creator Hub https://create.roblox.com/docs/production/analytics/acquisition

Ads Manager — Roblox Creator Hub https://create.roblox.com/docs/production/promotion/ads-manager

Analytics dashboard — Roblox Creator Hub https://create.roblox.com/docs/production/analytics/analytics-dashboard

Retention — Roblox Creator Hub https://create.roblox.com/docs/production/analytics/retention

Share links — Roblox Creator Hub https://create.roblox.com/docs/production/promotion/share-links

Roblox Kids and Select — Roblox Creator Hub https://create.roblox.com/docs/production/publishing/kids-and-select

## 11 Open World and Permanent Trophy Collection

A shared animal martial-arts adventure world, with the Grand Dojo as the home, training and social center. Explore a district, meet a mentor, complete a quest or challenge, earn progress and a trophy, then return to your dojo to train and display what you achieved.

The user requested the richer open-world direction and personal trophy collections. The detailed district names and content counts below are the editable production baseline. The existing 24 fighters, three stages per fighter, four fighting rings, four fighting modes, clans, trading, saving and every Roblox-supported device remain required. Mild remains the target; new world content must be included in actual ratings and rights review.

### 11.1 Grand Dojo and world structure

Six connected, walkable districts with authored routes and landmarks. Build a compact, activity-rich world; size is determined by measured traversal and device budgets. Four fighting rings have entrances in the city. Grand Dojo can use separate match instances for queued PvP. Co-op boss raids have their own encounters.

The Grand Dojo houses mentors, training courts, the main ring, the world map and the quest board.

Dojo grounds: market, gardens, social seating, secrets and routes into the world.

Personal dojo: each player has a persistent trophy room and cosmetic display layout.

Clan dojo: a separate shared social space; personal trophies and room ownership never belong to the clan.

Full v1 baseline: six districts, six mentor chapters with three quest steps each, twelve activity variants, eighteen permanent secrets, thirty trophies and two repeatable world events. Reuse activity systems while authoring distinct routes, puzzles, dialogue and art for each district.

### 11.2 Six district briefs

#### Dojo Valley

Grand Dojo City and Reedgrove Court. The Grand Dojo Ring opens at Level 1. Juniper Tortoise runs Bot Spar, and this ring hosts every PvP mode.

Mentor: Reed court keeper. Chapter: Find your footing.

Quest path: Meet the dojo mentor and learn movement. Then Complete the reed-path course and lantern timing drill. Then Finish a guided spar and return to the dojo.

Activities: Reed-path parkour; Lantern timing drill. Secrets: Three tucked-away reed seals. Mastery: Reed-path expert course.

#### Tideharbor Coast

Harbor paths, tide pools and shipwreck overlook. The Galleon Ring opens at Level 7 for Bot Spar with Granite Rhino.

Mentor: Harbor instructor. Chapter: Restore the harbor route.

Quest path: Find the harbor instructor and activate the shore marker. Then Carry training parcels across the tide-path route. Then Finish the harbor practice drill and report back.

Activities: Tide-path traversal; Harbor delivery route. Secrets: Three hidden tide seals. Mastery: Tide-path expert course.

#### Cinder Terraces

Kiln workshops, steam lifts and ceramic gardens. The Cinder Terraces Ring opens at Level 3 for Bot Spar with Bracken Boar.

Mentor: Kiln workshop keeper. Chapter: Set the workshop right.

Quest path: Meet the keeper and inspect three marked vents. Then Solve the bellows timing puzzle to restore the lift. Then Finish the workshop practice drill and return the repaired training tile.

Activities: Bellows timing puzzle; Steam-lift ascent. Secrets: Three hidden kiln seals. Mastery: Steam-lift expert course.

#### Skywalk Peaks

Wind bridges, cliff paths and the cloud temple. Cloud-Top Temple opens at Level 5 for Bot Spar with Sablecrest Lynx.

Mentor: Wind-court instructor. Chapter: Reconnect the wind courts.

Quest path: Reach the wind court using its marked accessible route. Then Activate the bridge switches through a movement challenge. Then Finish the temple practice drill and reconnect the route.

Activities: Wind-bridge course; Chime sequence puzzle. Secrets: Three hidden wind seals. Mastery: Wind-bridge expert course.

#### Frostglass Gardens

Ice gardens, warm shelters and frozen ponds anchor the district's activities and mentor chapter.

Mentor: Garden caretaker. Chapter: Bring the garden to life.

Quest path: Find the caretaker and survey three garden markers. Then Complete the sliding course and light puzzle. Then Finish the garden training trial and report back.

Activities: Ice-slide course; Reflector light puzzle. Secrets: Three hidden frost seals. Mastery: Ice-slide expert course.

#### Lantern Circuit

Neon courtyards, rooftop paths and a night market anchor the district's activities and mentor chapter.

Mentor: Circuit instructor. Chapter: Light the circuit.

Quest path: Meet the instructor and discover the rooftop route. Then Complete a signal-routing puzzle and delivery challenge. Then Finish the circuit practice drill and open the night display.

Activities: Rooftop delivery route; Signal-routing puzzle. Secrets: Three hidden circuit seals. Mastery: Rooftop expert course.

### 11.3 Activities and progression

NPC mentor chapters with short stories, persistent objectives and original dialogue. Chapter training drills stay available before a district's ring unlocks.

Traversal, timing, delivery and puzzle activities using reusable systems with different district layouts.

Permanent secrets and a discovery journal; exploration rewards do not require random purchases.

Opt-in Bot Spar at the four rings, all three PvP modes at Grand Dojo, and four-player Co-op Boss Raids at separate encounters.

Repeatable Lantern Relay and Training Festival world events; schedule and player-count scaling tested before release.

Personal trophy-room decorating, animal practice, player visits and clan gatherings.

Original ambient soundscapes, small NPC interactions and recognizable district landmarks; atmosphere must respect low-effect and comfort settings.

Basic exploration opens after the introduction; mentor chapters unlock advanced trials and discovered fast-travel points. No paid key is required for the core world.

World progress and ring unlocks are account-wide. Fighter XP, evolution and move mastery remain per fighter. Changing animals preserves quests, discoveries and unlocked rings.

Track one chosen quest and show a clear return-to-dojo action. Let players choose exploration or arena play without forcing a ranked win to continue the story.

Safe social routes do not allow unsolicited player damage. Fighting happens in clearly marked encounters, sparring courts, matches and opted-in events.

NPC dialogue uses authored choices. Core navigation and cooperative objectives do not require chat, an external account or clan membership.

World activity rewards use server eligibility and participation evidence; no last-hit-only credit or client-declared completion.

### 11.4 Permanent personal trophies

A permanent, account-bound collection of earned achievements, each with an original physical trophy and a journal entry. Rank Points measure competitive standing and can change. Trophy Collection records permanent earned achievements. Trophies are not currency, tradable fighters or a paid random drop.

Collection journal: earned, in progress and locked entries; category filter, exact requirement, progress and earned date.

Tracked goal: pin one trophy requirement to the world journal.

Personal trophy room: six featured pedestal slots plus paged wall displays. Choose a trophy for any unlocked display slot.

Room decoration and engraved dates are cosmetic. Do not require a paid shelf to access the collection or display the basic six trophies.

Room visits are opt-in and server-authorized. Visitors can inspect displays but cannot edit them.

### 11.5 Trophy catalog baseline

#### Journey

First Footing. Complete the introductory mentor quest, not simply the first login. Stable ID: journey-01.

A Chapter Begins. Complete the three-step Dojo Valley mentor chapter. Stable ID: journey-02.

Six Horizons. Discover the arrival checkpoint in all six districts. Stable ID: journey-03.

A New Form. Complete the first server-confirmed fighter evolution. Stable ID: journey-04.

Mentors Remember. Complete all six mentor chapters. Stable ID: journey-05.

Dojo Graduate. Complete the graduation quest after the six mentor chapters. Stable ID: journey-06.

#### Discovery

Dojo Valley Explorer. Find all three permanent seals in Dojo Valley. Stable ID: discovery-valley.

Tideharbor Coast Explorer. Find all three permanent seals in Tideharbor Coast. Stable ID: discovery-coast.

Cinder Terraces Explorer. Find all three permanent seals in Cinder Terraces. Stable ID: discovery-cinder.

Skywalk Peaks Explorer. Find all three permanent seals in Skywalk Peaks. Stable ID: discovery-sky.

Frostglass Gardens Explorer. Find all three permanent seals in Frostglass Gardens. Stable ID: discovery-frost.

Lantern Circuit Explorer. Find all three permanent seals in Lantern Circuit. Stable ID: discovery-circuit.

#### Mastery

Dojo Valley Master. Complete the server-validated Reed-path expert course at its authored expert standard. Exact scoring belongs to the activity specification. Stable ID: mastery-valley.

Tideharbor Coast Master. Complete the server-validated Tide-path expert course at its authored expert standard. Exact scoring belongs to the activity specification. Stable ID: mastery-coast.

Cinder Terraces Master. Complete the server-validated Steam-lift expert course at its authored expert standard. Exact scoring belongs to the activity specification. Stable ID: mastery-cinder.

Skywalk Peaks Master. Complete the server-validated Wind-bridge expert course at its authored expert standard. Exact scoring belongs to the activity specification. Stable ID: mastery-sky.

Frostglass Gardens Master. Complete the server-validated Ice-slide expert course at its authored expert standard. Exact scoring belongs to the activity specification. Stable ID: mastery-frost.

Lantern Circuit Master. Complete the server-validated Rooftop expert course at its authored expert standard. Exact scoring belongs to the activity specification. Stable ID: mastery-circuit.

#### Arena

First Duel. Win one eligible completed duel. Stable ID: arena-01.

Ring Reader. Finish in the top three of an eligible eight-player brawl. Stable ID: arena-02.

Tag Partners. Win one eligible tag-team match. Stable ID: arena-03.

Ten Duels. Win ten eligible duels; duplicate result IDs never increment the counter. Stable ID: arena-04.

Steady Guard. Perform ten server-validated parries across eligible completed encounters. Stable ID: arena-05.

Ring Veteran. Complete twenty eligible arena matches with participation evidence. Stable ID: arena-06.

#### World challenges

Kiln Keeper. Earn participation credit for clearing the Kilnback Custodian encounter. Stable ID: world-01.

Deepwater Team. Earn participation credit for clearing the Abyssal Kraken encounter. Stable ID: world-02.

Dawn Return. Earn participation credit for clearing the Solar Phoenix encounter. Stable ID: world-03.

Lantern Keeper. Complete one Lantern Relay world event with validated participation. Stable ID: world-04.

Festival Regular. Complete three Training Festival activities with unique valid completion IDs. Stable ID: world-05.

World Champion. Earn all three boss-clear trophies and both world-event trophies in this category. Stable ID: world-06.

### 11.6 Saving and award integrity

Server verifies the catalog criterion from trusted quest, activity, match or encounter results. Clients can request inspection or a display edit; they cannot award a trophy.

Store a unique trophy ID, earnedAt timestamp, criterion version and source completion ID; commit eligibility and ownership with the profile. Replaying a completion or reconnecting grants once.

Use pending/saving/unavailable feedback until durable confirmation. A failed load cannot become an empty collection, and leaving is never the only save path.

Keep earned trophies across seasons. Version changed criteria explicitly and migrate old records without silently deleting legitimate awards.

Never sell the achievement, award ranked power for owning it, or allow it into the trading system. Cosmetic room rewards may accompany milestones.

Optional Roblox badges can mirror selected committed achievements. Badge-service failure must not erase or block the in-game collection.

Persistent fields: world.discoveredDistrictIds and discoveredFastTravelIds; world.questStates and committed completion IDs; world.secretIds and activity best results; trophies.earnedById with earnedAt, criterionVersion and sourceId; trophies.cappedProgressCounters and trackedTrophyId; dojo.featuredTrophyIds, roomThemeId and visitPermission.

### 11.7 World implementation and release gates

Start with one streamed main-world place and test connected district transitions. Keep queued matches and heavy raids isolated when performance or match integrity requires it. Final place boundaries are a measured P4W decision.

Use instance streaming, distance-based NPC activity, capped effects and reusable props. Do not keep every district, trophy or evolution model resident on every client.

Build streaming-safe quest markers and interactions: missing scenery cannot imply a quest is complete or let a client grant a reward.

Design join/return points, party regrouping, interrupted transfers and profile ownership together. Save a safe checkpoint ID rather than trusting arbitrary client coordinates.

Use repeated world-server instances with a profiled per-server population; the overall CCU goal does not imply every player shares one simulation.

Roblox services remain authoritative. VPS outages must not prevent exploration, quest rewards, trophy collection or saving.

First complete slice: Grand Dojo and its grounds; One complete Dojo Valley route; One three-step mentor chapter; Two repeatable activities and three secrets; Guided combat and an arena entrance; Personal trophy room with three working awards. Prove the world, quest and trophy loop on target devices before producing the other five districts. The complete v1 world remains planned scope; this is not a schedule or implementation claim.

Duplicate event, match and quest callbacks award once.

Reconnect, device change, transfer failure and throttling preserve the same earned collection.

A client cannot forge an award, inflate progress, place an unowned trophy or edit another player’s room.

Every one of the 30 criteria has a reproducible valid earning path and a blocked invalid path in staging.

All-device journal, controller focus, pedestal inspection and room visits pass native tests.

Missing streamed displays and optional BadgeService/VPS outages cannot remove earned records.

Technical sources: https://create.roblox.com/docs/workspace/streaming ; https://create.roblox.com/docs/cloud-services/data-stores ; https://create.roblox.com/docs/production/publishing/badges
