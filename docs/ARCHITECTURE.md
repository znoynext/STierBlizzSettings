# Architecture

This document describes the current technical boundaries and contracts of S-Tier Blizz Settings. Mutable product behavior and release status belong in `docs/PROJECT_STATE.md`. The addon is loaded in `.toc` order into the shared `STBS` namespace; the boundaries below are conventions enforced by ownership, validation, and tests rather than by a Lua module loader.

## Component boundaries

- **Core** owns bootstrap/localization helpers, Retail capability checks, SavedVariables initialization, event routing, zone classification, FPS/frame-time sampling, the autonomous UI Tweaks draft, and small runtime integrations such as the performance widget and minimap entry.
- **Settings** is the only approved path for managed CVar access. It owns the allowlisted registry, validation, reads, writes with read-back verification, diff planning, backups, and transaction execution.
- **Profiles** owns the versioned profile schema, built-in recommended profiles, personal-profile persistence, legacy profile normalization, and flattening profiles into registry-backed settings.
- **ImportExport** owns deterministic serialization, bounded data-only parsing, integrity checks, schema/allowlist validation, and orchestration of profile or full-addon imports. Imported data must cross this boundary before it reaches persistence or a transaction.
- **UI** owns the shared visual style, lazily-created main window, reusable addon dialogs, dynamic page/action construction, responsive layout, and presentation of settings, profiles, backups, and FPS workflows. It may collect intent, but managed CVar mutation remains a Settings responsibility.
- **Integrations** contains optional adapters to Blizzard Settings, Edit Mode, and keybindings. Blizzard Settings launches the addon UI. Edit Mode capture/restore is a separate confirmed, non-CVar mechanism and is not part of the current profile transaction path. Keybinding integration is currently disabled and must remain explicit opt-in if enabled later.

## Settings registry contract

`Settings/Registry.lua` is the data-driven allowlist for every managed setting. Each record identifies the owning module and category and supplies the metadata needed to validate and compare values: type, allowed values or numeric bounds/step/tolerance, optional safety minimums, official-profile eligibility, graphics validation strategy, and capability/feature requirements. Entries also carry the verified client build used when the registry was authored.

Module ownership is a transaction boundary. A transaction selects modules; capture, backup, and write execution are filtered to registry entries owned by those modules. The diff planner can still describe an unselected entry submitted in a mixed payload, but the transaction ignores it as noted below. Runtime availability is checked separately from static registry validation: CVar access uses `C_CVar.GetCVarInfo`, while graphics features can require Blizzard capability APIs or feature validators. Missing, protected, locked, secure, read-only, or unsupported settings fail closed or become non-writable diff entries.

Every current registry entry declares `readable`, `writable`, and `portable` as true. These fields document intended semantics, but the current Reader, Writer, and import validation do not consistently consult the flags themselves. A future false value would therefore not yet be an enforced policy; this is technical debt. Portability also does not mean that device-local addon preferences should be exported.

## Transaction pipeline

The production pipeline in `Settings/Transaction.lua` is:

1. Validate the selected module map and the submitted setting values against the registry. At least one submitted setting must belong to a selected module.
2. Build a selected-module diff and its nested/summary statistics. When it contains no changed target, return `unchanged` immediately for identical/skipped entries, or fail closed as `unavailable`/`failed` when those entries prevent a verified no-op. No backup, snapshot, write, rollback, or transaction-history record is created.
3. If a real diff remains and combat lockdown is active, classify the request as a typed pending operation, deep-copy it into the priority-aware single slot when replacement is allowed, and return without a backup.
4. Re-read every selected `changed` entry and build a local immutable snapshot containing its exact previous value and target. If any changed entry cannot be read or its previous value cannot be validated, return `snapshot-failed` before creating a backup or making the first write. Unavailable entries outside the changed set do not block unrelated safe entries.
5. Unless `skipBackup` is set, capture all readable values in the selected modules and insert them into backup history with the workflow's normalized `backupSource` while retaining its diagnostic trigger. Exact changed-entry values from the transaction snapshot override duplicate backup reads.
6. Write only `changed` entries through `Settings/Writer.lua`, passing the snapshotted previous value instead of discovering it inside or after the write; each write is immediately read back and compared with registry-aware equality.
7. If a write or read-back fails, restore attempted entries in reverse order from the immutable pre-write snapshot and verify each rollback write. Record `rolled-back` or `rollback-failed` in the transaction log.
8. If writes complete, record an `applied` transaction result. Immediate callers update their own persistent selection/applied-state fields; combat-delayed work delegates that commit to the typed completion handler after the transaction result is known.

This implements the desired `Validate -> Diff -> No-op/Queue or Snapshot/Backup -> Write -> Read-back Verify -> Rollback on Failure -> Commit Applied State` invariant. Graphics callers pass desired mode/preset as transaction context and use `CommitAppliedGraphicsState` only after a verified `applied` or `unchanged` result; the UI selection setters update a separate runtime draft and never write the applied SavedVariables. Remaining transaction gaps are:
- Unsupported, unreadable, and non-writable entries do not fail the whole transaction; they are reported and the remaining changed entries may still apply.
- A mixed payload is accepted when at least one setting belongs to a selected module; settings owned by unselected modules are ignored rather than rejected as a module-closure error.

These gaps are technical debt, not alternative architectural invariants.

## Diff contract

`Settings/Diff.lua` produces a sorted plan and counts with these current statuses:

- `changed`: valid, readable, writable, and different from the current value;
- `identical`: equal under the registry's exact or tolerance-aware comparison;
- `skipped`: known but unsupported by the current client capability;
- `unavailable`: the current value cannot be read or the setting is not writable;
- `failed`: the submitted value is invalid for another reason.

The transaction writes only `changed` entries. The other statuses remain part of the result so the UI and logs can explain partial or empty work.

## Pending and combat architecture

Delayed work uses one in-memory, non-persistent typed slot owned by `Settings/Transaction.lua`. Every operation contains `kind`, copied `settings`, copied `modules`, `trigger`, copied transaction `options`, and copied logical `context`. Supported kinds are `graphics-user`, `zone-auto`, `zone-manual`, `ui-tweaks`, and `recovery`. Trigger strings remain transaction-log metadata and a compatibility input; post-combat routing uses kind/context rather than parsing trigger strings.

The pending API consists of `QueuePendingOperation`, `GetPendingOperation`, `CancelPendingOperation`, `CanReplacePendingOperation`, and `CompletePendingOperation`. The getter returns an isolated copy. Completion removes the operation from the slot and re-enters the normal validated transaction path, returning both the operation and its transaction result. Cancellation can require an expected kind so one workflow cannot accidentally cancel another.

Replacement is deliberately priority-based rather than FIFO: recovery/restore work outranks explicit user work; `graphics-user`, `zone-manual`, and `ui-tweaks` share the explicit-user priority; automatic `zone-auto` work is lowest. A strictly higher-priority operation may replace the current item. The one same-priority exception is `zone-auto` replacing an older `zone-auto`, which coalesces automatic zone requests to the latest observed state. Other equal- or lower-priority work receives `pending-exists`. Replaced lower-priority work is discarded rather than deferred because there is still no queue.

On `PLAYER_REGEN_ENABLED`, `Events.lua` makes one call to `CompletePendingAfterCombat`. That workflow re-resolves the live category and assignment for `zone-auto`, completes every other operation through the normal validated transaction path, and passes the operation plus result to `HandlePendingOperationCompletion`. Kind handlers for `graphics-user`, `zone-auto`, `zone-manual`, `ui-tweaks`, and `recovery` own final UI feedback and state cleanup for `applied`, `unchanged`, `failed`, `rolled-back`, and `rollback-failed`. Trigger inspection is confined to recovery subtypes such as FPS comparison restore; event routing does not branch on triggers.

Queued Graphics operations never retain or consume a pre-combat FPS baseline. A successful delayed apply reports that automatic comparison was skipped, commits desired mode/preset from operation context, refreshes the rolling baseline, and offers Reload UI. Failed, cancelled, rolled-back, and rollback-failed operations preserve the previous applied state and never start FPS measurement; their runtime UI draft remains distinct.

## Backup architecture

Before a normal transaction writes, `Settings/Backup.lua` captures all readable values owned by the selected modules. The transaction replaces duplicate reads for changed entries with their exact pre-write snapshot values, so both rollback and the user backup share the same known previous state. A backup records a stable persistent ID, normalized `source`, timestamp, addon/client versions, free-form diagnostic trigger, affected modules, captured values, and read failures. The supported sources are `manual-preset`, `personal-profile`, `zone-auto`, `zone-manual`, `profile-import`, `addon-import`, `fps-comparison-temp`, `restore-safety`, `manual-backup`, `ui-tweaks`, and `legacy`. Production workflows pass their source explicitly; an unknown supplied source is rejected, while omitted compatibility calls are stored conservatively as `legacy`. IDs are allocated from a persisted monotonic sequence and checked against every retained ID before insertion. New records are inserted at index 1 and history is trimmed to the configured limit (normalized to 1-50, default 10); index is presentation order only, while identity remains unchanged through insertion, reordering, retention, and repeated initialization. Deferred trimming is used by the preset-comparison restore flow.

`GetBackupById`, `RestoreBackupById`, and `DeleteBackupById` resolve records by stable ID and return `missing` for unknown IDs. Restore filters out removed or no-longer-owned settings, validates the remaining payload, and submits one transaction with `backupSource=restore-safety`. The transaction creates that safety record only when its final diff contains real writes; a combat-delayed recovery carries the stable source backup ID and creates safety history only at actual execution. Failed restore preserves the safety record.

Each preset comparison allocates one collision-safe session ID from the persisted backup-ID sequence before candidate application. Every newly created `fps-comparison-temp` record must carry that session ID; unrelated sources cannot carry it. Candidate and restore transactions defer retention while the in-memory session is active, including a combat-queued restore. Only an actually successful, read-back-verified restore closes the session and removes records matching both `source=fps-comparison-temp` and the exact session ID before normal retention resumes. Cancel uses the same workflow. Failed restore, failed rollback, or queued failure closes retention deferral but preserves the session's retained recovery records; cleanup never selects by array index and never touches another session or user/zone/manual records.

`trigger` remains unchanged for diagnostics and compatibility, but logic that needs workflow semantics uses `source`. `GetLatestUndoableBackup("graphics")` walks presentation order but returns the first retained graphics backup whose source is an explicit user change: `manual-preset`, `personal-profile`, `profile-import`, `zone-manual`, or `addon-import`. It excludes `zone-auto`, `fps-comparison-temp`, `restore-safety`, `manual-backup`, `legacy`, and unknown sources. The confirmation captures that record's stable ID; if retention or deletion removes it before acceptance, `RestoreBackupById` returns `missing` and never selects another record. Backup History explicit restore remains source-agnostic and separate from Undo.

## Database and schema architecture

Account-wide `STierBlizzSettingsDB` stores schema version, preferences, personal profiles, backups, the backup/profile sequences, and the transaction log. Initialization creates missing containers, normalizes known preferences and Zone Graphics data, removes structurally invalid backup records, and applies retention. Character-local `STierBlizzSettingsCharDB` stores measured FPS results and has no independent schema version.

The account schema constant is currently 5. `MigrateDatabase` owns an ordered table of migrations keyed by source schema. It preflights that every required `N -> N+1` function exists, runs each step in order, and advances `schemaVersion` only after that step succeeds. Migration `2 -> 3` moves legacy preset/mode intent into a runtime draft, initializes persisted applied preset as Custom, and sets a one-time flag so `ADDON_LOADED` can inspect real graphics CVars before committing applied preset/mode. Migration `3 -> 4` preserves valid unique backup IDs, assigns sequence-backed IDs to legacy records without one, resolves collisions, and persists `backupSequence`. Migration `4 -> 5` preserves any valid source, maps recognized historical triggers to normalized provenance, and assigns `legacy` to unknown triggers or invalid source values. Repeated initialization at schema 5 normalizes but never reruns these migrations or changes retained IDs/sources.

Fresh databases and databases with missing/corrupted version metadata use a separate unversioned recovery path and are initialized directly at the current schema; no fictitious schema 0/1 migration is claimed. Normalization then preserves valid preference containers, profiles, backups, transactions, Zone Graphics assignments, applied state, and device-local positions while repairing invalid known fields and applying retention. A numeric or numeric-string version above `DB_SCHEMA` returns `future-schema` before normalization. `InitializeDatabase` leaves the original global table untouched and exposes only an isolated normalized runtime view.

`RequireWritableDatabase` is the single account-persistence boundary. On a supported current database it returns the real normalized table. On an unsupported schema it returns `database-schema-unsupported`, so managed transactions, backups/retention/restore/delete, profile save/rename/delete, applied graphics commits, Zone Graphics preferences, benchmark/widget/window/minimap preferences, full import, transaction history, and logging cannot mutate either the future database or the fallback view or report false success. Read-only UI rendering and runtime-only drafts remain safe; character-local FPS results use the separate `STierBlizzSettingsCharDB` and are not claims about the unsupported account schema. This boundary prevents crashes without pretending that fallback writes were persisted.

Future persisted changes add exactly one migration under their source version. Stable backup identity belongs to schema 4 and structured backup provenance to schema 5. Device-local preferences must be preserved by shared-data import; the current full-addon import preserves window/widget fields but omits `minimapAngle` when replacing preferences.

## Profiles

Profiles use schema version 1 with validated metadata and module sections. Personal profiles are named account-wide records created by capturing current registry values. Built-in recommended profiles are generated in code and can adapt supported graphics capabilities. Legacy split graphics and Interface & Gameplay data remain accepted for compatibility even though the current primary graphics application path is unified.

`Profiles/Manager.lua` validates or migrates the profile, resolves the requested graphics mode, and flattens sections into a registry-backed settings map. Application then delegates to the normal transaction/FPS UI workflow; the profile layer does not write CVars. Profile migration rejects future schema versions, but its current migration work is limited to normalizing missing version/section/graphics containers.

## Import/export security boundary

Exports use a deterministic serializer with sorted keys and cycle/depth restrictions. The transport codec uses a deterministic non-cryptographic checksum and a hex payload encoding (despite legacy helper names referring to Base64). The checksum detects accidental corruption; it does not authenticate a sender.

Imports use a purpose-built data parser rather than `load`, `loadstring`, or execution of Lua source. Input size, nesting depth, entry count, string length, prefix/version/flavor, and checksum are bounded before data is accepted. Profile and full-addon validators reject unknown fields, unknown registry settings, invalid module ownership, future schemas, and malformed preferences/profiles. Imported strings displayed by the UI pass through `SafeText`.

A full-addon bundle applies shared graphics/UI Tweaks through one normal backup-first transaction. Only after that transaction reports success are validated preferences and personal profiles installed. Individual `STBS1` profile import is implemented in the import layer, but the current Profiles navigation has no launcher for it.

## FPS architecture

FPS functionality has four distinct mechanisms:

- **Live sampling** periodically reads `GetFramerate()` and feeds a bounded baseline window used by the UI.
- **Post-apply measurement** compares the rolling baseline with a short five-second sample only when a Graphics apply succeeds immediately. The baseline remains local to the immediate UI call and is never copied into a pending operation. A combat-queued Graphics apply carries only an `automaticFPS` context marker; after completion it resets rolling baseline state, reports that automatic comparison was skipped, and never starts the post sampler. This prevents measurements from different scenes/times being presented as a before/after result.
- **Standalone measurement** records raw `OnUpdate` frame times for 20 seconds and derives average FPS, 1% Low, stability, spike count, and worst-frame time into character-local results.
- **Preset comparison** captures a complete original graphics snapshot, measures the current state for 20 seconds, transactionally applies one built-in unified candidate, measures it for 20 seconds, and transactionally restores the exact captured values. Zone Graphics is suspended during this workflow. Cancellation after candidate apply also attempts restoration; combat can defer that restoration through the pending slot. Successful restoration removes every temporary backup from that comparison session and restores the user's prior Backup History; any uncertain recovery outcome retains its scoped recovery data.

The newer preset comparison is separate from the older unused `StartAccurateFPSComparison` 10+10-second path, which remains legacy code. Stored results have no scene identity or freshness context, and the current recommendation UI compares rounded display metrics rather than raw precision. Post-apply and legacy accurate modes are not included in every Zone Graphics benchmark guard. These are current technical limitations.

## Zone Graphics architecture

Zone Graphics currently owns a five-category mapping: world, party, raid, PvP/arena, and scenario/delve. The mapping stores built-in preset IDs, not copied setting tables. On relevant world/zone events, current Retail instance APIs classify the player, the assigned built-in unified profile is flattened and validated, and a graphics-only diff is built. Identical assignments stop before transaction/backup creation; changed assignments use the same graphics transaction path as manual applies.

Combat routes Zone Graphics through the typed pending slot as `zone-auto` for zone events or `zone-manual` for explicit enable/apply actions. A newer automatic request replaces an older `zone-auto`, but cannot replace explicit user or recovery work. At combat end, automatic handling reclassifies the live zone and reads its current assignment instead of applying the stored snapshot. If the final target already matches current graphics, the stale automatic operation is cancelled and no backup or transaction is created. `activeZoneCategory` and `activeZonePreset` are committed only after a verified successful apply or verified no-op, and are cleared on queued, failed, cancelled, or rolled-back attempts. Event handling still uses an uncancelled short timer, so rapid zone events can schedule redundant attempts; latest-state resolution makes those attempts safe but does not cancel the timers. Zone Graphics blocks standalone and preset-comparison measurement/restore states, but not every post-apply or legacy benchmark state.

## UI architecture and lifecycle

`UI/Style.lua` is the shared visual contract for addon buttons, checkboxes, palettes, and interactive states. `UI/MainWindow.lua` lazily creates one resizable main frame, computes responsive content/action geometry from its size, builds pages and their actions dynamically, and routes managed changes to profiles or transactions. `ShowAddonDialog` provides a reusable addon-owned confirmation/text-input surface; FPS measurement uses a dedicated reusable progress/result modal. The optional Performance Widget is a separate frame with a single replaceable 0.5-second ticker. The minimap entry and Blizzard Settings category both open the same main window.

Frames, callbacks, `OnUpdate` handlers, and tickers are expected to have explicit ownership and cleanup. The FPS samplers clear their handlers/tickers, the main window stops its live callbacks when hidden, the widget replaces or cancels its ticker, and minimap drag updates end with the drag. Two lifecycle gaps remain: repeated page renders create new action frames without reclaiming or reusing old ones, and Zone Graphics event delays use uncancellable timers. These can accumulate dormant frames or stale callbacks during a long session.

## Architectural invariants

The following are durable boundaries. Known deviations above are technical debt and must not be treated as precedent.

- Managed CVars are mutated only by `Settings/Writer.lua` through an approved transaction or rollback path; direct unsafe mutation elsewhere is forbidden.
- Registry allowlisting, module ownership, validation, and runtime capability checks fail closed for unknown or unavailable settings.
- Every successful managed write is read back; a failed write or verification triggers best-effort reverse rollback.
- Persistent state that claims an operation was applied is committed only after the transaction succeeds.
- Graphics/profile operations select only their intended modules and must not mutate unrelated autonomous modules such as UI Tweaks.
- Imports are bounded, schema-validated data and never execute code.
- User-visible text crosses the localization boundary; untrusted display strings are sanitized.
- Runtime frames, callbacks, `OnUpdate` handlers, and tickers have bounded ownership and cleanup.
