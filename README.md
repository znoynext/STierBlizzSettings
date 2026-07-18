# S-Tier Blizz Settings

A lightweight WoW Retail addon that applies a curated balance of FPS, image quality and combat readability using only standard Blizzard graphics settings.

![Balanced graphics preview](docs/images/graphics-preview.png)

> Real in-game screenshot. Actual FPS and appearance depend on your hardware, location and gameplay situation.

## Install

1. Download [STierBlizzSettings-v0.4.10-alpha.zip](https://github.com/znoynext/STierBlizzSettings/raw/refs/heads/main/dist/STierBlizzSettings-v0.4.10-alpha.zip).
2. Extract it into `World of Warcraft/_retail_/Interface/AddOns/`.
3. Verify the final path is `.../AddOns/STierBlizzSettings/STierBlizzSettings.toc`.
4. Enable the addon and open it with `/stier` or the minimap button.

## What works

- Four focused top-level tabs: **Graphics**, **Test FPS**, **Profiles**, and **About**. Graphics contains native **Graphics Settings** and **Zone Graphics Switcher** sub-tabs.
- Three presets: **PRO** for maximum practical FPS, **Optimized** for the recommended balance, and **Quality** for a better picture without wasteful maximums.
- Optional zone profiles for world/cities, dungeons, raids, PvP/arenas and scenarios/delves. They switch only when the content type changes and are off by default.
- Unified graphics everywhere or Blizzard's separate lighter raid/battleground profile.
- Concise result preview without a technical CVar list and an explicit confirmation before applying.
- A larger, resizable native WoW window that remembers its size; dragging is limited to the header so controls cannot move the window accidentally.
- Separate Profiles, Backups and Import / Export views. Backup restore/delete actions stay visible, and one `STBSA1` string can transfer the current graphics, addon choices, zone rules and personal profiles through large export and import fields.
- Transactional writes with automatic backup and read-back verification.
- One-click **Undo graphics changes**.
- Large live current FPS, an automatic 5-second comparison after applying graphics, and a dedicated Test FPS dashboard with a cancellable 20-second test, explained stability, actionable hints and visual before/after cards for real current-vs-PRO/Optimized/Quality comparisons.
- Optional compact bottom-screen FPS and real Home/World ping indicator with red-to-green status colors.
- Personal graphics profiles plus backup history in one screen.
- Apply, rename, export and delete profiles; restore or delete backups.
- Strict data-only `STBS1:` import. Imported text is never executed.
- Clear colored feedback after saves, backups, deletes, restores, and applies.
- A gold `S` minimap icon, larger standard WoW fonts, and subtle animations.

The addon optimizes every independent **Graphics Quality** control, including the separate raid set, plus safe **Graphics** and **Advanced** controls. Monitor, resolution, Render Scale, V-Sync, graphics API/card, FPS caps, color calibration, and latency mode are deliberately preserved because they are hardware- or preference-dependent. See the complete [coverage matrix](docs/RECOMMENDED_PROFILE_RESEARCH.md).

**Interface & Gameplay is temporarily hidden while it is being redesigned.** Its existing internal compatibility remains intact so old data is not destroyed.

## FPS measurement

While Graphics is open, the addon displays Retail `GetFramerate()` live and automatically compares the rolling current scene with five seconds after apply. The separate **Test FPS** page records every frame for 20 seconds. It reports average FPS, 1% Low from the average slowest 1% of frame times, the 1% Low-to-average stability ratio, adaptive frame spikes and the worst frame time. Optional preset comparison measures the current graphics for 20 seconds, temporarily applies one selected preset through a backup-first transaction, measures another 20 seconds and restores the original graphics. Results are local estimates, so keep the same view and activity.

## Safety and status

No telemetry, network access, ads, premium features, donation prompts or gameplay automation are included. Every supported setting is curated and validated against current Blizzard Retail UI sources; unavailable values fail closed.

Current version: **0.4.10-alpha**. Baseline: Retail 12.0.7, Interface 120007, Blizzard UI build 68453. Live-client visual testing and controlled hardware benchmarks are still required before declaring v1.0 production-ready.

See the [Russian README](README.ru.md), [preset research](docs/RECOMMENDED_PROFILE_RESEARCH.md), [architecture](docs/ARCHITECTURE.md), [UI/UX notes](docs/UI_UX_RESEARCH.md) and [test plan](docs/TEST_PLAN.md).
