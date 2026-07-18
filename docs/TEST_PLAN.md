# Manual live-client test plan

Run on a clean current Retail installation in English and Russian at 1080p, 1440p and above 1440p.

Focused 0.4 checks: validate all three presets; run the automatic 5-second post-apply comparison, standalone 20-second frame-time test and each current-vs-preset comparison; test Zone Graphics across world, dungeon, raid, PvP/arena and scenario/delve content; toggle the bottom FPS/ping indicator and verify it stops updating while disabled.

1. Open with `/stier`, `/stbs`, the minimap button and Blizzard Settings. Verify Graphics, Test FPS, Profiles and About appear on the left; Graphics Settings and Zone Graphics Switcher appear as native sub-tabs. Right-clicking the minimap button opens Profiles, `/stier zone` opens the nested Zone Graphics page, `/stier fps` opens Test FPS and `/stier about` opens About.
2. Drag the minimap button around the minimap, reload the UI and verify its position persists.
3. Select PRO, Optimized and Quality in turn and verify expensive settings scale while projected textures, particles, outlines and texture resolution remain safe. Select unified mode, review the diff, cancel the popup, then confirm. Verify only base graphics and `RAIDsettingsEnabled=0` change. Repeat for split mode and verify `RAIDsettingsEnabled=1` plus raid values.
4. Confirm the apply popup names the change count, a backup is created before writes, unavailable values are skipped, and a failed write rolls every attempted setting back.
5. Verify the large current FPS updates while Graphics is open and the post-apply comparison samples five seconds. In Test FPS, run one 20-second capture and verify the centered progress dialog blocks mouse input, updates elapsed time and Cancel immediately closes it. Verify average FPS, 1% Low, stability explanation, adaptive spike count, worst-frame time and advice; keep the scene fixed and compare the result with an external frame-time capture.
6. Run current-vs-PRO, current-vs-Optimized and current-vs-Quality. Each must capture 20 seconds before and after, show average and 1% Low deltas, retain exactly one rollback backup and restore every captured graphics value. Cancel during the current phase and candidate phase; in combat, verify restoration queues and Zone Graphics remains suspended until it completes.
7. Verify Reload UI appears after a successful apply, stays disabled during measurement, then becomes enabled. Confirm its popup and successful reload.
8. Use Undo graphics changes and verify the latest graphics backup is restored and a safety backup is created. Repeat after combat queuing.
9. Save more than five graphics profiles and backups. Verify Save Graphics accepts Enter, rejects whitespace-only names, shows success/failure, and all items remain selectable through scrolling. Apply/export/rename/delete profiles and restore/delete backups; verify every action reports a result.
10. Export and re-import graphics profiles; test profile mode and current mode. Reject interface-only, malformed, oversized, bad-checksum, duplicate-key, malformed-section, unsafe-metadata, unknown-CVar and future-schema imports.
11. Verify every Graphics Quality child, raid child, image AA, Multisample Alpha-Test, texture filtering and ray-traced shadows follows the profile. Verify monitor, display mode, resolution, Render Scale, UI scale, V-Sync, notch, latency, camera FOV, triple buffering, resampling, VRS, API/card, physics, FPS caps and color controls remain unchanged.
12. Test at 100%, 125% and 150% UI scale, minimum/default/maximum window sizes, long translated labels, larger fonts, window/page/status/hover animations, scroll/focus/escape behavior, header-only movement beyond every screen edge, resize persistence and the gold minimap icon.
13. On Profiles, verify the three internal views, select every backup after scrolling, then restore and delete it from the actions that reappear at the top.
14. Export `STBSA1`, paste it on a clean account, confirm the backup-first warning, verify graphics/preferences/zone mappings/profiles, and confirm that corrupted/oversized strings and combat imports fail closed.
15. Verify About accurately describes the source audit, transactional backup, no telemetry, preserved controls and non-guaranteed FPS result.
16. Verify existing saved Interface & Gameplay data survives upgrades even though that user-facing section is hidden.
17. Test corrupted SavedVariables and a clean install; confirm there are no Lua errors, duplicated nested addon directories or stale `home` UI files.
18. Enable Zone Graphics and cross each supported content type. Confirm a backup is created only for a real diff, combat queues one validated operation, disabled mode never writes, and unknown instance types use the world mapping.
19. Enable the FPS/ping indicator. Compare Home/World values with the Blizzard micro-menu tooltip, verify the higher latency is shown, check independent color transitions, then disable it and confirm its ticker is cancelled.
