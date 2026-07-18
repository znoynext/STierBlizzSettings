# Project state

Last updated: 2026-07-18. Current release: **0.4.13-alpha**. Target: WoW Retail 12.0.7, Interface 120007, Blizzard UI build 68453.

This is the short handoff for continuing work in a new Codex task. Read it before changing behavior or UI. Use `CHANGELOG.md` for version history and the linked specialist documents for implementation details.

## Product direction

S-Tier Blizz Settings applies curated standard Blizzard settings. The goal is high practical FPS without sacrificing combat readability or useful image quality. It is not a UI replacement and must continue to look like a polished native World of Warcraft addon.

Only four top-level pages are currently exposed: **Graphics**, **Test FPS**, **Profiles**, and **About**. Graphics contains **Graphics Settings** and **Zone Graphics Switcher** sub-tabs. Interface & Gameplay remains internally compatible but is intentionally hidden until its redesign.

## Implemented workflow

- Graphics offers PRO, Optimized and Quality presets plus unified graphics or Blizzard's separate lighter raid profile. Every apply shows a concise preview, asks for confirmation, creates a backup first, writes transactionally, verifies results and exposes Undo and Reload UI.
- The Graphics dashboard shows live FPS and measured before/after/change cards. The five-second result is local to the same scene and is never presented as a guaranteed gain or prediction.
- Test FPS captures every frame for 20 seconds and reports average FPS, 1% Low, stability, adaptive spikes and worst frame time. It can compare current graphics with each official preset using two 20-second measurements, then restore the original settings.
- Zone Graphics is optional and disabled by default. It maps world/city, dungeon, raid, PvP/arena and scenario/delve content to presets and delegates every real change to the same backup-first transaction.
- Profiles combines named graphics profiles, backup history and full-addon `STBSA1` import/export. Imports are untrusted data, parsed without execution and reviewed before application.
- The optional bottom overlay displays real live FPS and the greater Home/World latency. Ctrl + drag moves it.

## Current UX decisions

- Use standard WoW fonts, dark native panels, restrained gold accents and readable text sizes. Avoid unrelated modern web styling.
- The shared button system is in `UI/Style.lua`: flat dark Retail surfaces, thin scalable borders, a gold selected indicator, smooth hover/press feedback and red fills only for destructive actions.
- The main window is resizable, opens centered and is not clamped to screen edges. Layout must remain responsive at supported sizes.
- Every user action must produce visible success, warning or error feedback.
- The header detects the actual active PRO, Optimized or Quality preset; otherwise it shows Custom.
- Do not fake a live game preview. Addons cannot render the world with unapplied graphics settings or diagnose GPU/CPU load and temperatures.

## Safety boundaries

- Use only verified current Retail APIs and CVars. Unsupported settings fail closed.
- Preserve resolution, render scale, V-Sync, display/API choice, FPS caps and other hardware- or preference-dependent settings.
- Official presets preserve projected textures, particles, combat outlines and high-quality texture resolution. PRO uses minimum environment detail and ground clutter, with Essential spell density.
- No telemetry, networking, ads, premium gating, donation prompts, combat automation or obfuscation.

## Validation and release workflow

1. Run `lua Tests/run.lua` and `git diff --check`.
2. Review the complete diff and ensure no secrets or temporary files are included.
3. Build with `./build-release.ps1 -Version <version>` and inspect the ZIP contents.
4. Update README download links, version constants, TOC, changelog and relevant docs for each release.
5. Commit and push validated repository changes to the current branch.

Automated Lua tests do not replace visual testing in the live Retail client. In this local collaboration, copy released addon sources to `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\STierBlizzSettings`, verify hashes, and let the user run `/reload`. Do not attempt to control or enter the user's WoW client.

## Known unfinished work

- Interface & Gameplay is postponed and hidden.
- Production v1.0 still requires live-client visual QA at multiple resolutions and controlled hardware benchmarks.
- Preset values are researched and validated, but no fixed FPS gain can be promised across hardware, zones or combat load.

## Detailed references

- Architecture: `docs/ARCHITECTURE.md`
- Preset evidence and coverage: `docs/RECOMMENDED_PROFILE_RESEARCH.md`
- UI/UX research: `docs/UI_UX_RESEARCH.md`
- Registry: `docs/SETTINGS_REGISTRY.md`
- Import format: `docs/IMPORT_FORMAT.md`
- Test plan: `docs/TEST_PLAN.md`
- Release process: `docs/RELEASE.md`
