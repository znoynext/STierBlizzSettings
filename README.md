# S-Tier Blizz Settings

A lightweight WoW Retail addon that applies a curated balance of FPS, image quality and combat readability using only standard Blizzard graphics settings.

![Balanced graphics preview](docs/images/graphics-preview.png)

> Illustrative preview. Actual FPS and appearance depend on your hardware, location and gameplay situation.

## Install

1. Download [STierBlizzSettings-v0.3.0-alpha.zip](https://github.com/znoynext/STierBlizzSettings/raw/refs/heads/main/dist/STierBlizzSettings-v0.3.0-alpha.zip).
2. Extract it into `World of Warcraft/_retail_/Interface/AddOns/`.
3. Verify the final path is `.../AddOns/STierBlizzSettings/STierBlizzSettings.toc`.
4. Enable the addon and open it with `/stier` or the minimap button.

## What works

- Two focused tabs: **Graphics** and **Profiles**.
- Balanced graphics everywhere or a lighter Blizzard raid/battleground profile.
- Reviewed change preview and an explicit confirmation before applying.
- Transactional writes with automatic backup and read-back verification.
- One-click **Undo graphics changes**.
- Local before/after FPS estimate, shown as `Average FPS: 74 → 91, +17 FPS (+23%)`.
- Personal graphics profiles plus backup history in one screen.
- Apply, rename, export and delete profiles; restore or delete backups.
- Strict data-only `STBS1:` import. Imported text is never executed.
- A draggable minimap button and a compact animated Blizzard-style dashboard.

The addon preserves monitor, resolution, refresh rate, V-Sync, FPS limits, latency mode and other hardware-dependent or personal settings. Projected textures, useful particle density and outlines remain enabled in the official profiles.

**Interface & Gameplay is temporarily hidden while it is being redesigned.** Its existing internal compatibility remains intact so old data is not destroyed.

## FPS measurement

The addon samples the Retail `GetFramerate()` API before and for eight seconds after applying graphics. This is a local estimate, not a guaranteed benchmark. Stay in the same place and avoid entering combat during the measurement for a more useful comparison.

## Safety and status

No telemetry, network access, ads, premium features, donation prompts or gameplay automation are included. Every supported setting is curated and validated against current Blizzard Retail UI sources; unavailable values fail closed.

Current version: **0.3.0-alpha**. Baseline: Retail 12.0.7, Interface 120007, Blizzard UI build 68453. Live-client visual testing is still required before declaring v1.0 production-ready.

See the [Russian README](README.ru.md), [preset research](docs/RECOMMENDED_PROFILE_RESEARCH.md), [architecture](docs/ARCHITECTURE.md), [UI/UX notes](docs/UI_UX_RESEARCH.md) and [test plan](docs/TEST_PLAN.md).
