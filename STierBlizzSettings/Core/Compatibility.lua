local _, STBS = ...
function STBS:GetBuild() local _, build, _, interface = GetBuildInfo(); return build or "unknown", interface or "unknown" end
function STBS:IsRetail() return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE end
function STBS:CanUseCVar(name)
  if not C_CVar or not C_CVar.GetCVarInfo then return false, "api" end
  local value, _, _, _, locked, secure, readOnly = C_CVar.GetCVarInfo(name)
  if value == nil then return false, "unavailable" end
  if locked or secure or readOnly then return false, "protected" end
  return true
end
function STBS:IsSpellDensitySupported() return C_VideoOptions and C_VideoOptions.IsSpellVisualDensitySystemSupported and C_VideoOptions.IsSpellVisualDensitySystemSupported() or false end
function STBS:SupportsEditMode() return C_EditMode and C_EditMode.GetLayouts and C_EditMode.SaveLayouts and C_EditMode.ConvertLayoutInfoToString end
