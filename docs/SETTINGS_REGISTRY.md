# Curated settings registry

Research baseline: Blizzard `wow-ui-source` branch `live`, version `12.0.7.68453`, checked 2026-07-14. All writes are gated by `C_CVar.GetCVarInfo` and `C_CVar.SetCVar`; a post-write readback is required.

| Group | CVars | Official values |
|---|---|---|
| Base graphics | shadow, liquid, particles, SSAO, depth, compute, outlines, texture, view/environment/clutter | `2,2,4,1,1,1,2,2,6,4,3` |
| Raid graphics | same `raidGraphics*` set | `0,1,4,0,0,0,2,2,4,3,2` |
| Safety | projected textures, spell density | projected textures `1`; spell density full base `2`, reduced raid `1` when supported |
| Other graphics | texture filtering, ray-traced shadows, image AA | `5`, `0`; AA chosen only after client capability validation |
| Interface | camera smooth style | `0` (Never Adjust Camera) |

`RAIDsettingsEnabled` is set to `0` for unified mode and `1` for split mode. `graphicsQuality` and `raidGraphicsQuality` are deliberately not written. Hardware-dependent CVars are not present in the registry.
