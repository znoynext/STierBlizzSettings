local _, STBS = ...
function STBS:CreateMinimapButton()
  if self.minimapButton or not Minimap then return end
  local button=CreateFrame("Button","STierBlizzSettingsMinimapButton",Minimap)
  button:SetSize(31,31);button:SetFrameStrata("MEDIUM");button:SetFrameLevel(8);button:SetPoint("TOPLEFT",Minimap,"TOPLEFT",-4,4)
  button:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01");button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
  button:SetScript("OnClick",function()STBS:ShowHome()end)
  button:SetScript("OnEnter",function(self)GameTooltip:SetOwner(self,"ANCHOR_LEFT");GameTooltip:SetText(STBS:L("TITLE"));GameTooltip:AddLine(STBS:L("MINIMAP_TOOLTIP"),1,1,1,true);GameTooltip:Show()end)
  button:SetScript("OnLeave",function()GameTooltip:Hide()end)
  self.minimapButton=button
end
