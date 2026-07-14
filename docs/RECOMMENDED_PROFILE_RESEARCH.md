# Recommended profile research

Baseline reviewed 2026-07-14 against Blizzard UI source `live` (12.0.7 build 68453). The current UI registers `RAIDsettingsEnabled`, base and raid advanced graphics CVars, and gates spell density with `C_VideoOptions.IsSpellVisualDensitySystemSupported()`. Its image-AA choices expose FXAA Low `1`, FXAA High `2`, CMAA `3`, and CMAA2 `4` only when capability support is reported.

| CVar group | UI label | selected | impact / confidence |
|---|---|---:|---|
| `graphics*ShadowQuality`, `raidGraphics*ShadowQuality` | Shadow Quality | 2 / 0 | visual and GPU load; verified identifier/value range in UI |
| `*LiquidDetail`, `*ParticleDensity`, `*SSAO`, `*DepthEffects`, `*ComputeEffects` | Advanced Graphics | documented profile values | visual/GPU load; client validation still applied |
| `*OutlineMode`, `*ProjectedTextures` | Outline Mode / Projected Textures | 2 / 1 | combat visibility; enforced safety rule |
| `*SpellDensity` | Spell Density | 2 / 1 | combat visibility; only when feature API says supported |
| `*ViewDistance`, `*EnvironmentDetail`, `*GroundClutter` | sliders | 6/4/3 and 4/3/2 | visual/CPU-GPU; slider labels may differ from stored values |
| `cameraSmoothStyle` | Camera Follow Style | 0 | reversibly disables automatic camera adjustment |

This is an expert baseline, not a benchmark claim. Real hardware/client testing is required before changing the recommended values.
