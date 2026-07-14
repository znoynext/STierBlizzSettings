# Manual live-client test plan

Run on a clean Retail installation in English and Russian at 1080p, 1440p and above 1440p.

1. Load addon, run `/stier` and `/stbs`, then verify slash subcommands.
2. Select unified, apply graphics, verify only base graphics and `RAIDsettingsEnabled=0` changed; switch to split and verify retained inactive raid values plus `RAIDsettingsEnabled=1`.
3. Apply Interface & Gameplay and confirm graphics remain unchanged; apply Everything and confirm one combined backup and separated reports.
4. Check Projected Textures, non-zero particles/outlines, Spell Density feature detection, unavailable CVar handling, AA fallback and preservation of all display/hardware options.
5. Save Graphics, Interface and combined profiles; export and re-import each; test graphics-only, interface-only, full, malformed, oversized, bad-checksum, unknown-CVar and future-schema imports.
6. Create backups; restore all, graphics only, interface only; ensure restore itself adds one backup without recursion.
7. Trigger apply during combat, cancel/leave combat, and confirm no partial write before `PLAYER_REGEN_ENABLED`.
8. Verify settings requiring reload/restart are reported by the client; test corrupted SavedVariables, an addon upgrade, Edit Mode confirmation and opt-in keybinding handling.
