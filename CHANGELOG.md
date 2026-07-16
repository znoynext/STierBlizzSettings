# Changelog

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
