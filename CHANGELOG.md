# Changelog

Entries below are version-scoped historical records, not a description of the current UI or architecture. See `docs/PROJECT_STATE.md` and `docs/ARCHITECTURE.md` for current behavior and contracts.

## 0.4.20-alpha

- Cached actual PRO/Optimized/Quality detection across ordinary page renders instead of repeating a full Graphics/registry/capability scan. Verified graphics transactions invalidate the cache, applied-state sync and window open force a live refresh for external changes, and failed/rolled-back work cannot record the requested preset; no polling or preset/Diff values changed.
- Replaced per-session frame-time capture frames with one reusable FPS sampler frame. Explicit lifecycle state now rejects overlapping captures, clears frame times and callbacks on completion/Cancel/error, and uses a generation guard so a stale update cannot affect a restarted test; measurement methodology and recommendation thresholds are unchanged.
- Bounded repeated main-page rendering with typed reuse pools for dynamic buttons, checkboxes, sliders and section rows. Recycled controls now clear callbacks, tooltips, anchors, action references, text and interaction state so long sessions do not accumulate a new persistent frame or stale action on every page switch.
- Corrected Graphics, personal-profile, FPS recommendation and import review counts to use only settings that actually require writes. Already-matching graphics now skip misleading confirmation, while full-addon import still explains that shared profiles and preferences remain importable.
- Clarified the recommended UI Tweaks note so its expected performance cost is explicitly shown as **about 0 FPS**.
- Stopped combat-queued Graphics applies from comparing a stale pre-combat FPS baseline with a later scene. Delayed success now skips automatic comparison with clear feedback, keeps Test FPS available and still offers Reload UI; immediate applies retain the five-second workflow.
- Centralized post-combat completion for Graphics, automatic/manual Zone Graphics, UI Tweaks and recovery. Every final transaction outcome now clears Pending state through a typed handler; failed Graphics keeps the previous applied preset, reports an actionable error and never starts FPS measurement.
- Separated runtime Graphics selection from persisted applied state. Preset/mode now commit only after a verified successful immediate or queued transaction; failures, cancellation and rollback preserve the previous state, while schema 2 migrates explicitly to schema 3 and re-detects the real client graphics.
- Replaced ad-hoc SavedVariables initialization with an ordered migration pipeline. Schema 2 now advances through the explicit `2 -> 3` step once, while future unsupported schemas are preserved unchanged and block managed settings transactions instead of being rewritten as schema 3.
- Made the future-schema fallback genuinely read-only for account persistence. Backup, profile, import, Zone Graphics, applied-state and local-preference APIs now share one writable-database guard and return `database-schema-unsupported` instead of reporting session-only success.
- Added stable persistent backup IDs through the explicit schema `3 -> 4` migration. Restore, delete, Undo confirmations, queued recovery and temporary FPS cleanup now keep exact backup identity even when newer history entries shift presentation indexes.
- Added normalized backup provenance through schema `4 -> 5`. New backups explicitly distinguish manual presets, profiles, Zone Graphics, imports, FPS temporary work, restore safety, manual snapshots and UI Tweaks while retaining diagnostic triggers; unknown legacy data fails safe as `legacy`.
- Corrected Graphics Undo to select the latest retained user-initiated graphics change by stable backup ID. Automatic Zone Graphics, FPS temporary, restore-safety, manual snapshots, legacy and unknown records are skipped, while explicit Backup History restore remains independent.
- Scoped temporary FPS comparison backups by a collision-safe session ID. Successful and cancelled comparisons now remove only their own temporary records after verified restoration, queued restores wait for actual completion, and restore/rollback failures retain recovery data without deleting user or unrelated-session backups.
- Guaranteed an exact pre-write value for every changed transaction target. Transactions now complete an immutable snapshot before backup or writes, fail closed with zero writes if a changed value cannot be captured, and use that snapshot for verified reverse rollback without blocking unrelated unavailable settings.
- Removed no-op transaction side effects. Already-active settings now return explicit `unchanged` statistics without backups, writes, rollback, applied-change history, FPS measurement or Reload prompts; no-op restores also skip redundant safety backups.
- Added explicit partial restore semantics. Backup recovery now distinguishes complete, partial and all-unavailable outcomes with restored/identical/skipped/unavailable/failed counts, restores compatible legacy values without hiding removed CVars, preserves stable IDs through queued completion, and never labels write or rollback failure as partial success.
- Protected failed FPS-comparison and ordinary restore recovery records from backup retention, including at `backupLimit=1` and across database normalization. Combat-queued Backup History Restore and Undo now show a localized pending status until centralized completion reports the verified final outcome.
- Full-addon import now patches only its validated shared preferences instead of replacing the entire preferences table, preserving window/widget/minimap layout, backup limits, and unknown future device-local fields while retaining existing bundle compatibility and profile replacement behavior.
- Removed the unused quick/accurate benchmark selector, its dead 10+10-second workflow, persisted preference and new-export field. Schema `5 -> 6` deletes the obsolete value, while valid version-1 bundles carrying it remain import-compatible and ignore it; the current post-apply, standalone and preset-comparison workflows are unchanged.
- Formalized legacy split personal profiles without restoring split as a built-in workflow. Profiles now label the old architecture, recommend a non-destructive unified copy that retains inactive Raid/Battleground data, and keep exact split application behind an explicit advanced backup-first action; malformed legacy data fails closed.
- Made Save Graphics derive unified/split mode from the actual captured Blizzard `RAIDsettingsEnabled` value instead of persisted applied state. External Blizzard/addon CVar changes are reflected correctly, unavailable or unexpected values fail before persistence, and profile capture performs no CVar writes.
- Centralized diff/result statistics around one five-field summary contract. Graphics, profiles, Zone Graphics, UI Tweaks, imports, FPS candidate apply and Backup Restore now share compatible changed/identical/skipped/unavailable/failed semantics, and previews show the three non-applicable/error states separately.
- Added an optional human-readable **Show changes** view for Graphics, UI Tweaks, FPS recommendations, profiles and imports. It reuses the canonical diff, hides identical settings, separates unavailable/skipped/failed items, and shows localized labels, current/target values and short explanations without making raw CVar names primary text.
- Added validated registry product metadata for explainable previews: localized enum values, setting explanations, and qualitative performance/visual/readability/usability impact levels now share safe helpers and generic fallbacks. Preset values remain unchanged.

## 0.4.19-alpha

- Replaced every addon `StaticPopup` with one reusable S-Tier modal: dark native surface, gold frame, addon icon, larger standard WoW text, scalable primary/cancel buttons, destructive red actions and styled text fields.
- Added an optional autonomous **Maximum camera distance** UI Tweak using the verified Retail `cameraDistanceMaxZoomFactor` values `1.9` and `2.6`, with runtime availability checks, tooltip, backup, Undo and full-addon exchange support.
- Moved the current preset label farther right in the header and promoted it to the addon's standard large gold font.

## 0.4.18-alpha

- Added a centered, smoothly animated five-second progress bar after every successful Graphics preset apply.
- Reload UI is now offered automatically when that measurement finishes (or immediately when measurement is unavailable); the redundant permanent menu button was removed.
- Removed the duplicate lighter-raid checkbox. Built-in presets and FPS comparisons now use one active Blizzard graphics set, while Zone Graphics remains the single content-aware preset switcher.
- Confirmed and regression-tested that all UI Tweaks remain autonomous and are never changed by PRO, Optimized, Quality or Zone Graphics preset application.

## 0.4.17-alpha

- Added a concise post-comparison recommendation when a tested preset improves both Average FPS and 1% Low by at least 5%.
- Added a prominent one-click apply action for the recommended preset with explicit confirmation, a fresh graphics backup, verified transactional application and the normal five-second follow-up measurement.
- Suppressed recommendations for normal run-to-run variance, mixed results, incomplete restoration and presets already applied from the result.

## 0.4.16-alpha

- Replaced the remaining legacy checkbox frame with a scalable flat control that matches the shared Retail-style buttons.
- Added dark surfaces, thin bronze borders, gold checked states and smooth hover/press feedback to every checkbox without changing its behavior.

## 0.4.15-alpha

- Added a dedicated **UI Tweaks** navigation page with verified universal sharpening/glow recommendations and optional death/ghost-world effects.
- Added native Retail checkboxes, a `ResampleSharpness` stepper slider, concise hover tooltips, explicit confirmation, visible feedback and dedicated Undo.
- Added a separate `uiTweaks` registry/transaction module with automatic backups, runtime CVar availability checks, readback verification and normalized float comparison.
- Included available UI Tweaks values in strict data-only `STBSA1` full-addon import/export while preserving older bundles that omit the new field.
- Documented the evidence boundary and replaced a fixed zero-FPS promise with an honest expected cost of about 0 FPS that can vary by hardware.

## 0.4.14-alpha

- Moved Graphics Settings and Zone Graphics Switcher into a dedicated responsive tab bar at the top of the Graphics section.
- Placed the page title and status below the tabs with corrected spacing so text no longer collides with the selected tab border.
- Replaced the old per-tab visibility path with one tab-bar state to keep both tabs reliably visible and aligned.

## 0.4.13-alpha

- Replaced stretched red panel buttons with a shared scalable Blizzard Retail-style system across navigation, actions, graphics tabs, the FPS modal and Blizzard Settings integration.
- Added flat dark surfaces, thin bronze borders, a gold selected indicator, restrained primary emphasis and smooth hover/press feedback.
- Reserved red button fills for destructive actions and kept disabled states explicit.

## 0.4.12-alpha

- Replaced the wide Graphics FPS strip with four responsive native-style cards for live FPS, before apply, after apply and the signed change.
- Added clear positive, negative and neutral result colors plus a compact before/after legend.
- Hidden stale comparison values while a new measurement is running.

## 0.4.11-alpha

- Added an always-visible header label that detects the actual active PRO, Optimized or Quality graphics preset and falls back to Custom after manual differences.
- Shortened the FPS-test instruction and explicitly warns against minimizing WoW or using Alt+Tab during measurement.
- Replaced the hard progress fill with a softer Blizzard raid-bar texture and a subtle moving edge glow without changing its gold color.
- Added a compact legend below comparison cards that identifies the left values as the user's graphics and the right values as the tested preset.

## 0.4.10-alpha

- Added smooth interpolation and subtle native highlight/shadow layers to the FPS test progress bar while preserving its existing gold color.
- Replaced raw preset-comparison text with four visual cards for the tested preset, average FPS, 1% Low and stability; each metric now shows before/after values and a signed color-coded delta.

## 0.4.9-alpha

- Removed the height-dependent upward offset so the main addon window now opens at the exact center of the screen.

## 0.4.8-alpha

- Removed the single-line input artwork from the shared multiline import/export sheet so text now fills the page cleanly at every window size.

## 0.4.7-alpha

- Replaced the tiny full-settings import popup with the same large responsive multiline field used by export.
- Added an in-page **Review import** action and inline validation errors while preserving the existing data-only parser, preview, confirmation and backup-first apply flow.

## 0.4.6-alpha

- Removed the redundant **View result in game** action and its explanatory copy. The button only hid the addon window and printed a chat hint; applying, measuring, reloading, backups and Undo never depended on it.

## 0.4.5-alpha

- Removed screen-edge clamping from the main addon window so it can be dragged partially or fully beyond the display bounds. Reloading the UI still restores its default centered position.

## 0.4.4-alpha

- Added a centered, mouse-blocking FPS measurement dialog with live progress, fixed-scene guidance and a safe Cancel action.
- Added backup-first comparisons between the player's current graphics and PRO, Optimized or Quality using two real 20-second frame-time captures; original graphics are restored automatically.
- Expanded Test FPS results with a plain-language stability definition, scene-specific guidance, honest diagnostic limits and concise average/1% Low preset deltas.
- Renamed the optional control to **Show FPS & Ping overlay** and prevented Zone Graphics from changing settings during a benchmark or pending restoration.

## 0.4.3-alpha

- Nested the complete Zone Graphics Switcher under Graphics using native Blizzard panel tabs and removed its duplicate left-navigation entry.
- Added a dedicated top-level Test FPS page with one clear 20-second frame-time capture instead of exposing two measurement modes in Graphics.
- Added a responsive four-card FPS dashboard with live FPS, average, correctly derived 1% Low and stability, plus adaptive frame-spike count and worst-frame time stored per character.
- Kept the automatic five-second before/after comparison in the apply flow and moved the optional FPS/ping indicator control to Test FPS.

## 0.4.2-alpha

- Fixed boolean controls by keeping Blizzard's native checkbox art at its intended square size while making the full labelled row clickable.
- Shortened the FPS/ping tooltip and removed the latency unit from the compact indicator.
- Anchored both live values to independent halves of the widget and disabled word wrapping so latency stays inside the frame at different UI scales.

## 0.4.1-alpha

- Replaced the static in-addon screenshot with a compact live FPS card and an honest **View result in game** flow; WoW addons cannot embed a second world render with unapplied graphics settings.
- Enlarged the default window, added safe bottom-right resizing with persisted dimensions, made the layout adapt to width/height, restricted movement to the header and removed the unused lower action area from About.
- Reduced the FPS/ping widget by 15%, added Ctrl-drag positioning with a saved normalized position, and simplified its tooltip.
- Split Profiles into Profiles, Backups and Import / Export views. Selected backup Restore/Delete actions are always placed first.
- Added a validated `STBSA1` full-settings exchange string for current graphics, addon preferences, zone mappings and personal profiles; imports are data-only, backup-first and rejected in combat.
- Set PRO Environment Detail to 1 and Spell Density to Essential (`0`); Ground Clutter is now 1 in every base and raid preset.
- Standardized visible controls on the same native WoW `GameFont` family and replaced boolean action buttons with native checkboxes. Responsive columns collapse at narrow widths and use integer sizing to keep Blizzard textures crisp.

## 0.4.0-alpha

- Added PRO, Optimized and Quality presets across the reviewed Graphics, Graphics Quality and Advanced controls while preserving resolution, render scale, display, FPS caps and other hardware-dependent choices.
- Added opt-in Zone Graphics mappings for world/cities, dungeons, raids, PvP/arenas and scenarios/delves; switching happens only on content-type changes and every real apply is transactional and backed up.
- Shortened the quick FPS comparison to five seconds and added an accurate 20-second frame-time comparison with correctly derived 1% Low.
- Added an optional compact bottom-screen FPS/ping indicator using real `GetFramerate()` and Home/World `GetNetStats()` values with independent red-to-green color feedback.
- Increased native WoW font hierarchy, added page/status fades and reorganized the first visible actions into a simple three-row flow.
- Expanded localization, source research, architecture, benchmark documentation and regression coverage.

## 0.3.1-alpha

- Replaced the illustrative preview with a real in-game screenshot and redesigned the gold `S` emblem from the supplied visual reference.
- Added a live current-FPS display, retained the local before/after estimate, and removed the unsupported arrow glyph from FPS text.
- Added a concise first-use guide, larger WoW-native typography, a non-technical apply summary, and a documented About page.
- Added consistent success/warning/error feedback for apply, selection, save, rename, backup, restore, delete, export, import, and undo actions.
- Fixed Save Graphics, Rename and Import on current Retail by using the modern StaticPopup edit-box API; whitespace-only profile names are rejected.
- Added a post-apply Reload UI action that unlocks after FPS measurement, with confirmation.
- Audited every Graphics, Graphics Quality and Advanced control in Retail 12.0.7; added Multisample Alpha-Test handling and documented optimized versus deliberately preserved controls.
- Expanded regression tests for live FPS callbacks, safe FPS formatting, profile naming and About navigation.

## 0.3.0-alpha

- Rebuilt the dashboard around two focused tabs: Graphics and Profiles.
- Added an eight-second local before/after FPS estimate using Blizzard's documented `GetFramerate()` API.
- Added an explicit apply confirmation, a one-click graphics undo action and automatic safety backups.
- Combined personal profiles and backup history; profiles can now be applied and backups can be restored or deleted with confirmation.
- Added a new draggable minimap emblem, an illustrative graphics preview and subtle window/button animations.
- Temporarily hid Interface & Gameplay from the user workflow while preserving its stored data and internal compatibility.
- Expanded regression coverage for FPS metrics, combined navigation and backup deletion.

## 0.2.0-alpha

- Expanded the built-in Interface & Gameplay profile with verified Retail combat-readability settings while preserving personal, accessibility, audio and hardware options.
- Added Blizzard-equivalent graphics capability validation and fail-closed skipping for unsupported values.
- Hardened `STBS1` parsing and profile validation against duplicate keys, malformed sections, control-character metadata and parser exceptions.
- Improved the dashboard with localized Blizzard setting labels, grouped previews, scrollable action lists, safe profile names and deletion confirmation.
- Made personal profile IDs collision-safe, filtered stale backup keys during restore, preserved user values below official-profile safety minima and tightened module validation before combat queuing.
- Documented the product scope, source evidence, UI/UX decisions and expanded live-client test plan.

## 0.1.2-alpha

- Added a guided first-use flow: choose a graphics mode, review the planned changes, then confirm.
- Published a versioned ZIP and updated installation links.

## 0.1.0-alpha

- Initial Retail release: curated graphics and interface profiles, backups, profiles, safe import/export, localization, diagnostics, tests, packaging and CI.
- Refined native UI: scrollable pages, localized Russian copy, visual previews, profile naming/rename/selection, backup selection, and explicit import confirmation.
