# Manual live-client test plan

Run on a clean Retail installation in English and Russian at 1080p, 1440p and above 1440p.

1. Load addon, run `/stier` and `/stbs`, then verify slash subcommands.
2. Select unified, apply graphics, verify only base graphics and `RAIDsettingsEnabled=0` changed; switch to split and verify retained inactive raid values plus `RAIDsettingsEnabled=1`.
3. Apply Interface & Gameplay and confirm graphics remain unchanged; apply Everything and confirm one combined backup and separated reports.
4. Check Projected Textures, non-zero particles/outlines, Spell Density feature detection, unavailable CVar handling, Blizzard graphics capability rejection, AA fallback and preservation of all display/hardware options.
5. Apply Interface & Gameplay and verify cooldown numbers, target-of-target, player silhouette and enemy nameplate controls. Confirm audio, accessibility, mouse, UI scale, bindings and Edit Mode are unchanged.
6. Save Graphics, Interface and combined profiles; export and re-import each; test graphics-only, interface-only, full, malformed, oversized, bad-checksum, duplicate-key, malformed-section, unsafe-metadata, unknown-CVar and future-schema imports.
7. Create more than two profiles and backups; verify every item remains selectable by scrolling. Restore all, graphics only and interface only; ensure restore itself adds one backup without recursion and stale removed CVar keys are ignored.
8. Trigger valid and invalid apply operations during combat; confirm invalid work is never queued, queued work can be cancelled and no partial write occurs before `PLAYER_REGEN_ENABLED`.
9. Open the addon through slash command, minimap button and Blizzard Settings. Check 100%, 125% and 150% UI scale, long translated labels, scrolling, focus/escape behavior and deletion confirmation.
10. Verify settings requiring reload/restart are reported by the client; test corrupted SavedVariables, an addon upgrade, Edit Mode confirmation and opt-in keybinding handling.
