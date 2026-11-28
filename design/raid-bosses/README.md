# Kilnback Custodian and Solar Phoenix

The editable Blender scenes and compact glTF exports are in `assets/`. Kilnback has 23 mesh nodes and 15,104 triangles. Solar Phoenix has 16 mesh nodes and 7,144 triangles. The preview stands, lights and cameras are part of the Blender scenes only.

Regenerate the files with Blender 4.5 from this directory.

```sh
blender -b -t 4 -P build_bosses.py -- --out assets --previews /tmp/dojo-raid-previews
```

## Roblox import

The v0.378 build reads `assets/roblox-meshes.json`. The manifest records the Roblox-hosted mesh IDs, authored tint, material, corrected placement, and animation parent for each primitive imported from the two GLBs. The Studio importer split the exports by glTF material, yielding 56 Kilnback and 38 Phoenix MeshParts. The builder attaches them to the original hinges and leaves the gameplay markers as authored. These are original Beast Dojo models uploaded through Studio under the signed-in creator using the Me option. The manifest is the release asset reference. The published experience still needs a fresh-server permission check.

When replacing either GLB, import it into a scratch place with **Upload to Roblox** and select the experience owner. Match each resulting primitive against its GLB center and dimensions. The importer changed the forward axis. It also flattened six rotations on Kilnback, so preserve the corrected transforms and per-material tints in the manifest. Check both exposed cores and stream the assets using the intended Roblox universe before release.

## Studio fit evidence

The preview decoded the GLBs to temporary Studio EditableMeshes on copies of the existing rigs. It preserved each `Pose Hinge` and the three gameplay markers. Place the visual geometry using the boss’s `Origin.Position` plus the authored world-axis offsets. For Kilnback, the `Origin` marker faces the front for hazard logic, so use its position without applying its yaw to the export.

The 23 Kilnback and 16 Phoenix visual meshes fitted in Studio, and the gameplay volumes stayed fixed. Verify both glowing cores in their exposed poses after permanent import, since production materials and asset permissions depend on the importer. The preview used translated material colors and transient geometry.
