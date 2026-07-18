# S-Tier Blizz Settings

A lightweight WoW Retail addon that applies a curated balance of FPS, image quality and combat readability using only standard Blizzard graphics settings.

![Balanced graphics preview](docs/images/graphics-preview.png)

> Real in-game screenshot. Actual FPS and appearance depend on your hardware, location and gameplay situation.

## Install

1. Download [STierBlizzSettings-v0.4.20-alpha.zip](https://github.com/znoynext/STierBlizzSettings/raw/refs/heads/main/dist/STierBlizzSettings-v0.4.20-alpha.zip).
2. Extract it into `World of Warcraft/_retail_/Interface/AddOns/`.
3. Verify the final path is `.../AddOns/STierBlizzSettings/STierBlizzSettings.toc`.
4. Enable the addon and open it with `/stier` or the minimap button.

## What works

- Five focused top-level tabs: **Graphics**, **UI Tweaks**, **Test FPS**, **Profiles**, and **About**. Graphics contains native **Graphics Settings** and **Zone Graphics Switcher** sub-tabs.
- **UI Tweaks** exposes only curated live Retail CVars: universal resample sharpening/glow recommendations plus optional death/ghost-world effects and maximum camera distance. It is autonomous: graphics presets never change these values. Controls fail closed when unavailable, show short hover explanations and apply through a dedicated backup-first transaction with Undo.
- Three presets: **PRO** for maximum practical FPS, **Optimized** for the recommended balance, and **Quality** for a better picture without wasteful maximums.
- Optional zone profiles for world/cities, dungeons, raids, PvP/arenas and scenarios/delves. They are off by default; automatic checks run after entering the world or changing zones, and only a real settings diff is applied.
- One clear preset at a time; optional Zone Graphics is the single place for content-specific switching.
- Concise result preview without a technical CVar list and an explicit confirmation before applying.
- A larger, resizable native WoW window that remembers its size; dragging is limited to the header so controls cannot move the window accidentally.
- Separate Profiles, Backups and Import / Export views. Backup restore/delete actions stay visible, and one `STBSA1` string can transfer current graphics, available UI Tweaks, selected preset/mode, stored benchmark choice, performance-widget enabled state, zone rules and personal profiles through large export and import fields. Backup history and screen positions are not exported.
- Transactional writes with automatic backup and read-back verification.
- One-click **Undo graphics changes**.
- A four-card Graphics dashboard with live FPS and color-coded before, after and change results. Applying a preset opens a smooth 5-second progress dialog and then offers Reload UI automatically. Test FPS adds a cancellable 20-second test, explained stability, actionable hints and visual current-vs-preset comparisons. If both Average FPS and 1% Low improve by at least 5%, the tested preset can be applied directly with confirmation and a fresh backup.
- Optional compact bottom-screen FPS and real Home/World ping indicator with red-to-green status colors.
- Personal graphics profiles plus a separate backup-history view in the Profiles section.
- Apply, rename, export and delete profiles; restore or delete backups.
- Deterministic `STBS1:` profile export with a strict data-only importer. The importer exists in code but has no current Profiles launcher; the visible transfer page exposes full-addon `STBSA1` import. Imported text is never executed.
- Clear colored feedback after saves, backups, deletes, restores, and applies.
- A gold `S` minimap icon, larger standard WoW fonts, and scalable Blizzard Retail-style buttons, checkboxes and addon-owned modal dialogs with dark surfaces, restrained gold states, smooth feedback and red reserved for destructive actions.
- The header prominently shows the detected active graphics preset in the standard large addon font: **PRO**, **Optimized**, **Quality**, or **Custom** after manual changes.

The addon optimizes every independent control in the active **Graphics Quality** set, plus safe **Graphics** and **Advanced** controls. Monitor, resolution, Render Scale, V-Sync, graphics API/card, FPS caps, color calibration, and latency mode are deliberately preserved because they are hardware- or preference-dependent. See the complete [coverage matrix](docs/RECOMMENDED_PROFILE_RESEARCH.md).

**Interface & Gameplay is temporarily hidden while it is being redesigned.** Its existing internal compatibility remains intact so old data is not destroyed.

## FPS measurement

While Graphics is open, the addon displays Retail `GetFramerate()` live and automatically compares the rolling current scene with five seconds after apply. The separate **Test FPS** page records every frame for 20 seconds. It reports average FPS, 1% Low from the average slowest 1% of frame times, the 1% Low-to-average stability ratio, adaptive frame spikes and the worst frame time. Optional preset comparison measures the current graphics for 20 seconds, temporarily applies one selected preset through a backup-first transaction, measures another 20 seconds and restores the original graphics. Results are local estimates, so keep the same view and activity.

## Safety and status

No telemetry, network access, ads, premium features, donation prompts or gameplay automation are included. Every supported setting is curated and validated against current Blizzard Retail UI sources; unavailable values fail closed.

Current version: **0.4.20-alpha**. Baseline: Retail 12.0.7, Interface 120007, Blizzard UI build 68453. Live-client visual testing and controlled hardware benchmarks are still required before declaring v1.0 production-ready.

See the [current project state](docs/PROJECT_STATE.md), [Russian README](README.ru.md), [preset research](docs/RECOMMENDED_PROFILE_RESEARCH.md), [architecture](docs/ARCHITECTURE.md), [UI/UX notes](docs/UI_UX_RESEARCH.md) and [test plan](docs/TEST_PLAN.md).
