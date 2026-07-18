local _, STBS = ...
function STBS:WriteSetting(setting, value, knownCurrent)
  local valid, why = self:ValidateValue(setting, value); if not valid then return false, why end
  local writable, blocked = self:CanUseCVar(setting.key); if not writable then return false, blocked end
  local before,readWhy=knownCurrent,nil;if before==nil then before,readWhy=self:ReadSetting(setting) end;if before==nil then return false,readWhy or "previous-unavailable" end
  if self:SettingValuesEqual(setting,before,value) then return true, "identical" end
  local called, success = pcall(C_CVar.SetCVar, setting.key, value); if not called or not success then return false, "rejected" end
  local after = self:ReadSetting(setting); if not self:SettingValuesEqual(setting,after,value) then return false, "unverified" end
  return true, "changed"
end
