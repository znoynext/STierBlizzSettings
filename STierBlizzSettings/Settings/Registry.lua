local _, STBS = ...
local function range(first, last) local values = {}; for i = first, last do values[tostring(i)] = true end; return values end
local function c(key, module, category, values, extra)
  local entry = { key=key,module=module,category=category,valueType="numberString",readable=true,writable=true,portable=true,validValues=values,verifiedClientBuild="12.0.7.68453" }
  for k, v in pairs(extra or {}) do entry[k] = v end;return entry
end
local entries = {
  c("RAIDsettingsEnabled", "graphics", "graphics", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="RAID_SETTINGS_ENABLED", diffExplanationKey="DIFF_EXPLAIN_RAID_MODE" }),
  c("textureFilteringMode","graphics","graphics",range(0,5),{officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="ANISOTROPIC",diffExplanationKey="DIFF_EXPLAIN_TEXTURE_FILTERING"}),
  c("shadowrt","graphics","graphics",range(0,3),{officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="RT_SHADOW_QUALITY",diffExplanationKey="DIFF_EXPLAIN_SHADOWS"}),
  c("ffxAntiAliasingMode","graphics","graphics",range(0,4),{officialProfileAllowed=true,capability="aa",blizzardLabel="FXAA_CMAA_LABEL",diffExplanationKey="DIFF_EXPLAIN_ANTIALIASING"}),
  c("MSAAQuality","graphics","graphics",{["0"]=true},{officialProfileAllowed=true,capability="aa",blizzardLabel="MSAA_LABEL",diffExplanationKey="DIFF_EXPLAIN_ANTIALIASING"}),
  c("msaaAlphaTest","graphics","graphics",{["0"]=true,["1"]=true},{valueType="booleanString",officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="MULTISAMPLE_ALPHA_TEST",diffExplanationKey="DIFF_EXPLAIN_ANTIALIASING"}),
  c("cameraSmoothStyle", "interfaceGameplay", "camera", { ["0"]=true,["1"]=true,["2"]=true,["4"]=true }, { officialProfileAllowed=true, blizzardLabel="CAMERA_FOLLOWING_STYLE", diffExplanationKey="DIFF_EXPLAIN_CAMERA" }),
  c("countdownForCooldowns", "interfaceGameplay", "interface", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="COUNTDOWN_FOR_COOLDOWNS_TEXT", diffExplanationKey="DIFF_EXPLAIN_INTERFACE" }),
  c("showTargetOfTarget", "interfaceGameplay", "combat", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="SHOW_TARGET_OF_TARGET_TEXT", diffExplanationKey="DIFF_EXPLAIN_COMBAT" }),
  c("occludedSilhouettePlayer", "interfaceGameplay", "combat", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="SHOW_SILHOUETTE_OPTION", diffExplanationKey="DIFF_EXPLAIN_COMBAT" }),
  c("nameplateShowEnemies", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_SHOW_ENEMIES", diffExplanationKey="DIFF_EXPLAIN_NAMEPLATES" }),
  c("nameplateShowAll", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_AUTOMODE", diffExplanationKey="DIFF_EXPLAIN_NAMEPLATES" }),
  c("nameplateShowOffscreen", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_SHOW_OFFSCREEN", diffExplanationKey="DIFF_EXPLAIN_NAMEPLATES" }),
  c("ResampleAlwaysSharpen", "uiTweaks", "recommendedTweaks", { ["0"]=true,["1"]=true }, { valueType="booleanString",labelKey="UI_TWEAK_ALWAYS_SHARPEN",diffExplanationKey="UI_TWEAK_ALWAYS_SHARPEN_TIP" }),
  c("ResampleSharpness", "uiTweaks", "recommendedTweaks", nil, { numericMinimum=0, numericMaximum=2, numericStep=0.1, numericTolerance=0.001,labelKey="UI_TWEAK_SHARPNESS",diffExplanationKey="UI_TWEAK_SHARPNESS_TIP" }),
  c("ffxGlow", "uiTweaks", "recommendedTweaks", { ["0"]=true,["1"]=true }, { valueType="booleanString",labelKey="UI_TWEAK_GLOW",diffExplanationKey="UI_TWEAK_GLOW_TIP" }),
  c("ffxDeath", "uiTweaks", "optionalTweaks", { ["0"]=true,["1"]=true }, { valueType="booleanString",labelKey="UI_TWEAK_DEATH",diffExplanationKey="UI_TWEAK_DEATH_TIP" }),
  c("ffxNether", "uiTweaks", "optionalTweaks", { ["0"]=true,["1"]=true }, { valueType="booleanString",labelKey="UI_TWEAK_NETHER",diffExplanationKey="UI_TWEAK_NETHER_TIP" }),
  c("cameraDistanceMaxZoomFactor", "uiTweaks", "optionalTweaks", nil, { numericMinimum=1,numericMaximum=2.6,numericStep=0.1,numericTolerance=0.001,toggleOn="2.6",toggleOff="1.9",labelKey="UI_TWEAK_CAMERA_DISTANCE",diffExplanationKey="UI_TWEAK_CAMERA_DISTANCE_TIP" }),
}
local function graphicPair(base, raid, values, extra)
  extra = extra or {}; extra.graphicsValidation = "advanced"
  table.insert(entries, c(base,"graphics","graphics",values,extra)); table.insert(entries, c(raid,"graphics","raidGraphics",values,extra))
end
graphicPair("graphicsShadowQuality","raidGraphicsShadowQuality",range(0,5),{officialProfileAllowed=true,blizzardLabel="SHADOW_QUALITY",diffExplanationKey="DIFF_EXPLAIN_SHADOWS"})
graphicPair("graphicsLiquidDetail","raidGraphicsLiquidDetail",range(0,3),{officialProfileAllowed=true,blizzardLabel="LIQUID_DETAIL",diffExplanationKey="DIFF_EXPLAIN_LIQUID"})
graphicPair("graphicsParticleDensity","raidGraphicsParticleDensity",range(0,5),{officialProfileAllowed=true,minimum=1,blizzardLabel="PARTICLE_DENSITY",diffExplanationKey="DIFF_EXPLAIN_PARTICLES"})
graphicPair("graphicsSSAO","raidGraphicsSSAO",range(0,4),{officialProfileAllowed=true,blizzardLabel="SSAO_LABEL",diffExplanationKey="DIFF_EXPLAIN_LIGHTING"})
graphicPair("graphicsDepthEffects","raidGraphicsDepthEffects",range(0,3),{officialProfileAllowed=true,blizzardLabel="DEPTH_EFFECTS",diffExplanationKey="DIFF_EXPLAIN_EFFECTS"})
graphicPair("graphicsComputeEffects","raidGraphicsComputeEffects",range(0,4),{officialProfileAllowed=true,blizzardLabel="COMPUTE_EFFECTS",diffExplanationKey="DIFF_EXPLAIN_EFFECTS"})
graphicPair("graphicsOutlineMode","raidGraphicsOutlineMode",range(0,2),{officialProfileAllowed=true,minimum=1,blizzardLabel="OUTLINE_MODE",diffExplanationKey="DIFF_EXPLAIN_OUTLINES"})
graphicPair("graphicsTextureResolution","raidGraphicsTextureResolution",range(0,2),{officialProfileAllowed=true,blizzardLabel="TEXTURE_DETAIL",diffExplanationKey="DIFF_EXPLAIN_TEXTURES"})
graphicPair("graphicsSpellDensity","raidGraphicsSpellDensity",range(0,2),{officialProfileAllowed=true,feature="spellDensity",blizzardLabel="SPELL_DENSITY",diffExplanationKey="DIFF_EXPLAIN_SPELLS"})
graphicPair("graphicsProjectedTextures","raidGraphicsProjectedTextures",range(0,1),{officialProfileAllowed=true,minimum=1,blizzardLabel="PROJECTED_TEXTURES",diffExplanationKey="DIFF_EXPLAIN_PROJECTED"})
graphicPair("graphicsViewDistance","raidGraphicsViewDistance",range(0,10),{officialProfileAllowed=true,blizzardLabel="FARCLIP",diffExplanationKey="DIFF_EXPLAIN_DISTANCE"})
graphicPair("graphicsEnvironmentDetail","raidGraphicsEnvironmentDetail",range(0,10),{officialProfileAllowed=true,blizzardLabel="ENVIRONMENT_DETAIL",diffExplanationKey="DIFF_EXPLAIN_ENVIRONMENT"})
graphicPair("graphicsGroundClutter","raidGraphicsGroundClutter",range(0,10),{officialProfileAllowed=true,blizzardLabel="GROUND_CLUTTER",diffExplanationKey="DIFF_EXPLAIN_CLUTTER"})
STBS.Registry = entries
STBS.RegistryByKey = {}; for _, setting in ipairs(STBS.Registry) do STBS.RegistryByKey[setting.key] = setting end
function STBS:GetRegistry(module) local out = {}; for _, s in ipairs(self.Registry) do if not module or s.module == module then table.insert(out,s) end end return out end
function STBS:GetSettingLabel(setting)
  if type(setting)~="table" then return self:L("DIFF_SETTING_GENERIC") end
  local label=setting.labelKey and self:L(setting.labelKey) or setting.blizzardLabel and _G[setting.blizzardLabel]
  if type(label)=="string" and label~="" then return label end
  local categoryLabels={raidGraphics="DIFF_SETTING_RAID",recommendedTweaks="DIFF_SETTING_TWEAK",optionalTweaks="DIFF_SETTING_TWEAK",camera="DIFF_SETTING_CAMERA",interface="DIFF_SETTING_INTERFACE",combat="DIFF_SETTING_COMBAT",nameplates="DIFF_SETTING_NAMEPLATE"}
  return self:L(categoryLabels[setting.category] or "DIFF_SETTING_GRAPHICS")
end
