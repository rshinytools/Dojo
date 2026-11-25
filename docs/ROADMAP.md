# Beast Dojo Release Roadmap

Portable production roadmap for the approved four-ring plan. [Code entry points and verified play](IMPLEMENTATION.md)

## P0 Identity remediation and release boundaries

Remove identified references and establish original character and asset rules before scaling content.

**Status** In progress

**Release gate** Internal development may proceed after the documented substitutions are applied. Public promotion waits for P12 title and asset clearance.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P0.1 | Naming and reference changes | Complete | Canonical GDD, site and current design sources use the revised names; former names appear only in archived evidence or change history. |
| P0.2 | Original fighter and boss briefs | Prototype ready | New briefs and revised inspection geometry exist; final meshes, clips and audio still require review. |
| P0.3 | Asset intake rules and register | In progress | A concept or generated asset cannot be marked production-ready solely because it exists or passed upload moderation. |
| P0.4 | Scope and gameplay decisions | Decision needed | World and trophy baseline is recorded separately from implementation. One approved rules table is shared by combat data, progression and UI; no conflicting unlock schedules. |

## P1 Project setup and development safeguards

Make development reproducible and isolate production data.

**Status** In progress

**Dependencies** P0

**Release gate** A clean checkout recreates the staging experience; development cannot modify live profiles or purchases.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P1.1 | Repository and Studio workflow | Verified | A fresh checkout recreates the place and the offline browser build. Verify published staging separately under P1.2 and P11. |
| P1.2 | Environment isolation | Prototype ready | Rejoin a different private beta server with a disposable profile and prove that test progress and purchase identifiers stay isolated from production. |
| P1.3 | Server and network contracts | Planned | Malformed or repeated client requests cannot award resources or choose damage. |
| P1.4 | Build and rollback checks | Planned | A broken combat formula or save migration is detected before staging publication. |

## P2 One original fighter vertical slice

Make Reedguard Kangaroo enjoyable and controllable before producing the roster.

**Status** In progress

**Dependencies** P1

**Release gate** One arena supports a complete playable match on touch, keyboard and controller, with a comfortable working VR baseline.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P2.1 | Inspection rig and design v2 | Prototype ready | Geometry checks passed for the inspection geometry and playable outfit welds. Test the current costume for movement, jumps, stairs, motion clipping and supported-device camera views in Studio. |
| P2.2 | Movement and camera | Prototype ready | V0.322 fits Reedguard’s local ground stride to the visible paving. Each boot follows the stock step timing with a softer roll, alternating support and swing, and a contact shadow under the low edge. Desktop keyboard and Galaxy A06 landscape thumbstick checks retained one supporting boot in every sampled moving frame. Desktop reduced deepest sampled clipping from 0.499 to 0.009 studs and showed 0.179 studs of swing clearance. The native Space jump and live Juniper stance and sidestep passed the regression. Published Roblox and physical-device verification remain open. V0.321 shortens Reedguard’s tail from 0.865 to 0.778 studs across all three forms. The local standing pose checks the full boot outline and tilts at shallow edges. Desktop Studio sampled the fitted boots at spawn, around the promenade edge and in live Juniper Bot Spar. The adjustment applies to the visible boots. V0.319 adds takeoff, airtime and landing poses to normal arena jumps. Desktop Studio checked Reedguard against Juniper and both views of a Casual Duel. The 24-fighter fit and unsupported fall logic passed exact-source checks. V0.318 removes the local idle hip lift in the ring and reads the visible plaza flagstone for foot placement and shadows. Desktop Studio checked ordinary idle, Juniper’s intro and the live stance. All three forms mount the 0.865-stud tail. V0.316 fits lateral footwork across the roster. Exact Luau verified all 24 kits and native desktop Bot Spar checked both directions for Penguin and Golden Eagle. V0.314 fits local Reedguard’s standing boots to plaza flagstone and keeps the pose active during Lantern Timing. Desktop Studio checked the plaza, bridge and real drill. The equipped tail is 0.95 studs long. V0.309 fits each local idle boot to the floor. Desktop and Galaxy A06 Studio verified the bridge boot contact and a 1.04-stud equipped tail. V0.305 levels local Reedguard’s boots while idle on flat ground and trims the tail to 1.12 studs. Desktop and Galaxy A06 Studio checked the toe, center and heel at arrival. Desktop also checked stopping on the promenade. V0.302 shortens Reedguard’s tail to 1.24 studs, strengthens his boot shadows, and corrects the opening height in Duel, Tag Team and Brawl. Desktop Studio checked the plaza, promenade and the two-client Casual Duel intro. V0.296 levels Reedguard’s standing soles in the ring and adds lightweight contact shadows at his boots. The plaza spawn support follows the paving. V0.275 fits both fighters to the viewport and restores the city camera. Galaxy A06 landscape and forced portrait simulations completed a match. Verify slopes, camera clearance and comfort on physical devices and VR. |
| P2.3 | Original combat kit | In progress | V0.340 extends Basic and Ultimate alternatives to Penguin, Silverback and Fire Salamander. All four starters have three choices in each slot. V0.339 completes Reedguard’s three-slot loadout and adds independent saved choices, a compact tabbed picker and immutable match loadouts for five modes. Extend Basic and Ultimate choices across the other 23 fighters. V0.327 preserves recoil in a simultaneous trade while keeping both confirmed effects and any earned signature camera cue. Two v0.327 desktop Studio clients matched both grounded recoil poses, both impact marks and synchronized HP for a staged Body–Jab trade. Published play and physical-device verification remain open. V0.326 gives all 24 fighters the authored early shoulder pose on an eligible opening light strike. The current combo state and existing busy windows gate the preview. The server continues to buffer and start Cross and Body, including when the local client has an earlier snapshot. Desktop Studio at 239 ms measured round trip showed Reedguard’s Jab on the first sampled frame (1.1 ms in this run). The server decision returned after 280.8 ms. The prior checkpoint first showed the Jab after 267.8 ms at 232 ms round trip. A real E–E–E sequence dealt 13, 14 and 15 damage at 180, 660 and 1,270 ms from the server’s opener. The next two presses carried no Jab preview. Studio also verified that an opener sent during a Palm stun yielded its preview and dealt no damage. Exact Luau checks covered the roster, preserved Heavy startup, and exercised stale replies, combo expiry, stun and Tag Team shell updates. Published play, hardware, and live verification of the other modes remain open. V0.325 starts the local Heavy windup from the equipped fighter’s authored shoulder pose on press. The preview blends into the authoritative animation after confirmation and clears on interruption. Desktop Studio at 240 ms median round-trip time showed Reedguard’s revised motion on the first sampled frame after input (0.9 ms in this run), with the decision returning after 264.3 ms. The earlier checkpoint first showed authored motion after 266 ms at 235 ms round trip. Penguin also showed the new Heavy motion after 0.8 ms at 235 ms round trip. The server resolved Reedguard’s 22-damage hit at 420 ms and Penguin’s 20-damage hit at 430 ms from acceptance. A Heavy input sent while Juniper had Reedguard stunned showed its early pose, then yielded to the incoming hit and returned to the original arm mount. Exact Luau checks covered all 24 kits, rejection and timeout, and the Reduced Motion and VR opt-out. Galaxy A06 landscape Studio simulation registered an actual Heavy touch, showed the preparation on the first sampled frame at about 250 ms round trip, and preserved the 420 ms contact and 11 damage against Shell Set. Published play, physical devices and live validation of the other modes remain open. V0.324 adds an authored 40 ms pose hold to the confirmed third combo strike for all 24 fighters. It adds one local camera pulse per damaging signature cast, keyed to the move’s meaningful hit. Nine grounded signatures also hold their contact pose for 80 ms. Desktop Studio Bot Spar verified the camera returns cleanly after Reedstep Rising and Silverback’s Seismic Chest-Pound. The observed peak shifts were 0.13 and 0.08 studs. The kick dealt 15 damage, Rising dealt 9, 9 and 14, and Seismic dealt 34. Exact-source checks covered every kit, per-cast deduplication, defense exclusions, stock camera, smaller touch motion, Reduced Motion and VR. Live checks in the other modes, published Roblox playback and physical devices remain open. V0.323 briefly holds Reedguard’s authored contact pose for 40 ms on the clean combo kick and 80 ms on the final clean Reedstep Rising hit. The attacker’s shoulders and the combo kick’s boot use the local hold, followed by a short blend back to the fight. Desktop Studio against Juniper verified both holds and their releases at roughly 15 frames per second. The kick still dealt 15 and Rising dealt 9, 9 and 14. Exact-source checks covered guarded contacts, Reduced Motion, VR, airborne cancellation and the unchanged root and health. Studio also loaded and played all six creator-owned combat sounds. Published play, physical devices and live checks of the other match modes remain open. V0.321 adds a shield for blocks, crossed cyan chevrons for parries, a golden strike mark and distinct guard-break and deflect cues. Desktop Bot Spar verified a zero-damage block, zero-damage parry and a 22-HP Heavy counter. Exact-source checks verified the effect caps for touch and Reduce Motion. Uploaded all six original WAVs to ApexGameD. Desktop Studio decoded and played every cue family. Live Reedguard–Juniper practice matched the four bell notes and the guard, parry and Heavy sounds to their native cues. V0.320 gives Bracken, Sablecrest and Granite one visible recoil on a confirmed mid-windup hit. Desktop Studio confirmed each attack reached its original deadline and a later attempt could still be parried. V0.317 verifies distinct resident footwork in Bracken, Sablecrest and Granite sparring bouts. All three back up when crowded and circle before committing. V0.315 verifies visible Juniper recoil during Stillwater Palm. A native Heavy and palm each dealt 22 damage, with the original glove path and parry cue. V0.312 articulates knockout falls for the playable roster and residents. A native Studio fixture checked all 72 forms, with separate Brawl Penguin and Bot Spar Juniper finish replays. V0.307 recovers a fresh missed shoulder recoil after a late server update. Native Duel and Bot Spar verified the visual response and exact damage. V0.306 plants Reedguard’s boots in head recoil, body recoil, parry and stagger. Exact mesh checks and native Studio confirmed grounded reactions. Clients cannot invent damage or bypass cooldowns. Review actual impacts, audio, finishers and camera against current rating definitions; no copied choreography. |
| P2.4 | One arena and end-to-end loop | Prototype ready | A fresh v0.322 desktop Studio profile selected Reedguard, walked to the Grand Dojo Ring and opened Juniper’s native challenge. The ten-second intro gave way to one block, three timed parries, two Heavy hits, Uppercut and all three Reedstep Rising hits, using automated keyboard input. Juniper reached zero health 13.32 seconds after the bell with Reedguard at 100 HP. The recap confirmed the first-win award of 60 XP and Close restored the city camera and interaction prompts. Studio used its local test profile. Published Roblox Player playback and a live reconnect still require a beta update. Verify final Reedguard shoulder poses and late guard cue in a fresh Studio Play session. Confirm the same complete loop using touch, gamepad and VR. Add remaining skills, animation polish and full combat feedback in the original combat kit. |

Desktop Studio verified the Reedguard–Juniper intro, Uppercut whiff and recovery, landed Uppercut, contact effects, parry counter, knockout and first-win reward in v0.269. Galaxy A06 landscape simulation repeated the full round through an emulated tap on Uppercut and the XP recap. The phone fight stayed on the mat. Controller and VR verification remain open. Physical-device and published play are release gates. Additional fighter kits, match modes and combat audio remain in development.

V0.271 adds the Level 5 Silverback–Sablecrest round. Desktop and Galaxy A06 landscape Studio verified the introduction, 20-damage palm, one 34-damage ground slam, both bot parries and 60 XP. Phone simulation also observed both cooldown rejections. The Level 5 gate used temporary Studio XP.

V0.284 adds the shared round-start bell and spatial audio routing for starter and resident hits, blocks, parries and each boss hazard step. Exact fixtures cover starts across modes and duplicate boss impacts. Original Roblox audio assets, published playback and physical-device listening remain open.

V0.272 adds the Level 7 Fire Salamander–Granite round. Desktop and Galaxy A06 landscape Studio verified Ember Sweep, both delayed Magma contacts, both Granite parries, both cooldowns and 60 XP. The Level 7 gate used temporary Studio XP. Shared fighter kits for other matchups, original in-game combat audio and player-versus-player presentation remain open.

V0.275 adds a damage trail, mirrored health meters and viewport-aware camera framing. Galaxy A06 landscape Studio verified the changed HUD in Reedguard versus Juniper through knockout, XP and camera return. A separate desktop Studio test exercised the Duel HUD through a one-client bout against a fitted stand-in. Server contact cues and the audio mixer are wired. The original WAVs require Roblox audio asset IDs and an audible mix pass.

V0.288 keeps zero-HP fighters on the mat until the final knockout outro ends in Tag Team and Brawl. Exact-source checks covered mat contact, simultaneous knockouts, timeouts with HP remaining, broken Brawl tiles, and restoration of movement after the outro. Live Tag Team and Brawl verification remains open. Desktop Studio v0.289 verified Reedguard’s grounded landing and city stance after a 25% tail reduction and reset both fighters through the actual Retry button.

V0.290 gives Reedguard planted shuffles and a right body kick at the end of the Strike chain. Juniper circles in both directions and steps back after defense. Desktop Studio checked native keyboard movement, fixed windups, whiffs, parry, all three combo contacts, first-win XP and restored city speed and camera. Galaxy A06 landscape simulation used the touch joystick, three native Strike taps and touch exit. Live multiplayer and physical-device input tests remain release gates.

## P3 Persistent player progression

Implement safe saving before a persistent economy or trading.

**Status** In progress

**Dependencies** P2

**Release gate** Committed progression survives reconnects, server changes and device changes; failure drills cannot wipe or duplicate profiles.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P3.1 | Versioned account profile | Prototype ready | Verify cloud reconnect and future migrations preserve XP and trophy history. Restore permanent ring access across reconnects, server changes and fighter switches once any owned fighter reached the threshold. Production also adds the remaining account fields and boost expiry. |
| P3.2 | Session ownership and safe loading | Prototype ready | Repeat the conflict, expiry and failed-load checks on staging. Automatic teleport handoff remains planned. |
| P3.3 | Idempotent rewards | Prototype ready | Verify the cloud grant and retry path. Extend it to the planned first-time mentor XP grant and later match and purchase receipts. |
| P3.4 | Autosave and recovery | In progress | Exercise cloud throttling and abrupt server loss on staging. Versioned support tooling and future migrations remain open. |
| P3.5 | Player save feedback | Prototype ready | Verify native UI feedback on a staging outage and reconnect. Add support tools for the last committed revision. |

## P4 Native UI and all-device access

Translate the UI direction to Roblox while the feature set is still small.

**Status** In progress

**Dependencies** P2, P3

**Release gate** The core loop and menus work on every supported input family; untested hardware remains explicitly unverified.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P4.1 | Native UI component library | Prototype ready | The shared Festival Championship HUD covers Bot Spar, Duel and Brawl. Confirm controller focus, notch clearance, VR and older-phone performance on hardware. |
| P4.2 | Input and safe-area layouts | Planned | Core actions require neither hover nor an external website; controls do not collide. |
| P4.3 | Onboarding and comfort | Prototype ready | Desktop and Galaxy A06 Studio Play covered the first-join fighter picker. Verify on hardware and continue the onboarding loop so first-time players navigate dojo, quest, activity, fight and reward; returning players restore a tracked goal. VR has no forced camera shake, snapping or hit-stop. |
| P4.4 | Early physical-device checkpoint | Planned | Record the device, settings, frame-time and usability findings; resolve architectural issues before roster expansion. |

## P4W Open-world city foundation and Dojo Valley slice

Prove a walkable city around the Grand Dojo Ring, with different experiences along connected streets, before producing all districts. Keep district roads and activity entrances accessible independently of combat ring unlocks.

**Status** In progress

**Dependencies** P3, P4

**Release gate** Dojo grounds and one district support a complete mentor quest, two activities, three secrets, safe return and arena entry on target devices. The six-district browser edition is available for concept playtesting.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P4W.1 | World layout and traversal | Prototype ready | Play through the current plaza, ring, canal and official Relay in Studio. Check the raised ring, both gateway appearances, the marquee from spawn and as players turn toward the ring, and the revised waterfall. Walk the forecourt from the plaza and Reed Market, take the main stair to Bot Spar and check the view across the cleared mat. Check the title and the exterior and rear pennants from the garden, the approach and the practice canvas on touch, gamepad and VR. Cross the taller red bridge in both directions, verify the lanterns, new planting and ripples on device, swim between the cove and the main canal, use both exits, and confirm the new map position is visible and readable from spawn. Check Trophy Hall’s crest and the two lower wings from spawn, under the porch and from the east ramp. Compare the four new emissive panes at high and low graphics settings. Take the viewing gallery stairs in both directions, greet the curator and check the sightline to the center trophy from above. Walk Weavers’ Walk in both directions, greet the Reed Weaver, enter the workshop and follow the Tideharbor ramp onto the existing causeway. Complete Harbor Parcel Delivery twice across all target input families. Check objective visibility, prompts, respawn and how the route streams in. Inspect the upper spring, two linked plunge basins and lower pool from both Reedfall overlooks. Desktop Studio verified all seven official Relay gates and the trophy on the center pedestal after the approach from the front stairs. Repeat the check by the east ramp and on target hardware. Walk all nine signed roads, the overlooks and both Skywalk branches with the generated terrain loaded. Walk the Ring Viewing Terrace in both directions, check the flat turn and sightline, and cross the lower causeway while the terrace streams in. Visit the new Wind Court from the square and from Cloudstep Pass. Verify the stairs and chime prompts on each supported device family. Follow Cloudstep Pass from Potters’ Yard to the Skywalk courtyard and back. Verify the stairs and ramp joins into both towns, the viewpoint, map line, guide prompt and streamed terrain. The Pinecrest Crossing models passed both Studio walking directions in desktop and Galaxy A06 simulation. Exact Studio launches of v0.241 and v0.242 later verified the crossing HUD and v0.242 exercised both Skywalk town connectors. Physical-phone profiling remains open. Exact v0.240 Studio Play verified the Reedfall arrival view, Ring practice and the Crown route to Cinder. The v0.239 Studio test copy verified the split Trophy Hall approach and all three ways into the Hall. Exact v0.238 Studio Play verified the shared Eagle Eye button and single-image overview in desktop Play and Galaxy landscape simulation. Exact v0.237 desktop verified Plum Lantern Walk, the covered porch and both main road directions. Exact v0.236 desktop verified the revised canal, both bridge directions and both swim exits. Exact v0.235 desktop verified the new paving and walked to the Fighting Ring and Trophy Hall gallery. Exact v0.234 desktop verified the revised western ridge views and traversed Mistline Crossing in both directions. Exact v0.233 desktop verified the Reed Market to Fighting Ring route and Mistline Crossing in both directions. Exact v0.232 desktop verified the revised overflow and six route legs around Reedfall and Cinder Gate. Exact v0.231 desktop verified the changed northern skyline and five routes in both directions. Exact v0.230 desktop verified the Trophy Hall stairs, gallery and both approaches, then completed the official Relay. Exact v0.229 desktop verified Glacier Lantern Walk, Mistline Crossing and the Upper Market road in both directions. Exact v0.228 desktop verified Copper Kiln Walk, Cloudstep and the Cinder–Tideharbor road both ways. Verify the new rock references and frame time on physical devices. Exact v0.227 desktop confirmed the clear Skywalk gate, both Pinecrest directions and the Mistline and Cloudstep links. Exact v0.226 desktop and Galaxy landscape Studio walked Cedar Foothill Walk both ways. Desktop also verified the Skywalk bridge and the Mistline and Cloudstep crossings. Verify the new grades and frame time on physical devices. Exact v0.225 desktop and Galaxy landscape verified the revised skyline from arrival. Verify ridge rendering and frame time on physical devices. Desktop Studio verified both directions on the cedar ramp and original stone stairs from Garden Lookout to Lantern Tower. The Galaxy A06 landscape simulator covered both ramp legs with scripted movement. Verify rail clearance and the Relay view using touch, gamepad and VR on target hardware. Walk the Saltwind approach, terrace and descent in both directions. Check both joins with the direct causeway after terrain generation and streaming. Walk the waterfront loop in both directions from the square, visit Mooring Rest, greet the Ropekeeper, test the swim return and take the Cinder road, then climb to Potters’ Yard and descend via the lower street. Walk both ramps at Frostglass, take the Mistline Vista loop in both directions and continue from its return to Skywalk Peaks. Follow the Frostglass road to Lantern Circuit and verify the upper market loop. Walk both directions through the Reedfall Gallery and its junction with the Cinder road. Cross the Frostglass bridge in both directions, inspect the lookout and try both meltwater bank exits. Follow the Promenade Garden signs, walk both ramps in both directions, and enter the seating spur. Walk the arrival canal lookout ramp, use and leave the bench, and verify the reverse map emblem. Walk Mistline Crossing in both directions, including the marked lanes from the Frostglass and Skywalk courtyards. Sit on all three Ring Balcony seats, observe the mat with the default camera, and leave for the Skybridge or Tideharbor ramp. Walk from Pond Terrace to Mistline Vista and under the Frostglass span on the direct road. Walk the revised terrace to the Skybridge with the default follow camera and read both directions at the junction. Check first spawn and respawn with the default Roblox camera, the three landmark titles, the direction post and the relocated map prompt. Compare with the authored Blender views. Check the overlook sightlines, rail clearance and map readability across supported device families. Open a city map in the plaza and at each town post. Use touch, keyboard and mouse, gamepad and VR to select and clear a route. Follow the Frostglass to Skywalk result via Mistline Crossing. Verify each input family on hardware and finish district activities. |
| P4W.2 | Quest and activity framework | Prototype ready | Verify the current practice forms, Relay entrance and wayfinding, prompts, retries, timeouts and reconnect behavior. Guide players from the Ring Steward to the planned first mentor activity that closes the 40 XP gap to Level 3. Add festival drills, market errands, clues and the complete mentor chapter. Durable duplicate protection is a production gate. |
| P4W.3 | Streaming and server budgets | In progress | Measure terrain initialization, creek travel, rapid return, slow streaming, memory and frame time in Studio and on target low-end devices. Verify that proximity effects and prompts recover after streaming out. Missing objects cannot grant rewards. |
| P4W.4 | Shared-world rules and recovery | In progress | Unsolicited attacks cannot damage players in safe areas. Verify two players can explore the same city across district boundaries, including Roblox friend joins, in published staging. Test full servers, recoverable transfers and unique profile ownership. |

## P4T Permanent trophies and personal dojo

Give every player a saved achievement collection and a place to display it.

**Status** In progress

**Dependencies** P3, P4, P4W

**Release gate** Three original awards can be earned, committed, restored and displayed in an owner-controlled room; the complete 30-entry catalog has defined criteria.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P4T.1 | Trophy catalog and rank distinction | Planned | Every trophy has a criterion and source event; account trophies are distinct from currencies, ranked score and trading inventory. |
| P4T.2 | Authoritative awards and migration | Prototype ready | Verify the cloud grant and two-player isolation with disposable staging profiles. Extend the same contract to the remaining trophy criteria. |
| P4T.3 | Collection journal and goal tracking | Prototype ready | Native UI distinguishes pending saves and supports controller, touch and VR without requiring chat. Browser collection tracking is playable. |
| P4T.4 | Personal trophy room and visits | Prototype ready | Production adds six featured pedestals, paged walls and a saved layout per account. Rooms default to Private. Invited visitors can inspect displays and return to the city. Verify owner-only edits, expired or revoked invitations, reconnect and return. |

## P5 Original asset pipeline and budgets

Prove one production-quality asset pipeline before creating 72 evolution representations.

**Status** In progress

**Dependencies** P2, P4

**Release gate** One fighter and the replacement boss have reviewed designs and a documented build/import/animation pipeline within measured budgets.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P5.1 | Originality and source review | Planned | Review expression against known comparators; no ripped models, clips, voices or franchise prompts. |
| P5.2 | Production fighter asset | Planned | Import, joint deformation, scaled collisions and all input/camera views pass in Studio. |
| P5.3 | Replacement boss pipeline | Planned | No Kong name, ape silhouette or film presentation; warnings readable with low VFX. |
| P5.4 | Memory and effects budgets | In progress | Import and profile the new meshes. Compare both Cinder hillside variants at the recorded pivot while keeping all planted ledges and colliders. Place each roof variant at its recorded pivot using Studs, disable collision, and compare the native and baked lighting and render cost in Studio. Compare the native pine and blossom crowns with their two baked variants in the plaza. Compare the native skyline with the detailed and lower-detail ridge meshes at the same camera on target hardware. Verify the limestone, slate, rock, brass, leafy and indigo clay variants, threshold lights, canal ripple beams, staggered waterfall curtains, basin foam trails, planted cliff ledges and six ambient textures in Studio and staging. Compare the warm grade and landmark visibility at low and high graphics settings. Measure full-fighter load and evolution memory on target hardware. |

## P6 Four-fighter closed alpha

Validate fun, pacing and saving with a small complete game.

**Status** In progress

**Dependencies** P3, P4, P4W, P4T, P5

**Release gate** External playtesters complete the Dojo Valley exploration/quest/trophy loop, matches, rewards and reconnects before full content production.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P6.1 | Four complete fighters | Prototype ready | All 16 starter Bot Spar pairings passed desktop technique checks. Galaxy landscape simulation completed a mixed bout with touch. All four starter kits are wired into casual Duel. Verify live two-client play, progression and published rejoin. |
| P6.2 | Duel and brawl alpha | Prototype ready | V0.314 keeps the final knockout pose above the remaining mat. Desktop Studio verified deciding hits at the edges of the 81-tile and nine-tile decks. V0.311 grounds the Brawl victory pose on the remaining deck. Desktop Studio verified the previously suspended champion. V0.310 resolves valid earlier contacts before a live-floor exit and gives the exit priority at the same timestamp. Studio replay confirmed a touch Ridge Palm and one Kraken pulse. V0.308 completed a full 60-second Brawl with eight Studio clients, a shared jab and parry, all three drops, all placements and city returns. V0.304 preserves scheduled hits across delayed floor drops and checks ties on the new floor. Galaxy A06 Studio verified one retained hit and the ensuing ring-out with seven stand-ins. V0.301 verifies 25 and 16 damage, both elemental HUD labels and floor-warning priority in Galaxy A06 Studio with seven practice stand-ins. V0.278 adds an eight-seat Grand Dojo Brawl with three timed floor drops, ring-outs, spectating and final placement. V0.301 also verified two local Casual Duel clients through pairing, hits, a parry and a leave result. Verify full rounds, published Duel and eight-player Brawl, disconnects, repeated matches, rewards and older-phone performance. |
| P6.3 | Alpha playtests and measurement | Planned | Players find an activity, finish a quest, earn/display a trophy and return to an arena. Record findings; no invented retention data. |
| P6.4 | Alpha exit review | Planned | No unresolved defect threatens data or makes the world/combat loop unusable. |

## P7 Complete roster and rich six-district world

Scale the proven fighter, world, quest and collection pipelines to full v1.

**Status** In progress

**Dependencies** P5, P6

**Release gate** 24 fighters, three stages, six districts, four combat rings, three original bosses, 18 mentor quest steps, 12 activity variants, 18 secrets, 30 trophies and two repeatable world events pass content checks.

| Ring | District | Account unlock level | Resident bot | Combat in Studio |
| --- | --- | ---: | --- | --- |
| Grand Dojo Ring | Grand Dojo City | 1 | Juniper Tortoise | Bot Spar and the sole PvP queue and venue |
| Cinder Terraces Ring | Cinder Terraces | 3 | Bracken Boar | Bot Spar only |
| Cloud-Top Temple | Skywalk Peaks | 5 | Sablecrest Lynx | Bot Spar only |
| Galleon Ring | Tideharbor Coast | 7 | Granite Rhino | Bot Spar only |

Frostglass Gardens and Lantern Circuit remain activity districts. The four themed Bot Spar courts and Grand Dojo same-server Duel Court are present in Studio. Published multiplayer and all-device checks remain open. [Current checkpoint and XP path](IMPLEMENTATION.md#four-ring-progression-plan)

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P7.1 | Playable roster expansion | Prototype ready | All twenty-four base fighters are available in v0.298. Golden Eagle and Celestial Storm Dragon complete the base roster. V0.303 adds all 48 earned outfits. Validate final unlocks, balance, move variants, live multiplayer and physical devices. |
| P7.2 | Fighter XP, evolution, breeds and mutations | Prototype ready | V0.340 uses own Level 5 and 10 to unlock Basic and Ultimate choices across all four starters. V0.339 adds Reedguard’s own Level 5 and 10 Basic and Ultimate choices. V0.338 adds Level 5 and 10 Technique choices for Magma Grizzly Bear, Obsidian Hellhound, Golden Eagle and Celestial Storm Dragon. All 24 fighters now have three choices in the Technique slot. Alternate Basic and Ultimate moves remain planned. V0.337 adds Level 5 and 10 Technique choices for Honey Badger, Emerald Saber-Tooth, Great White Shark and Abyssal Kraken. Twenty fighters have the three-choice Technique slot. V0.336 adds Level 5 and 10 Technique choices for Armadillo Striker, Komodo Dragon, Electric Owl and Bighorn Ram. Sixteen fighters have the three-choice Technique slot. V0.335 adds Level 5 and 10 Technique choices for Desert Scorpion, Pistol Shrimp, Walrus Sumo and Snapping Tortoise. Twelve fighters have the three-choice Technique slot. V0.334 adds the Level 5 and 10 Technique choices for Karate Frog, River Otter, Rooster Kickboxer and Sugar Glider, bringing the complete Technique slot to eight fighters. V0.333 completes the three-choice Technique slot for all four starters with the addition of Reedstone Heel and Glacier Press. V0.332 adds three Technique choices each for Silverback and Fire Salamander, with own-fighter unlocks at Levels 5 and 10. V0.331 adds Penguin’s saved Level 5 alternative and shares the same per-fighter technique selection path with Reedguard. Verify published saves, native multiplayer and raid behavior, physical devices and the remaining roster variants. V0.329 adds and verifies Reed Sweep as the first earned technique variant. The saved Reedguard Level 5 choice works in the native picker and Juniper practice, with fitted contact, a clean miss and a planted recovery. Apply the pattern to the rest of the roster and verify published saves and remaining native modes. All 24 fighters have three looks in v0.303. Warrior and Grandmaster use each fighter’s own Level 5 and 10 milestones. A New Form saves with the first evolved equip. Continue with evolved move variants, settle breeds, mutations and move variants, and verify published rejoin. |
| P7.3 | Four combat rings and original bosses | In progress | All four rings support the four authored starter kits in Studio. Kilnback Custodian, Abyssal Kraken and Solar Phoenix have original animated rigs and separate co-op arenas in Studio. Verify published access, boss audio and device play. |
| P7.4 | Content balance and regression | Planned | Fix outliers and ensure content additions do not regress the alpha save/input contract. |
| P7.5 | Six connected world districts | Planned | All six three-step chapters, twelve activity variants and eighteen secrets have original content, valid earning paths, usable routes and persistent progress. |
| P7.6 | Complete trophies and world events | Planned | Every trophy has valid/invalid path evidence; events scale within measured occupancy, return regularly and preserve existing earned records. |

## P8 Full multiplayer and social systems

Complete advanced modes, matchmaking and clans.

**Status** In progress

**Dependencies** P3, P6, P7

**Release gate** 1v1 Duels, 2v2 Tag Team and eight-player Brawl share the Grand Dojo Ring queue and venue. Four-player Co-op Raids remain a separately staged PvE mode. All four modes, parties and social progression work through disconnects, teleports and recovery.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P8.1 | Matchmaking, ranked rules and bots | Prototype ready | V0.328 verified a full two-client Studio Ranked match. Both Level 1 fighters started each round at 156 ranked HP. A 2–0 result transferred 16 points once and both ranks matched the later queue reread. Published ratings remain open. V0.327 verified a 2–0 Best of 3 with two desktop Studio clients, including both knockouts, fresh round-two profiles and full HP, the three-second countdown, matching attack timing and both city returns. V0.327 passed a two-client Studio Casual Duel at 231–234 ms median round trip with normal prompt and menu input, prompt local Jab and Heavy poses, matching damage, a timed parry, a knockout and both returns. Published multiplayer and physical devices remain open. V0.307 verified one late hit and synchronized recoil in a two-client Studio Duel, with valid follow-up input. V0.306 ran the native two-client Casual Duel to a knockout at 233–234 ms median measured round-trip time. Six non-final jab, cross and body contacts showed recoil and HP changes in the same rendered frame on both clients. A second delayed run confirmed a zero-damage parry and both knockout results. Published audio and wider match coverage remain open. V0.277 adds a local Ranked queue with fixed Level 15 combat, elemental advantages, rating-gap matching and six Elo divisions. Exact tests verified one rating per outcome and recovery after interrupted writes. Verify an invited live two-client match and the published rating store. Build cross-server matchmaking and tune the ranked rules. |
| P8.2 | Tag Team and Co-op Raids | Prototype ready | V0.330 scopes each combat input to its fighter entry. V0.327 matches a delayed Tag backup shell to its profile and retains the latest Jab readiness for up to one second. Exact-source Luau covered delayed replication, stale packets, rapid replacement and exit. A v0.327 four-client Tag Team Studio match verified the manual backup swap, a fresh Penguin profile, 25-damage Heavy at 430 ms, shared HP and all four recaps and city returns through ordinary exits. V0.315 adds a grounded revive rise and verifies the original 34 HP grant followed by a guard in Kilnback, Solar, and Abyssal Studio raids. Exact checks retain the deadline when the update comes late. V0.304 verifies a full 90-second Studio match with four clients, shared damage, a manual swap and matching results at the bell. All four returned to the city. V0.303 checked the forfeit path. V0.280 adds four-seat same-server Tag Team with a backup pick, a 90-second round, a 12-second swap and a defendable entry assist. Test published four-player matches, reconnect and rewards. V0.283 rotates all three co-op bosses on the raid bell. Each has separate arena warnings, revives and first-clear trophies. Verify the live bell, profile rejoin and four real players. Label each bot and show the roster and reward eligibility before play. |
| P8.3 | Parties and clans | Planned | Roblox join settings and full servers resolve safely. An invited party can regroup in a common city and return together after a match. Server authorization protects clan resources and room visits, and contributions commit once. |
| P8.4 | Cross-server failure drills | Planned | Players recover to a valid state and authoritative profile ownership remains unique. |

## P9 Economy, purchases and safe trading

Add monetization and exchanges only after save correctness is demonstrated.

**Status** In progress

**Dependencies** P3, P4, P8

**Release gate** Every economic grant is traceable and idempotent; restricted transactions are server-gated; crash drills cannot duplicate items.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P9.1 | Progression economy, boosts and exact cosmetics | Prototype ready | Free browser simulation exercises duration and reward/combat effects. Native staging must verify exact price/effect and duration, no stacking or lost duplicate purchases, receipt retries, reconnect expiry, and boost isolation from PvP and competitive records. No paid level skips or exclusive competitive moves in the proposed first release. |
| P9.2 | Random outcomes and eligibility | Planned | Unknown eligibility blocks restricted actions; published odds match the actual server distribution. |
| P9.3 | Trading plaza transaction protocol | Planned | Crash/timeout/retry tests show no item loss/duplication; no assumption of multi-key atomicity. Account-bound awards are rejected in offers. |
| P9.4 | Pass, season and rewarded ads | Planned | All grants commit once; only eligible accounts/devices receive ad or restricted offers. |

## P10 Optional VPS operations

Use the existing VPS where it adds value beyond native Roblox services.

**Status** Planned

**Dependencies** P3

**Release gate** VPS outage does not prevent loading, playing, reward validation or saving; core release does not depend on this optional phase.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P10.1 | Telemetry and health | Planned | No per-hit HTTP or unnecessary personal data; outages cannot fill an unbounded queue. |
| P10.2 | Read-only support console | Planned | Start read-only; any later mutation honors profile ownership and idempotent commands. |
| P10.3 | Config, analysis and scheduling | Planned | Last-known-good defaults work offline; no mid-match rule drift or executable remote code. |
| P10.4 | Optional community tools | Planned | No external account or community membership is required to play. |

## P11 Full-content beta and reliability

Qualify the complete game with recorded functional and device evidence.

**Status** Planned

**Dependencies** P7, P8, P9

**Release gate** Every mandatory device family and complete GDD core flow passes; critical data/economy/exploit defects block launch.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P11.1 | Full-content beta | Planned | No placeholder production feature; regressions tracked with reproduction and evidence. |
| P11.2 | All-device release matrix | Planned | Actual hardware passes exploration, streaming transitions, quest/journal, trophy room, combat, saving and transaction review; emulators supplement only. |
| P11.3 | Load and failure qualification | Planned | No loss or duplication in designed recovery drills; memory/frame-time/latency budgets recorded. |
| P11.4 | Security and operational rehearsal | Planned | All release-blocking failures repaired and support/recovery procedures exercised. |

## P12 Final rights and Roblox release clearance

Review the actual release, not only its concept names.

**Status** Planned

**Dependencies** P0, P11

**Release gate** Final title, all production assets/dependencies, marketing and platform policies pass the documented release review.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P12.1 | Title and brand clearance | Planned | Record evidence and review outcome before public branding or creator promotion; the current web screen is not a legal clearance. |
| P12.2 | Complete asset and dependency audit | Planned | Required licenses/permissions/attributions retained; unresolved material risk is replaced or resolved. |
| P12.3 | Final expression and marketing review | Planned | No retired names or identifiable franchise expression; assess any material patent issue with qualified advice if needed. |
| P12.4 | Roblox publishing and launch approval | Planned | Record Creator Hub confirmation for Kids and Select, the assigned rating, and the review outcome. Preserve the private documentation audience. |

## P13 Controlled production and maintenance

Launch gradually and maintain within solo capacity.

**Status** Planned

**Dependencies** P12

**Release gate** The game is live with verified smoke tests, monitored progression/economy and a rehearsed rollback path.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P13.1 | Staged launch | Planned | Stop rollout if saving, purchases, crashes or any device core flow regress. |
| P13.2 | Measure before optional marketing | Planned | Compare source/device cohorts with matched Creator Analytics benchmarks. Validate actual cost per retained player before scaling; no assumed revenue, guaranteed 1–2k CCU or universal retention threshold. |
| P13.3 | Sustainable updates | Planned | Every update rechecks affected devices, policy and asset/IP provenance. |
| P13.4 | Living implementation record | Planned | Local source and this same private site remain synchronized; no invented completion or background monitoring. |
