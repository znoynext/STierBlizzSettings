local _, STBS = ...
local ICON = "Interface\\AddOns\\STierBlizzSettings\\Assets\\STierIcon"

local function place(button, angle)
  angle=tonumber(angle) or math.rad(225)
  local radius=((Minimap and Minimap.GetWidth and Minimap:GetWidth() or 140)/2)+7
  button:ClearAllPoints();button:SetPoint("CENTER",Minimap,"CENTER",math.cos(angle)*radius,math.sin(angle)*radius)
end

function STBS:CreateMinimapButton()
  if self.minimapButton or not Minimap then return end
  local button=CreateFrame("Button","STierBlizzSettingsMinimapButton",Minimap)
  button:SetSize(36,36);button:SetFrameStrata("MEDIUM");button:SetFrameLevel(8)
  if button.RegisterForClicks then button:RegisterForClicks("LeftButtonUp","RightButtonUp") end
  if button.RegisterForDrag then button:RegisterForDrag("LeftButton") end
  button:SetNormalTexture(ICON);button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight","ADD")
  if button.SetPushedTexture then button:SetPushedTexture(ICON) end
  local border=button.CreateTexture and button:CreateTexture(nil,"OVERLAY")
  if border then border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");border:SetSize(56,56);border:SetPoint("TOPLEFT",0,0) end
  place(button,self:InitializeDatabase().preferences.minimapAngle)
  button:SetScript("OnClick",function(_,mouseButton)if mouseButton=="RightButton" then STBS:ShowProfiles() else STBS:ShowGraphics() end end)
  button:SetScript("OnDragStart",function(self)
    self:SetScript("OnUpdate",function(current)
      if not GetCursorPosition or not UIParent or not Minimap.GetCenter then return end
      local cursorX,cursorY=GetCursorPosition();local scale=UIParent:GetEffectiveScale();cursorX,cursorY=cursorX/scale,cursorY/scale
      local centerX,centerY=Minimap:GetCenter();if not centerX or not centerY then return end
      local db=STBS:RequireWritableDatabase();if not db then return end
      local angle=math.atan2(cursorY-centerY,cursorX-centerX);db.preferences.minimapAngle=angle;place(current,angle)
    end)
  end)
  button:SetScript("OnDragStop",function(self)self:SetScript("OnUpdate",nil)end)
  button:SetScript("OnEnter",function(self)if not GameTooltip then return end;GameTooltip:SetOwner(self,"ANCHOR_LEFT");GameTooltip:SetText(STBS:L("TITLE"));GameTooltip:AddLine(STBS:L("MINIMAP_TOOLTIP"),1,1,1,true);GameTooltip:AddLine(STBS:L("RIGHT_CLICK_PROFILES"),0.55,0.8,0.9,true);GameTooltip:Show()end)
  button:SetScript("OnLeave",function()if GameTooltip then GameTooltip:Hide() end end)
  self.minimapButton=button
end
