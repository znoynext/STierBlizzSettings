# Recommended profile research

Baseline reviewed 2026-07-16 against Blizzard UI source `live` (12.0.7 build 68453, commit `6e96727fd523c80f2cd43dc1c43946b0336f1217`). The authoritative local files used for the audit are `Blizzard_SettingsDefinitions_Shared/Graphics.lua` and `Blizzard_Settings_Shared/Mainline/GraphicsOverrides.lua`. The current UI registers `RAIDsettingsEnabled`, base and raid advanced graphics CVars, and gates spell density with `C_VideoOptions.IsSpellVisualDensitySystemSupported()`. Its image-AA choices expose FXAA Low `1`, FXAA High `2`, CMAA `3`, and CMAA2 `4` only when capability support is reported. Values are checked at runtime with Blizzard's graphics-support validators.

## What “best” means

There is no hardware-independent setting set that can guarantee the maximum FPS with zero visual difference. A CPU-limited raid, a GPU-limited 4K scene and an integrated-GPU laptop have different bottlenecks. The three official profiles are therefore evidence-traceable baselines: PRO reduces expensive effects most aggressively, Optimized is the default quality/performance balance, and Quality raises useful image detail without blindly selecting every maximum. All three retain combat information and high texture clarity while preserving every hardware-, display- or preference-dependent control. The in-addon FPS comparison measures the actual local result instead of presenting a promised percentage.

The Blizzard source proves which controls exist, their CVar names, ranges, support gates and interaction rules. It does not prove a universal FPS gain. Controlled hardware benchmarks are the only valid way to quantify that claim; the required method is documented in [OPTIMAL_PROFILE_BENCHMARK.md](OPTIMAL_PROFILE_BENCHMARK.md).

| CVar group | UI label | PRO / Optimized / Quality | impact / confidence |
|---|---|---:|---|
| `graphics*ShadowQuality` | Shadow Quality | 1 / 2 / 3 | visual and GPU load; verified identifier/value range in UI |
| `*LiquidDetail` | Liquid Detail | 1 / 2 / 3 | visible GPU effect scaled across presets |
| `*ParticleDensity` | Particle Density | 3 / 4 / 5 | never disabled; preserves readable combat effects |
| `*SSAO`, `*DepthEffects`, `*ComputeEffects` | Advanced Graphics | 0 / 1 / 2 | costly effects scaled together; client validation still applied |
| `*OutlineMode`, `*ProjectedTextures` | Outline Mode / Projected Textures | 2 / 1 in every preset | combat visibility; enforced safety rule |
| `*SpellDensity` | Spell Density | 1 / 2 / 2 | combat visibility; only when feature API says supported |
| `*ViewDistance` | View Distance | 4 / 6 / 8 | CPU/GPU and world readability balance |
| `*EnvironmentDetail`, `*GroundClutter` | detail sliders | 3/2, 4/3, 7/6 | visual/CPU-GPU; slider labels may differ from stored values |
| `ffxAntiAliasingMode`, `MSAAQuality`, `msaaAlphaTest` | Antialiasing | best supported CMAA, MSAA off, alpha-test off | capability-gated image AA; avoids MSAA cost and disables its dependent option |
| `cameraSmoothStyle` | Camera Follow Style | 0 | reversibly disables automatic camera adjustment |

## Complete Retail graphics coverage

“Covered” does not mean “force a value”. It means the control was reviewed and has an explicit policy. Forcing a display or hardware choice would be unsafe and would invalidate the FPS comparison.

| Blizzard section | controls | profile policy | reason |
|---|---|---|---|
| Graphics | Monitor, Display Mode, Window Size | preserve | physical display and window preference; applying may rebuild the window |
| Graphics | Resolution / Render Scale | preserve | dominant image-quality control and hardware-specific; never silently reduce it |
| Graphics | UI Scale | preserve | accessibility and layout preference, not a graphics optimization |
| Graphics | Vertical Sync | preserve | depends on refresh rate, tearing tolerance and latency preference |
| Graphics | Notch Mode | preserve | display-specific |
| Graphics | Low Latency Mode | preserve | vendor- and hardware-specific; Blizzard exposes NVIDIA Reflex and Intel XeLL only when supported |
| Graphics | Antialiasing, Image Based, Multisample, Multisample Alpha-Test | optimize | choose the best supported CMAA path; disable MSAA and its dependent alpha-test |
| Graphics | Camera FOV | preserve | gameplay/comfort preference |
| Graphics Quality | Shadow, Liquid, Particle Density, SSAO, Depth Effects, Compute Effects, Outline Mode, Texture Resolution, Spell Density, Projected Textures, View Distance, Environment Detail, Ground Clutter | optimize all individually | these are the independent quality controls exposed by `GraphicsOverrides.CreateAdvancedSettingsTable` |
| Graphics Quality | master Graphics Quality number | do not write | Blizzard applies this proxy last and it overwrites the individual controls; after individual tuning the UI correctly reports Custom |
| Graphics Quality | Raid and Battleground toggle and all raid quality controls | optimize in split mode | uses Blizzard's own separate raid profile and the same validated child controls |
| Advanced | Triple Buffering | preserve | coupled to V-Sync and frame-latency preference; requires graphics restart |
| Advanced | Texture Filtering | 16x | high texture clarity with low cost on supported modern hardware; value validated by Blizzard UI |
| Advanced | Ray Traced Shadows | off | removes a high-cost optional shadow path while regular shadows remain enabled |
| Advanced | Resample Quality and Sharpness | preserve | only meaningful with Render Scale; changing them while preserving scale can alter appearance unexpectedly |
| Advanced | Variable Rate Shading | preserve | hardware-specific and can trade local image quality for performance |
| Advanced | Graphics API, Physics Interaction, Graphics Card | preserve | hardware/driver choice; API/card changes can require restart; physics is visible content |
| Advanced | Foreground, Background and Target FPS controls | preserve | user caps are part of power, temperature and pacing policy, not raw quality |
| Advanced | Contrast, Brightness and Gamma | preserve | calibration/accessibility controls |

Each preset also contains a separate lower-cost raid/battleground set when split mode is selected. Zone Graphics reuses these exact reviewed presets; it never constructs hidden values. It is opt-in, detects Delves with the current `C_PartyInfo.IsDelveInProgress()` API, maps the documented `IsInInstance()` content types (`party`, `raid`, `pvp`, `arena`, `scenario`) and applies only when a real CVar diff exists. Unknown types fail back to the world mapping.

The audit covers every control registered in Retail `Graphics.lua`. Resolution is a Blizzard proxy backed by `C_VideoOptions`, not a normal CVar, so the addon deliberately does not pretend that it can safely port or restore it through the CVar registry.

The Interface & Gameplay baseline also enables standard Blizzard controls that expose information rather than automate play: cooldown numbers, target-of-target, the occluded player silhouette, enemy nameplates, always-visible nameplates and off-screen nameplate indicators. These choices improve combat readability but remain preferences, so every change is previewed and backed up. Audio, accessibility, Edit Mode, bindings, mouse behavior and UI scale are deliberately excluded.

The profile remains a conservative expert baseline, not a universal benchmark result. The exact expected FPS improvement depends on hardware, resolution, zone and encounter. The status is `expert_baseline_unbenchmarked`; no fixed FPS percentage may be advertised until the benchmark matrix has real results.
