local _, STBS = ...

local categories={"world","party","raid","pvp","scenario"}

function STBS:ClearActiveZoneGraphicsState()
  self.activeZoneCategory=nil;self.activeZonePreset=nil
end

function STBS:CommitActiveZoneGraphicsState(category,preset)
  self.activeZoneCategory=category;self.activeZonePreset=preset
end

function STBS:GetZoneGraphicsConfig()
  local config=self:InitializeDatabase().preferences.zoneGraphics
  return self:IsDatabaseSchemaSupported() and config or self:Copy(config)
end

function STBS:GetZoneCategory()
  if type(_G.C_PartyInfo)=="table" and type(_G.C_PartyInfo.IsDelveInProgress)=="function" then
    local ok,isDelve=pcall(_G.C_PartyInfo.IsDelveInProgress);if ok and isDelve then return "scenario" end
  end
  if type(_G.IsInInstance)~="function" then return "world" end
  local ok,inInstance,instanceType=pcall(_G.IsInInstance)
  if not ok or not inInstance then return "world" end
  if instanceType=="party" or instanceType=="raid" or instanceType=="scenario" then return instanceType end
  if instanceType=="pvp" or instanceType=="arena" then return "pvp" end
  return "world"
end

function STBS:SetZoneGraphicsEnabled(enabled)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return false,databaseFailure.code end
  enabled=enabled==true;db.preferences.zoneGraphics.enabled=enabled
  if not enabled then local pending=self:GetPendingOperation();if pending and pending.kind=="zone-auto" then self:CancelPendingOperation("zone-auto") end;self:ClearActiveZoneGraphicsState() end
  return true
end

function STBS:CycleZonePreset(category)
  local known=false;for _,value in ipairs(categories) do if value==category then known=true break end end
  if not known then return false end
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return nil,databaseFailure.code end
  local config=db.preferences.zoneGraphics;local current=config.assignments[category]
  if current==self.GRAPHICS_PRESET_PRO then current=self.GRAPHICS_PRESET_OPTIMIZED
  elseif current==self.GRAPHICS_PRESET_OPTIMIZED then current=self.GRAPHICS_PRESET_QUALITY
  else current=self.GRAPHICS_PRESET_PRO end
  config.assignments[category]=current;return current
end

function STBS:ApplyZoneGraphics(trigger)
  trigger=trigger or "zone-graphics"
  if self.fpsTestMeasurement or self.fpsPresetRestorePending then self:ClearActiveZoneGraphicsState();return self:Result(false,"fps-test") end
  local config=self:GetZoneGraphicsConfig();if not config.enabled then self:ClearActiveZoneGraphicsState();return self:Result(false,"disabled") end
  local category=self:GetZoneCategory();local preset=config.assignments[category]
  if not self:IsGraphicsPreset(preset) then self:ClearActiveZoneGraphicsState();return self:Result(false,"preset") end
  local mode=self.GRAPHICS_MODE_UNIFIED
  local settings=self:FlattenProfile(self:GetOfficialGraphics(mode,preset),{graphics=true})
  local valid,why=self:ValidateSettings(settings,true);if not valid then self:ClearActiveZoneGraphicsState();return self:Result(false,why) end
  local pendingKind=trigger=="zone-change" and "zone-auto" or "zone-manual"
  local result=self:ApplySettings(settings,{graphics=true},trigger,{backupSource=pendingKind=="zone-auto" and "zone-auto" or "zone-manual"},{kind=pendingKind,context={category=category,preset=preset,mode=mode}})
  if result.code=="unchanged" then local pending=self:GetPendingOperation();if pending and pending.kind=="zone-auto" then self:CancelPendingOperation("zone-auto") end end
  local graphics=self:GetResultDiffSummary(result,"graphics")
  self.zoneStatus={ok=result.ok,code=result.code,category=category,preset=preset,changed=result.ok and graphics.changed or 0}
  if result.ok then self:CommitActiveZoneGraphicsState(category,preset);self:CommitAppliedGraphicsState(mode,preset) else self:ClearActiveZoneGraphicsState() end
  if self.ui and self.ui:IsShown() and self.ui.currentPageKey=="graphics" and self.ui.currentGraphicsSection=="zones" then self:ShowZoneGraphics() end
  return result
end
