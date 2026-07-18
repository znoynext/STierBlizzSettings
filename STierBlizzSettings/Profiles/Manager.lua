local _, STBS = ...
function STBS:GetAppliedGraphicsPreset() return self:InitializeDatabase().preferences.graphicsPreset end
function STBS:GetAppliedGraphicsMode() return self:InitializeDatabase().preferences.graphicsMode end
function STBS:GetSelectedPreset() local applied=self:GetAppliedGraphicsPreset();return self.graphicsPresetSelection or (self:IsGraphicsPreset(applied) and applied or self.GRAPHICS_PRESET_OPTIMIZED) end
function STBS:SetSelectedPreset(preset) if not self:IsGraphicsPreset(preset) then return false end;self.graphicsPresetSelection=preset;return true end
function STBS:GetSelectedMode() return self.graphicsModeSelection or self:GetAppliedGraphicsMode() end
function STBS:SetSelectedMode(mode) if mode~=self.GRAPHICS_MODE_UNIFIED and mode~=self.GRAPHICS_MODE_SPLIT then return false end;self.graphicsModeSelection=mode;return true end
function STBS:ResolveGraphicsModeFromRaidSetting(value)
  if value=="1" then return self.GRAPHICS_MODE_SPLIT end
  if value=="0" then return self.GRAPHICS_MODE_UNIFIED end
  return nil,value==nil and "graphics-mode-unavailable" or "graphics-mode-invalid"
end
function STBS:GetCurrentGraphicsMode()
  local current=self:ReadSetting(self.RegistryByKey.RAIDsettingsEnabled)
  return self:ResolveGraphicsModeFromRaidSetting(current)
end
function STBS:CommitAppliedGraphicsState(mode,preset)
  mode=mode or self:GetCurrentGraphicsMode();if mode~=self.GRAPHICS_MODE_UNIFIED and mode~=self.GRAPHICS_MODE_SPLIT then return false end
  if preset==nil then preset=self:GetCurrentGraphicsPreset() or self.GRAPHICS_PRESET_CUSTOM end
  if not self:IsGraphicsPreset(preset) and preset~=self.GRAPHICS_PRESET_CUSTOM then return false end
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return false,databaseFailure.code end
  local preferences=db.preferences;preferences.graphicsMode=mode;preferences.graphicsPreset=preset;return true
end
function STBS:SyncAppliedGraphicsState()
  local mode=self:GetCurrentGraphicsMode();if not mode then return false end
  local committed=self:CommitAppliedGraphicsState(mode,self:GetCurrentGraphicsPreset() or self.GRAPHICS_PRESET_CUSTOM)
  if committed then self:InitializeDatabase().graphicsStateNeedsSync=nil end
  return committed
end
function STBS:FlattenProfile(profile, modules, keepMode)
  local out={}; local sections=profile.sections or {}; if modules.graphics then local g=sections.graphics or {}; for k,v in pairs(g.base or {}) do out[k]=v end; if (not keepMode and g.mode==self.GRAPHICS_MODE_SPLIT) or (keepMode==self.GRAPHICS_MODE_SPLIT) then for k,v in pairs(g.raid or {}) do out[k]=v end end; if not keepMode then out.RAIDsettingsEnabled=g.mode==self.GRAPHICS_MODE_SPLIT and "1" or "0" end end
  if modules.interfaceGameplay then for _,n in ipairs({"interface","camera","gameplay","controls","combat","nameplates","chat"}) do for k,v in pairs(sections[n] or {}) do out[k]=v end end end; return out
end
function STBS:IsLegacySplitProfile(profile)
  local valid,why=self:ValidateProfile(profile);if not valid then return false,why end
  if profile.profileType~="personal" then return false,"profileType" end
  local graphics=profile.sections and profile.sections.graphics
  if type(graphics)~="table" or graphics.mode~=self.GRAPHICS_MODE_SPLIT then return false,"not-legacy-split" end
  return true
end
function STBS:ConvertLegacySplitProfile(profile)
  local legacy,why=self:IsLegacySplitProfile(profile);if not legacy then return nil,why end
  local converted=self:Copy(profile);converted.sections.graphics.mode=self.GRAPHICS_MODE_UNIFIED
  local valid,convertedWhy=self:ValidateProfile(converted);if not valid then return nil,convertedWhy end
  return converted
end
function STBS:GetLegacySplitProfileSettings(profile)
  local legacy,why=self:IsLegacySplitProfile(profile);if not legacy then return nil,why end
  local settings=self:FlattenProfile(profile,{graphics=true});local valid,settingsWhy=self:ValidateSettings(settings,false)
  if not valid then return nil,settingsWhy end
  return settings
end
function STBS:SaveConvertedLegacyProfile(profileId,name)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  if type(name)=="string" then name=name:match("^%s*(.-)%s*$") end
  if type(name)~="string" or name=="" or #name>self.MAX_PROFILE_NAME_BYTES or name:find("[%c]") then return self:Result(false,"name") end
  local original=db.profiles[profileId]
  if type(original)~="table" or original.id~=profileId then return self:Result(false,"missing") end
  local converted,why=self:ConvertLegacySplitProfile(original);if not converted then return self:Result(false,why) end
  db.profileSequence=db.profileSequence+1
  local id="personal_"..tostring(time()).."_"..tostring(db.profileSequence)
  while db.profiles[id] do db.profileSequence=db.profileSequence+1;id="personal_"..tostring(time()).."_"..tostring(db.profileSequence) end
  converted.id=id;converted.displayName=name;converted.schemaVersion=self.PROFILE_SCHEMA;converted.addonVersion=self.VERSION;converted.testedClientBuild=self:GetBuild();converted.createdAt=time();converted.updatedAt=converted.createdAt
  local valid,convertedWhy=self:ValidateProfile(converted);if not valid then return self:Result(false,convertedWhy) end
  db.profiles[id]=converted
  return self:Result(true,"converted",converted)
end
function STBS:GetPreferredAntiAliasing()
  if type(_G.AntiAliasingSupported) ~= "function" then return nil end
  local ok, _, cmaa, cmaa2 = pcall(_G.AntiAliasingSupported); if not ok then return nil end
  if cmaa2 then return { ffxAntiAliasingMode="4", MSAAQuality="0" } end
  if cmaa then return { ffxAntiAliasingMode="3", MSAAQuality="0" } end
  return { ffxAntiAliasingMode="2", MSAAQuality="0" }
end
function STBS:PlanImport(payload, modules, graphicsMode)
  if type(payload) ~= "table" or type(payload.profile) ~= "table" then return nil,"payload" end
  local validModules = self:ValidateModules(modules); if not validModules then return nil,"modules" end
  if graphicsMode ~= "profile" and graphicsMode ~= "current" then return nil,"mode" end
  local validProfile, why = self:ValidateProfile(payload.profile); if not validProfile then return nil,why end
  if graphicsMode == "current" and modules.graphics and not self:GetSelectedMode() then return nil,"mode" end
  local settings = self:FlattenProfile(payload.profile, modules, graphicsMode == "current" and self:GetSelectedMode() or nil)
  if graphicsMode == "current" and modules.graphics then settings.RAIDsettingsEnabled = self:GetSelectedMode() == self.GRAPHICS_MODE_SPLIT and "1" or "0" end
  local plan,summary=self:BuildDiff(settings,modules)
  return plan,settings,summary
end
function STBS:SaveCurrent(name, modules)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return nil,databaseFailure.code end
  local validModules = self:ValidateModules(modules); if not validModules then return nil,"modules" end
  name = name or (self:L("PERSONAL").." "..date("%Y-%m-%d %H:%M"))
  if type(name) == "string" then name = name:match("^%s*(.-)%s*$") end
  if type(name) ~= "string" or name == "" or #name > self.MAX_PROFILE_NAME_BYTES or name:find("[%c]") then return nil,"name" end
  local values,failures=self:CaptureModules(modules);local capturedMode,modeWhy
  if modules.graphics then capturedMode,modeWhy=self:ResolveGraphicsModeFromRaidSetting(values.RAIDsettingsEnabled);if not capturedMode then return nil,modeWhy end end
  db.profileSequence=db.profileSequence+1
  local p=self:NewProfile("personal_"..tostring(time()).."_"..tostring(db.profileSequence),"personal",name)
  p.capturedModules=self:Copy(modules);p.captureFailures=failures
  p.sections.graphics={mode=capturedMode,base={},raid={},storedInactiveRaidSettings={}}
  for k,v in pairs(values) do local s=self.RegistryByKey[k]; if s.module=="graphics" then if s.category=="raidGraphics" then p.sections.graphics.raid[k]=v else p.sections.graphics.base[k]=v end elseif s.category=="camera" then p.sections.camera[k]=v else p.sections[s.category][k]=v end end
  db.profiles[p.id]=p;return p
end
function STBS:ListPersonalProfiles()
  local profiles = {}; for id, profile in pairs(self:InitializeDatabase().profiles) do local valid=type(profile)=="table" and profile.id==id and self:ValidateProfile(profile);if valid then table.insert(profiles, profile) end end
  table.sort(profiles, function(a,b) return (tonumber(a.updatedAt) or 0) > (tonumber(b.updatedAt) or 0) end); return profiles
end
function STBS:RenameProfile(id, name)
  if type(name) == "string" then name = name:match("^%s*(.-)%s*$") end
  if type(name) ~= "string" or name == "" or #name > self.MAX_PROFILE_NAME_BYTES or name:find("[%c]") then return self:Result(false,"name") end
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  local profile = db.profiles[id]; if type(profile)~="table" then return self:Result(false,"missing") end
  profile.displayName=name; profile.updatedAt=time(); return self:Result(true,"renamed",profile)
end
function STBS:DeleteProfile(id)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  local profiles=db.profiles;if not profiles[id] then return self:Result(false,"missing") end;profiles[id]=nil;return self:Result(true,"deleted")
end
