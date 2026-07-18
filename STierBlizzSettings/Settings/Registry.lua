local _, STBS = ...
local function range(first, last) local values = {}; for i = first, last do values[tostring(i)] = true end; return values end
local function c(key, module, category, values, extra)
  local entry = {}; for k, v in pairs(extra or {}) do entry[k] = v end
  entry.key = key; entry.module = module; entry.category = category; entry.valueType = "numberString"; entry.readable = true; entry.writable = true; entry.portable = true; entry.validValues = values; entry.verifiedClientBuild = "12.0.7.68453"; return entry
end
local entries = {
  c("RAIDsettingsEnabled", "graphics", "graphics", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="RAID_SETTINGS_ENABLED" }),
  c("textureFilteringMode","graphics","graphics",range(0,5),{officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="ANISOTROPIC"}),
  c("shadowrt","graphics","graphics",range(0,3),{officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="RT_SHADOW_QUALITY"}),
  c("ffxAntiAliasingMode","graphics","graphics",range(0,4),{officialProfileAllowed=true,capability="aa",blizzardLabel="FXAA_CMAA_LABEL"}),
  c("MSAAQuality","graphics","graphics",{["0"]=true},{officialProfileAllowed=true,capability="aa",blizzardLabel="MSAA_LABEL"}),
  c("msaaAlphaTest","graphics","graphics",{["0"]=true,["1"]=true},{valueType="booleanString",officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="MULTISAMPLE_ALPHA_TEST"}),
  c("cameraSmoothStyle", "interfaceGameplay", "camera", { ["0"]=true,["1"]=true,["2"]=true,["4"]=true }, { officialProfileAllowed=true, blizzardLabel="CAMERA_FOLLOWING_STYLE" }),
  c("countdownForCooldowns", "interfaceGameplay", "interface", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="COUNTDOWN_FOR_COOLDOWNS_TEXT" }),
  c("showTargetOfTarget", "interfaceGameplay", "combat", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="SHOW_TARGET_OF_TARGET_TEXT" }),
  c("occludedSilhouettePlayer", "interfaceGameplay", "combat", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="SHOW_SILHOUETTE_OPTION" }),
  c("nameplateShowEnemies", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_SHOW_ENEMIES" }),
  c("nameplateShowAll", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_AUTOMODE" }),
  c("nameplateShowOffscreen", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_SHOW_OFFSCREEN" }),
  c("ResampleAlwaysSharpen", "uiTweaks", "recommendedTweaks", { ["0"]=true,["1"]=true }, { valueType="booleanString" }),
  c("ResampleSharpness", "uiTweaks", "recommendedTweaks", nil, { numericMinimum=0, numericMaximum=2, numericStep=0.1, numericTolerance=0.001 }),
  c("ffxGlow", "uiTweaks", "recommendedTweaks", { ["0"]=true,["1"]=true }, { valueType="booleanString" }),
  c("ffxDeath", "uiTweaks", "optionalTweaks", { ["0"]=true,["1"]=true }, { valueType="booleanString" }),
  c("ffxNether", "uiTweaks", "optionalTweaks", { ["0"]=true,["1"]=true }, { valueType="booleanString" }),
}
local function graphicPair(base, raid, values, extra)
  extra = extra or {}; extra.graphicsValidation = "advanced"
  table.insert(entries, c(base,"graphics","graphics",values,extra)); table.insert(entries, c(raid,"graphics","raidGraphics",values,extra))
end
graphicPair("graphicsShadowQuality","raidGraphicsShadowQuality",range(0,5),{officialProfileAllowed=true,blizzardLabel="SHADOW_QUALITY"})
graphicPair("graphicsLiquidDetail","raidGraphicsLiquidDetail",range(0,3),{officialProfileAllowed=true,blizzardLabel="LIQUID_DETAIL"})
graphicPair("graphicsParticleDensity","raidGraphicsParticleDensity",range(0,5),{officialProfileAllowed=true,minimum=1,blizzardLabel="PARTICLE_DENSITY"})
graphicPair("graphicsSSAO","raidGraphicsSSAO",range(0,4),{officialProfileAllowed=true,blizzardLabel="SSAO_LABEL"})
graphicPair("graphicsDepthEffects","raidGraphicsDepthEffects",range(0,3),{officialProfileAllowed=true,blizzardLabel="DEPTH_EFFECTS"})
graphicPair("graphicsComputeEffects","raidGraphicsComputeEffects",range(0,4),{officialProfileAllowed=true,blizzardLabel="COMPUTE_EFFECTS"})
graphicPair("graphicsOutlineMode","raidGraphicsOutlineMode",range(0,2),{officialProfileAllowed=true,minimum=1,blizzardLabel="OUTLINE_MODE"})
graphicPair("graphicsTextureResolution","raidGraphicsTextureResolution",range(0,2),{officialProfileAllowed=true,blizzardLabel="TEXTURE_DETAIL"})
graphicPair("graphicsSpellDensity","raidGraphicsSpellDensity",range(0,2),{officialProfileAllowed=true,feature="spellDensity",blizzardLabel="SPELL_DENSITY"})
graphicPair("graphicsProjectedTextures","raidGraphicsProjectedTextures",range(0,1),{officialProfileAllowed=true,minimum=1,blizzardLabel="PROJECTED_TEXTURES"})
graphicPair("graphicsViewDistance","raidGraphicsViewDistance",range(0,10),{officialProfileAllowed=true,blizzardLabel="FARCLIP"})
graphicPair("graphicsEnvironmentDetail","raidGraphicsEnvironmentDetail",range(0,10),{officialProfileAllowed=true,blizzardLabel="ENVIRONMENT_DETAIL"})
graphicPair("graphicsGroundClutter","raidGraphicsGroundClutter",range(0,10),{officialProfileAllowed=true,blizzardLabel="GROUND_CLUTTER"})
STBS.Registry = entries
STBS.RegistryByKey = {}; for _, setting in ipairs(STBS.Registry) do STBS.RegistryByKey[setting.key] = setting end
function STBS:GetRegistry(module) local out = {}; for _, s in ipairs(self.Registry) do if not module or s.module == module then table.insert(out,s) end end return out end
function STBS:GetSettingLabel(setting) return (setting.blizzardLabel and _G[setting.blizzardLabel]) or setting.key end
