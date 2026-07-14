local _, STBS = ...
function STBS:ValidateValue(setting, value)
  if type(value) ~= "string" or #value > self.MAX_STRING_BYTES then return false, "type" end
  if setting.feature == "spellDensity" and not self:IsSpellDensitySupported() then return false, "unsupported" end
  if setting.validValues and not setting.validValues[value] then return false, "value" end
  return true
end
function STBS:ValidateSettings(settings, official)
  if type(settings) ~= "table" then return false, "settings" end
  for key, value in pairs(settings) do
    local setting = self.RegistryByKey[key]
    if not setting or (official and not setting.officialProfileAllowed) then return false, "unknown:"..tostring(key) end
    local ok, why = self:ValidateValue(setting, value); if not ok and why ~= "unsupported" then return false, why..":"..key end
  end
  local projected = settings.graphicsProjectedTextures or settings.raidGraphicsProjectedTextures
  if projected == "0" then return false, "visibility:projectedTextures" end
  for _, key in ipairs({"graphicsParticleDensity","raidGraphicsParticleDensity","graphicsOutlineMode","raidGraphicsOutlineMode"}) do if settings[key] == "0" then return false, "visibility:"..key end end
  return true
end
