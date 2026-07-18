local _, STBS = ...
function STBS:WriteSetting(setting, value)
  local valid, why = self:ValidateValue(setting, value); if not valid then return false, why end
  local writable, blocked = self:CanUseCVar(setting.key); if not writable then return false, blocked end
  local before = self:ReadSetting(setting); if self:SettingValuesEqual(setting,before,value) then return true, "identical" end
  local called, success = pcall(C_CVar.SetCVar, setting.key, value); if not called or not success then return false, "rejected" end
  local after = self:ReadSetting(setting); if not self:SettingValuesEqual(setting,after,value) then return false, "unverified" end
  return true, "changed"
end
