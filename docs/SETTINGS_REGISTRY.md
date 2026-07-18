# Curated settings registry

Research baseline: Blizzard `wow-ui-source` branch `live`, version `12.0.7.68453`, commit `6e96727fd523c80f2cd43dc1c43946b0336f1217`, checked 2026-07-16. All writes are gated by `C_CVar.GetCVarInfo` and `C_CVar.SetCVar`; a post-write readback is required. Graphics choices also use `IsGraphicsSettingValueSupported` or `IsGraphicsCVarValueSupported`, matching Blizzard's own settings definitions.

| Group | CVars | Current registry/profile policy |
|---|---|---|
| Base graphics | shadow, liquid, particles, SSAO, depth, compute, outlines, texture, view/environment/clutter | preset-specific; current Optimized active values are `2,2,4,1,1,1,2,2,6,4,1` |
| Raid graphics | same `raidGraphics*` set | legacy split compatibility; retained Optimized values are `0,1,4,0,0,0,2,2,4,3,1` |
| Safety | projected textures, spell density | projected textures `1` in every preset; active spell density is PRO/Optimized/Quality `0/2/2`, retained raid compatibility `0/1/2`, when supported |
| Other graphics | texture filtering, ray-traced shadows, image AA | `5`, `0`; AA chosen only after client capability validation |
| Camera | `cameraSmoothStyle` | `0` (Never Adjust Camera) |
| Action bars | `countdownForCooldowns` | `1` (show cooldown numbers) |
| Combat | `showTargetOfTarget`, `occludedSilhouettePlayer` | `1`, `1` |
| Nameplates | `nameplateShowEnemies`, `nameplateShowAll`, `nameplateShowOffscreen` | `1`, `1`, `1` |
| UI Tweaks — universal | `ResampleAlwaysSharpen`, `ResampleSharpness`, `ffxGlow` | `1`, `0.3`, `1` |
| UI Tweaks — optional | `ffxDeath`, `ffxNether` | user choice (`0` or `1`) |
| UI Tweaks — camera | `cameraDistanceMaxZoomFactor` | standard `1.9` or Retail maximum `2.6` |

`RAIDsettingsEnabled` is set to `0` by every current built-in Graphics, Zone Graphics, and preset-comparison workflow. Value `1` and the retained `raidGraphics*` values are used only when applying legacy split personal/imported profiles. `graphicsQuality` and `raidGraphicsQuality` are deliberately not written. Hardware-dependent CVars are not present in the registry. The exact current per-preset matrix is documented in `RECOMMENDED_PROFILE_RESEARCH.md` and implemented in `Profiles/Recommended.lua`.

Every registry entry also carries product metadata consumed by the optional detailed-diff view: a Blizzard-localized or addon-localized user-facing label, a localized explanation, one qualitative primary-impact domain (`performance`, `visual`, `readability`, or `usability`) and level (`low`, `medium`, or `high`), plus optional localized enum display values. Validation checks the metadata structure, localization references, and display-value domain. Missing or invalid optional metadata falls back safely and never exposes the raw CVar as primary text. These labels are qualitative setting descriptions, not measured FPS estimates and not a recommendation engine.

`risk`, `requiresReload`, and preset-specific reason metadata are not currently stored. There is no verified per-setting reload/risk consumer, and preset reasoning remains in the documented profile research rather than being duplicated into an unverified registry matrix. Real preset values and their safety constraints are unchanged.

`ResampleSharpness` mirrors Blizzard's own 0.0–2.0 slider with 0.1 steps; the UI Tweaks recommendation is 0.3. `cameraDistanceMaxZoomFactor` is deliberately presented as a checkbox rather than a free slider: checked selects Retail's supported maximum `2.6`, while unchecked restores the standard `1.9`. The registry still accepts and preserves an existing valid value in the documented `1.0–2.6` Retail range until the user toggles that checkbox. The current command remains confirmed on Blizzard's [UI and Macro forum](https://us.forums.blizzard.com/en/wow/t/how-to-set-max-camera-distance/1901520), including a 2026 Retail report; runtime metadata and readback remain authoritative. Hidden effect, sharpening and camera CVars are never assumed to exist: the live Retail client must return writable metadata through `C_CVar.GetCVarInfo`, the pre-change value must be captured, and the post-write readback must match. A missing, protected or read-only CVar disables its control. UI Tweaks are independent of PRO/Optimized/Quality and are included in full-addon exchange only when readable.

Primary evidence:

- [Blizzard graphics definitions](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Shared/Graphics.lua)
- [Retail graphics CVar registration](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_Settings_Shared/Mainline/GraphicsOverrides.lua)
- [Camera controls](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Frame/Controls.lua)
- [Combat controls](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Frame/Combat.lua), [action bars](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Frame/ActionBars.lua), [nameplates](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Frame/Nameplates.lua)
