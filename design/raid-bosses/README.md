# Kilnback Custodian and Solar Phoenix

The editable Blender scenes and compact glTF exports are in `assets/`. Kilnback has 23 mesh nodes and 15,104 triangles. Solar Phoenix has 16 mesh nodes and 7,144 triangles. The preview stands, lights and cameras are part of the Blender scenes only.

Regenerate the files with Blender 4.5 from this directory.

```sh
blender -b -t 4 -P build_bosses.py -- --out assets --previews /tmp/dojo-raid-previews
```

## Roblox import

Import each GLB into a scratch place first. Match groups using the companion JSON and preserve existing parent-relative pivots, motion groups, and gameplay weak points. Blender suffixes such as `.001` distinguish repeated names in the export. Map them under their listed parents when fitting the runtime rig. Check materials, emissions, mesh asset ownership and permissions, wing and leg motion, boss health contact, and weak-point alignment in Studio before replacing the current raid geometry. Record the granted Roblox mesh IDs with the release dependencies.


## Studio fit evidence

The preview decoded the GLBs to temporary Studio EditableMeshes on copies of the existing rigs. It preserved each `Pose Hinge` and the three gameplay markers. Place the visual geometry using the boss’s `Origin.Position` plus the authored world-axis offsets. For Kilnback, the `Origin` marker faces the front for hazard logic, so use its position without applying its yaw to the export.

The 23 Kilnback and 16 Phoenix visual meshes fitted in Studio, and the gameplay volumes stayed fixed. Verify both glowing cores in their exposed poses after permanent import, since production materials and asset permissions depend on the importer. The preview used translated material colors and transient geometry.
