# Curated settings registry

Research baseline: Blizzard `wow-ui-source` branch `live`, version `12.0.7.68453`, commit `6e96727fd523c80f2cd43dc1c43946b0336f1217`, checked 2026-07-16. All writes are gated by `C_CVar.GetCVarInfo` and `C_CVar.SetCVar`; a post-write readback is required. Graphics choices also use `IsGraphicsSettingValueSupported` or `IsGraphicsCVarValueSupported`, matching Blizzard's own settings definitions.

| Group | CVars | Official values |
|---|---|---|
| Base graphics | shadow, liquid, particles, SSAO, depth, compute, outlines, texture, view/environment/clutter | `2,2,4,1,1,1,2,2,6,4,3` |
| Raid graphics | same `raidGraphics*` set | `0,1,4,0,0,0,2,2,4,3,2` |
| Safety | projected textures, spell density | projected textures `1`; spell density full base `2`, reduced raid `1` when supported |
| Other graphics | texture filtering, ray-traced shadows, image AA | `5`, `0`; AA chosen only after client capability validation |
| Camera | `cameraSmoothStyle` | `0` (Never Adjust Camera) |
| Action bars | `countdownForCooldowns` | `1` (show cooldown numbers) |
| Combat | `showTargetOfTarget`, `occludedSilhouettePlayer` | `1`, `1` |
| Nameplates | `nameplateShowEnemies`, `nameplateShowAll`, `nameplateShowOffscreen` | `1`, `1`, `1` |

`RAIDsettingsEnabled` is set to `0` for unified mode and `1` for split mode. `graphicsQuality` and `raidGraphicsQuality` are deliberately not written. Hardware-dependent CVars are not present in the registry.

Primary evidence:

- [Blizzard graphics definitions](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Shared/Graphics.lua)
- [Retail graphics CVar registration](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_Settings_Shared/Mainline/GraphicsOverrides.lua)
- [Camera controls](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Frame/Controls.lua)
- [Combat controls](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Frame/Combat.lua), [action bars](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Frame/ActionBars.lua), [nameplates](https://github.com/Gethe/wow-ui-source/blob/6e96727fd523c80f2cd43dc1c43946b0336f1217/Interface/AddOns/Blizzard_SettingsDefinitions_Frame/Nameplates.lua)
