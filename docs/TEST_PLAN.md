# Manual live-client test plan

Run on a clean current Retail installation in English and Russian at 1080p, 1440p and above 1440p.

1. Open with `/stier`, `/stbs`, the minimap button and Blizzard Settings. Verify only Graphics and Profiles appear as tabs; right-clicking the minimap button opens Profiles.
2. Drag the minimap button around the minimap, reload the UI and verify its position persists.
3. Select unified mode, review the diff, cancel the popup, then confirm. Verify only base graphics and `RAIDsettingsEnabled=0` change. Repeat for split mode and verify `RAIDsettingsEnabled=1` plus raid values.
4. Confirm the apply popup names the change count, a backup is created before writes, unavailable values are skipped, and a failed write rolls every attempted setting back.
5. Remain in one location while applying. Verify the UI first shows an eight-second measurement state, then a concise result such as `Average FPS: 74 → 91, +17 FPS (+23%)`. Repeat after moving zones to confirm the result is clearly described as an estimate.
6. Use Undo graphics changes and verify the latest graphics backup is restored and a safety backup is created. Repeat after combat queuing.
7. Save more than five graphics profiles and backups. Verify all remain selectable through scrolling; apply/export/rename/delete profiles and restore/delete backups. Confirm every destructive deletion uses a popup.
8. Export and re-import graphics profiles; test profile mode and current mode. Reject interface-only, malformed, oversized, bad-checksum, duplicate-key, malformed-section, unsafe-metadata, unknown-CVar and future-schema imports.
9. Verify Projected Textures, non-zero particles/outlines, Spell Density detection, AA fallback and preservation of monitor, resolution, refresh rate, V-Sync, FPS limits and latency settings.
10. Test at 100%, 125% and 150% UI scale, long translated labels, opening/hover animations, scroll/focus/escape behavior and the bundled preview texture.
11. Verify existing saved Interface & Gameplay data survives upgrades even though that user-facing section is hidden.
12. Test corrupted SavedVariables and a clean install; confirm there are no Lua errors, duplicated nested addon directories or stale `home` UI files.
