# Architecture

`Core` owns startup, compatibility checks, SavedVariables and diagnostics. `Settings` contains the curated registry, validation, read/write verification, diffs, backups and transactions. `Profiles` owns schema, migration, built-ins and personal profiles. `ImportExport` implements deterministic serialization and a data-only parser; it never calls `loadstring`. `Integrations` includes Settings-panel registration; Edit Mode and keybinding profile operations are intentionally unavailable until fully integrated. `UI` is lazily created and uses Blizzard templates.

Application is one operation: validate modules and values → read/diff → save one backup → write individual CVars → read back → keep a module-separated report. Invalid work is rejected before combat queuing. If any write or read-back verification fails, every attempted CVar is restored to its pre-operation value in reverse order; the result is reported as rolled back (or rollback failed). In combat the whole validated operation is queued for `PLAYER_REGEN_ENABLED`, never partially applied.

Graphics is isolated from Interface & Gameplay. The official interface profile contains only standard Blizzard controls for combat readability and stable camera behavior. Hardware/display, audio, accessibility, mouse, UI scale, Edit Mode and keybindings remain untouched.

The standalone dashboard and the Blizzard Settings canvas are separate frames. The canvas is a lightweight launcher, preventing the movable dashboard from being reparented into Blizzard's settings panel. Long profile, backup and action lists scroll instead of clipping.
