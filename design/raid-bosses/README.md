# Kilnback Custodian and Solar Phoenix

The editable Blender scenes and compact glTF exports are in `assets/`. Kilnback has 23 mesh nodes and 15,104 triangles. Solar Phoenix has 16 mesh nodes and 7,144 triangles. The preview stands, lights and cameras are part of the Blender scenes only.

Regenerate the files with Blender 4.5 from this directory.

```sh
blender -b -t 4 -P build_bosses.py -- --out assets --previews /tmp/dojo-raid-previews
```

## Roblox import

Import each GLB into a scratch place first. Match groups using the companion JSON and preserve existing parent-relative pivots, motion groups, and gameplay weak points. Blender suffixes such as `.001` distinguish repeated names in the export. Map them under their listed parents when fitting the runtime rig. Check materials, emissions, mesh asset ownership and permissions, wing and leg motion, boss health contact, and weak-point alignment in Studio before replacing the current raid geometry. Record the granted Roblox mesh IDs with the release dependencies.
