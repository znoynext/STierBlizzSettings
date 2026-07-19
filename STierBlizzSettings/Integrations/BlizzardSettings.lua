local _, STBS = ...
function STBS:RegisterBlizzardSettings()
  if self.settingsCategory then return true end
  if not Settings or not Settings.RegisterCanvasLayoutCategory or not Settings.RegisterAddOnCategory then return false end
  local panel=CreateFrame("Frame",nil,UIParent)
  local title=panel:CreateFontString(nil,"ARTWORK","GameFontNormalLarge");title:SetPoint("TOPLEFT",16,-16);title:SetText(self:L("TITLE"))
  local description=panel:CreateFontString(nil,"ARTWORK","GameFontHighlight");description:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-12);description:SetWidth(620);description:SetJustifyH("LEFT");description:SetText(self:L("HOME_TEXT"))
  local open=self:CreateModernButton(panel,self:L("TITLE"),240,30,function()STBS:ShowHome()end);open:SetPoint("TOPLEFT",description,"BOTTOMLEFT",0,-18)
  local reset=self:CreateModernButton(panel,self:L("RESET_WINDOW_POSITION"),240,30,function()STBS:ResetUILayoutAndShow()end);reset:SetPoint("TOPLEFT",open,"BOTTOMLEFT",0,-10)
  local category = Settings.RegisterCanvasLayoutCategory(panel, self:L("TITLE")); Settings.RegisterAddOnCategory(category);self.settingsCategory=category;return true
end
