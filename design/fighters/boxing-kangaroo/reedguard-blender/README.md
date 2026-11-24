# Reedguard festival shell

An original Blender fighter model based on Beast Dojo’s Festival Championship concept. The angular muzzle and asymmetric ears preserve Reedguard’s silhouette. The red boxing wraps have overlapping fabric bands. A woven reed brace, split tabard and single curved tail remain readable at ring distance.

| File | Role |
| --- | --- |
| [Reedguard_Festival_Shell.glb](Reedguard_Festival_Shell.glb) | Neutral export with seven rigid visual groups and one embedded 512 × 512 color texture |
| [Reedguard_Festival_Preview.blend](Reedguard_Festival_Preview.blend) | Editable guard pose, authored materials, camera and lighting |
| [Reedguard_Guard_Offline_Blender.jpg](Reedguard_Guard_Offline_Blender.jpg) | Offline Blender render of the guard pose with preview lighting and shader detail |
| [rig-bindings.json](rig-bindings.json) | Group names, pivots, bounds and triangle counts |
| [build_reedguard.py](build_reedguard.py) | Rebuilds the visual groups, their texture, the export and the preview |

The neutral model is **4.92 units high** at the authored one-unit-per-stud scale. The GLB is Y up, faces −Z, and contains **12,272 triangles** across seven separately pivoted mesh nodes. Its texture is embedded, with no linked media or Creator Store assets. The preview scene includes lighting and procedural surface detail that does not travel with the GLB.

## Rebuild in Blender

Run with Blender 4.5 LTS or Python 3.11 with Blender’s bpy 4.5.16 package.

    blender --background --python build_reedguard.py -- --save-blend

Use --skip-render to export the neutral shell and handoff data only. The output files are placed beside the builder.

## Roblox handoff

The export is rigid visual geometry prepared for the existing Torso, Head, arms, legs and tail joints. The JSON gives each group's pivot in both Blender and glTF coordinates. Confirm transform and scale after importing, then attach the visuals to a disposable copy of the existing character with its original collision and server rules intact. The guard render uses an art pose. Skin weights, rig binding, Studio animation and clipping checks, mobile performance and release asset permissions remain open.
