local _, STBS = ...
function STBS:RegisterBlizzardSettings()
  if self.settingsCategory then return true end
  if not Settings or not Settings.RegisterCanvasLayoutCategory or not Settings.RegisterAddOnCategory then return false end
  local panel=CreateFrame("Frame",nil,UIParent)
  local title=panel:CreateFontString(nil,"ARTWORK","GameFontNormalLarge");title:SetPoint("TOPLEFT",16,-16);title:SetText(self:L("TITLE"))
  local description=panel:CreateFontString(nil,"ARTWORK","GameFontHighlight");description:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-12);description:SetWidth(620);description:SetJustifyH("LEFT");description:SetText(self:L("HOME_TEXT"))
  local open=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate");open:SetSize(240,30);open:SetPoint("TOPLEFT",description,"BOTTOMLEFT",0,-18);open:SetText(self:L("TITLE"));open:SetScript("OnClick",function()STBS:ShowHome()end)
  local category = Settings.RegisterCanvasLayoutCategory(panel, self:L("TITLE")); Settings.RegisterAddOnCategory(category);self.settingsCategory=category;return true
end
