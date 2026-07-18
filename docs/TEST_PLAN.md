# Manual live-client test plan

Run on a clean current Retail installation in English and Russian at 1080p, 1440p and above 1440p.

Focused 0.4 checks: validate all three presets; run quick 5-second and accurate 10+10-second frame-time measurements; test Zone Graphics across world, dungeon, raid, PvP/arena and scenario/delve content; toggle the bottom FPS/ping indicator and verify it stops updating while disabled.

1. Open with `/stier`, `/stbs`, the minimap button and Blizzard Settings. Verify Graphics, Profiles, Zone Graphics and About appear as tabs; right-clicking the minimap button opens Profiles, `/stier zone` opens Zone Graphics and `/stier about` opens About.
2. Drag the minimap button around the minimap, reload the UI and verify its position persists.
3. Select PRO, Optimized and Quality in turn and verify expensive settings scale while projected textures, particles, outlines and texture resolution remain safe. Select unified mode, review the diff, cancel the popup, then confirm. Verify only base graphics and `RAIDsettingsEnabled=0` change. Repeat for split mode and verify `RAIDsettingsEnabled=1` plus raid values.
4. Confirm the apply popup names the change count, a backup is created before writes, unavailable values are skipped, and a failed write rolls every attempted setting back.
5. Verify the large current FPS updates while Graphics is open. Quick mode must sample five seconds after apply. Accurate mode must sample frame times 10 seconds before and 10 seconds after, then show average FPS and 1% Low with the built-in arrow texture.
6. Verify Reload UI appears after a successful apply, stays disabled during measurement, then becomes enabled. Confirm its popup and successful reload.
7. Use Undo graphics changes and verify the latest graphics backup is restored and a safety backup is created. Repeat after combat queuing.
8. Save more than five graphics profiles and backups. Verify Save Graphics accepts Enter, rejects whitespace-only names, shows success/failure, and all items remain selectable through scrolling. Apply/export/rename/delete profiles and restore/delete backups; verify every action reports a result.
9. Export and re-import graphics profiles; test profile mode and current mode. Reject interface-only, malformed, oversized, bad-checksum, duplicate-key, malformed-section, unsafe-metadata, unknown-CVar and future-schema imports.
10. Verify every Graphics Quality child, raid child, image AA, Multisample Alpha-Test, texture filtering and ray-traced shadows follows the profile. Verify monitor, display mode, resolution, Render Scale, UI scale, V-Sync, notch, latency, camera FOV, triple buffering, resampling, VRS, API/card, physics, FPS caps and color controls remain unchanged.
11. Test at 100%, 125% and 150% UI scale, minimum/default/maximum window sizes, long translated labels, larger fonts, window/page/status/hover animations, scroll/focus/escape behavior, header-only movement, resize persistence and the gold minimap icon.
12. On Profiles, verify the three internal views, select every backup after scrolling, then restore and delete it from the actions that reappear at the top.
13. Export `STBSA1`, paste it on a clean account, confirm the backup-first warning, verify graphics/preferences/zone mappings/profiles, and confirm that corrupted/oversized strings and combat imports fail closed.
12. Verify About accurately describes the source audit, transactional backup, no telemetry, preserved controls and non-guaranteed FPS result.
13. Verify existing saved Interface & Gameplay data survives upgrades even though that user-facing section is hidden.
14. Test corrupted SavedVariables and a clean install; confirm there are no Lua errors, duplicated nested addon directories or stale `home` UI files.
15. Enable Zone Graphics and cross each supported content type. Confirm a backup is created only for a real diff, combat queues one validated operation, disabled mode never writes, and unknown instance types use the world mapping.
16. Enable the FPS/ping indicator. Compare Home/World values with the Blizzard micro-menu tooltip, verify the higher latency is shown, check independent color transitions, then disable it and confirm its ticker is cancelled.
