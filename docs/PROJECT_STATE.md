# Project state

Last updated: 2026-07-18.

This file is a compact snapshot of the implementation on `main`, not a permanent specification or version history. Use `CHANGELOG.md` for release history and inspect current code and tests before changing behavior.

## Current release state

- Addon version: **0.4.20-alpha** in both `Core/Constants.lua` and the TOC.
- Client target: **WoW Retail 12.0.7**, Interface **120007**.
- Verified registry baseline: Blizzard client build **68453** (`12.0.7.68453`); the same build is used by the Lua test harness.
- Status: **alpha**. Live-client visual QA and controlled hardware benchmarks are still required before a stable/production release.

## Current product navigation

The main window exposes five top-level pages:

1. **Graphics**
2. **UI Tweaks**
3. **Test FPS**
4. **Profiles**
5. **About**

Graphics has two sub-tabs: **Graphics Settings** and **Zone Graphics Switcher**. Profiles has **Profiles**, **Backups**, and **Import / Export** views. Interface & Gameplay has no current top-level page; its module and profile fields remain only for compatibility.

## Current Graphics workflow

- Built-in presets are **PRO**, **Optimized**, and **Quality**. The header detects the actually active preset and otherwise shows Custom.
- Preset/mode selection in Graphics is a runtime draft. Account-wide `graphicsPreset` and `graphicsMode` describe only the last verified applied state and change after a successful immediate or queued transaction; failed, cancelled, and rolled-back work leaves them unchanged.
- The primary UI selects a preset, shows a diff preview, asks for confirmation, and applies it through the graphics transaction. An immediate successful apply then runs the five-second post-apply measurement. A combat-queued apply skips that comparison because its pre-combat baseline is no longer statistically comparable, reports the reason, and leaves the standalone FPS Test available. Built-in UI applies always use **unified** graphics (`RAIDsettingsEnabled=0`).
- Zone Graphics and preset FPS comparisons also use unified graphics. The old **split** mode is still accepted by SavedVariables, profile schema, import, flattening, restore, and personal-profile application, but there is no current split-mode selector in Graphics.
- The graphics registry intentionally does not manage monitor/display choice, resolution, render scale, refresh rate, V-Sync, graphics API, FPS caps, or latency controls. Anti-aliasing is selected only when the client reports support.
- Official presets currently preserve projected textures, usable particles and outlines, and high texture resolution while scaling more expensive quality settings.

## Current Zone Graphics behavior

- Zone Graphics is opt-in and disabled by default.
- Assignments are stored as a category-to-preset map: `world`, `party`, `raid`, `pvp`, and `scenario` each select `pro`, `optimized`, or `quality`.
- Defaults are Optimized for World/City, Dungeon, and Scenario/Delve; PRO for Raid and PvP/Arena.
- `C_PartyInfo.IsDelveInProgress()` maps an active Delve to `scenario`; otherwise `IsInInstance()` maps party, raid, scenario, PvP/arena, and falls back to world.
- Enabling the feature applies the current assignment immediately. Assignments can be cycled without applying, and **Apply for current zone** is available explicitly.
- Automatic checks run 0.8 seconds after `PLAYER_ENTERING_WORLD` and `ZONE_CHANGED_NEW_AREA`. Unchanged settings skip the transaction and backup.
- In combat, a validated zone transaction uses the typed single pending slot (`zone-auto` or `zone-manual`). A newer automatic request replaces an older `zone-auto`; on `PLAYER_REGEN_ENABLED`, the addon re-detects the live zone and reads its current assignment before applying. Explicit user and recovery work cannot be replaced by an automatic request.
- If the final automatic target already matches current graphics, the stale pending request is cleared without creating a backup or transaction. Active zone category/preset state is recorded only after a verified successful apply or verified no-op and is cleared after queued, failed, cancelled, or rolled-back attempts.
- Zone switching is suspended while the standalone/preset FPS test flag is active and while a preset restore is pending. More limited interactions are listed under current technical debt.

## Current UI Tweaks

UI Tweaks is an autonomous `uiTweaks` module. Graphics presets and Zone Graphics do not read, write, or back up its settings.

- Recommended image controls: resample sharpening enable, sharpness amount, and glow.
- Optional visual controls: death and ghost/nether effects.
- Optional camera control: maximum camera distance toggle between `1.9` and `2.6`.
- Each control is runtime-gated by current CVar metadata. Changes remain in a draft until confirmation, then use the normal transaction and a module-specific backup. The page exposes a dedicated latest-backup Undo.

The registry is the source for exact CVar names and value ranges; this snapshot intentionally does not duplicate it.

## Current transaction and backup behavior

- `ApplySettings` validates modules, allowlisted settings, and values before either writing or combat queuing.
- Outside combat it builds a diff, captures a backup of every readable setting in each selected module, writes changed values, and verifies every write by reading it back.
- A write or read-back failure rolls back attempted writes in reverse order. The result and rollback outcome are stored in a transaction history capped at 20 entries.
- Unsupported values are skipped and unavailable entries are reported; the UI receives changed, identical, skipped, unavailable, and failed counts.
- Combat work is copied into one typed in-memory pending slot and re-enters the same validation/transaction path on `PLAYER_REGEN_ENABLED`. Recovery can replace explicit or automatic work; explicit work can replace automatic Zone Graphics; automatic Zone Graphics can replace only an older `zone-auto`. Other equal/lower priority work is rejected with `pending-exists`.
- One post-combat dispatcher handles the final result for `graphics-user`, `zone-auto`, `zone-manual`, `ui-tweaks`, and `recovery`. It clears Pending UI state and applies kind-specific state/feedback for success, no-op, failure, rollback, and rollback failure. Queued Graphics commits a requested built-in preset only after verified success; failures keep the previous applied state and never start FPS measurement.
- Backups store a stable persistent ID, timestamp, addon/client build, trigger, affected modules, captured values, and read failures. IDs use a persisted monotonic sequence with collision checks and do not change when history is inserted, reordered, trimmed, or reinitialized. The default history limit is 10 and is normalized to 1–50.
- Restore and delete resolve the selected record by stable ID rather than list position. Restore filters removed registry keys, creates an ID-addressed safety backup, then applies the selected saved values transactionally.

## Current FPS workflows

- **Post-apply:** for an immediate Graphics apply, the page keeps up to 20 baseline samples at 0.25-second intervals, then captures 20 post-apply samples over **5 seconds**. A non-cancellable progress dialog is shown and Reload UI is offered afterwards. Combat-queued applies never retain or consume the pre-combat baseline and do not start an automatic post measurement; after successful delayed application they report that the comparison was skipped, restart a fresh rolling baseline, keep standalone Test FPS available, and offer Reload UI.
- **Standalone:** one **20-second** `OnUpdate` frame-time capture reports average FPS, 1% Low, stability, adaptive spikes, and worst frame time.
- **Preset comparison:** captures current graphics for **20 seconds**, transactionally applies one unified built-in preset, waits 0.75 seconds, captures it for **20 seconds**, and transactionally restores the original graphics. A temporary restore backup is removed by its exact stable ID only after verified restoration, leaving the candidate-apply backup as the user rollback point.
- A preset recommendation appears only after restoration when rounded Average FPS and rounded 1% Low both improve by at least 5%. Applying it requires confirmation and uses the normal graphics workflow plus the five-second follow-up.
- FPS results are character-local measurements, not universal performance guarantees.

## Current profiles, backups, and transfer

- The UI creates, renames, applies, exports, and deletes named personal **graphics** profiles. A profile retains unified/split mode so older split profiles can still be applied.
- Backup History is a separate record list with manual graphics backup, restore, and delete actions. The UI keeps the selected stable ID through confirmation, so a newly inserted backup cannot redirect restore/delete to another row. Restore always creates a safety backup first.
- `STBS1` profile export/import uses deterministic serialization, an integrity checksum, and a data-only parser. Individual export is exposed; the graphics import/preview flow exists in code but no current Profiles action opens it.
- `STBSA1` full-addon bundles contain current graphics, available UI Tweaks, selected graphics preset/mode, benchmark mode, Zone Graphics assignments, performance-widget enabled state, and personal profiles. They exclude backup/transaction history and screen-specific layout values.
- Full-addon import applies graphics and UI Tweaks in one backup-first transaction, then replaces imported preferences and personal profiles. It is rejected in combat rather than queued.
- Imported text is untrusted: size/depth/entry/string limits, exact schemas, checksums, field allowlists, registry validation, and display-text escaping are enforced without `load` or `loadstring`.
- Legacy profile data without a schema version normalizes to profile schema 1; future profile schemas are rejected. A version-1 full bundle without `uiTweaksSettings` remains accepted as an empty UI Tweaks payload.

## Current UI architecture

- `UI/Style.lua` supplies the shared scalable button and checkbox system. `UI/MainWindow.lua` owns the lazily created page shell, responsive action layout, graphics sub-tabs, FPS dashboards, and the current slider wrapper.
- `ShowAddonDialog` is the reusable confirmation/text-entry component. FPS tests use a separate reusable progress modal.
- The main window opens centered, is resizable within screen-derived bounds, saves its size, and is deliberately not clamped to screen edges.
- The minimap button opens Graphics on left click and Profiles on right click; Ctrl is not required to drag it around the minimap.
- The Blizzard Settings launcher is registered lazily when Graphics is first shown.
- The optional performance widget shows live FPS and the greater Home/World latency every 0.5 seconds. Ctrl + drag moves it; enabled state and normalized position persist locally.

## Current tests and validation

- Run the pure Lua regression suite with `lua Tests/run.lua`.
- Run whitespace/error validation with `git diff --check`.
- The suite covers registry safety, profiles/migration, serialization/import, transactions/rollback, backups, FPS workflows, Zone Graphics, UI Tweaks, localization, and important UI source contracts.
- Automated Lua tests do not replace visual and behavioral testing in a live WoW Retail client.

## Current known limitations and technical debt

- Pending work remains one non-persistent in-memory slot with typed provenance and priority replacement instead of FIFO. Replaced lower-priority work is not deferred, and equal-priority work is rejected except for latest-state `zone-auto` coalescing.
- Backups still have no structured provenance beyond their trigger/context. General `ApplySettings` can also create a backup when its whole diff is identical, although Zone Graphics and UI Tweaks pre-check their no-op paths.
- Core DB schema `4` uses an ordered migration pipeline. The known `2 -> 3` migration preserves old preset/mode as the runtime draft, marks persisted applied state as Custom, and requests one actual-CVar sync after addon load; `3 -> 4` assigns collision-safe stable IDs to every legacy backup and initializes the persisted backup sequence. Fresh, missing, or corrupted version metadata uses a separate unversioned recovery path rather than invented historical migrations. A future schema is never normalized or rewritten: the original SavedVariables stay untouched, runtime consumers receive an isolated read-only safe view, and every account-database mutation API fails with `database-schema-unsupported` through one writable guard. Runtime-only drafts and independently persisted character FPS results remain available. Profile migration remains separate and currently only normalizes legacy schema-1 data.
- `benchmarkMode` and the two-phase 10+10-second `StartAccurateFPSComparison` path remain stored code but are not used by the current UI. Recommendation thresholds use rounded metrics, and stored FPS results do not identify the scene in which they were measured.
- Zone Graphics blocks standalone/preset tests and pending preset restoration, but it does not block the five-second post-apply sampler or the unused legacy accurate sampler.
- Individual `STBS1` profile import is implemented but is not reachable from the current Profiles navigation; only full-addon import is exposed there.
- Full-addon import preserves window size and performance-widget position, but replacing preferences currently drops the device-local minimap button angle.
- Live Retail QA across supported resolutions and controlled hardware benchmarking remain outstanding.

## Continuation workflow

1. Read `AGENTS.md` and this snapshot.
2. Inspect the current implementation and regression tests for the affected area.
3. Prefer the current task, production code, tests, and this snapshot over stale historical or research documents; report and update contradictions when they are in scope.

## Detailed references

- Architecture: `docs/ARCHITECTURE.md`
- Preset evidence: `docs/RECOMMENDED_PROFILE_RESEARCH.md`
- Registry: `docs/SETTINGS_REGISTRY.md`
- Import format: `docs/IMPORT_FORMAT.md`
- Test plan: `docs/TEST_PLAN.md`
- Release process: `docs/RELEASE.md`
