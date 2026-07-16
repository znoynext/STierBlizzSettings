local _, STBS = ...
function STBS:GetSelectedMode() return self:InitializeDatabase().preferences.graphicsMode end
function STBS:SetSelectedMode(mode) if mode~=self.GRAPHICS_MODE_UNIFIED and mode~=self.GRAPHICS_MODE_SPLIT then return false end; self:InitializeDatabase().preferences.graphicsMode=mode; return true end
function STBS:FlattenProfile(profile, modules, keepMode)
  local out={}; local sections=profile.sections or {}; if modules.graphics then local g=sections.graphics or {}; for k,v in pairs(g.base or {}) do out[k]=v end; if (not keepMode and g.mode==self.GRAPHICS_MODE_SPLIT) or (keepMode==self.GRAPHICS_MODE_SPLIT) then for k,v in pairs(g.raid or {}) do out[k]=v end end; if not keepMode then out.RAIDsettingsEnabled=g.mode==self.GRAPHICS_MODE_SPLIT and "1" or "0" end end
  if modules.interfaceGameplay then for _,n in ipairs({"interface","camera","gameplay","controls","combat","nameplates","chat"}) do for k,v in pairs(sections[n] or {}) do out[k]=v end end end; return out
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
  return self:BuildDiff(settings), settings
end
function STBS:SaveCurrent(name, modules)
  local validModules = self:ValidateModules(modules); if not validModules then return nil,"modules" end
  if modules.graphics and not self:GetSelectedMode() then
    local currentRaid=self:ReadSetting(self.RegistryByKey.RAIDsettingsEnabled)
    self:SetSelectedMode(currentRaid=="1" and self.GRAPHICS_MODE_SPLIT or self.GRAPHICS_MODE_UNIFIED)
  end
  name = name or (self:L("PERSONAL").." "..date("%Y-%m-%d %H:%M"))
  if type(name) == "string" then name = name:match("^%s*(.-)%s*$") end
  if type(name) ~= "string" or name == "" or #name > self.MAX_PROFILE_NAME_BYTES or name:find("[%c]") then return nil,"name" end
  local db=self:InitializeDatabase();db.profileSequence=db.profileSequence+1
  local p=self:NewProfile("personal_"..tostring(time()).."_"..tostring(db.profileSequence),"personal",name)
  local values,failures=self:CaptureModules(modules);p.capturedModules=self:Copy(modules);p.captureFailures=failures
  p.sections.graphics={mode=self:GetSelectedMode(),base={},raid={},storedInactiveRaidSettings={}}
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
  local profile = self:InitializeDatabase().profiles[id]; if type(profile)~="table" then return self:Result(false,"missing") end
  profile.displayName=name; profile.updatedAt=time(); return self:Result(true,"renamed",profile)
end
function STBS:DeleteProfile(id)
  local profiles=self:InitializeDatabase().profiles; if not profiles[id] then return self:Result(false,"missing") end; profiles[id]=nil; return self:Result(true,"deleted")
end
