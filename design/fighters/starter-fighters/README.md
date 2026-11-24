# Beast Dojo starter fighters

These are the four fighters specified for the Beast Dojo closed alpha. Reedguard uses the existing festival shell. Penguin Brawler, Silverback Gorilla and Fire Salamander use new original Blender models. The first-pass health values scale the GDD roster to 100 HP for Reedguard.

| Fighter | HP | Normal hit damage | Editable Blender model | Roblox import file | Close-up |
| --- | ---: | ---: | --- | --- | --- |
| Reedguard Kangaroo | 100 | 13 | [Blender](assets/Reedguard_Kangaroo.blend) | [GLB](assets/Reedguard_Kangaroo.glb) | [Guard](assets/Reedguard_Kangaroo_Guard.jpg) |
| Penguin Brawler | 98 | 12 | [Blender](assets/Penguin_Brawler.blend) | [GLB](assets/Penguin_Brawler.glb) | [Guard](assets/Penguin_Brawler_Guard.jpg) |
| Silverback Gorilla | 135 | 15 | [Blender](assets/Silverback_Gorilla.blend) | [GLB](assets/Silverback_Gorilla.glb) | [Guard](assets/Silverback_Gorilla_Guard.jpg) |
| Fire Salamander | 96 | 14 | [Blender](assets/Fire_Salamander.blend) | [GLB](assets/Fire_Salamander.glb) | [Guard](assets/Fire_Salamander_Guard.jpg) |

[Lineup render](assets/Dojo_Starter_Lineup.jpg) · [Editable Blender lineup](assets/Dojo_Starter_Lineup.blend) · [Four Roads to Grand Dojo stories and move designs](roster.json)

## Roblox handoff

Each GLB is a standalone visual shell with six or seven separately pivoted mesh groups, Y up, and forward −Z. The single embedded 1024 × 1024 color atlas contains painted colors and baked contact shading. The associated `_bindings.json` files record the exact bounds, triangle counts and pivots. Use the Stud scale unit when checking the import preview. [Roblox Blender settings](https://create.roblox.com/docs/art/blender)

Blender 4.5.16 reimport verified all four GLBs at 4.70–5.62 authored studs and 6,486–12,272 triangles. The editable Blender files include a posed fighter collection, camera, lighting and stage for art review.

The v0.266 Studio checkpoint uses these exact exports for the animated picker and player avatars. The [Roblox import manifest](../../../roblox/grand-dojo/starter_fighter_assets.json) records the uploaded mesh and atlas IDs, floor-aligned transforms and source checksums. Studio Play verified selection, movement and respawn for all four fighters. Combat animations, power behavior, balance and physical-device testing remain open.

## Rebuild

Run Blender 4.5 LTS from this directory.

```sh
blender --background --python build_starters.py
```

Use `-- --fighter penguin` for one fighter or `-- --lineup` to rebuild the lineup from the current individual Blender files. The builder uses the shared sparring-model pipeline and original Reedguard geometry.
