local _, STBS = ...
function STBS:ReadSetting(setting)
  if not C_CVar or not C_CVar.GetCVar then return nil, "api" end
  local ok, value = pcall(C_CVar.GetCVar, setting.key); if not ok or value == nil then return nil, "unavailable" end
  return tostring(value)
end
function STBS:CaptureModules(modules)
  local values, failures = {}, {}
  for _, setting in ipairs(self.Registry) do if modules[setting.module] and (not setting.feature or setting.feature ~= "spellDensity" or self:IsSpellDensitySupported()) then local v,e=self:ReadSetting(setting); if v then values[setting.key]=v else failures[setting.key]=e end end end
  return values, failures
end
