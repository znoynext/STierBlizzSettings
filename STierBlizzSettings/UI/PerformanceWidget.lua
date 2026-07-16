local _, STBS = ...

local function lerp(a,b,t) return a+(b-a)*math.max(0,math.min(1,t)) end
local function fpsColor(value)
  if value<=25 then return 1,0.24,0.2 end
  if value<45 then local t=(value-25)/20;return 1,lerp(0.24,0.82,t),0.2 end
  if value<60 then local t=(value-45)/15;return lerp(1,0.24,t),lerp(0.82,1,t),lerp(0.2,0.42,t) end
  return 0.24,1,0.42
end
local function latencyColor(value)
  if value<=50 then return 0.24,1,0.42 end
  if value<120 then local t=(value-50)/70;return lerp(0.24,1,t),1,lerp(0.42,0.2,t) end
  if value<250 then local t=(value-120)/130;return 1,lerp(1,0.24,t),0.2 end
  return 1,0.24,0.2
end

function STBS:CreatePerformanceWidget()
  if self.performanceWidget then return self.performanceWidget end
  local f=CreateFrame("Frame","STierBlizzSettingsPerformanceWidget",UIParent,"BackdropTemplate")
  f:SetSize(236,34);f:SetPoint("BOTTOM",UIParent,"BOTTOM",0,156);f:SetFrameStrata("MEDIUM");f:EnableMouse(true)
  f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=10,insets={left=3,right=3,top=3,bottom=3}});f:SetBackdropColor(0.025,0.02,0.012,0.9);f:SetBackdropBorderColor(0.66,0.48,0.18,0.9)
  f.fps=f:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.fps:SetPoint("LEFT",14,0);f.fps:SetWidth(92);f.fps:SetJustifyH("LEFT")
  f.divider=f:CreateTexture(nil,"ARTWORK");f.divider:SetColorTexture(0.55,0.42,0.22,0.7);f.divider:SetSize(1,18);f.divider:SetPoint("CENTER",0,0)
  f.ping=f:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.ping:SetPoint("LEFT",128,0);f.ping:SetWidth(94);f.ping:SetJustifyH("LEFT")
  f:SetScript("OnEnter",function(self)GameTooltip:SetOwner(self,"ANCHOR_TOP");GameTooltip:SetText(STBS:L("PERFORMANCE_WIDGET"));GameTooltip:AddLine(STBS:L("PERFORMANCE_WIDGET_HELP"),0.85,0.82,0.72,true);GameTooltip:Show()end)
  f:SetScript("OnLeave",function()GameTooltip:Hide()end);f:Hide();self.performanceWidget=f;return f
end

function STBS:UpdatePerformanceWidget()
  local f=self.performanceWidget;if not f or not f:IsShown() then return end
  local snapshot=self:GetPerformanceSnapshot();local fps,ping=snapshot.fps,snapshot.ping
  local fr,fg,fb=fpsColor(fps);local pr,pg,pb=latencyColor(ping)
  f.fps:SetText(string.format(self:L("WIDGET_FPS_FORMAT"),math.floor(fps+0.5)));f.fps:SetTextColor(fr,fg,fb)
  f.ping:SetText(string.format(self:L("WIDGET_PING_FORMAT"),math.floor(ping+0.5)));f.ping:SetTextColor(pr,pg,pb)
end

function STBS:GetPerformanceSnapshot()
  local fps=self:ReadFramerate() or 0;local home,world=0,0
  if type(_G.GetNetStats)=="function" then local ok,bandwidthIn,bandwidthOut,a,b=pcall(_G.GetNetStats);if ok then home=tonumber(a) or 0;world=tonumber(b) or 0 end end
  return {fps=fps,home=home,world=world,ping=math.max(home,world)}
end

function STBS:SetPerformanceWidgetEnabled(enabled)
  local value=enabled==true;self:InitializeDatabase().preferences.performanceWidgetEnabled=value
  local f=self:CreatePerformanceWidget()
  if self.performanceWidgetTicker and self.performanceWidgetTicker.Cancel then self.performanceWidgetTicker:Cancel() end;self.performanceWidgetTicker=nil
  if value then
    f:SetAlpha(0);f:Show();if type(_G.UIFrameFadeIn)=="function" then UIFrameFadeIn(f,0.18,0,1)else f:SetAlpha(1)end;self:UpdatePerformanceWidget()
    if C_Timer and type(C_Timer.NewTicker)=="function" then self.performanceWidgetTicker=C_Timer.NewTicker(0.5,function()STBS:UpdatePerformanceWidget()end) end
  else if type(_G.UIFrameFadeOut)=="function" then UIFrameFadeOut(f,0.14,f:GetAlpha(),0)end;if C_Timer and type(C_Timer.After)=="function" then C_Timer.After(0.15,function()if not STBS:InitializeDatabase().preferences.performanceWidgetEnabled then f:Hide() end end)else f:Hide()end end
  return value
end

function STBS:InitializePerformanceWidget()
  if self:InitializeDatabase().preferences.performanceWidgetEnabled then self:SetPerformanceWidgetEnabled(true) end
end
