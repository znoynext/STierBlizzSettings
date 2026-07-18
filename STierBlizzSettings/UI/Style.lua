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
