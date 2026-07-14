local _, STBS = ...
function STBS:RegisterBlizzardSettings(frame)
  if not Settings or not Settings.RegisterCanvasLayoutCategory or not Settings.RegisterAddOnCategory then return false end
  local category = Settings.RegisterCanvasLayoutCategory(frame, self:L("TITLE")); Settings.RegisterAddOnCategory(category); return true
end
