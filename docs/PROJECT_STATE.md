# Project state

Last updated: 2026-07-19.

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
- The primary UI selects a preset, shows a concise diff preview, asks for confirmation, and applies it through the graphics transaction. Optional **Show changes** pages for built-in/personal Graphics, UI Tweaks, FPS recommendations, and import previews render only relevant settings with localized labels, human-readable current/target values, short explanations, and qualitative primary-effect metadata; identical entries remain hidden and unavailable/skipped entries stay separate. An immediate successful apply then runs the five-second post-apply measurement. A combat-queued apply skips that comparison because its pre-combat baseline is no longer statistically comparable, reports the reason, and leaves the standalone FPS Test available. Built-in UI applies always use **unified** graphics (`RAIDsettingsEnabled=0`).
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

- `ApplySettings` validates modules, allowlisted settings, and values, then builds a selected-module diff before writing or combat queuing. A zero-change diff returns explicit `unchanged` statistics without a backup, snapshot, write, rollback, or applied transaction-history record; unavailable/failed-only plans fail closed with their counts.
- Outside combat, a real diff re-reads every selected changed entry into an immutable transaction snapshot containing its exact previous value and target. A missing or invalid previous value returns `snapshot-failed` before backup creation and before the first write.
- After the snapshot succeeds, it captures a backup of every readable setting in each selected module, overrides changed-entry backup values from the exact snapshot, writes changed values, and verifies every write by reading it back.
- A write or read-back failure rolls back attempted writes in reverse order using only the immutable pre-write snapshot and verifies rollback writes. The result and rollback outcome are stored in a transaction history capped at 20 entries.
- Unsupported values and unavailable non-changed entries are reported without automatically blocking unrelated safe changed entries; the UI receives changed, identical, skipped, unavailable, and failed counts.
- `Settings/Diff.lua` is the single source for the five-field summary shape and status accounting. `Settings/DetailedDiff.lua` derives a read-only presentation model from that plan/summary without recounting it. Registry helpers own localized enum display values, explanations, and qualitative impact descriptions, with safe generic fallbacks when optional metadata is absent or invalid. Built-in/personal/FPS-candidate Graphics, Zone Graphics, UI Tweaks, profile/full-addon import, transaction results, pending feedback, and Backup Restore consume compatible summaries; previews and confirmations use `summary.changed` rather than inspected plan size, show skipped/unavailable/failed separately, and report an already-matching zero diff without a misleading confirmation.
- Combat work is copied into one typed in-memory pending slot and re-enters the same validation/transaction path on `PLAYER_REGEN_ENABLED`. Recovery can replace explicit or automatic work; explicit work can replace automatic Zone Graphics; automatic Zone Graphics can replace only an older `zone-auto`. Other equal/lower priority work is rejected with `pending-exists`.
- One post-combat dispatcher handles the final result for `graphics-user`, `zone-auto`, `zone-manual`, `ui-tweaks`, and `recovery`. It clears Pending UI state and applies kind-specific state/feedback for success, no-op, failure, rollback, and rollback failure. Queued Graphics commits a requested built-in preset only after verified success; failures keep the previous applied state and never start FPS measurement.
- Backups store a stable persistent ID, normalized source, timestamp, addon/client build, diagnostic trigger, affected modules, captured values, and read failures. Temporary FPS comparison records additionally carry their comparison session ID. Sources distinguish manual presets, personal profiles, automatic/manual Zone Graphics, imports, temporary FPS comparison work, restore safety, manual backups, UI Tweaks, and conservative legacy records. IDs use a persisted monotonic sequence with collision checks and do not change when history is inserted, reordered, trimmed, or reinitialized. The default history limit is 10 and is normalized to 1–50.
- Restore and delete resolve the selected record by stable ID rather than list position. Restore reports `restore-complete`, `restore-partial`, or `restore-unavailable` with explicit restored/identical/skipped/unavailable/failed counts. Removed legacy keys and values that were not captured are counted as unavailable; compatible settings still restore transactionally when safe. A real restore creates an ID-addressed safety backup, while a no-write complete/partial result creates no redundant safety history. Write failures remain failed restore outcomes, and `rollback-failed` stays distinct.

## Current FPS workflows

- **Post-apply:** for an immediate Graphics apply, the page keeps up to 20 baseline samples at 0.25-second intervals, then captures 20 post-apply samples over **5 seconds**. A non-cancellable progress dialog is shown and Reload UI is offered afterwards. Combat-queued applies never retain or consume the pre-combat baseline and do not start an automatic post measurement; after successful delayed application they report that the comparison was skipped, restart a fresh rolling baseline, keep standalone Test FPS available, and offer Reload UI.
- **Standalone:** one **20-second** `OnUpdate` frame-time capture reports average FPS, 1% Low, stability, adaptive spikes, and worst frame time.
- **Preset comparison:** captures current graphics for **20 seconds**, transactionally applies one unified built-in preset, waits 0.75 seconds, captures it for **20 seconds**, and transactionally restores the original graphics. Candidate and restore backups share one collision-safe comparison session ID and temporarily defer retention. After a verified restore—including Cancel and queued post-combat completion—only temporary records from that session are removed, so user Backup History is unchanged. Restore or rollback failure retains the session recovery records.
- A preset recommendation appears only after restoration when rounded Average FPS and rounded 1% Low both improve by at least 5%. Applying it requires confirmation and uses the normal graphics workflow plus the five-second follow-up.
- FPS results are character-local measurements, not universal performance guarantees.

## Current profiles, backups, and transfer

- The UI creates, renames, applies, exports, and deletes named personal **graphics** profiles. Valid personal profiles whose saved mode is `split` are explicitly labelled as legacy compatibility profiles. Their recommended action creates a new unified copy that uses base graphics everywhere while retaining the separate Raid/Battleground values as inactive compatibility data; the original profile and active client graphics remain unchanged. An advanced secondary action can still transactionally apply the exact legacy split values with a normal `personal-profile` backup. Invalid legacy data fails closed.
- **Save Graphics** derives the saved unified/split mode from the actual `RAIDsettingsEnabled` value in the same client CVar snapshot as the profile data. The persisted applied-mode preference never overrides this live value. Missing or unexpected values fail closed before a profile ID is allocated or any data is saved; profile capture never writes CVars.
- Backup History is a separate record list with manual graphics backup, restore, and delete actions. Explicit restore can target any selected retained graphics backup. Normal Graphics Undo separately selects the latest retained `manual-preset`, `personal-profile`, `profile-import`, `zone-manual`, or `addon-import` record and skips automatic Zone Graphics, FPS temporary, restore-safety, manual snapshot, legacy, and unknown sources. Both flows capture a stable ID before confirmation, so insertion, deletion, or retention cannot redirect the action to another row. A restore with real writes creates a safety backup first; an already-matching target does not. Combat-queued Restore and Undo show a pending warning until centralized completion reports the final result.
- `STBS1` profile export/import uses deterministic serialization, an integrity checksum, and a data-only parser. Individual export is exposed; the graphics import/preview flow exists in code but no current Profiles action opens it.
- `STBSA1` full-addon bundles contain current graphics, available UI Tweaks, selected graphics preset/mode, Zone Graphics assignments, performance-widget enabled state, and personal profiles. They exclude backup/transaction history, the removed legacy benchmark mode, and screen-specific layout values.
- Full-addon import applies graphics and UI Tweaks in one backup-first transaction, patches only the validated shared preference contract (performance-widget enabled state and Zone Graphics), and replaces personal profiles. The existing preferences table is retained, so backup limit, window/minimap/widget layout, and unknown future device-local fields survive. Import is rejected in combat rather than queued. Existing version-1 bundles may still contain a valid legacy `benchmarkMode`; it is accepted for compatibility and ignored.
- Imported text is untrusted: size/depth/entry/string limits, exact schemas, checksums, field allowlists, registry validation, and display-text escaping are enforced without `load` or `loadstring`.
- Legacy profile data without a schema version normalizes to profile schema 1; future profile schemas are rejected. A version-1 full bundle without `uiTweaksSettings` remains accepted as an empty UI Tweaks payload.

## Current UI architecture

- `UI/Style.lua` supplies the shared scalable button and checkbox system. `UI/MainWindow.lua` owns the lazily created page shell, responsive action layout, graphics sub-tabs, FPS dashboards, and the current slider wrapper. Dynamic page buttons, checkboxes, sliders, and section rows use typed pools capped by the greatest simultaneously rendered page; release clears callbacks, tooltips, anchors, action references, text, visibility, and interaction state before reuse.
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
- Structured backup sources are persisted, but Backup History intentionally still displays its existing concise trigger/date presentation until a later UI task.
- Core DB schema `6` uses an ordered migration pipeline. The known `2 -> 3` migration preserves old preset/mode as the runtime draft, marks persisted applied state as Custom, and requests one actual-CVar sync after addon load; `3 -> 4` assigns collision-safe stable IDs to every legacy backup and initializes the persisted backup sequence; `4 -> 5` adds normalized backup provenance; `5 -> 6` removes the obsolete persisted benchmark selector. Known historical triggers are mapped conservatively, while unknown triggers or invalid source values become `legacy` rather than being treated as user actions. Fresh, missing, or corrupted version metadata uses a separate unversioned recovery path rather than invented historical migrations. A future schema is never normalized or rewritten: the original SavedVariables stay untouched, runtime consumers receive an isolated read-only safe view, and every account-database mutation API fails with `database-schema-unsupported` through one writable guard. Runtime-only drafts and independently persisted character FPS results remain available. Profile migration remains separate and currently only normalizes legacy schema-1 data.
- There is no benchmark mode selector or persisted benchmark preference. Automatic post-apply, standalone FPS Test, and current-vs-preset comparison are independent fixed workflows. Recommendation thresholds use rounded metrics, and stored FPS results do not identify the scene in which they were measured.
- Zone Graphics blocks standalone/preset tests and pending preset restoration, but it does not block the five-second post-apply sampler.
- Individual `STBS1` profile import is implemented but is not reachable from the current Profiles navigation; only full-addon import is exposed there.
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
