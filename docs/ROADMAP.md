# Beast Dojo Release Roadmap

Portable phase snapshot for Studio checkpoint 0.217, updated 2026-11-23. See [Implementation](IMPLEMENTATION.md) for code entry points, verified play and open work.

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
| P1.2 | Environment isolation | Planned | Tests and destructive failure drills target disposable staging records. |
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
| P2.2 | Movement and camera | Planned | Ring edges, respawns, slopes and input changes do not break movement. |
| P2.3 | Original combat kit | Planned | Clients cannot invent damage or bypass cooldowns. Review actual impacts, audio, finishers and camera against current rating definitions; no copied choreography. |
| P2.4 | One arena and end-to-end loop | Prototype ready | Verify final Reedguard shoulder poses and late guard cue in a fresh Studio Play session. Confirm the same complete loop using touch, gamepad and VR. Add remaining skills, animation polish and full combat feedback in the original combat kit. |

## P3 Persistent player progression

Implement safe saving before a persistent economy or trading.

**Status** In progress

**Dependencies** P2

**Release gate** Committed progression survives reconnects, server changes and device changes; failure drills cannot wipe or duplicate profiles.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P3.1 | Versioned account profile | Prototype ready | Verify cloud reconnect and future migrations preserve XP and trophy history. Production adds the remaining account fields and boost expiry. |
| P3.2 | Session ownership and safe loading | Prototype ready | Repeat the conflict, expiry and failed-load checks on staging. Automatic teleport handoff remains planned. |
| P3.3 | Idempotent rewards | Prototype ready | Verify the cloud grant and retry path. Extend it to further match and purchase receipts in the relevant phases. |
| P3.4 | Autosave and recovery | In progress | Exercise cloud throttling and abrupt server loss on staging. Versioned support tooling and future migrations remain open. |
| P3.5 | Player save feedback | Prototype ready | Verify native UI feedback on a staging outage and reconnect. Add support tools for the last committed revision. |

## P4 Native UI and all-device access

Translate the UI direction to Roblox while the feature set is still small.

**Status** In progress

**Dependencies** P2, P3

**Release gate** The core loop and menus work on every supported input family; untested hardware remains explicitly unverified.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P4.1 | Native UI component library | Prototype ready | Verify controller focus, the board action’s activation, safe-area placement, touch and VR in Studio and on target devices before extending the component library to other activities. |
| P4.2 | Input and safe-area layouts | Planned | Core actions require neither hover nor an external website; controls do not collide. |
| P4.3 | Onboarding and comfort | Planned | First-time players navigate dojo, quest, activity, fight and reward; returning players restore a tracked goal. VR has no forced camera shake, snapping or hit-stop. |
| P4.4 | Early physical-device checkpoint | Planned | Record the device, settings, frame-time and usability findings; resolve architectural issues before roster expansion. |

## P4W Open-world city foundation and Dojo Valley slice

Prove a walkable city around the central Fighting Ring, with different experiences along connected streets, before producing all districts.

**Status** In progress

**Dependencies** P3, P4

**Release gate** Dojo grounds and one district support a complete mentor quest, two activities, three secrets, safe return and arena entry on target devices. The six-district browser edition is available for concept playtesting.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P4W.1 | World layout and traversal | Prototype ready | Play through the current plaza, ring, canal and official Relay in Studio. Check the raised ring, both gateway appearances, the marquee from spawn and as players turn toward the ring, and the revised waterfall. Walk the forecourt from the plaza and Reed Market, take the main stair to the practice target and check the marquee, pennants, and visibility of both trainees from each approach. Check the title and the exterior and rear pennants from the garden, the approach and the practice canvas on touch, gamepad and VR. Cross the taller red bridge in both directions, verify the lanterns, new planting and ripples on device, swim between the cove and the main canal, use both exits, and confirm the new map position is visible and readable from spawn. Check Trophy Hall’s crest and the two lower wings from spawn, under the porch and from the east ramp. Compare the four new emissive panes at high and low graphics settings. Take the viewing gallery stairs in both directions, greet the curator and check the sightline to the center trophy from above. Walk Weavers’ Walk in both directions, greet the Reed Weaver, enter the workshop and follow the Tideharbor ramp onto the existing causeway. Complete Harbor Parcel Delivery twice across all target input families. Check objective visibility, prompts, respawn and how the route streams in. Inspect the upper spring, two linked plunge basins and lower pool from both Reedfall overlooks. Desktop Studio verified all seven official Relay gates and the trophy on the center pedestal after the approach from the front stairs. Repeat the check by the east ramp and on target hardware. Walk all nine signed roads, the overlooks and both Skywalk branches with the generated terrain loaded. Walk the Ring Viewing Terrace in both directions, check the flat turn and sightline, and cross the lower causeway while the terrace streams in. Visit the new Wind Court from the square and from Cloudstep Pass. Verify the stairs and chime prompts on each supported device family. Follow Cloudstep Pass from Potters’ Yard to the Skywalk courtyard and back. Verify the stairs and ramp joins into both towns, the viewpoint, map line, guide prompt and streamed terrain. Climb from Garden Lookout to Lantern Tower, verify rail clearance, see the Relay from the balcony and descend in Studio on all target input families. Walk the Saltwind approach, terrace and descent in both directions. Check both joins with the direct causeway after terrain generation and streaming. Walk the waterfront loop in both directions from the square, visit Mooring Rest, greet the Ropekeeper, test the swim return and take the Cinder road, then climb to Potters’ Yard and descend via the lower street. Walk both ramps at Frostglass, take the Mistline Vista loop in both directions and continue from its return to Skywalk Peaks. Follow the Frostglass road to Lantern Circuit and verify the upper market loop. Walk both directions through the Reedfall Gallery and its junction with the Cinder road. Cross the Frostglass bridge in both directions, inspect the lookout and try both meltwater bank exits. Follow the Promenade Garden signs, walk both ramps in both directions, and enter the seating spur. Walk the arrival canal lookout ramp, use and leave the bench, and verify the reverse map emblem. Walk Mistline Crossing in both directions, including the marked lanes from the Frostglass and Skywalk courtyards. Sit on all three Ring Balcony seats, observe the mat with the default camera, and leave for the Skybridge or Tideharbor ramp. Walk from Pond Terrace to Mistline Vista and under the Frostglass span on the direct road. Walk the revised terrace to the Skybridge with the default follow camera and read both directions at the junction. Check first spawn and respawn with the default Roblox camera, the three landmark titles, the direction post and the relocated map prompt. Compare with the authored Blender views. Check the overlook sightlines, rail clearance and map readability across supported device families. Open a city map in the plaza and at each town post. Use touch, keyboard and mouse, gamepad and VR to select and clear a route. Follow the Frostglass to Skywalk result via Mistline Crossing. Verify each input family on hardware and finish district activities. |
| P4W.2 | Quest and activity framework | Prototype ready | Verify the current practice forms, Relay entrance and wayfinding, prompts, retries, timeouts and reconnect behavior. Add festival drills, market errands, clues and the complete mentor chapter. Durable duplicate protection is a production gate. |
| P4W.3 | Streaming and server budgets | In progress | Measure terrain initialization, creek travel, rapid return, slow streaming, memory and frame time in Studio and on target low-end devices. Verify that proximity effects and prompts recover after streaming out. Missing objects cannot grant rewards. |
| P4W.4 | Shared-world rules and recovery | In progress | Unsolicited attacks cannot damage players in safe areas. Validate recovery in every district and prevent stranded transfers or duplicate profile ownership. |

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
| P4T.4 | Personal trophy room and visits | Prototype ready | Verify two-player ownership isolation, respawn and reconnect. Production adds six featured pedestals, paged walls, saved layout and optional visits. |

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

**Status** Planned

**Dependencies** P3, P4, P4W, P4T, P5

**Release gate** External playtesters complete the Dojo Valley exploration/quest/trophy loop, matches, rewards and reconnects before full content production.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P6.1 | Four complete fighters | Planned | All four are playable with progression transitions and no placeholder skill. |
| P6.2 | Duel and brawl alpha | Planned | Full occupancy, disconnects and repeated matches produce correct results/rewards. |
| P6.3 | Alpha playtests and measurement | Planned | Players find an activity, finish a quest, earn/display a trophy and return to an arena. Record findings; no invented retention data. |
| P6.4 | Alpha exit review | Planned | No unresolved defect threatens data or makes the world/combat loop unusable. |

## P7 Complete roster and rich six-district world

Scale the proven fighter, world, quest and collection pipelines to full v1.

**Status** In progress

**Dependencies** P5, P6

**Release gate** 24 fighters, three stages, six districts and arenas, 18 mentor quest steps, 12 activity variants, 18 secrets, 30 trophies and two repeatable world events pass content checks.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P7.1 | Remaining twenty fighters | Planned | Counts and unlock data match approved rules; every fighter completes a match. |
| P7.2 | Fighter XP, evolution, breeds and mutations | Prototype ready | A new player can see the next milestone and level up through a first completed practice win. Confirm the live XP curve and move milestones before revising the 30-level GDD baseline. No evolution or mutation conceals hazards or creates a collision advantage. |
| P7.3 | Six arenas and original bosses | In progress | Warnings remain visible at all quality tiers; every asset passes source/originality review. |
| P7.4 | Content balance and regression | Planned | Fix outliers and ensure content additions do not regress the alpha save/input contract. |
| P7.5 | Six connected world districts | Planned | All six three-step chapters, twelve activity variants and eighteen secrets have original content, valid earning paths, usable routes and persistent progress. |
| P7.6 | Complete trophies and world events | Planned | Every trophy has valid/invalid path evidence; events scale within measured occupancy, return regularly and preserve existing earned records. |

## P8 Full multiplayer and social systems

Complete advanced modes, matchmaking and clans.

**Status** In progress

**Dependencies** P3, P6, P7

**Release gate** All four modes, parties and social progression work through disconnects, teleports and recovery.

| ID | Work item | Status | Acceptance |
| --- | --- | --- | --- |
| P8.1 | Matchmaking, ranked rules and bots | Prototype ready | Browser simulates casual/ranked search and acceptance; its practice path has three playable bot tiers. Staging must verify human pairing, connection and skill bounds, bot consent, teleport/requeue recovery, and that bot or mixed results never award Rank Points or competitive trophies. |
| P8.2 | Tag-team and co-op raids | Planned | Full teams can win/lose/reconnect without reward duplication or a stuck match. Label each bot and confirm the roster and reward eligibility before play. |
| P8.3 | Parties and clans | Planned | Server authorization protects shared resources and room visits; contributions commit once. Leaving a clan cannot remove personal trophies. |
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
