# Changelog

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
