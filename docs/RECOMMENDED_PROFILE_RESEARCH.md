# Recommended profile research

Baseline reviewed 2026-07-16 against Blizzard UI source `live` (12.0.7 build 68453, commit `6e96727fd523c80f2cd43dc1c43946b0336f1217`). The current UI registers `RAIDsettingsEnabled`, base and raid advanced graphics CVars, and gates spell density with `C_VideoOptions.IsSpellVisualDensitySystemSupported()`. Its image-AA choices expose FXAA Low `1`, FXAA High `2`, CMAA `3`, and CMAA2 `4` only when capability support is reported. Advanced values are now checked at runtime with Blizzard's own graphics-support validators.

| CVar group | UI label | selected | impact / confidence |
|---|---|---:|---|
| `graphics*ShadowQuality`, `raidGraphics*ShadowQuality` | Shadow Quality | 2 / 0 | visual and GPU load; verified identifier/value range in UI |
| `*LiquidDetail`, `*ParticleDensity`, `*SSAO`, `*DepthEffects`, `*ComputeEffects` | Advanced Graphics | documented profile values | visual/GPU load; client validation still applied |
| `*OutlineMode`, `*ProjectedTextures` | Outline Mode / Projected Textures | 2 / 1 | combat visibility; enforced safety rule |
| `*SpellDensity` | Spell Density | 2 / 1 | combat visibility; only when feature API says supported |
| `*ViewDistance`, `*EnvironmentDetail`, `*GroundClutter` | sliders | 6/4/3 and 4/3/2 | visual/CPU-GPU; slider labels may differ from stored values |
| `cameraSmoothStyle` | Camera Follow Style | 0 | reversibly disables automatic camera adjustment |

The Interface & Gameplay baseline also enables standard Blizzard controls that expose information rather than automate play: cooldown numbers, target-of-target, the occluded player silhouette, enemy nameplates, always-visible nameplates and off-screen nameplate indicators. These choices improve combat readability but remain preferences, so every change is previewed and backed up. Audio, accessibility, Edit Mode, bindings, mouse behavior and UI scale are deliberately excluded.

The profile remains a conservative expert baseline, not a universal benchmark result. The exact expected FPS improvement depends on hardware, resolution, zone and encounter. Real hardware/client testing is required before changing recommended values; see [benchmark methodology](OPTIMAL_PROFILE_BENCHMARK.md) for the evidence required before making quantified claims.
