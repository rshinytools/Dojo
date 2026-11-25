# Beast Dojo combat audio

Six original, unlooped cues synthesized for the Dojo Ring. The Python source uses oscillators and seeded noise. The WAV files contain no external recordings or samples.

| Cue | Texture | Suggested playback | Starting volume |
| --- | --- | --- | ---: |
| [Light thup](light-thup.wav) | Short wooden tap with a soft cloth edge | Confirmed light strike or quick counter at the contact point | 0.33 |
| [Planted impact](planted-impact.wav) | Low, weighty drum with a dry cedar knock | Confirmed heavy strike or committed resident hit at the contact point | 0.40 |
| [Guard clack](guard-clack.wav) | Dry stave clack and a second muted leather tap | Confirmed block at the defender | 0.34 |
| [Parry chime](parry-chime.wav) | Bright two-part bell flash with a short decay | Confirmed timed parry at the point of deflection | 0.36 |
| [Ground pulse](ground-pulse.wav) | Boot knock, low rolling pulse and airy grit | Once at the resolved floor origin for a slam, stamp or trail burst | 0.34 |
| [Countdown bell](countdown-bell.wav) | Soft bronze strike with a short, mellow ring | Local countdown change at 3, 2 and 1 and a lower start note | 0.24 |

Each confirmed contact should select one cue. Give a block or parry its own cue, even when it intercepts a heavy attack. Play a ground pulse at the authored strike time and keep it spatial. A separate countdown bell can follow the local HUD without panning.

The cues use mono 44.1 kHz signed 16-bit PCM with a peak of −3 dBFS. The WAVs occupy about 151 KiB combined. The [manifest](manifest.json) records durations, hashes and initial volume suggestions.

[CombatAudio](../../CombatAudio.luau) receives server-confirmed contacts and one separate cue at each boss hazard’s authored position. It uses at most four simultaneous spatial voices on touch and six on other inputs, with one separate local countdown voice. A cue that starts nearby briefly lowers the existing music and the playlist carries on. The six original WAVs were uploaded through Studio Asset Manager to ApexGameD. Their IDs are in [CombatCueAssets](../../CombatCueAssets.luau). In order above, the keys are `light`, `heavy`, `guard`, `parry`, `ground` and `countdown`. Confirm playback and asset access in the published experience before assessing the final ring mix. [Roblox’s audio import documentation](https://create.roblox.com/docs/audio/assets)

From the repository root, use Python 3.10 or newer to reproduce and check the outputs.

```sh
python3 -B roblox/grand-dojo/art/combat-audio/render_combat_audio.py
python3 -B roblox/grand-dojo/art/combat-audio/render_combat_audio.py --check
```
