# Festival Championship Studio proof

This is a native Roblox presentation mockup for the approved Fighting Ring design. The demo listens to the existing server-owned bot round. The close side view, fighter poses, impact accents and layered health bars are local presentation prototypes in a disposable Studio session. None of these scripts are embedded in the release place.

## Replay

1. Open a local Beast Dojo Studio copy in Play. Walk Reedguard to the **Bot Spar** sign inside the Fighting Ring. Use a fresh local profile to see the first-win reward.
2. Concatenate [Hud.luau](Hud.luau), [Poses.luau](Poses.luau) and [Director.luau](Director.luau) in that order. Execute the combined text in the Play client through Studio MCP.
3. The preview opens the native spar prompt and plays the round. It deliberately takes one hit before blocking, parrying and countering. Read the `FestivalChampionshipProof` player attribute for the local results.
4. Stop the disposable playtest to clear the preview.

## Production work

Replace the presentation stand-ins with articulated fighters and animation clips. Tie windups, contact, reaction, and recovery markers to the live combat state. Handle camera restoration and accessibility on reset, leave, retry, knockout, reduced motion and VR. Validate the live HUD and camera on phones, controllers and consoles. Test published first-win saving separately.

## Combat spec review

Use the proposed spec for the first 1v1 combat milestone. The game design still calls for the wider fighter roster, multiplayer modes and release features. Keep the server-owned fight state, shared move timing, responsive local windups, training opponent and Festival Championship interface.

| Area | Suggested change before implementation |
| --- | --- |
| Timing and reach | Keep editable 60 fps frame data and convert it to server-time intervals. Evaluate the active interval even when a server step skips over it. Limit overlap checks to dedicated body volumes from the active match. Sample current positions first and tune a bounded rewind from server-observed history after comparison under latency. |
| Rig and effects | Use the new Blender shell as the visual reference for the articulated rig. A custom Humanoid can carry the anatomical joints. Use animation markers for local sound and trails, with server-owned timing for contact. The final animation clips need ownership and playback checks in a published test. |
| Parry and guard | A guard press starts normal blocking immediately. A short valid press window upgrades a frontal hit to a parry. Define repeated-press cooldown and hold checks separately. A parry creates a counter opportunity. A follow-up input still needs to land in range. Resolve guard break and chip damage consistently and keep the guard indicator separate from HP. |
| Controls and accessibility | Use the core UI safe area for the combat HUD. Keep touch Dodge explicit at first, preserve native movement controls, and keep desktop and controller inputs contextual to the ring. Skip forced camera movement and flashes in the reduced-motion and VR presentation. |
| Round endings | Define simultaneous knockouts, equal-health timeouts, bounded tiebreaks and forfeits. A disconnect must still release both slots and return the remaining participant to the normal world loop. Use the same once-only progression policy for eligible wins. |

Start with a complete jab exchange against Juniper, including windup, validated contact, recoil and a delayed damage trail. Next add block, parry and counter, then links in the combo, heavy, kick and dodge. After that, play best-of-three in two Studio clients and a published staging arena across the chosen latency and device matrix. Compare 150 ms round-trip latency as a playtest target.

[Spatial overlap queries](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#GetPartBoundsInBox) · [Player ping](https://create.roblox.com/docs/reference/engine/classes/Player#GetNetworkPing) · [Custom character rigs](https://create.roblox.com/docs/onboarding/artists) · [ScreenGui safe areas](https://create.roblox.com/docs/reference/engine/classes/ScreenGui#ScreenInsets)
