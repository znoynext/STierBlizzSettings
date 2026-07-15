# Architecture

`Core` owns startup, compatibility checks, SavedVariables and diagnostics. `Settings` contains the curated registry, validation, read/write verification, diffs, backups and transactions. `Profiles` owns schema, migration, built-ins and personal profiles. `ImportExport` implements deterministic serialization and a data-only parser; it never calls `loadstring`. `Integrations` includes Settings-panel registration; Edit Mode and keybinding profile operations are intentionally unavailable until fully integrated. `UI` is lazily created and uses Blizzard templates.

Application is one operation: validate → read/diff → save one backup → write individual CVars → read back → keep module-separated report. If any write or read-back verification fails, every attempted CVar is restored to its pre-operation value in reverse order; the result is reported as rolled back (or rollback failed). In combat the whole operation is queued for `PLAYER_REGEN_ENABLED`, never partially applied.

Graphics is isolated from Interface & Gameplay. The only default interface CVar is `cameraSmoothStyle=0`; all sensitive or personal categories remain captured-only or disabled.
