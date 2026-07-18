local _, STBS = ...
function STBS:ValidateValue(setting, value)
  if type(value) ~= "string" or #value > self.MAX_STRING_BYTES then return false, "type" end
  if setting.feature == "spellDensity" and not self:IsSpellDensitySupported() then return false, "unsupported" end
  if setting.validValues and not setting.validValues[value] then return false, "value" end
  if setting.numericMinimum ~= nil then
    local number=tonumber(value)
    if not number or number~=number or number<setting.numericMinimum or number>setting.numericMaximum then return false,"value" end
    if setting.numericStep then
      local steps=(number-setting.numericMinimum)/setting.numericStep
      if math.abs(steps-math.floor(steps+0.5))>(setting.numericTolerance or 0.000001) then return false,"value" end
    end
  end
  local supported, supportWhy = self:IsGraphicsValueSupported(setting, value); if not supported then return false, supportWhy end
  return true
end
function STBS:SettingValuesEqual(setting, first, second)
  if first==second then return true end
  if not setting or not setting.numericTolerance then return false end
  local a,b=tonumber(first),tonumber(second)
  return a~=nil and b~=nil and math.abs(a-b)<=setting.numericTolerance
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
