local _, STBS = ...
function STBS:ValidateValue(setting, value)
  if type(value) ~= "string" or #value > self.MAX_STRING_BYTES then return false, "type" end
  if setting.feature == "spellDensity" and not self:IsSpellDensitySupported() then return false, "unsupported" end
  if setting.validValues and not setting.validValues[value] then return false, "value" end
  local supported, supportWhy = self:IsGraphicsValueSupported(setting, value); if not supported then return false, supportWhy end
  return true
end
function STBS:ValidateModules(modules)
  if type(modules) ~= "table" then return false, "modules" end
  local selected = 0
  for key, value in pairs(modules) do
    if not self.Modules[key] or type(value) ~= "boolean" then return false, "modules" end
    if value then selected = selected + 1 end
  end
  if selected == 0 then return false, "modules" end
  return true
end
function STBS:ValidateSettings(settings, official)
  if type(settings) ~= "table" then return false, "settings" end
  for key, value in pairs(settings) do
    local setting = self.RegistryByKey[key]
    if not setting or (official and not setting.officialProfileAllowed) then return false, "unknown:"..tostring(key) end
    local ok, why = self:ValidateValue(setting, value); if not ok and why ~= "unsupported" then return false, why..":"..tostring(key) end
  end
  if official then for _, key in ipairs({"graphicsProjectedTextures","raidGraphicsProjectedTextures","graphicsParticleDensity","raidGraphicsParticleDensity","graphicsOutlineMode","raidGraphicsOutlineMode"}) do local setting = self.RegistryByKey[key];if settings[key] and setting.minimum and tonumber(settings[key]) < setting.minimum then return false, "visibility:"..key end end end
  return true
end
