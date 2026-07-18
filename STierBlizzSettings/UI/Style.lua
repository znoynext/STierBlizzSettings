local _, STBS = ...

local WHITE = "Interface\\Buttons\\WHITE8X8"
local PALETTES = {
  default={background={0.045,0.05,0.055,0.98},border={0.31,0.29,0.24,1},text={0.92,0.86,0.72}},
  primary={background={0.14,0.095,0.018,0.98},border={0.72,0.5,0.12,1},text={1,0.82,0.18}},
  danger={background={0.17,0.025,0.018,0.98},border={0.62,0.16,0.1,1},text={1,0.78,0.48}},
}
local ACTIVE_BACKGROUND={0.085,0.073,0.035,0.99}
local ACTIVE_BORDER={0.95,0.68,0.12,1}
local ACTIVE_TEXT={1,0.82,0.18}

local function setColor(target,method,color)
  target[method](target,color[1],color[2],color[3],color[4] or 1)
end

function STBS:CreateModernButton(parent,text,width,height,callback,style)
  local palette=PALETTES[style] or PALETTES.default
  local button=CreateFrame("Button",nil,parent,"BackdropTemplate");button:SetSize(width or 200,height or 34);button:RegisterForClicks("LeftButtonUp")
  button:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1,insets={left=1,right=1,top=1,bottom=1}})
  button.label=button:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");button.label:SetPoint("CENTER",0,0);button.label:SetJustifyH("CENTER");button.label:SetText(text or "")
  button.accent=button:CreateTexture(nil,"ARTWORK");button.accent:SetColorTexture(1,0.72,0.1,1);button.accent:SetPoint("TOPLEFT",1,-1);button.accent:SetPoint("BOTTOMLEFT",1,1);button.accent:SetWidth(3);button.accent:Hide()
  button.hover=button:CreateTexture(nil,"ARTWORK");button.hover:SetAllPoints(button);button.hover:SetColorTexture(1,0.76,0.2,0.1);button.hover:SetAlpha(0)
  button.pressed=button:CreateTexture(nil,"ARTWORK");button.pressed:SetAllPoints(button);button.pressed:SetColorTexture(0,0,0,0.22);button.pressed:Hide()
  local hoverIn=button.hover:CreateAnimationGroup();hoverIn:SetToFinalAlpha(true);local hoverInAlpha=hoverIn:CreateAnimation("Alpha");hoverInAlpha:SetFromAlpha(0);hoverInAlpha:SetToAlpha(1);hoverInAlpha:SetDuration(0.12);hoverInAlpha:SetSmoothing("OUT")
  local hoverOut=button.hover:CreateAnimationGroup();hoverOut:SetToFinalAlpha(true);local hoverOutAlpha=hoverOut:CreateAnimation("Alpha");hoverOutAlpha:SetFromAlpha(1);hoverOutAlpha:SetToAlpha(0);hoverOutAlpha:SetDuration(0.12);hoverOutAlpha:SetSmoothing("OUT")
  function button:RefreshVisual(hovered)
    local active=self.active==true;setColor(self,"SetBackdropColor",active and ACTIVE_BACKGROUND or palette.background);setColor(self,"SetBackdropBorderColor",active and ACTIVE_BORDER or palette.border);setColor(self.label,"SetTextColor",active and ACTIVE_TEXT or palette.text)
    if active then self.accent:Show() else self.accent:Hide() end
    if hovered and not self.disabled then self:SetBackdropBorderColor(0.82,0.59,0.16,1) end
  end
  function button:SetText(value)self.label:SetText(value or "")end
  function button:GetText()return self.label:GetText()end
  function button:GetFontString()return self.label end
  function button:SetActive(active)self.active=active==true;self:RefreshVisual(self.hovered)end
  function button:SetDisabled(disabled)self.disabled=disabled==true;self.hovered=false;hoverIn:Stop();hoverOut:Stop();self.hover:SetAlpha(0);self:SetEnabled(not self.disabled);self:SetAlpha(self.disabled and 0.42 or 1);self.pressed:Hide();self:RefreshVisual(false)end
  button:SetScript("OnClick",callback or function()end)
  button:SetScript("OnEnter",function(self)if self.disabled then return end;self.hovered=true;hoverOut:Stop();hoverIn:Stop();hoverIn:Play();self:RefreshVisual(true)end)
  button:SetScript("OnLeave",function(self)self.hovered=false;hoverIn:Stop();hoverOut:Stop();hoverOut:Play();self.pressed:Hide();self:RefreshVisual(false)end)
  button:SetScript("OnMouseDown",function(self,mouseButton)if mouseButton=="LeftButton" and not self.disabled then self.pressed:Show()end end)
  button:SetScript("OnMouseUp",function(self)self.pressed:Hide()end)
  button:RefreshVisual(false);return button
end

function STBS:CreateModernCheckBox(parent,checked,callback)
  local checkbox=CreateFrame("CheckButton",nil,parent,"BackdropTemplate");checkbox:SetSize(24,24);checkbox:RegisterForClicks("LeftButtonUp")
  checkbox:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1,insets={left=1,right=1,top=1,bottom=1}})
  checkbox.checkedFill=checkbox:CreateTexture(nil,"ARTWORK");checkbox.checkedFill:SetPoint("TOPLEFT",3,-3);checkbox.checkedFill:SetPoint("BOTTOMRIGHT",-3,3);checkbox.checkedFill:SetColorTexture(0.34,0.24,0.055,0.9)
  checkbox.hover=checkbox:CreateTexture(nil,"ARTWORK");checkbox.hover:SetPoint("TOPLEFT",1,-1);checkbox.hover:SetPoint("BOTTOMRIGHT",-1,1);checkbox.hover:SetColorTexture(1,0.76,0.2,0.12);checkbox.hover:SetAlpha(0)
  checkbox.mark=checkbox:CreateTexture(nil,"OVERLAY");checkbox.mark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check");checkbox.mark:SetPoint("CENTER",0,0);checkbox.mark:SetSize(22,22);checkbox.mark:SetVertexColor(1,0.82,0.18,1)
  checkbox.pressed=checkbox:CreateTexture(nil,"OVERLAY");checkbox.pressed:SetPoint("TOPLEFT",1,-1);checkbox.pressed:SetPoint("BOTTOMRIGHT",-1,1);checkbox.pressed:SetColorTexture(0,0,0,0.22);checkbox.pressed:Hide()
  local hoverIn=checkbox.hover:CreateAnimationGroup();hoverIn:SetToFinalAlpha(true);local hoverInAlpha=hoverIn:CreateAnimation("Alpha");hoverInAlpha:SetFromAlpha(0);hoverInAlpha:SetToAlpha(1);hoverInAlpha:SetDuration(0.12);hoverInAlpha:SetSmoothing("OUT")
  local hoverOut=checkbox.hover:CreateAnimationGroup();hoverOut:SetToFinalAlpha(true);local hoverOutAlpha=hoverOut:CreateAnimation("Alpha");hoverOutAlpha:SetFromAlpha(1);hoverOutAlpha:SetToAlpha(0);hoverOutAlpha:SetDuration(0.12);hoverOutAlpha:SetSmoothing("OUT")
  local nativeSetChecked=checkbox.SetChecked
  function checkbox:RefreshVisual(hovered)
    local active=self:GetChecked()==true
    setColor(self,"SetBackdropColor",active and ACTIVE_BACKGROUND or PALETTES.default.background)
    setColor(self,"SetBackdropBorderColor",active and ACTIVE_BORDER or PALETTES.default.border)
    if active then self.checkedFill:Show();self.mark:Show() else self.checkedFill:Hide();self.mark:Hide() end
    if hovered and not self.disabled then self:SetBackdropBorderColor(0.82,0.59,0.16,1) end
  end
  function checkbox:SetChecked(value)nativeSetChecked(self,value==true);self:RefreshVisual(self.hovered)end
  function checkbox:SetDisabled(disabled)
    self.disabled=disabled==true;self.hovered=false;hoverIn:Stop();hoverOut:Stop();self.hover:SetAlpha(0);self:SetEnabled(not self.disabled);self.pressed:Hide();self:RefreshVisual(false)
  end
  checkbox:SetScript("OnClick",function(self)self:RefreshVisual(self.hovered);if callback then callback(self:GetChecked()==true)end end)
  checkbox:SetScript("OnEnter",function(self)if self.disabled then return end;self.hovered=true;hoverOut:Stop();hoverIn:Stop();hoverIn:Play();self:RefreshVisual(true)end)
  checkbox:SetScript("OnLeave",function(self)self.hovered=false;hoverIn:Stop();hoverOut:Stop();hoverOut:Play();self.pressed:Hide();self:RefreshVisual(false)end)
  checkbox:SetScript("OnMouseDown",function(self,mouseButton)if mouseButton=="LeftButton" and not self.disabled then self.pressed:Show()end end)
  checkbox:SetScript("OnMouseUp",function(self)self.pressed:Hide()end)
  checkbox:SetChecked(checked==true);return checkbox
end
