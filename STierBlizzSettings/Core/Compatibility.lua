local _, STBS = ...
function STBS:GetBuild() local _, build, _, interface = GetBuildInfo(); return build or "unknown", interface or "unknown" end
function STBS:IsRetail() return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE end
function STBS:CanUseCVar(name)
  if not C_CVar or not C_CVar.GetCVarInfo then return false, "api" end
  local ok, value, _, _, _, locked, secure, readOnly = pcall(C_CVar.GetCVarInfo, name)
  if not ok or value == nil then return false, "unavailable" end
  if locked or secure or readOnly then return false, "protected" end
  return true
end
function STBS:IsSpellDensitySupported() return C_VideoOptions and C_VideoOptions.IsSpellVisualDensitySystemSupported and C_VideoOptions.IsSpellVisualDensitySystemSupported() or false end
function STBS:SupportsEditMode() return C_EditMode and C_EditMode.GetLayouts and C_EditMode.SaveLayouts and C_EditMode.ConvertLayoutInfoToString end
function STBS:IsGraphicsValueSupported(setting, value)
  if setting.capability == "aa" and setting.key == "ffxAntiAliasingMode" and tonumber(value) >= 3 then
    if type(_G.AntiAliasingSupported) ~= "function" then return false, "unsupported" end
    local ok, _, cmaa, cmaa2 = pcall(_G.AntiAliasingSupported);if not ok or (value == "3" and not cmaa) or (value == "4" and not cmaa2) then return false, "unsupported" end
  end
  if not setting.graphicsValidation then return true end
  local validator = setting.graphicsValidation == "advanced" and _G.IsGraphicsSettingValueSupported or _G.IsGraphicsCVarValueSupported
  if type(validator) ~= "function" then return false, "unsupported" end
  local ok, rejection
  if setting.graphicsValidation == "advanced" then
    ok, rejection = pcall(validator, setting.key, tonumber(value), setting.category == "raidGraphics")
  else
    ok, rejection = pcall(validator, setting.key, tonumber(value))
  end
  if not ok or (rejection ~= nil and rejection ~= 0) then return false, "unsupported" end
  return true
end
