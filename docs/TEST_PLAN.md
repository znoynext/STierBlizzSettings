# Manual live-client test plan

Run on a clean current Retail installation in English and Russian at 1080p, 1440p and above 1440p.

1. Open with `/stier`, `/stbs`, the minimap button and Blizzard Settings. Verify Graphics, Profiles and About appear as tabs; right-clicking the minimap button opens Profiles and `/stier about` opens About.
2. Drag the minimap button around the minimap, reload the UI and verify its position persists.
3. Select unified mode, review the diff, cancel the popup, then confirm. Verify only base graphics and `RAIDsettingsEnabled=0` change. Repeat for split mode and verify `RAIDsettingsEnabled=1` plus raid values.
4. Confirm the apply popup names the change count, a backup is created before writes, unavailable values are skipped, and a failed write rolls every attempted setting back.
5. Verify the large current FPS updates while Graphics is open. Remain in one location while applying; verify the UI first shows an eight-second measurement state, then a concise result such as `Average FPS: 74 to 91, +17 FPS (+23%)` without a broken arrow glyph.
6. Verify Reload UI appears after a successful apply, stays disabled during measurement, then becomes enabled. Confirm its popup and successful reload.
7. Use Undo graphics changes and verify the latest graphics backup is restored and a safety backup is created. Repeat after combat queuing.
8. Save more than five graphics profiles and backups. Verify Save Graphics accepts Enter, rejects whitespace-only names, shows success/failure, and all items remain selectable through scrolling. Apply/export/rename/delete profiles and restore/delete backups; verify every action reports a result.
9. Export and re-import graphics profiles; test profile mode and current mode. Reject interface-only, malformed, oversized, bad-checksum, duplicate-key, malformed-section, unsafe-metadata, unknown-CVar and future-schema imports.
10. Verify every Graphics Quality child, raid child, image AA, Multisample Alpha-Test, texture filtering and ray-traced shadows follows the profile. Verify monitor, display mode, resolution, Render Scale, UI scale, V-Sync, notch, latency, camera FOV, triple buffering, resampling, VRS, API/card, physics, FPS caps and color controls remain unchanged.
11. Test at 100%, 125% and 150% UI scale, long translated labels, larger fonts, opening/hover animations, scroll/focus/escape behavior, gold minimap icon and the real screenshot texture.
12. Verify About accurately describes the source audit, transactional backup, no telemetry, preserved controls and non-guaranteed FPS result.
13. Verify existing saved Interface & Gameplay data survives upgrades even though that user-facing section is hidden.
14. Test corrupted SavedVariables and a clean install; confirm there are no Lua errors, duplicated nested addon directories or stale `home` UI files.
