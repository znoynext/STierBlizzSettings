# Architecture

`Core` owns startup, compatibility, SavedVariables, FPS sampling and diagnostics. `Settings` contains the curated registry, validation, verified read/write operations, diffs, backups and transactions. `Profiles` owns schema, migration, built-ins and personal profiles. `ImportExport` implements deterministic serialization and a data-only parser; it never calls `loadstring`. `UI` is lazily created from Blizzard frame primitives and exposes two user-facing tabs: Graphics and Profiles.

Application is one operation: validate modules and values → read/diff → save one backup → write individual CVars → read back → report. Invalid work is rejected before combat queuing. If any write or verification fails, attempted CVars are restored in reverse order. In combat, the complete validated operation is queued for `PLAYER_REGEN_ENABLED`.

The Graphics tab owns the official mode selector, illustrative preview, reviewed diff, confirmation, automatic FPS comparison and latest-backup undo. FPS sampling uses Blizzard's documented `GetFramerate()` function at 0.5-second intervals. Results are character-local estimates and are never presented as guaranteed gains.

The Profiles tab combines personal graphics profiles and backup history. They remain separate persisted record types: profiles are named/exportable configurations, while backups are automatic point-in-time snapshots. Restore always creates a safety backup first; deleting either record requires explicit confirmation.

Interface & Gameplay remains a separate internal module for backward compatibility, import validation and lossless old-data handling, but it is temporarily hidden from the 0.3 user workflow while being redesigned. Hardware/display, audio, accessibility, mouse, UI scale, Edit Mode and keybindings remain untouched.
