# Beast Dojo sparring bots

Four original Blender models for the four Dojo Rings. The lineup shows the models at authored scale under a shared lighting setup.

| Bot | Height in authored studs | Export triangles | Editable model | Roblox import file | Detail |
| --- | ---: | ---: | --- | --- | --- |
| Juniper Tortoise | 4.60 | 7,826 | [Blender](assets/Juniper_Tortoise.blend) | [GLB](assets/Juniper_Tortoise.glb) | [Guard](assets/Juniper_Tortoise_Guard.jpg) · [Shell](assets/Juniper_Tortoise_Shell.jpg) |
| Bracken Boar | 5.20 | 10,828 | [Blender](assets/Bracken_Boar.blend) | [GLB](assets/Bracken_Boar.glb) | [Guard](assets/Bracken_Boar_Guard.jpg) |
| Granite Rhino | 5.55 | 8,646 | [Blender](assets/Granite_Rhino.blend) | [GLB](assets/Granite_Rhino.glb) | [Guard](assets/Granite_Rhino_Guard.jpg) |
| Sablecrest Lynx | 5.38 | 7,966 | [Blender](assets/Sablecrest_Lynx.blend) | [GLB](assets/Sablecrest_Lynx.glb) | [Guard](assets/Sablecrest_Lynx_Guard.jpg) |

[Lineup render](assets/Dojo_Bot_Lineup.jpg) · [Editable Blender lineup](assets/Dojo_Bot_Lineup.blend)

## Bot stories and combat design

The [roster brief](roster.json) includes the four backstories, their shared Lantern Relay story, and proposed health, damage, powers and counters. The current 100 HP Reedguard spar provides the balance reference. The proposed moves need playtesting.

## Roblox handoff

Each GLB contains six or seven rigid mesh groups with separate body-part pivots, soles at ground level, Y up, and forward −Z. Its single embedded 1024 × 1024 color map carries the painted colors and baked contact shading. The matching `_bindings.json` lists the pivots, bounds and triangle counts. The files are sized around the 4.92-stud Reedguard shell. Use the Stud scale unit when checking the import preview. [Roblox Blender guidance](https://create.roblox.com/docs/art/blender) · [Studio Importer](https://create.roblox.com/docs/studio/importer)

All four GLBs were reimported in Blender 4.5.16 to verify mesh groups, pivots, dimensions, triangle counts and embedded textures. The Blender files include the posed art-review scenes. The GLBs contain the game geometry.

Studio v0.267 uses these exports for the resident opponents. The [Studio asset manifest](../../../roblox/grand-dojo/sparring_bot_assets.json) ties the uploaded mesh and texture IDs to the source checksums. Studio Play verified the assets loaded and each resident completed a match. Physical-device profiling and production combat balance remain open.

## Rebuild

Use Blender 4.5 LTS. From this directory, run:

```sh
blender --background --python build_bots.py
```

Use `-- --bot bracken` to rebuild one opponent, or `-- --lineup` to rebuild the lineup from the current individual Blender files. The builder uses the shared modeling primitives from the Reedguard Blender workflow.
