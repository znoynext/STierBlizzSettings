local _, STBS = ...
local function range(first, last) local values = {}; for i = first, last do values[tostring(i)] = true end; return values end
local function c(key, module, category, values, extra)
  local entry = { key=key,module=module,category=category,valueType="numberString",readable=true,writable=true,portable=true,validValues=values,verifiedClientBuild="12.0.7.68453" }
  for k, v in pairs(extra or {}) do entry[k] = v end;return entry
end
local function product(extra,explanationKey,impact,impactLevel,displayValues)
  extra=extra or {};extra.explanationKey=explanationKey;extra.impact=impact;extra.impactLevel=impactLevel;extra.displayValues=displayValues;return extra
end
local entries = {
  c("RAIDsettingsEnabled", "graphics", "graphics", { ["0"]=true,["1"]=true }, product({ valueType="booleanString", officialProfileAllowed=true, blizzardLabel="RAID_SETTINGS_ENABLED" },"DIFF_EXPLAIN_RAID_MODE","usability","medium",{["0"]="DIFF_VALUE_UNIFIED",["1"]="DIFF_VALUE_SEPARATE"})),
  c("textureFilteringMode","graphics","graphics",range(0,5),product({officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="ANISOTROPIC"},"DIFF_EXPLAIN_TEXTURE_FILTERING","visual","medium")),
  c("shadowrt","graphics","graphics",range(0,3),product({officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="RT_SHADOW_QUALITY"},"DIFF_EXPLAIN_SHADOWS","performance","high")),
  c("ffxAntiAliasingMode","graphics","graphics",range(0,4),product({officialProfileAllowed=true,capability="aa",blizzardLabel="FXAA_CMAA_LABEL"},"DIFF_EXPLAIN_ANTIALIASING","visual","medium",{["0"]="DIFF_VALUE_DISABLED",["1"]="DIFF_VALUE_FXAA_LOW",["2"]="DIFF_VALUE_FXAA_HIGH",["3"]="DIFF_VALUE_CMAA",["4"]="DIFF_VALUE_CMAA2"})),
  c("MSAAQuality","graphics","graphics",{["0"]=true},product({officialProfileAllowed=true,capability="aa",blizzardLabel="MSAA_LABEL"},"DIFF_EXPLAIN_ANTIALIASING","visual","medium",{["0"]="DIFF_VALUE_DISABLED"})),
  c("msaaAlphaTest","graphics","graphics",{["0"]=true,["1"]=true},product({valueType="booleanString",officialProfileAllowed=true,graphicsValidation="cvar",blizzardLabel="MULTISAMPLE_ALPHA_TEST"},"DIFF_EXPLAIN_ANTIALIASING","visual","low")),
  c("cameraSmoothStyle", "interfaceGameplay", "camera", { ["0"]=true,["1"]=true,["2"]=true,["4"]=true }, product({ officialProfileAllowed=true, blizzardLabel="CAMERA_FOLLOWING_STYLE" },"DIFF_EXPLAIN_CAMERA","usability","low")),
  c("countdownForCooldowns", "interfaceGameplay", "interface", { ["0"]=true,["1"]=true }, product({ valueType="booleanString", officialProfileAllowed=true, blizzardLabel="COUNTDOWN_FOR_COOLDOWNS_TEXT" },"DIFF_EXPLAIN_INTERFACE","readability","medium")),
  c("showTargetOfTarget", "interfaceGameplay", "combat", { ["0"]=true,["1"]=true }, product({ valueType="booleanString", officialProfileAllowed=true, blizzardLabel="SHOW_TARGET_OF_TARGET_TEXT" },"DIFF_EXPLAIN_COMBAT","readability","high")),
  c("occludedSilhouettePlayer", "interfaceGameplay", "combat", { ["0"]=true,["1"]=true }, product({ valueType="booleanString", officialProfileAllowed=true, blizzardLabel="SHOW_SILHOUETTE_OPTION" },"DIFF_EXPLAIN_COMBAT","readability","high")),
  c("nameplateShowEnemies", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, product({ valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_SHOW_ENEMIES" },"DIFF_EXPLAIN_NAMEPLATES","readability","high")),
  c("nameplateShowAll", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, product({ valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_AUTOMODE" },"DIFF_EXPLAIN_NAMEPLATES","readability","high")),
  c("nameplateShowOffscreen", "interfaceGameplay", "nameplates", { ["0"]=true,["1"]=true }, product({ valueType="booleanString", officialProfileAllowed=true, blizzardLabel="UNIT_NAMEPLATES_SHOW_OFFSCREEN" },"DIFF_EXPLAIN_NAMEPLATES","readability","medium")),
  c("ResampleAlwaysSharpen", "uiTweaks", "recommendedTweaks", { ["0"]=true,["1"]=true }, product({ valueType="booleanString",labelKey="UI_TWEAK_ALWAYS_SHARPEN" },"UI_TWEAK_ALWAYS_SHARPEN_TIP","visual","low")),
  c("ResampleSharpness", "uiTweaks", "recommendedTweaks", nil, product({ numericMinimum=0, numericMaximum=2, numericStep=0.1, numericTolerance=0.001,labelKey="UI_TWEAK_SHARPNESS" },"UI_TWEAK_SHARPNESS_TIP","visual","low")),
  c("ffxGlow", "uiTweaks", "recommendedTweaks", { ["0"]=true,["1"]=true }, product({ valueType="booleanString",labelKey="UI_TWEAK_GLOW" },"UI_TWEAK_GLOW_TIP","visual","low")),
  c("ffxDeath", "uiTweaks", "optionalTweaks", { ["0"]=true,["1"]=true }, product({ valueType="booleanString",labelKey="UI_TWEAK_DEATH" },"UI_TWEAK_DEATH_TIP","visual","low")),
  c("ffxNether", "uiTweaks", "optionalTweaks", { ["0"]=true,["1"]=true }, product({ valueType="booleanString",labelKey="UI_TWEAK_NETHER" },"UI_TWEAK_NETHER_TIP","visual","low")),
  c("cameraDistanceMaxZoomFactor", "uiTweaks", "optionalTweaks", nil, product({ numericMinimum=1,numericMaximum=2.6,numericStep=0.1,numericTolerance=0.001,toggleOn="2.6",toggleOff="1.9",labelKey="UI_TWEAK_CAMERA_DISTANCE" },"UI_TWEAK_CAMERA_DISTANCE_TIP","usability","medium",{["1.9"]="DIFF_VALUE_STANDARD",["2.6"]="DIFF_VALUE_MAXIMUM"})),
}
local function graphicPair(base, raid, values, extra)
  extra = extra or {}; extra.graphicsValidation = "advanced"
  table.insert(entries, c(base,"graphics","graphics",values,extra)); table.insert(entries, c(raid,"graphics","raidGraphics",values,extra))
end
graphicPair("graphicsShadowQuality","raidGraphicsShadowQuality",range(0,5),product({officialProfileAllowed=true,blizzardLabel="SHADOW_QUALITY"},"DIFF_EXPLAIN_SHADOWS","performance","high"))
graphicPair("graphicsLiquidDetail","raidGraphicsLiquidDetail",range(0,3),product({officialProfileAllowed=true,blizzardLabel="LIQUID_DETAIL"},"DIFF_EXPLAIN_LIQUID","visual","medium"))
graphicPair("graphicsParticleDensity","raidGraphicsParticleDensity",range(0,5),product({officialProfileAllowed=true,minimum=1,blizzardLabel="PARTICLE_DENSITY"},"DIFF_EXPLAIN_PARTICLES","readability","high"))
graphicPair("graphicsSSAO","raidGraphicsSSAO",range(0,4),product({officialProfileAllowed=true,blizzardLabel="SSAO_LABEL"},"DIFF_EXPLAIN_LIGHTING","visual","medium"))
graphicPair("graphicsDepthEffects","raidGraphicsDepthEffects",range(0,3),product({officialProfileAllowed=true,blizzardLabel="DEPTH_EFFECTS"},"DIFF_EXPLAIN_EFFECTS","visual","medium"))
graphicPair("graphicsComputeEffects","raidGraphicsComputeEffects",range(0,4),product({officialProfileAllowed=true,blizzardLabel="COMPUTE_EFFECTS"},"DIFF_EXPLAIN_EFFECTS","performance","medium"))
graphicPair("graphicsOutlineMode","raidGraphicsOutlineMode",range(0,2),product({officialProfileAllowed=true,minimum=1,blizzardLabel="OUTLINE_MODE"},"DIFF_EXPLAIN_OUTLINES","readability","high"))
graphicPair("graphicsTextureResolution","raidGraphicsTextureResolution",range(0,2),product({officialProfileAllowed=true,blizzardLabel="TEXTURE_DETAIL"},"DIFF_EXPLAIN_TEXTURES","visual","high"))
graphicPair("graphicsSpellDensity","raidGraphicsSpellDensity",range(0,2),product({officialProfileAllowed=true,feature="spellDensity",blizzardLabel="SPELL_DENSITY"},"DIFF_EXPLAIN_SPELLS","readability","high",{["0"]="DIFF_VALUE_ESSENTIAL",["1"]="DIFF_VALUE_REDUCED",["2"]="DIFF_VALUE_EVERYTHING"}))
graphicPair("graphicsProjectedTextures","raidGraphicsProjectedTextures",range(0,1),product({officialProfileAllowed=true,minimum=1,blizzardLabel="PROJECTED_TEXTURES"},"DIFF_EXPLAIN_PROJECTED","readability","high"))
graphicPair("graphicsViewDistance","raidGraphicsViewDistance",range(0,10),product({officialProfileAllowed=true,blizzardLabel="FARCLIP"},"DIFF_EXPLAIN_DISTANCE","performance","high"))
graphicPair("graphicsEnvironmentDetail","raidGraphicsEnvironmentDetail",range(0,10),product({officialProfileAllowed=true,blizzardLabel="ENVIRONMENT_DETAIL"},"DIFF_EXPLAIN_ENVIRONMENT","performance","medium"))
graphicPair("graphicsGroundClutter","raidGraphicsGroundClutter",range(0,10),product({officialProfileAllowed=true,blizzardLabel="GROUND_CLUTTER"},"DIFF_EXPLAIN_CLUTTER","performance","medium"))
STBS.Registry = entries
STBS.RegistryByKey = {}; for _, setting in ipairs(STBS.Registry) do STBS.RegistryByKey[setting.key] = setting end
function STBS:GetRegistry(module) local out = {}; for _, s in ipairs(self.Registry) do if not module or s.module == module then table.insert(out,s) end end return out end
local impactDomains={performance=true,visual=true,readability=true,usability=true}
local impactLevels={low=true,medium=true,high=true}
local function localizedKey(addon,key)return type(key)=="string" and key~="" and type(addon)=="table" and type(addon.Locale)=="table" and type(addon.Locale.enUS)=="table" and type(addon.Locale.enUS[key])=="string" end
function STBS:ValidateRegistryProductMetadata(setting)
  if type(setting)~="table" then return false,"metadata-setting" end
  if setting.labelKey~=nil and not localizedKey(self,setting.labelKey) then return false,"metadata-label" end
  if setting.blizzardLabel~=nil and (type(setting.blizzardLabel)~="string" or setting.blizzardLabel=="") then return false,"metadata-blizzard-label" end
  if setting.explanationKey~=nil and not localizedKey(self,setting.explanationKey) then return false,"metadata-explanation" end
  local hasImpact=setting.impact~=nil;local hasLevel=setting.impactLevel~=nil
  if hasImpact~=hasLevel then return false,"metadata-impact-pair" end
  if hasImpact and not impactDomains[setting.impact] then return false,"metadata-impact" end
  if hasLevel and not impactLevels[setting.impactLevel] then return false,"metadata-impact-level" end
  if setting.displayValues~=nil then
    if type(setting.displayValues)~="table" or (not setting.validValues and setting.numericMinimum==nil) then return false,"metadata-display-values" end
    local count=0
    for value,key in pairs(setting.displayValues) do
      count=count+1;if type(value)~="string" or not localizedKey(self,key) then return false,"metadata-display-value" end
      if setting.validValues and not setting.validValues[value] then return false,"metadata-display-domain" end
      if setting.numericMinimum~=nil then
        local number=tonumber(value);if not number or type(setting.numericMaximum)~="number" or number<setting.numericMinimum or number>setting.numericMaximum then return false,"metadata-display-domain" end
        if setting.numericStep then local steps=(number-setting.numericMinimum)/setting.numericStep;if math.abs(steps-math.floor(steps+0.5))>(setting.numericTolerance or 0.000001) then return false,"metadata-display-domain" end end
      end
    end
    if count==0 then return false,"metadata-display-values" end
  end
  return true
end
function STBS:GetSettingLabel(setting)
  if type(setting)~="table" then return self:L("DIFF_SETTING_GENERIC") end
  local label=localizedKey(self,setting.labelKey) and self:L(setting.labelKey) or setting.blizzardLabel and _G[setting.blizzardLabel]
  if type(label)=="string" and label~="" then return label end
  local categoryLabels={raidGraphics="DIFF_SETTING_RAID",recommendedTweaks="DIFF_SETTING_TWEAK",optionalTweaks="DIFF_SETTING_TWEAK",camera="DIFF_SETTING_CAMERA",interface="DIFF_SETTING_INTERFACE",combat="DIFF_SETTING_COMBAT",nameplates="DIFF_SETTING_NAMEPLATE"}
  return self:L(categoryLabels[setting.category] or "DIFF_SETTING_GRAPHICS")
end
function STBS:GetSettingDisplayValue(setting,value)
  if value==nil then return self:L("DIFF_VALUE_UNAVAILABLE") end
  value=tostring(value)
  local metadataValid=type(setting)=="table" and self:ValidateRegistryProductMetadata(setting)
  if metadataValid and type(setting.displayValues)=="table" and localizedKey(self,setting.displayValues[value]) then return self:L(setting.displayValues[value]) end
  if type(setting)=="table" and setting.valueType=="booleanString" then return self:L(value=="1" and "DIFF_VALUE_ENABLED" or value=="0" and "DIFF_VALUE_DISABLED" or "DIFF_VALUE_UNKNOWN") end
  if type(setting)=="table" and setting.key=="cameraDistanceMaxZoomFactor" then return string.format(self:L("DIFF_VALUE_FACTOR"),tonumber(value) or 0) end
  if type(setting)=="table" and setting.numericTolerance then return value end
  if tonumber(value) then return string.format(self:L("DIFF_VALUE_LEVEL"),value) end
  return self:L("DIFF_VALUE_UNKNOWN")
end
function STBS:GetSettingExplanation(setting)
  return self:L(type(setting)=="table" and self:ValidateRegistryProductMetadata(setting) and localizedKey(self,setting.explanationKey) and setting.explanationKey or "DIFF_EXPLAIN_GENERIC")
end
function STBS:GetSettingImpactDescription(setting)
  if type(setting)~="table" or not self:ValidateRegistryProductMetadata(setting) or not impactDomains[setting.impact] or not impactLevels[setting.impactLevel] then return nil end
  return string.format(self:L("DIFF_IMPACT_FORMAT"),self:L("DIFF_IMPACT_"..string.upper(setting.impact)),self:L("DIFF_IMPACT_"..string.upper(setting.impactLevel)))
end
