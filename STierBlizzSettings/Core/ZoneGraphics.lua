local _, STBS = ...

local categories={"world","party","raid","pvp","scenario"}

function STBS:ClearActiveZoneGraphicsState()
  self.activeZoneCategory=nil;self.activeZonePreset=nil
end

function STBS:CommitActiveZoneGraphicsState(category,preset)
  self.activeZoneCategory=category;self.activeZonePreset=preset
end

function STBS:GetZoneGraphicsConfig()
  return self:InitializeDatabase().preferences.zoneGraphics
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
  enabled=enabled==true;self:GetZoneGraphicsConfig().enabled=enabled
  if not enabled then local pending=self:GetPendingOperation();if pending and pending.kind=="zone-auto" then self:CancelPendingOperation("zone-auto") end;self:ClearActiveZoneGraphicsState() end
  return true
end

function STBS:CycleZonePreset(category)
  local known=false;for _,value in ipairs(categories) do if value==category then known=true break end end
  if not known then return false end
  local config=self:GetZoneGraphicsConfig();local current=config.assignments[category]
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
  local plan=self:BuildDiff(settings);local changed=0
  for _,entry in ipairs(plan) do if entry.status=="changed" then changed=changed+1 end end
  if changed==0 then
    local pending=self:GetPendingOperation();if pending and pending.kind=="zone-auto" then self:CancelPendingOperation("zone-auto") end
    self:CommitActiveZoneGraphicsState(category,preset);self:CommitAppliedGraphicsState(mode,preset)
    self.zoneStatus={ok=true,code="unchanged",category=category,preset=preset,changed=0}
    if self.ui and self.ui:IsShown() and self.ui.currentPageKey=="graphics" and self.ui.currentGraphicsSection=="zones" then self:ShowZoneGraphics() end
    return self:Result(true,"unchanged",self.zoneStatus)
  end
  local pendingKind=trigger=="zone-change" and "zone-auto" or "zone-manual"
  local result=self:ApplySettings(settings,{graphics=true},trigger,nil,{kind=pendingKind,context={category=category,preset=preset,mode=mode}})
  self.zoneStatus={ok=result.ok,code=result.code,category=category,preset=preset,changed=changed}
  if result.ok then self:CommitActiveZoneGraphicsState(category,preset);self:CommitAppliedGraphicsState(mode,preset) else self:ClearActiveZoneGraphicsState() end
  if self.ui and self.ui:IsShown() and self.ui.currentPageKey=="graphics" and self.ui.currentGraphicsSection=="zones" then self:ShowZoneGraphics() end
  return result
end
