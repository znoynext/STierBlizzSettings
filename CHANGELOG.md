# Changelog

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
