local _, STBS = ...

local ASSET = "Interface\\AddOns\\STierBlizzSettings\\Assets\\"
local categoryNames={graphics="BASE_GRAPHICS",raidGraphics="RAID_GRAPHICS"}
local categoryOrder={"graphics","raidGraphics"}
local MIN_WINDOW_WIDTH,MIN_WINDOW_HEIGHT=900,640
local DEFAULT_WINDOW_WIDTH,DEFAULT_WINDOW_HEIGHT=1080,760

local function popupEditBox(dialog)
  if dialog and type(dialog.GetEditBox)=="function" then return dialog:GetEditBox() end
  return dialog and (dialog.editBox or dialog.EditBox)
end

local function popupAcceptOnEnter(editBox)
  local dialog=editBox and editBox:GetParent()
  local accept=dialog and type(dialog.GetButton1)=="function" and dialog:GetButton1()
  if accept then accept:Click() end
end

local function button(parent,text,x,y,width,callback,style)
  local b=STBS:CreateModernButton(parent,text,width or 200,34,callback,style);b:SetPoint("TOPLEFT",x,y)
  return b
end

local function checkBox(parent,text,callback,checked)
  local row=CreateFrame("Button",nil,parent);row:SetSize(200,34);row:SetPoint("TOPLEFT",0,0);row:RegisterForClicks("LeftButtonUp");row.isCheckBox=true
  row.check=CreateFrame("CheckButton",nil,row,"UICheckButtonTemplate");row.check:SetSize(24,24);row.check:SetPoint("RIGHT",-2,0);row.check:SetChecked(checked==true)
  row.label=row:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");row.label:SetPoint("LEFT",4,0);row.label:SetPoint("RIGHT",row.check,"LEFT",-10,0);row.label:SetJustifyH("LEFT");row.label:SetText(text);row.label:SetTextColor(1,0.82,0)
  row.check:SetScript("OnClick",function(self)callback(self:GetChecked()==true)end)
  row:SetScript("OnClick",function(self)local value=not self.check:GetChecked();self.check:SetChecked(value);callback(value)end)
  row:SetScript("OnEnter",function(self)self.label:SetTextColor(1,0.9,0.35)end);row:SetScript("OnLeave",function(self)self.label:SetTextColor(1,0.82,0)end)
  function row:SetChecked(value)self.check:SetChecked(value==true)end
  function row:GetChecked()return self.check:GetChecked()end
  function row:SetActive()end
  function row:SetDisabled(disabled)self.disabled=disabled;self:SetEnabled(not disabled);self.check:SetEnabled(not disabled);self:SetAlpha(disabled and 0.42 or 1)end
  return row
end

local function addTooltip(frame,title,description)
  if not frame or not description then return end
  frame:HookScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText(title,1,0.82,0);GameTooltip:AddLine(description,1,1,1,true);GameTooltip:Show()
  end)
  frame:HookScript("OnLeave",function()GameTooltip:Hide()end)
end

local function sectionLabel(parent,text)
  local row=CreateFrame("Frame",nil,parent);row:SetSize(200,28)
  row.label=row:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");row.label:SetPoint("LEFT",3,0);row.label:SetPoint("RIGHT",-3,0);row.label:SetJustifyH("LEFT");row.label:SetText(text);row.label:SetTextColor(0.4,0.82,1)
  function row:SetDisabled()end
  function row:SetActive()end
  return row
end

local function sliderRow(parent,text,minimum,maximum,step,value,callback,formatter)
  local row=CreateFrame("Frame",nil,parent);row:SetSize(200,58)
  row.label=row:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");row.label:SetPoint("TOPLEFT",4,-2);row.label:SetPoint("TOPRIGHT",-68,-2);row.label:SetJustifyH("LEFT");row.label:SetText(text);row.label:SetTextColor(1,0.82,0)
  row.value=row:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge");row.value:SetPoint("TOPRIGHT",-5,-2);row.value:SetJustifyH("RIGHT")
  row.slider=CreateFrame("Frame",nil,row,"MinimalSliderWithSteppersTemplate");row.slider:SetPoint("BOTTOMLEFT",4,0);row.slider:SetPoint("BOTTOMRIGHT",-4,0);row.slider:SetHeight(34)
  local function format(number)return formatter and formatter(number) or tostring(number)end
  row.slider:Init(value,minimum,maximum,(maximum-minimum)/step,nil);row.value:SetText(format(value))
  row.slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged,function(_,number)
    local rounded=math.floor((number/step)+0.5)*step;row.value:SetText(format(rounded));callback(rounded)
  end,row)
  function row:SetDisabled(disabled)self.disabled=disabled;self.slider:SetEnabled(not disabled);self:SetAlpha(disabled and 0.42 or 1)end
  function row:SetActive()end
  return row
end

local function navButton(parent,text,icon,y,pageKey,callback)
  local b=button(parent,text,14,y,170,callback);b:SetSize(170,44);b.pageKey=pageKey
  b.label:ClearAllPoints();b.label:SetPoint("LEFT",44,0);b.label:SetJustifyH("LEFT");b.label:SetFontObject(GameFontNormalLarge)
  b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetTexture(icon);b.icon:SetSize(24,24);b.icon:SetPoint("LEFT",12,0)
  return b
end

local function panelTab(parent,text,callback)
  local tab=STBS:CreateModernButton(parent,text,180,32,function()if type(_G.PlaySound)=="function" and _G.SOUNDKIT and _G.SOUNDKIT.IG_CHARACTER_INFO_TAB then _G.PlaySound(_G.SOUNDKIT.IG_CHARACTER_INFO_TAB)end;callback()end)
  tab.label:SetFontObject(GameFontNormal);tab:SetWidth(math.max(150,math.min(235,tab.label:GetStringWidth()+38)));tab.accent:ClearAllPoints();tab.accent:SetPoint("BOTTOMLEFT",1,1);tab.accent:SetPoint("BOTTOMRIGHT",-1,1);tab.accent:SetHeight(3)
  return tab
end

local function setPanelTabActive(tab,active)
  tab:SetActive(active)
end

local function resultSummary(data)
  data=data or {}
  local lines={"|cff35e6ad"..STBS:L("CHANGED")..":|r "..(data.changed or 0),STBS:L("IDENTICAL")..": "..(data.identical or 0),STBS:L("SKIPPED")..": "..(data.skipped or 0),"|cffffd36b"..STBS:L("UNAVAILABLE")..":|r "..(data.unavailable or 0),"|cffff6666"..STBS:L("FAILED")..":|r "..(data.failed or 0)}
  for _,category in ipairs(categoryOrder) do
    local values=(data.categories or {})[category]
    if values then table.insert(lines,"\n|cff65cfff"..STBS:L(categoryNames[category])..":|r "..STBS:L("CHANGED").." "..(values.changed or 0)..", "..STBS:L("SKIPPED").." "..(values.skipped or 0)..", "..STBS:L("UNAVAILABLE").." "..(values.unavailable or 0)) end
  end
  return table.concat(lines,"\n")
end

local function clamp(value,minimum,maximum)return math.max(minimum,math.min(maximum,value))end

local function updateSmoothProgress(bar,elapsed)
  local current=bar.displayValue or 0;local target=bar.targetValue or current;local difference=target-current
  if math.abs(difference)<0.002 then current=target else current=current+difference*math.min(1,(tonumber(elapsed) or 0)*10) end
  bar.displayValue=current;bar:SetValue(current);if bar.spark then bar.spark:SetAlpha(current>0 and current<(bar.maximum or 1) and 0.32 or 0) end
end

local function layoutActionButtons(f)
  local available=math.max(360,math.floor(f.actionContent:GetWidth()+0.5));local row,col,columns=0,0,2
  for _,created in ipairs(f.pageButtons) do
    local action=created.action;local wantedColumns=action.third and (available>=660 and 3 or available>=460 and 2 or 1) or (available>=540 and 2 or 1)
    if action.kind=="section" or action.kind=="slider" then
      if col>0 then row=row+1;col=0 end
      created:ClearAllPoints();created:SetPoint("TOPLEFT",0,-row*40);created:SetSize(available,action.kind=="slider" and 58 or 28);row=row+(action.kind=="slider" and 2 or 1);columns=2
    else
    if (action.wide or wantedColumns~=columns) and col>0 then row=row+1;col=0 end
    columns=wantedColumns
    local gap=action.third and 10 or 12;local width=action.wide and available or math.floor((available-gap*(columns-1))/columns);local x=action.wide and 0 or col*(width+gap)
    created:ClearAllPoints();created:SetPoint("TOPLEFT",x,-row*40);created:SetSize(width,34)
    if action.wide then row=row+1;col=0 else col=col+1;if col==columns then row=row+1;col=0 end end
    end
  end
  if col>0 then row=row+1 end
  f.actionRows=row;f.actionContent:SetHeight(math.max(1,row*40));return row
end

local function layoutFPSDashboard(f,width)
  local available=math.max(320,width-19);local columns=available>=650 and 4 or 2;local gap=10;local cardHeight=104;local cardWidth=math.floor((available-gap*(columns-1))/columns);local rows=math.ceil(#f.fpsDashboardCards/columns)
  f.fpsDashboard:SetSize(available,rows*cardHeight+(rows-1)*gap)
  for index,card in ipairs(f.fpsDashboardCards) do local row=math.floor((index-1)/columns);local column=(index-1)%columns;card:ClearAllPoints();card:SetPoint("TOPLEFT",column*(cardWidth+gap),-row*(cardHeight+gap));card:SetSize(cardWidth,cardHeight) end
  f.fpsDashboardLegend:ClearAllPoints();f.fpsDashboardLegend:SetPoint("TOPLEFT",f.fpsDashboard,"BOTTOMLEFT",2,-7);f.fpsDashboardLegend:SetPoint("TOPRIGHT",f.fpsDashboard,"BOTTOMRIGHT",-2,-7)
end

function STBS:LayoutUI()
  local f=self.ui;if not f then return end
  local panelWidth=math.max(440,math.floor(f.panel:GetWidth()+0.5));local panelHeight=math.max(448,math.floor(f.panel:GetHeight()+0.5));local contentWidth=math.max(360,panelWidth-76)
  f.status:SetWidth(panelWidth-60);f.content:SetWidth(contentWidth);f.actionContent:SetWidth(contentWidth)
  local tabWidth=math.floor(math.min(478,panelWidth-44)/2)-4;f.graphicsSettingsTab:SetWidth(tabWidth);f.zoneGraphicsTab:SetWidth(tabWidth)
  f.body:SetWidth(contentWidth-19);f.metricCard:SetWidth(contentWidth-19);f.metricSub:SetWidth(contentWidth-50)
  if f.fpsDashboard:IsShown() then layoutFPSDashboard(f,contentWidth);f.bodyY=-(f.fpsDashboard:GetHeight()+(f.fpsDashboardLegend:IsShown() and 38 or 16));f.body:ClearAllPoints();f.body:SetPoint("TOPLEFT",7,f.bodyY) end
  if f.copyBox then f.copyBox:SetWidth(contentWidth-19);f.copyBox:SetHeight(math.max(120,(f.scroll:GetHeight() or 200)-18)) end
  layoutActionButtons(f)
  local contentTop=f.graphicsTabsVisible and 112 or 76;local availableHeight=panelHeight-contentTop-18
  f.scroll:ClearAllPoints();f.scroll:SetPoint("TOPLEFT",18,-contentTop);f.scroll:SetPoint("TOPRIGHT",-27,-contentTop)
  if f.hasActions then
    local actionCap=f.currentPageKey=="uiTweaks" and 360 or 240;local contentReserve=f.currentPageKey=="uiTweaks" and 180 or 220
    local desired=math.max(82,(f.actionRows or 0)*40);local actionHeight=math.min(desired,math.max(122,math.min(actionCap,availableHeight-contentReserve)))
    local scrollHeight=math.max(180,availableHeight-actionHeight-20)
    f.scroll:SetHeight(scrollHeight)
    f.rule:ClearAllPoints();f.rule:SetPoint("TOPLEFT",22,-(contentTop+scrollHeight+10));f.rule:SetPoint("TOPRIGHT",-26,-(contentTop+scrollHeight+10));f.rule:Show()
    f.actionScroll:ClearAllPoints();f.actionScroll:SetPoint("TOPLEFT",18,-(contentTop+scrollHeight+20));f.actionScroll:SetPoint("BOTTOMRIGHT",-27,18);f.actionScroll:Show()
  else
    f.scroll:SetPoint("BOTTOMRIGHT",-27,18);f.rule:Hide();f.actionScroll:Hide()
  end
  local bodyHeight=f.body:GetStringHeight() or 0;local required=-(f.bodyY or -6)+bodyHeight+20
  if f.copyBox and f.copyBox:IsShown() then required=math.max(required,f.copyBox:GetHeight()+16) end
  f.content:SetHeight(math.max(f.scroll:GetHeight(),required));f.scroll:SetVerticalScroll(0);f.actionScroll:SetVerticalScroll(0)
end

function STBS:SaveWindowSize()
  if not self.ui then return end
  local db=self:InitializeDatabase();db.preferences.windowWidth=math.floor(self.ui:GetWidth()+0.5);db.preferences.windowHeight=math.floor(self.ui:GetHeight()+0.5)
end

function STBS:CreateUI()
  if self.ui then return end
  local f=CreateFrame("Frame","STierBlizzSettingsFrame",UIParent,"BackdropTemplate")
  local screenWidth,screenHeight=UIParent:GetWidth(),UIParent:GetHeight();local maxWidth=math.max(760,math.min(1280,screenWidth-24));local maxHeight=math.max(560,math.min(900,screenHeight-24));local minWidth=math.min(MIN_WINDOW_WIDTH,maxWidth);local minHeight=math.min(MIN_WINDOW_HEIGHT,maxHeight)
  local preferences=self:InitializeDatabase().preferences;local width=clamp(preferences.windowWidth or DEFAULT_WINDOW_WIDTH,minWidth,maxWidth);local height=clamp(preferences.windowHeight or DEFAULT_WINDOW_HEIGHT,minHeight,maxHeight)
  f:SetSize(width,height);f:SetPoint("CENTER",UIParent,"CENTER",0,0);f:SetMovable(true);f:SetResizable(true);f:SetResizeBounds(minWidth,minHeight,maxWidth,maxHeight);f:SetClampedToScreen(false);f:EnableMouse(true);f:Hide()
  f:SetBackdrop({bgFile="Interface\\FrameGeneral\\UI-Background-Rock",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=256,edgeSize=32,insets={left=11,right=12,top=12,bottom=11}});f:SetBackdropColor(0.42,0.42,0.42,1);f:SetBackdropBorderColor(1,1,1,1)
  local fade=f:CreateAnimationGroup();fade:SetToFinalAlpha(true);local alpha=fade:CreateAnimation("Alpha");alpha:SetFromAlpha(0);alpha:SetToAlpha(1);alpha:SetDuration(0.18);alpha:SetSmoothing("OUT");f.fade=fade
  f:SetScript("OnShow",function(self)self:SetAlpha(1);self.fade:Stop();self.fade:Play();STBS:RefreshCurrentPresetLabel()end)
  f:SetScript("OnHide",function()STBS:SetLiveFPSCallback(nil);STBS:StopFPSBaselineSampling()end)

  local top=CreateFrame("Frame",nil,f,"BackdropTemplate");top:SetPoint("TOPLEFT",18,-18);top:SetPoint("TOPRIGHT",-18,-18);top:SetHeight(62);top:EnableMouse(true);top:RegisterForDrag("LeftButton");top:SetScript("OnDragStart",function()f:StartMoving()end);top:SetScript("OnDragStop",function()f:StopMovingOrSizing()end);top:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});top:SetBackdropColor(0.05,0.04,0.025,0.98);top:SetBackdropBorderColor(0.72,0.52,0.2,1)
  f.logo=top:CreateTexture(nil,"ARTWORK");f.logo:SetTexture(ASSET.."STierIcon");f.logo:SetSize(48,48);f.logo:SetPoint("LEFT",12,0)
  f.title=top:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.title:SetPoint("LEFT",68,8);f.title:SetText(self:L("TITLE"));f.title:SetTextColor(1,0.82,0)
  f.version=top:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");f.version:SetPoint("LEFT",69,-15);f.version:SetText("v"..self.VERSION);f.version:SetTextColor(0.68,0.62,0.5)
  f.currentPreset=top:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");f.currentPreset:SetPoint("LEFT",f.version,"RIGHT",18,0);f.currentPreset:SetPoint("RIGHT",top,"RIGHT",-48,-15);f.currentPreset:SetJustifyH("LEFT");f.currentPreset:SetTextColor(0.82,0.72,0.48)
  local close=CreateFrame("Button",nil,f,"UIPanelCloseButton");close:SetPoint("TOPRIGHT",3,3)

  local side=CreateFrame("Frame",nil,f,"BackdropTemplate");side:SetPoint("TOPLEFT",18,-92);side:SetPoint("BOTTOMLEFT",18,20);side:SetWidth(194);side:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});side:SetBackdropColor(0.035,0.028,0.018,0.98);side:SetBackdropBorderColor(0.52,0.4,0.2,0.95)
  local panel=CreateFrame("Frame",nil,f,"BackdropTemplate");panel:SetPoint("TOPLEFT",222,-92);panel:SetPoint("BOTTOMRIGHT",-18,20);panel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});panel:SetBackdropColor(0.035,0.028,0.018,0.98);panel:SetBackdropBorderColor(0.52,0.4,0.2,0.95);f.panel=panel

  f.header=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.header:SetPoint("TOPLEFT",22,-20);f.header:SetTextColor(1,0.82,0)
  f.status=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge");f.status:SetPoint("TOPLEFT",24,-50);f.status:SetWidth(660);f.status:SetJustifyH("LEFT");f.status:SetTextColor(0.78,0.72,0.58)
  f.graphicsTabBar=CreateFrame("Frame",nil,panel);f.graphicsTabBar:SetPoint("TOPLEFT",panel,"TOPLEFT",22,-10);f.graphicsTabBar:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-22,-10);f.graphicsTabBar:SetHeight(32);f.graphicsTabBar:Hide()
  f.graphicsSettingsTab=panelTab(f.graphicsTabBar,self:L("GRAPHICS_SETTINGS_TAB"),function()STBS:ShowGraphics()end);f.graphicsSettingsTab:SetPoint("TOPLEFT",f.graphicsTabBar,"TOPLEFT",0,0)
  f.zoneGraphicsTab=panelTab(f.graphicsTabBar,self:L("ZONE_SWITCHER_TAB"),function()STBS:ShowZoneGraphics()end);f.zoneGraphicsTab:SetPoint("TOPLEFT",f.graphicsSettingsTab,"TOPRIGHT",8,0)
  local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate");scroll:SetPoint("TOPLEFT",18,-76)
  local content=CreateFrame("Frame",nil,scroll);content:SetHeight(350);scroll:SetScrollChild(content);f.scroll,f.content=scroll,content
  local pageFade=content:CreateAnimationGroup();pageFade:SetToFinalAlpha(true);local pageAlpha=pageFade:CreateAnimation("Alpha");pageAlpha:SetFromAlpha(0.35);pageAlpha:SetToAlpha(1);pageAlpha:SetDuration(0.16);pageAlpha:SetSmoothing("OUT");f.pageFade=pageFade
  f.metricCard=CreateFrame("Frame",nil,content,"BackdropTemplate");f.metricCard:SetHeight(94);f.metricCard:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});f.metricCard:SetBackdropColor(0.045,0.038,0.022,0.98);f.metricCard:SetBackdropBorderColor(0.72,0.52,0.2,1);f.metricCard:Hide()
  f.metricTitle=f.metricCard:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.metricTitle:SetPoint("TOPLEFT",14,-12);f.metricTitle:SetText(self:L("LIVE_FPS"));f.metricTitle:SetTextColor(1,0.82,0)
  f.metricValue=f.metricCard:CreateFontString(nil,"OVERLAY","GameFontNormalHuge2");f.metricValue:SetPoint("TOPRIGHT",-16,-14);f.metricValue:SetTextColor(0.45,1,0.72)
  f.metricSub=f.metricCard:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge");f.metricSub:SetPoint("BOTTOMLEFT",14,14);f.metricSub:SetJustifyH("LEFT");f.metricSub:SetTextColor(0.82,0.82,0.75)
  f.fpsDashboard=CreateFrame("Frame",nil,content);f.fpsDashboard:SetPoint("TOPLEFT",5,-2);f.fpsDashboard:Hide();f.fpsDashboardCards={}
  for index=1,4 do local card=CreateFrame("Frame",nil,f.fpsDashboard,"BackdropTemplate");card:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});card:SetBackdropColor(0.045,0.038,0.022,0.98);card:SetBackdropBorderColor(0.58,0.43,0.2,0.95);card.title=card:CreateFontString(nil,"OVERLAY","GameFontNormal");card.title:SetPoint("TOPLEFT",12,-11);card.title:SetPoint("TOPRIGHT",-10,-11);card.title:SetJustifyH("LEFT");card.title:SetTextColor(1,0.82,0);card.value=card:CreateFontString(nil,"OVERLAY","GameFontNormalHuge2");card.value:SetJustifyH("LEFT");card.subtitle=card:CreateFontString(nil,"OVERLAY","GameFontHighlight");card.subtitle:SetPoint("BOTTOMLEFT",12,10);card.subtitle:SetPoint("BOTTOMRIGHT",-10,10);card.subtitle:SetJustifyH("LEFT");card.subtitle:SetWordWrap(false);f.fpsDashboardCards[index]=card end
  f.fpsDashboardLegend=content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");f.fpsDashboardLegend:SetJustifyH("CENTER");f.fpsDashboardLegend:SetTextColor(0.72,0.68,0.58);f.fpsDashboardLegend:Hide()
  f.body=content:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge");f.body:SetJustifyH("LEFT");f.body:SetJustifyV("TOP");f.body:SetSpacing(6)

  local rule=panel:CreateTexture(nil,"ARTWORK");rule:SetColorTexture(0.55,0.4,0.18,0.75);rule:SetHeight(1);f.rule=rule
  local actionScroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
  local actionContent=CreateFrame("Frame",nil,actionScroll);actionContent:SetHeight(82);actionScroll:SetScrollChild(actionContent);f.actionScroll,f.actionContent=actionScroll,actionContent
  f.pageButtons={};f.navButtons={};self.ui=f
  table.insert(f.navButtons,navButton(side,self:L("GRAPHICS"),"Interface\\Icons\\INV_Misc_EngGizmos_30",-16,"graphics",function()STBS:ShowGraphics()end))
  table.insert(f.navButtons,navButton(side,self:L("UI_TWEAKS"),"Interface\\Icons\\INV_Gizmo_02",-68,"uiTweaks",function()STBS:ShowUITweaks()end))
  table.insert(f.navButtons,navButton(side,self:L("FPS_TEST"),"Interface\\Icons\\INV_Misc_PocketWatch_01",-120,"fpsTest",function()STBS:ShowFPSTest()end))
  table.insert(f.navButtons,navButton(side,self:L("PROFILES"),"Interface\\Icons\\INV_Misc_Book_09",-172,"profiles",function()STBS:ShowProfiles()end))
  table.insert(f.navButtons,navButton(side,self:L("ABOUT"),"Interface\\Icons\\INV_Misc_Note_05",-224,"about",function()STBS:ShowAbout()end))
  local resize=CreateFrame("Button",nil,f);resize:SetSize(22,22);resize:SetPoint("BOTTOMRIGHT",-13,12);resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up");resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight");resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  resize:SetScript("OnMouseDown",function(_,mouseButton)if mouseButton=="LeftButton" then f:StartSizing("BOTTOMRIGHT",true)end end);resize:SetScript("OnMouseUp",function()f:StopMovingOrSizing();STBS:SaveWindowSize();STBS:LayoutUI()end)
  resize:SetScript("OnEnter",function(self)GameTooltip:SetOwner(self,"ANCHOR_TOPLEFT");GameTooltip:SetText(STBS:L("RESIZE_WINDOW"));GameTooltip:Show()end);resize:SetScript("OnLeave",function()GameTooltip:Hide()end);f.resize=resize
  f:SetScript("OnSizeChanged",function()STBS:LayoutUI()end);self:LayoutUI()
end

function STBS:RefreshCurrentPresetLabel()
  local label=self.ui and self.ui.currentPreset;if not label then return end
  local preset=self:GetCurrentGraphicsPreset();label:SetText(string.format(self:L("CURRENT_PRESET"),preset and self:GetPresetLabel(preset) or self:L("PRESET_CUSTOM")))
end

function STBS:CreateFPSTestModal()
  if self.fpsTestModal then return self.fpsTestModal end
  local shade=CreateFrame("Frame","STierBlizzSettingsFPSTestModal",UIParent,"BackdropTemplate");shade:SetAllPoints(UIParent);shade:SetFrameStrata("FULLSCREEN_DIALOG");shade:SetFrameLevel(90);shade:EnableMouse(true);shade:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"});shade:SetBackdropColor(0,0,0,0.58);shade:Hide()
  local dialog=CreateFrame("Frame",nil,shade,"BackdropTemplate");dialog:SetSize(520,238);dialog:SetPoint("CENTER");dialog:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",edgeSize=32,insets={left=11,right=11,top=12,bottom=11}});dialog:SetBackdropColor(0.035,0.028,0.018,0.99)
  dialog.title=dialog:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");dialog.title:SetPoint("TOP",0,-28);dialog.title:SetTextColor(1,0.82,0)
  dialog.message=dialog:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge");dialog.message:SetPoint("TOPLEFT",34,-67);dialog.message:SetPoint("TOPRIGHT",-34,-67);dialog.message:SetJustifyH("CENTER");dialog.message:SetJustifyV("TOP");dialog.message:SetSpacing(5)
  dialog.phase=dialog:CreateFontString(nil,"OVERLAY","GameFontNormal");dialog.phase:SetPoint("TOP",dialog.message,"BOTTOM",0,-15);dialog.phase:SetTextColor(0.4,0.82,1)
  dialog.progress=CreateFrame("StatusBar",nil,dialog,"BackdropTemplate");dialog.progress:SetPoint("TOPLEFT",44,-145);dialog.progress:SetPoint("TOPRIGHT",-44,-145);dialog.progress:SetHeight(19);dialog.progress:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");dialog.progress:SetStatusBarColor(0.78,0.52,0.08);dialog.progress:SetMinMaxValues(0,1);dialog.progress:SetValue(0);dialog.progress.displayValue=0;dialog.progress.targetValue=0;dialog.progress.maximum=1;dialog.progress:SetScript("OnUpdate",updateSmoothProgress);dialog.progress:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=9,insets={left=2,right=2,top=2,bottom=2}});dialog.progress:SetBackdropColor(0.025,0.02,0.015,1)
  local fill=dialog.progress:GetStatusBarTexture();fill:SetHorizTile(false);fill:SetVertTile(false);dialog.progress.spark=dialog.progress:CreateTexture(nil,"OVERLAY");dialog.progress.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");dialog.progress.spark:SetBlendMode("ADD");dialog.progress.spark:SetSize(18,29);dialog.progress.spark:SetPoint("CENTER",fill,"RIGHT",-2,0);dialog.progress.spark:SetVertexColor(1,0.82,0.3);dialog.progress.spark:SetAlpha(0)
  dialog.progressText=dialog.progress:CreateFontString(nil,"OVERLAY","GameFontHighlight");dialog.progressText:SetPoint("CENTER")
  dialog.cancel=button(dialog,self:L("FPS_TEST_CANCEL"),0,0,190,function()
    local result=STBS:CancelFPSTest();shade:Hide();STBS.flashMessage=result.code=="cancelled-restore-queued" and STBS:L("FPS_TEST_CANCELLED_QUEUED") or result.code=="cancelled-restore-failed" and STBS:L("FPS_TEST_CANCELLED_FAILED") or STBS:L("FPS_TEST_CANCELLED");STBS.flashKind=result.ok and (result.code=="cancelled" and "warning" or "error") or "error";if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="fpsTest" then STBS:ShowFPSTest() end
  end);dialog.cancel:ClearAllPoints();dialog.cancel:SetSize(190,30);dialog.cancel:SetPoint("BOTTOM",0,23)
  shade.dialog=dialog;self.fpsTestModal=shade;return shade
end

function STBS:ShowFPSTestModal(kind,preset)
  local modal=self:CreateFPSTestModal();local dialog=modal.dialog;dialog.title:SetText(kind=="comparison" and string.format(self:L("FPS_COMPARE_MODAL_TITLE"),self:GetPresetLabel(preset)) or self:L("FPS_TEST_MODAL_TITLE"));dialog.message:SetText(self:L("FPS_TEST_MODAL_HELP"));dialog.preset=preset;modal:Show();self:UpdateFPSTestModal(kind=="comparison" and "comparison-current" or "standalone",0,20,preset)
end

function STBS:UpdateFPSTestModal(phase,elapsed,duration,preset)
  local modal=self.fpsTestModal;if not modal or not modal:IsShown() then return end
  local dialog=modal.dialog;local key=phase=="comparison-current" and "FPS_COMPARE_CURRENT" or phase=="comparison-switch" and "FPS_COMPARE_SWITCH" or phase=="comparison-preset" and "FPS_COMPARE_PRESET" or phase=="comparison-restore" and "FPS_COMPARE_RESTORE" or "FPS_TEST_MODAL_PHASE"
  dialog.phase:SetText(string.format(self:L(key),self:GetPresetLabel(preset)))
  local maximum=(phase=="comparison-current" or phase=="comparison-preset") and 20 or (duration or 20);maximum=tonumber(maximum) or 20;local value=math.max(0,math.min(maximum,tonumber(elapsed) or 0));local reset=dialog.progressPhase~=phase or dialog.progressMaximum~=maximum;dialog.progressPhase=phase;dialog.progressMaximum=maximum;dialog.progress.maximum=maximum;dialog.progress:SetMinMaxValues(0,maximum);dialog.progress.targetValue=value;if reset then dialog.progress.displayValue=value;dialog.progress:SetValue(value) end;dialog.progressText:SetText(string.format(self:L("FPS_TEST_MODAL_PROGRESS"),math.floor(value+0.5),math.floor(maximum+0.5)))
end

function STBS:HideFPSTestModal() if self.fpsTestModal then self.fpsTestModal:Hide() end end

function STBS:SetPage(title,text,actions,status,options)
  self:CreateUI();local f=self.ui;options=options or {};f.currentPageKey=options.pageKey
  self:RefreshCurrentPresetLabel()
  f.pageFade:Stop();f.content:SetAlpha(1);f.pageFade:Play()
  f.header:SetText(title);f.status:SetText(status or "")
  if options.statusKind=="success" then f.status:SetTextColor(0.35,1,0.62) elseif options.statusKind=="error" then f.status:SetTextColor(1,0.35,0.3) elseif options.statusKind=="warning" then f.status:SetTextColor(1,0.78,0.24) else f.status:SetTextColor(0.78,0.72,0.58) end
  if options.statusKind and type(_G.UIFrameFadeIn)=="function" then UIFrameFadeIn(f.status,0.18,0.35,1) end
  if f.copyBox then f.copyBox:Hide() end;f.scroll:Show();f.metricCard:Hide();f.fpsDashboard:Hide();f.fpsDashboardLegend:Hide()
  local graphicsSection=options.pageKey=="graphics" and (options.graphicsSection or "settings") or nil;f.currentGraphicsSection=graphicsSection;f.graphicsTabsVisible=graphicsSection~=nil
  f.graphicsTabBar:SetShown(f.graphicsTabsVisible)
  if f.graphicsTabsVisible then setPanelTabActive(f.graphicsSettingsTab,graphicsSection=="settings");setPanelTabActive(f.zoneGraphicsTab,graphicsSection=="zones");f.header:ClearAllPoints();f.header:SetPoint("TOPLEFT",22,-55);f.status:ClearAllPoints();f.status:SetPoint("TOPLEFT",24,-82)
  else f.header:ClearAllPoints();f.header:SetPoint("TOPLEFT",22,-20);f.status:ClearAllPoints();f.status:SetPoint("TOPLEFT",24,-50) end
  local bodyY=-6
  if options.metric then
    f.metricCard:ClearAllPoints();f.metricCard:SetPoint("TOPLEFT",5,-2);f.metricCard:Show();bodyY=-110
    f.metricValue:SetText(self:L("FPS_READING"));f.metricSub:SetText(options.metricText or self:L("FPS_UNAVAILABLE"));f.metricSub:SetTextColor(options.metricPositive==false and 1 or 0.82,options.metricPositive==false and 0.42 or 0.82,options.metricPositive==false and 0.4 or 0.75)
  end
  if options.fpsDashboard then
    layoutFPSDashboard(f,math.max(360,f.content:GetWidth() or 360));f.fpsDashboard:Show();if options.fpsLegend then f.fpsDashboardLegend:SetText(options.fpsLegend);f.fpsDashboardLegend:Show();bodyY=-(f.fpsDashboard:GetHeight()+38) else bodyY=-(f.fpsDashboard:GetHeight()+16) end
    for index,card in ipairs(f.fpsDashboardCards) do local data=options.fpsDashboard[index] or {};local color=data.color or {0.45,1,0.72};local border=data.borderColor or {0.58,0.43,0.2};card.title:SetText(data.label or "");card.value:SetText(data.value or "—");card.value:SetFontObject(data.compact and GameFontNormalLarge or GameFontNormalHuge2);card.value:SetTextColor(color[1],color[2],color[3]);card.value:ClearAllPoints();if data.subtitle and data.subtitle~="" then card.value:SetPoint("TOPLEFT",12,-36);card.value:SetPoint("TOPRIGHT",-10,-36);card.subtitle:SetText(data.subtitle);card.subtitle:SetTextColor(color[1],color[2],color[3]);card.subtitle:Show() else card.value:SetPoint("BOTTOMLEFT",12,12);card.value:SetPoint("BOTTOMRIGHT",-10,12);card.subtitle:Hide() end;card:SetBackdropBorderColor(border[1],border[2],border[3],0.95) end
  end
  f.bodyY=bodyY;f.body:ClearAllPoints();f.body:SetPoint("TOPLEFT",7,bodyY);f.body:SetText(text or "")
  for _,nav in ipairs(f.navButtons) do nav:SetActive(nav.pageKey==options.pageKey) end
  for _,old in ipairs(f.pageButtons) do old:Hide() end;f.pageButtons={}
  for _,action in ipairs(actions or {}) do
    local created
    if action.kind=="check" then created=checkBox(f.actionContent,action.label,action.fn,action.checked)
    elseif action.kind=="slider" then created=sliderRow(f.actionContent,action.label,action.minimum,action.maximum,action.step,action.value,action.fn,action.formatter)
    elseif action.kind=="section" then created=sectionLabel(f.actionContent,action.label)
    else created=button(f.actionContent,action.label,0,0,200,action.fn,action.style) end
    created.action=action;created:SetDisabled(action.disabled);created:SetActive(action.active);if action.tooltip then addTooltip(created,action.label,action.tooltip);if created.check then addTooltip(created.check,action.label,action.tooltip)end;if created.slider then addTooltip(created.slider,action.label,action.tooltip);if created.slider.Slider then addTooltip(created.slider.Slider,action.label,action.tooltip)end;if created.slider.Back then addTooltip(created.slider.Back,action.label,action.tooltip)end;if created.slider.Forward then addTooltip(created.slider.Forward,action.label,action.tooltip)end end end;table.insert(f.pageButtons,created)
  end
  f.hasActions=#f.pageButtons>0;f:Show();self:LayoutUI()
end

function STBS:FormatDiff(plan)
  local changed,unchanged,unavailable=0,0,0
  for _,entry in ipairs(plan or {}) do
    if entry.status=="changed" then changed=changed+1 elseif entry.status=="identical" then unchanged=unchanged+1 else unavailable=unavailable+1 end
  end
  return string.format(self:L("PLAN_SUMMARY"),changed,unchanged,unavailable).."\n\n|cff35e6ad- |r"..self:L("PERFORMANCE_TUNED").."\n|cff35e6ad- |r"..self:L("QUALITY_PRESERVED").."\n|cff35e6ad- |r"..self:L("HARDWARE_UNCHANGED")
end

function STBS:ShowHome() return self:ShowGraphics() end
function STBS:ShowInterface() return self:ShowGraphics() end

function STBS:BuildGraphicsFPSDashboard(metric,live,measuring)
  local neutral={0.72,0.78,0.82};local gold={1,0.82,0.2};local green={0.35,1,0.62};local red={1,0.38,0.3};local muted={0.58,0.43,0.2}
  local function rounded(value)return math.floor((tonumber(value) or 0)+0.5)end
  local hasMetric=not measuring and type(metric)=="table" and tonumber(metric.before) and tonumber(metric.after) and tonumber(metric.before)>0 and tonumber(metric.after)>0
  local before,after,delta,percent
  if hasMetric then before=rounded(metric.before);after=rounded(metric.after);delta=rounded(metric.delta or (metric.after-metric.before));percent=rounded(metric.percent or ((metric.after-metric.before)/metric.before*100)) end
  local resultColor=not hasMetric and neutral or delta>0 and green or delta<0 and red or gold
  return {
    {label=self:L("FPS_DASH_LIVE"),value=live and string.format(self:L("LIVE_FPS_FORMAT"),rounded(live)) or "—",subtitle=self:L("FPS_DASH_LIVE_NOTE"),color={0.45,1,0.72}},
    {label=self:L("FPS_DASH_BEFORE"),value=hasMetric and string.format(self:L("LIVE_FPS_FORMAT"),before) or "—",subtitle=self:L("FPS_DASH_BEFORE_NOTE"),color=neutral,borderColor=muted},
    {label=self:L("FPS_DASH_AFTER"),value=hasMetric and string.format(self:L("LIVE_FPS_FORMAT"),after) or "—",subtitle=self:L("FPS_DASH_AFTER_NOTE"),color=resultColor,borderColor=hasMetric and resultColor or muted},
    {label=self:L("FPS_DASH_CHANGE"),value=hasMetric and string.format("%+d FPS",delta) or "—",subtitle=hasMetric and string.format("%+d%%",percent) or self:L("FPS_DASH_CHANGE_NOTE"),color=resultColor,borderColor=hasMetric and resultColor or muted},
  }
end

function STBS:ShowGraphics()
  self:StartFPSBaselineSampling()
  local mode=self:GetSelectedMode();local preset=self:GetSelectedPreset()
  local metric=self:GetLastFPSMetric();local measuring=self.fpsAfterMeasurement or self.fpsAccurateMeasurement or self.fpsTestMeasurement;local dashboard=self:BuildGraphicsFPSDashboard(metric,self:ReadFramerate(),measuring)
  local text="|cffffd36b"..self:L("QUICK_START").."|r\n"..self:L("QUICK_START_TEXT").."\n\n|cffffd36b"..self:L("SAVE_OWN_TITLE").."|r\n"..self:L("SAVE_OWN_TEXT").."\n\n|cff9aa7b8"..self:L("GRAPHICS_SELECTION_SUMMARY").."|r"
  local latest=self:GetLatestBackupIndex("graphics")
  local actions={
    {label=self:L("PRESET_PRO"),third=true,fn=function()STBS:SetSelectedPreset(STBS.GRAPHICS_PRESET_PRO);STBS.flashMessage=STBS:L("PRESET_SELECTED");STBS.flashKind="success";STBS:ShowGraphics()end,active=preset==self.GRAPHICS_PRESET_PRO},
    {label=self:L("PRESET_OPTIMIZED"),third=true,fn=function()STBS:SetSelectedPreset(STBS.GRAPHICS_PRESET_OPTIMIZED);STBS.flashMessage=STBS:L("PRESET_SELECTED");STBS.flashKind="success";STBS:ShowGraphics()end,active=preset==self.GRAPHICS_PRESET_OPTIMIZED},
    {label=self:L("PRESET_QUALITY"),third=true,fn=function()STBS:SetSelectedPreset(STBS.GRAPHICS_PRESET_QUALITY);STBS.flashMessage=STBS:L("PRESET_SELECTED");STBS.flashKind="success";STBS:ShowGraphics()end,active=preset==self.GRAPHICS_PRESET_QUALITY},
    {kind="check",label=self:L("LIGHT_RAID_CHECK"),checked=mode==self.GRAPHICS_MODE_SPLIT,third=true,fn=function(checked)STBS:SetSelectedMode(checked and STBS.GRAPHICS_MODE_SPLIT or STBS.GRAPHICS_MODE_UNIFIED);STBS.flashMessage=STBS:L("MODE_SELECTED");STBS.flashKind="success";STBS:ShowGraphics()end},
    {label=self:L("APPLY_AND_MEASURE"),fn=function()STBS:ShowOfficialPreview("graphics")end,style="primary",wide=true,disabled=measuring},
  }
  if self.reloadRecommended then table.insert(actions,{label=self:L("RELOAD_UI"),fn=function()STBS:ConfirmReloadUI()end,style="primary",wide=true,disabled=measuring and true or false}) end
  table.insert(actions,{label=self:L("UNDO"),fn=function()STBS:ConfirmUndoGraphics()end,disabled=not latest})
  table.insert(actions,{label=self:L("PROFILES"),fn=function()STBS:ShowProfiles()end})
  local phase=self.fpsAccuratePhase=="before" and self:L("FPS_MEASURING_BEFORE") or self.fpsAccuratePhase=="after" and self:L("FPS_MEASURING_AFTER") or self:L("FPS_MEASURING")
  local status=self.flashMessage or (measuring and phase or self:L("READY"));local statusKind=self.flashKind or (measuring and "warning" or nil);self.flashMessage=nil;self.flashKind=nil
  self:SetPage(self:L("GRAPHICS_TITLE"),text,actions,status,{pageKey="graphics",graphicsSection="settings",fpsDashboard=dashboard,fpsLegend=self:L("FPS_GRAPHICS_DASH_LEGEND"),statusKind=statusKind})
  self:SetLiveFPSCallback(function(value)
    if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="graphics" then STBS.ui.fpsDashboardCards[1].value:SetText(value and string.format(STBS:L("LIVE_FPS_FORMAT"),math.floor(value+0.5)) or "—") end
  end)
  if not self.settingsRegistered then self.settingsRegistered=self:RegisterBlizzardSettings() end
end

function STBS:SetUITweakPageStatus(message,kind)
  local f=self.ui;if not f or not f:IsShown() or f.currentPageKey~="uiTweaks" then self.flashMessage=message;self.flashKind=kind;return end
  f.status:SetText(message or "")
  if kind=="success" then f.status:SetTextColor(0.35,1,0.62) elseif kind=="error" then f.status:SetTextColor(1,0.35,0.3) elseif kind=="warning" then f.status:SetTextColor(1,0.78,0.24) else f.status:SetTextColor(0.78,0.72,0.58) end
  if type(_G.UIFrameFadeIn)=="function" then UIFrameFadeIn(f.status,0.18,0.35,1) end
end

function STBS:ShowUITweaks()
  self:SetLiveFPSCallback(nil);self:StopFPSBaselineSampling()
  local draft=self:GetUITweaksDraft();local _,availability=self:GetAvailableUITweakSettings();local unavailable=0
  for _,key in ipairs(self.UI_TWEAK_KEYS) do if not availability[key].available then unavailable=unavailable+1 end end
  local function enabled(key)return availability[key] and availability[key].available end
  local function choose(key,value)
    if STBS:SetUITweakDraft(key,value) then STBS:SetUITweakPageStatus(STBS:L("UI_TWEAK_CHANGED"),"success") end
  end
  local actions={
    {kind="section",label=self:L("UI_TWEAKS_RECOMMENDED"),wide=true},
    {kind="check",label=self:L("UI_TWEAK_ALWAYS_SHARPEN"),checked=draft.ResampleAlwaysSharpen=="1",disabled=not enabled("ResampleAlwaysSharpen"),tooltip=self:L("UI_TWEAK_ALWAYS_SHARPEN_TIP"),fn=function(value)choose("ResampleAlwaysSharpen",value and "1" or "0")end},
    {kind="check",label=self:L("UI_TWEAK_GLOW"),checked=draft.ffxGlow=="1",disabled=not enabled("ffxGlow"),tooltip=self:L("UI_TWEAK_GLOW_TIP"),fn=function(value)choose("ffxGlow",value and "1" or "0")end},
    {kind="slider",label=self:L("UI_TWEAK_SHARPNESS"),minimum=0,maximum=2,step=0.1,value=tonumber(draft.ResampleSharpness) or 0.3,disabled=not enabled("ResampleSharpness"),tooltip=self:L("UI_TWEAK_SHARPNESS_TIP"),formatter=function(value)return string.format("%.1f",value)end,fn=function(value)choose("ResampleSharpness",string.format("%.1f",value))end},
    {label=self:L("UI_TWEAK_USE_RECOMMENDED"),wide=true,fn=function()STBS:SelectRecommendedUITweaks();STBS.flashMessage=STBS:L("UI_TWEAK_SELECTED");STBS.flashKind="success";STBS:ShowUITweaks()end},
    {kind="section",label=self:L("UI_TWEAKS_OPTIONAL"),wide=true},
    {kind="check",label=self:L("UI_TWEAK_DEATH"),checked=draft.ffxDeath=="1",disabled=not enabled("ffxDeath"),tooltip=self:L("UI_TWEAK_DEATH_TIP"),fn=function(value)choose("ffxDeath",value and "1" or "0")end},
    {kind="check",label=self:L("UI_TWEAK_NETHER"),checked=draft.ffxNether=="1",disabled=not enabled("ffxNether"),tooltip=self:L("UI_TWEAK_NETHER_TIP"),fn=function(value)choose("ffxNether",value and "1" or "0")end},
    {label=self:L("UI_TWEAK_APPLY"),style="primary",wide=true,fn=function()STBS:ConfirmApplyUITweaks()end},
    {label=self:L("UI_TWEAK_UNDO"),wide=true,disabled=not self:GetLatestBackupIndex("uiTweaks"),fn=function()STBS:ConfirmUndoUITweaks()end},
  }
  local text="|cff35e6ad"..self:L("UI_TWEAKS_TRUST").."|r\n\n|cffffd36b"..self:L("UI_TWEAKS_RECOMMENDED").."|r\n"..self:L("UI_TWEAKS_RECOMMENDED_NOTE").."\n\n|cffffd36b"..self:L("UI_TWEAKS_OPTIONAL").."|r\n"..self:L("UI_TWEAKS_OPTIONAL_NOTE").."\n\n|cff9aa7b8"..self:L("UI_TWEAK_TOOLTIP_HINT").."|r"
  local status=self.flashMessage or (unavailable>0 and self:L("UI_TWEAK_UNAVAILABLE") or self:L("UI_TWEAKS_STATUS"));local kind=self.flashKind or (unavailable>0 and "warning" or nil);self.flashMessage=nil;self.flashKind=nil
  self:SetPage(self:L("UI_TWEAKS_TITLE"),text,actions,status,{pageKey="uiTweaks",statusKind=kind})
end

function STBS:ConfirmApplyUITweaks()
  local settings=self:GetAvailableUITweakSettings();local plan=self:BuildDiff(settings);local changed=0
  for _,entry in ipairs(plan) do if entry.status=="changed" then changed=changed+1 end end
  if changed==0 then self.flashMessage=self:L("UI_TWEAK_ALREADY");self.flashKind="success";self:ShowUITweaks();return end
  StaticPopupDialogs["STBS_APPLY_UI_TWEAKS"]={text=self:L("UI_TWEAK_APPLY_CONFIRM"),subText=string.format(self:L("UI_TWEAK_APPLY_CONFIRM_TEXT"),changed),button1=ACCEPT,button2=CANCEL,OnAccept=function()
    local result=STBS:ApplySettings(settings,{uiTweaks=true},"ui-tweaks")
    if result.code=="queued" then STBS.flashMessage=STBS:L("PENDING");STBS.flashKind="warning"
    elseif result.ok then STBS.uiTweaksDraft=nil;STBS.flashMessage=string.format(STBS:L("UI_TWEAK_APPLIED"),(result.data.uiTweaks and result.data.uiTweaks.changed) or changed);STBS.flashKind="success"
    else STBS.flashMessage=STBS:L("APPLY_FAILED").." ("..tostring(result.code)..")";STBS.flashKind="error" end
    STBS:ShowUITweaks()
  end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_APPLY_UI_TWEAKS")
end

function STBS:ConfirmUndoUITweaks()
  local index=self:GetLatestBackupIndex("uiTweaks");if not index then self.flashMessage=self:L("UI_TWEAK_ALREADY");self.flashKind="warning";self:ShowUITweaks();return end
  StaticPopupDialogs["STBS_UNDO_UI_TWEAKS"]={text=self:L("UI_TWEAK_UNDO_CONFIRM"),subText=self:L("UI_TWEAK_UNDO_CONFIRM_TEXT"),button1=ACCEPT,button2=CANCEL,OnAccept=function()
    local result=STBS:RestoreBackup(index,{uiTweaks=true});if result.ok then STBS.uiTweaksDraft=nil end;STBS.flashMessage=result.ok and STBS:L("UI_TWEAK_RESTORED") or STBS:L("APPLY_FAILED");STBS.flashKind=result.ok and "success" or "error";STBS:ShowUITweaks()
  end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_UNDO_UI_TWEAKS")
end

function STBS:GetFPSStabilityLabel(value)
  if value>=85 then return self:L("FPS_STABILITY_EXCELLENT") end
  if value>=70 then return self:L("FPS_STABILITY_GOOD") end
  if value>=50 then return self:L("FPS_STABILITY_UNEVEN") end
  return self:L("FPS_STABILITY_POOR")
end

function STBS:FormatStandaloneFPSTest(result)
  if type(result)~="table" then return self:L("FPS_TEST_NO_RESULT") end
  local average=math.floor((result.average or 0)+0.5);local stability=math.floor((result.stability or 0)+0.5);local spikes=result.spikes or 0;local worst=math.floor((result.worstFrameMs or 0)+0.5)
  local diagnosis
  if average<45 then diagnosis=self:L("FPS_DIAG_LOW")
  elseif stability<70 or spikes>=3 then diagnosis=self:L("FPS_DIAG_UNEVEN")
  elseif worst>=50 then diagnosis=self:L("FPS_DIAG_HITCH")
  else diagnosis=self:L("FPS_DIAG_HEALTHY") end
  return string.format(self:L("FPS_TEST_STABILITY_EXPLAIN"),stability).."\n"..string.format(self:L("FPS_TEST_SPIKES"),spikes).." · "..string.format(self:L("FPS_TEST_WORST"),worst).."\n\n|cffffd36b"..self:L("FPS_TEST_ADVICE").."|r\n"..diagnosis.."\n|cff9aa7b8"..self:L("FPS_DIAG_LIMIT").."|r"
end

function STBS:BuildPresetFPSComparisonDashboard(comparison)
  if type(comparison)~="table" or type(comparison.beforeStats)~="table" or type(comparison.afterStats)~="table" then return nil end
  local function rounded(value)return math.floor((tonumber(value) or 0)+0.5)end
  local function percent(before,after)return before>0 and math.floor((after-before)/before*100+0.5) or 0 end
  local function color(delta)if delta>0 then return {0.35,1,0.62} elseif delta<0 then return {1,0.38,0.3} end;return {1,0.82,0.2} end
  local beforeAverage,afterAverage=rounded(comparison.beforeStats.average),rounded(comparison.afterStats.average);local averageDelta=afterAverage-beforeAverage;local averagePercent=percent(beforeAverage,afterAverage)
  local beforeLow,afterLow=rounded(comparison.beforeStats.onePercentLow),rounded(comparison.afterStats.onePercentLow);local lowDelta=afterLow-beforeLow;local lowPercent=percent(beforeLow,afterLow)
  local beforeStability,afterStability=rounded(comparison.beforeStats.stability),rounded(comparison.afterStats.stability);local stabilityDelta=afterStability-beforeStability
  local verdictKey,verdictColor
  if averagePercent>=5 and lowPercent>=5 then verdictKey,verdictColor="FPS_COMPARE_FASTER_SHORT",{0.35,1,0.62}
  elseif averagePercent<=-5 and lowPercent<=-5 then verdictKey,verdictColor="FPS_COMPARE_SLOWER_SHORT",{1,0.38,0.3}
  elseif math.abs(averagePercent)<5 and math.abs(lowPercent)<5 then verdictKey,verdictColor="FPS_COMPARE_SIMILAR_SHORT",{1,0.82,0.2}
  else verdictKey,verdictColor="FPS_COMPARE_MIXED_SHORT",{1,0.72,0.2} end
  return {
    {label=self:L("FPS_COMPARE_DASH_PRESET"),value=self:GetPresetLabel(comparison.preset),subtitle=self:L(verdictKey),color=verdictColor,borderColor=verdictColor,compact=true},
    {label=self:L("FPS_DASH_AVERAGE"),value=string.format(self:L("FPS_COMPARE_DASH_VALUE"),beforeAverage,afterAverage),subtitle=string.format(self:L("FPS_COMPARE_DASH_DELTA"),averageDelta,averagePercent),color=color(averageDelta),borderColor=color(averageDelta),compact=true},
    {label=self:L("FPS_DASH_ONE_LOW"),value=string.format(self:L("FPS_COMPARE_DASH_VALUE"),beforeLow,afterLow),subtitle=string.format(self:L("FPS_COMPARE_DASH_DELTA"),lowDelta,lowPercent),color=color(lowDelta),borderColor=color(lowDelta),compact=true},
    {label=self:L("FPS_DASH_STABILITY"),value=string.format(self:L("FPS_COMPARE_DASH_PERCENT_VALUE"),beforeStability,afterStability),subtitle=string.format(self:L("FPS_COMPARE_DASH_POINTS"),stabilityDelta),color=color(stabilityDelta),borderColor=color(stabilityDelta),compact=true},
  }
end

function STBS:ShowFPSTest()
  self:StartFPSBaselineSampling();local result=self:GetLastStandaloneFPSTest();local measuring=self.fpsTestMeasurement==true;local preferences=self:InitializeDatabase().preferences
  local comparison=self:GetLastPresetFPSComparison();local comparisonDashboard=self:BuildPresetFPSComparisonDashboard(comparison);local restoreText=comparison and (comparison.restoreQueued and self:L("FPS_COMPARE_RESTORE_QUEUED") or comparison.restoreFailed and self:L("FPS_COMPARE_RESTORE_FAILED") or self:L("FPS_COMPARE_RESTORED"));local restoreColor=comparison and (comparison.restoreFailed and "|cffff6154" or comparison.restoreQueued and "|cffffd36b" or "|cff9aa7b8") or ""
  local resultText=self:FormatStandaloneFPSTest(result);local text=comparisonDashboard and ("|cffffd36b"..self:L("FPS_COMPARE_DASH_HELP").."|r\n\n"..restoreColor..restoreText.."|r") or (self:L("FPS_TEST_HELP").."\n\n|cffffd36b"..self:L("FPS_TEST_DETAILS").."|r\n"..resultText)
  local function startStandalone()
    local started,why=STBS:StartStandaloneFPSTest(function()STBS:HideFPSTestModal();if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="fpsTest" then STBS.flashMessage=STBS:L("FPS_TEST_COMPLETE");STBS.flashKind="success";STBS:ShowFPSTest()end end)
    if started then STBS:ShowFPSTestModal("standalone") else STBS.flashMessage=why=="busy" and STBS:L("FPS_TEST_BUSY") or STBS:L("FPS_TEST_UNAVAILABLE");STBS.flashKind="error";STBS:ShowFPSTest() end
  end
  local function comparePreset(preset)
    local started,why=STBS:StartPresetFPSComparison(preset,function(comparison,restored,errorResult)
      STBS:HideFPSTestModal();if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="fpsTest" then STBS.flashMessage=comparison and (restored and restored.code=="queued" and STBS:L("FPS_COMPARE_COMPLETE_QUEUED") or restored and not restored.ok and STBS:L("FPS_COMPARE_COMPLETE_RESTORE_FAILED") or STBS:L("FPS_COMPARE_COMPLETE")) or STBS:L("FPS_COMPARE_FAILED").." ("..tostring(errorResult and errorResult.code or "unknown")..")";STBS.flashKind=comparison and restored and restored.ok and "success" or comparison and "warning" or "error";STBS:ShowFPSTest()end
    end)
    if started then STBS:ShowFPSTestModal("comparison",preset) else local key=why=="combat" and "FPS_COMPARE_COMBAT" or why=="pending" and "FPS_COMPARE_PENDING" or why=="busy" and "FPS_TEST_BUSY" or "FPS_TEST_UNAVAILABLE";STBS.flashMessage=STBS:L(key);STBS.flashKind="error";STBS:ShowFPSTest() end
  end
  local actions={
    {label=self:L("FPS_TEST_START"),style="primary",wide=true,disabled=measuring,fn=startStandalone},
    {label=string.format(self:L("FPS_COMPARE_BUTTON"),self:L("PRESET_PRO")),third=true,disabled=measuring,fn=function()comparePreset(STBS.GRAPHICS_PRESET_PRO)end},
    {label=string.format(self:L("FPS_COMPARE_BUTTON"),self:L("PRESET_OPTIMIZED")),third=true,disabled=measuring,fn=function()comparePreset(STBS.GRAPHICS_PRESET_OPTIMIZED)end},
    {label=string.format(self:L("FPS_COMPARE_BUTTON"),self:L("PRESET_QUALITY")),third=true,disabled=measuring,fn=function()comparePreset(STBS.GRAPHICS_PRESET_QUALITY)end},
    {kind="check",label=self:L("WIDGET_CHECK"),checked=preferences.performanceWidgetEnabled,wide=true,fn=function(checked)STBS:SetPerformanceWidgetEnabled(checked);STBS.flashMessage=checked and STBS:L("WIDGET_ENABLED") or STBS:L("WIDGET_DISABLED");STBS.flashKind="success";STBS:ShowFPSTest()end},
  }
  local live=self:ReadFramerate();local average=result and math.floor(result.average+0.5);local low=result and math.floor(result.onePercentLow+0.5);local stability=result and math.floor(result.stability+0.5);local stabilityColor=stability and (stability>=85 and {0.35,1,0.62} or stability>=70 and {1,0.82,0.2} or {1,0.38,0.3}) or {0.65,0.65,0.6}
  local dashboard=comparisonDashboard or {
    {label=self:L("FPS_DASH_LIVE"),value=live and string.format(self:L("LIVE_FPS_FORMAT"),math.floor(live+0.5)) or "—",color={0.45,1,0.72}},
    {label=self:L("FPS_DASH_AVERAGE"),value=average and string.format(self:L("LIVE_FPS_FORMAT"),average) or "—",color={0.45,1,0.72}},
    {label=self:L("FPS_DASH_ONE_LOW"),value=low and string.format(self:L("LIVE_FPS_FORMAT"),low) or "—",color={0.4,0.8,1}},
    {label=self:L("FPS_DASH_STABILITY"),value=stability and string.format("%d%%",stability) or "—",color=stabilityColor},
  }
  local status=self.flashMessage or (measuring and self:L("FPS_TEST_RUNNING") or self:L("FPS_TEST_READY"));local statusKind=self.flashKind or (measuring and "warning" or nil);self.flashMessage=nil;self.flashKind=nil
  self:SetPage(self:L("FPS_TEST_TITLE"),text,actions,status,{pageKey="fpsTest",fpsDashboard=dashboard,fpsComparison=comparisonDashboard~=nil,fpsLegend=comparisonDashboard and string.format(self:L("FPS_COMPARE_DASH_LEGEND"),self:GetPresetLabel(comparison.preset)) or nil,statusKind=statusKind})
  self:SetLiveFPSCallback(function(value)if not comparisonDashboard and STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="fpsTest" then STBS.ui.fpsDashboardCards[1].value:SetText(value and string.format(STBS:L("LIVE_FPS_FORMAT"),math.floor(value+0.5)) or "—") end end)
end

function STBS:ShowOfficialPreview()
  local mode=self:GetSelectedMode();if not mode then self:ShowGraphics();return end
  local settings=self:FlattenProfile(self:GetOfficialGraphics(mode,self:GetSelectedPreset()),{graphics=true});local plan=self:BuildDiff(settings)
  self:SetLiveFPSCallback(nil)
  self:SetPage(self:L("PREVIEW"),self:FormatDiff(plan),{
    {label=self:L("APPLY_AND_MEASURE"),fn=function()STBS:ConfirmApplyGraphics(#plan)end,style="primary",wide=true},
    {label=self:L("BACK"),fn=function()STBS:ShowGraphics()end},
  },self:L("REVIEW_READY"),{pageKey="graphics"})
end

function STBS:ConfirmApplyGraphics(count)
  StaticPopupDialogs["STBS_APPLY_GRAPHICS"]={text=self:L("APPLY_CONFIRM"),subText=string.format(self:L("APPLY_CONFIRM_TEXT"),count or 0),button1=ACCEPT,button2=CANCEL,OnAccept=function()STBS:ApplyGraphicsWithFPS()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3}
  StaticPopup_Show("STBS_APPLY_GRAPHICS")
end

function STBS:ApplyGraphicsWithFPS(settings,trigger,selectedMode)
  local function applyNow(options)
    if settings then return self:ApplySettings(settings,{graphics=true},trigger or "personal-graphics",options) end
    return self:ApplyOfficial("graphics",options)
  end
  local before=self:TakeFPSBaseline();local result=applyNow({fpsBefore=before})
  if result.ok then
    self.reloadRecommended=true
    if selectedMode then self:SetSelectedMode(selectedMode) end
    local measuring=self:StartFPSPostMeasurement(before,function()if STBS.ui and STBS.ui:IsShown() then STBS:ShowGraphics() end end)
    self.flashMessage=measuring and self:L("SETTINGS_APPLIED") or self:L("SETTINGS_APPLIED_NO_MEASURE");self.flashKind="success"
    self:ShowGraphics()
  elseif result.code=="queued" then
    if selectedMode then self:SetSelectedMode(selectedMode) end
    self.flashMessage=self:L("PENDING_FPS");self.flashKind="warning";self:ShowGraphics()
  else self:ShowReport(result) end
  return result
end

function STBS:ConfirmReloadUI()
  StaticPopupDialogs["STBS_RELOAD_UI"]={text=self:L("RELOAD_CONFIRM"),subText=self:L("RELOAD_CONFIRM_TEXT"),button1=self:L("RELOAD_UI"),button2=CANCEL,OnAccept=function()if type(_G.ReloadUI)=="function" then _G.ReloadUI() else STBS.flashMessage=STBS:L("RELOAD_FAILED");STBS.flashKind="error";STBS:ShowGraphics() end end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3}
  StaticPopup_Show("STBS_RELOAD_UI")
end

function STBS:ConfirmUndoGraphics()
  local index=self:GetLatestBackupIndex("graphics");if not index then self.flashMessage=self:L("UNDO_UNAVAILABLE");self.flashKind="warning";self:ShowGraphics();return end
  StaticPopupDialogs["STBS_UNDO_GRAPHICS"]={text=self:L("UNDO_CONFIRM"),subText=self:L("UNDO_CONFIRM_TEXT"),button1=ACCEPT,button2=CANCEL,OnAccept=function()local result=STBS:RestoreBackup(index,{graphics=true});STBS.flashMessage=result.ok and STBS:L("RESTORE_COMPLETE") or STBS:L("APPLY_FAILED");STBS.flashKind=result.ok and "success" or "error";STBS:ShowGraphics()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3}
  StaticPopup_Show("STBS_UNDO_GRAPHICS")
end

function STBS:OpenSaveDialog()
  StaticPopupDialogs["STBS_SAVE"]={text=self:L("PROFILE_NAME"),subText=self:L("PROFILE_SAVE_HELP"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=self.MAX_PROFILE_NAME_BYTES,EditBoxOnEnterPressed=popupAcceptOnEnter,EditBoxOnTextChanged=StaticPopup_StandardNonEmptyTextHandler,OnAccept=function(p)local box=popupEditBox(p);local profile,why=STBS:SaveCurrent(box and box:GetText(),{graphics=true});if profile then STBS.selectedItemType="profile";STBS.selectedProfileId=profile.id;STBS.flashMessage=string.format(STBS:L("PROFILE_SAVED"),STBS:SafeText(profile.displayName));STBS.flashKind="success" else STBS.flashMessage=STBS:L("PROFILE_SAVE_FAILED").." ("..tostring(why)..")";STBS.flashKind="error" end;STBS:ShowProfiles()end,OnShow=function(p)local box=popupEditBox(p);if box then box:SetText("");box:SetFocus() end end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_SAVE")
end

function STBS:OpenRenameDialog(profile)
  StaticPopupDialogs["STBS_RENAME"]={text=self:L("PROFILE_NAME"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=self.MAX_PROFILE_NAME_BYTES,EditBoxOnEnterPressed=popupAcceptOnEnter,EditBoxOnTextChanged=StaticPopup_StandardNonEmptyTextHandler,OnAccept=function(p)local box=popupEditBox(p);local result=STBS:RenameProfile(profile.id,box and box:GetText());STBS.flashMessage=result.ok and STBS:L("PROFILE_RENAMED") or STBS:L("PROFILE_RENAME_FAILED");STBS.flashKind=result.ok and "success" or "error";STBS:ShowProfiles()end,OnShow=function(p)local box=popupEditBox(p);if box then box:SetText(profile.displayName);box:SetFocus();box:HighlightText() end end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_RENAME")
end

function STBS:ConfirmDeleteProfile(profile)
  StaticPopupDialogs["STBS_DELETE_PROFILE"]={text=self:L("DELETE")..": "..self:SafeText(profile.displayName).."?",button1=ACCEPT,button2=CANCEL,OnAccept=function()local result=STBS:DeleteProfile(profile.id);STBS.selectedProfileId=nil;STBS.selectedItemType=nil;STBS.flashMessage=result.ok and STBS:L("PROFILE_DELETED") or STBS:L("ACTION_FAILED");STBS.flashKind=result.ok and "success" or "error";STBS:ShowProfiles()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_DELETE_PROFILE")
end

function STBS:ConfirmDeleteBackup(index)
  StaticPopupDialogs["STBS_DELETE_BACKUP"]={text=self:L("DELETE_BACKUP"),subText=self:L("DELETE_BACKUP_CONFIRM"),button1=ACCEPT,button2=CANCEL,OnAccept=function()local result=STBS:DeleteBackup(index);STBS.selectedBackupIndex=nil;STBS.selectedItemType=nil;STBS.flashMessage=result.ok and STBS:L("BACKUP_DELETED") or STBS:L("ACTION_FAILED");STBS.flashKind=result.ok and "success" or "error";STBS:ShowProfiles()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_DELETE_BACKUP")
end

function STBS:ConfirmRestoreBackup(index)
  StaticPopupDialogs["STBS_RESTORE_BACKUP"]={text=self:L("RESTORE_SELECTED"),button1=ACCEPT,button2=CANCEL,OnAccept=function()local result=STBS:RestoreBackup(index,{graphics=true});STBS.flashMessage=result.ok and STBS:L("RESTORE_COMPLETE") or STBS:L("APPLY_FAILED");STBS.flashKind=result.ok and "success" or "error";STBS:ShowGraphics()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_RESTORE_BACKUP")
end

function STBS:GetGraphicsProfiles()
  local result={}
  for _,profile in ipairs(self:ListPersonalProfiles()) do
    local graphics=profile.sections and profile.sections.graphics
    if type(graphics)=="table" and (graphics.mode==self.GRAPHICS_MODE_UNIFIED or graphics.mode==self.GRAPHICS_MODE_SPLIT) then table.insert(result,profile) end
  end
  return result
end

function STBS:ShowProfiles(section)
  self:SetLiveFPSCallback(nil);self:StopFPSBaselineSampling()
  local profiles=self:GetGraphicsProfiles();local backups=self:InitializeDatabase().backups
  section=section or self.profileSection or "profiles";if section~="profiles" and section~="backups" and section~="transfer" then section="profiles" end;self.profileSection=section
  local selectedProfile;for _,profile in ipairs(profiles) do if profile.id==self.selectedProfileId then selectedProfile=profile end end
  local selectedBackup=backups[self.selectedBackupIndex or 0];if selectedBackup and not self:BackupHasModule(selectedBackup,"graphics") then selectedBackup=nil end
  if section=="profiles" and not selectedProfile and profiles[1] then selectedProfile=profiles[1];self.selectedProfileId=selectedProfile.id end
  if section=="backups" and not selectedBackup then local index=self:GetLatestBackupIndex("graphics");if index then self.selectedBackupIndex=index;selectedBackup=backups[index] end end
  local actions={
    {label=self:L("PROFILES_TAB"),third=true,active=section=="profiles",fn=function()STBS:ShowProfiles("profiles")end},
    {label=self:L("BACKUPS_TAB"),third=true,active=section=="backups",fn=function()STBS:ShowProfiles("backups")end},
    {label=self:L("TRANSFER_TAB"),third=true,active=section=="transfer",fn=function()STBS:ShowProfiles("transfer")end},
  }
  local text
  if section=="profiles" then
    text="|cffffd36b"..self:L("PERSONAL_PROFILES").."|r\n"..(#profiles==0 and self:L("NO_GRAPHICS_PROFILES") or string.format(self:L("PROFILE_COUNT"),#profiles))
    if selectedProfile then text=text.."\n\n|cff65cfff"..self:L("SELECTED")..":|r "..self:SafeText(selectedProfile.displayName) end
    table.insert(actions,{label=self:L("SAVE_GRAPHICS"),fn=function()STBS:OpenSaveDialog()end,style="primary",wide=true})
    if selectedProfile then
      table.insert(actions,{label=self:L("APPLY_PROFILE"),fn=function()STBS:ShowProfilePreview(selectedProfile)end,style="primary",wide=true})
      table.insert(actions,{label=self:L("EXPORT"),third=true,fn=function()STBS:ShowExport(selectedProfile)end});table.insert(actions,{label=self:L("RENAME"),third=true,fn=function()STBS:OpenRenameDialog(selectedProfile)end});table.insert(actions,{label=self:L("DELETE"),third=true,fn=function()STBS:ConfirmDeleteProfile(selectedProfile)end,style="danger"})
    end
    for _,profile in ipairs(profiles) do local current=profile;table.insert(actions,{label=self:L("PROFILE_LABEL")..": "..self:SafeText(current.displayName),active=current.id==self.selectedProfileId,fn=function()STBS.selectedProfileId=current.id;STBS.flashMessage=string.format(STBS:L("ITEM_SELECTED"),STBS:SafeText(current.displayName));STBS.flashKind="success";STBS:ShowProfiles("profiles")end}) end
  elseif section=="backups" then
    local count=0;for _,backup in ipairs(backups) do if self:BackupHasModule(backup,"graphics") then count=count+1 end end
    text="|cffffd36b"..self:L("BACKUP_HISTORY").."|r\n"..(count==0 and self:L("NO_BACKUPS") or string.format(self:L("BACKUP_COUNT"),count))
    if selectedBackup then text=text.."\n\n|cff65cfff"..self:L("SELECTED")..":|r #"..self.selectedBackupIndex.." · "..self:SafeText(selectedBackup.trigger or "backup").." · "..date("%Y-%m-%d %H:%M",selectedBackup.timestamp) end
    if selectedBackup then table.insert(actions,{label=self:L("RESTORE_SELECTED"),fn=function()STBS:ConfirmRestoreBackup(STBS.selectedBackupIndex)end,style="primary"});table.insert(actions,{label=self:L("DELETE_BACKUP"),fn=function()STBS:ConfirmDeleteBackup(STBS.selectedBackupIndex)end,style="danger"}) end
    table.insert(actions,{label=self:L("CREATE_GRAPHICS_BACKUP"),wide=true,fn=function()local result=STBS:CreateBackup({graphics=true},"manual");if result.ok then STBS.selectedBackupIndex=1;STBS.flashMessage=STBS:L("BACKUP_CREATED");STBS.flashKind="success" else STBS.flashMessage=STBS:L("BACKUP_CREATE_FAILED");STBS.flashKind="error" end;STBS:ShowProfiles("backups")end})
    for i,backup in ipairs(backups) do if self:BackupHasModule(backup,"graphics") then local index=i;table.insert(actions,{label=self:L("BACKUP_LABEL").." #"..index.." · "..date("%m-%d %H:%M",backup.timestamp),active=index==self.selectedBackupIndex,fn=function()STBS.selectedBackupIndex=index;STBS.flashMessage=string.format(STBS:L("ITEM_SELECTED"),STBS:L("BACKUP_LABEL").." #"..index);STBS.flashKind="success";STBS:ShowProfiles("backups")end}) end end
  else
    text="|cffffd36b"..self:L("TRANSFER_TITLE").."|r\n"..self:L("TRANSFER_HELP").."\n\n|cff9aa7b8"..self:L("TRANSFER_EXCLUDES").."|r"
    table.insert(actions,{label=self:L("EXPORT_ALL"),wide=true,style="primary",fn=function()STBS:ShowAddonExport()end})
    table.insert(actions,{label=self:L("IMPORT_ALL"),wide=true,fn=function()STBS:OpenAddonImport()end})
  end
  local status=self.flashMessage or (section=="transfer" and self:L("TRANSFER_READY") or self:L("SELECT_ITEM"));local statusKind=self.flashKind;self.flashMessage=nil;self.flashKind=nil
  self:SetPage(self:L("BACKUPS_AND_PROFILES"),text,actions,status,{pageKey="profiles",statusKind=statusKind})
end

function STBS:GetPresetLabel(preset)
  if preset==self.GRAPHICS_PRESET_PRO then return self:L("PRESET_PRO") end
  if preset==self.GRAPHICS_PRESET_QUALITY then return self:L("PRESET_QUALITY") end
  return self:L("PRESET_OPTIMIZED")
end

function STBS:ShowZoneGraphics()
  self:SetLiveFPSCallback(nil);self:StopFPSBaselineSampling()
  local config=self:GetZoneGraphicsConfig();local category=self:GetZoneCategory()
  local categoryKeys={world="ZONE_WORLD",party="ZONE_PARTY",raid="ZONE_RAID",pvp="ZONE_PVP",scenario="ZONE_SCENARIO"}
  local text="|cffffd36b"..self:L("ZONE_CURRENT").."|r\n"..self:L(categoryKeys[category]).." · "..self:GetPresetLabel(config.assignments[category]).."\n\n"..self:L("ZONE_GRAPHICS_HELP").."\n\n|cff9aa7b8"..self:L("ZONE_SAFE_NOTE").."|r"
  local actions={{kind="check",label=self:L("ZONE_CHECK"),checked=config.enabled,wide=true,fn=function(enabled)STBS:SetZoneGraphicsEnabled(enabled);if enabled then STBS:ApplyZoneGraphics("zone-enabled")else STBS.zoneStatus={ok=true,code="disabled"}end;STBS:ShowZoneGraphics()end}}
  for _,key in ipairs({"world","party","raid","pvp","scenario"}) do local item=key;table.insert(actions,{label=self:L(categoryKeys[item])..": "..self:GetPresetLabel(config.assignments[item]),active=item==category,fn=function()STBS:CycleZonePreset(item);STBS.zoneStatus={ok=true,code="mapping",category=item,preset=STBS:GetZoneGraphicsConfig().assignments[item]};STBS:ShowZoneGraphics()end}) end
  table.insert(actions,{label=self:L("ZONE_APPLY_NOW"),style="primary",wide=true,disabled=not config.enabled,fn=function()STBS:ApplyZoneGraphics("zone-manual");STBS:ShowZoneGraphics()end})
  local zoneStatus=self.zoneStatus;local status=config.enabled and self:L("ZONE_ENABLED") or self:L("ZONE_DISABLED");local kind=config.enabled and "success" or nil
  if zoneStatus then
    if zoneStatus.code=="unchanged" then status=self:L("ZONE_ALREADY_ACTIVE");kind="success"
    elseif zoneStatus.code=="applied" then status=string.format(self:L("ZONE_APPLIED"),zoneStatus.changed or 0);kind="success"
    elseif zoneStatus.code=="queued" then status=self:L("ZONE_QUEUED");kind="warning"
    elseif zoneStatus.code=="mapping" then status=self:L("ZONE_MAPPING_SAVED");kind="success"
    elseif zoneStatus.ok==false then status=self:L("APPLY_FAILED");kind="error" end
  end
  self:SetPage(self:L("ZONE_GRAPHICS_TITLE"),text,actions,status,{pageKey="graphics",graphicsSection="zones",statusKind=kind})
end

function STBS:ShowAbout()
  self:SetLiveFPSCallback(nil);self:StopFPSBaselineSampling()
  local text="|cffffd36b"..self:L("ABOUT_SOURCE_HEADER").."|r\n"..self:L("ABOUT_SOURCE_BODY").."\n\n|cffffd36b"..self:L("ABOUT_BALANCE_HEADER").."|r\n"..self:L("ABOUT_BALANCE_BODY").."\n\n|cffffd36b"..self:L("ABOUT_TRUST_HEADER").."|r\n"..self:L("ABOUT_TRUST_BODY").."\n\n|cff9aa7b8"..self:L("ABOUT_LIMIT").."|r"
  self:SetPage(self:L("ABOUT_TITLE"),text,{},self:L("ABOUT_STATUS"),{pageKey="about",statusKind="success"})
end

function STBS:ShowBackups() self.selectedItemType="backup";return self:ShowProfiles() end

function STBS:ShowProfilePreview(profile)
  local valid=self:ValidateProfile(profile);if not valid then self:ShowProfiles();return end
  local settings=self:FlattenProfile(profile,{graphics=true});local plan=self:BuildDiff(settings)
  self:SetPage(self:L("PREVIEW"),"|cffffd36b"..self:SafeText(profile.displayName).."|r\n\n"..self:FormatDiff(plan),{
    {label=self:L("APPLY_AND_MEASURE"),fn=function()STBS:ConfirmApplyProfile(profile)end,style="primary",wide=true},
    {label=self:L("BACK"),fn=function()STBS:ShowProfiles()end},
  },self:L("STATUS")..": "..#plan.." "..self:L("SETTINGS_COUNT"),{pageKey="profiles"})
end

function STBS:ConfirmApplyProfile(profile)
  StaticPopupDialogs["STBS_APPLY_PROFILE"]={text=self:L("PROFILE_APPLY_CONFIRM"),subText=self:L("PROFILE_APPLY_CONFIRM_TEXT"),button1=ACCEPT,button2=CANCEL,OnAccept=function()local settings=STBS:FlattenProfile(profile,{graphics=true});STBS:ApplyGraphicsWithFPS(settings,"personal-profile",profile.sections.graphics.mode)end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_APPLY_PROFILE")
end

function STBS:ShowDiagnostics() self:SetPage(self:L("DIAGNOSTICS"),self:DiagnosticReport(),{{label=self:L("COPY"),fn=function()STBS:ShowCopyBox(STBS:DiagnosticReport())end},{label=self:L("BACK"),fn=function()STBS:ShowGraphics()end}},nil,{}) end

function STBS:ShowCopyBox(text,selectAll)
  self:CreateUI();local f=self.ui;local box=f.copyBox
  if not box then box=CreateFrame("EditBox",nil,f.content);box:SetMultiLine(true);box:SetAutoFocus(false);box:SetFontObject(GameFontHighlightLarge);box:SetPoint("TOPLEFT",7,-6);box:SetScript("OnEscapePressed",function(x)x:ClearFocus()end);f.copyBox=box end
  box:SetMaxLetters(self.MAX_IMPORT_BYTES);f.metricCard:Hide();f.body:SetText("");box:SetText(text or "");box:Show();box:SetFocus();if selectAll==false then box:SetCursorPosition(0) else box:HighlightText() end;f:Show();self:LayoutUI()
end

function STBS:ShowExport(profile)
  local output=self:ExportProfile(profile,{graphics=true});self:SetPage(self:L("EXPORT"),self:L("EXPORT_HELP").."\n\n"..self:L("SELECTED")..": "..self:SafeText(profile.displayName).."\n"..self:L("SIZE")..": "..#output.." bytes",{{label=self:L("COPY"),fn=function()STBS:ShowCopyBox(output)end},{label=self:L("BACK"),fn=function()STBS:ShowProfiles()end}},self:L("EXPORT_READY"),{pageKey="profiles",statusKind="success"})
end

function STBS:ShowAddonExport()
  local output,why=self:ExportAddonBundle()
  if not output then self.flashMessage=self:L("BUNDLE_EXPORT_FAILED").." ("..tostring(why)..")";self.flashKind="error";self:ShowProfiles("transfer");return end
  self:SetPage(self:L("EXPORT_ALL"),self:L("BUNDLE_EXPORT_READY"),{{label=self:L("COPY"),fn=function()STBS:ShowCopyBox(output)end,style="primary",wide=true},{label=self:L("BACK"),fn=function()STBS:ShowProfiles("transfer")end}},self:L("EXPORT_READY"),{pageKey="profiles",statusKind="success"})
end

function STBS:OpenAddonImport()
  self:SetPage(self:L("IMPORT_ALL"),"",{{label=self:L("IMPORT_REVIEW"),style="primary",wide=true,fn=function()
    local box=STBS.ui and STBS.ui.copyBox;local payload,why=STBS:ImportAddonBundle(box and box:GetText() or "")
    if not payload then local f=STBS.ui;if f then f.status:SetText(STBS:L("BUNDLE_IMPORT_FAILED").." ("..tostring(why)..")");f.status:SetTextColor(1,0.35,0.3);if type(_G.UIFrameFadeIn)=="function" then UIFrameFadeIn(f.status,0.18,0.35,1) end end;if box then box:SetFocus();box:HighlightText() end;return end
    STBS.pendingAddonBundle=payload;STBS:ShowAddonImportPreview(payload)
  end},{label=self:L("BACK"),wide=true,fn=function()STBS:ShowProfiles("transfer")end}},self:L("BUNDLE_IMPORT_PASTE"),{pageKey="profiles",statusKind="warning"})
  self:ShowCopyBox("",false)
end

function STBS:ShowAddonImportPreview(payload)
  local count=0;for _ in pairs(payload.profiles or {}) do count=count+1 end
  local text=string.format(self:L("BUNDLE_IMPORT_SUMMARY"),count,self:GetPresetLabel(payload.preferences.graphicsPreset))
  self:SetPage(self:L("IMPORT_ALL"),text,{{label=self:L("IMPORT_ALL_CONFIRM"),style="primary",wide=true,fn=function()
    local result=STBS:ApplyAddonBundle(STBS.pendingAddonBundle);STBS.pendingAddonBundle=nil
    if result.ok then STBS.reloadRecommended=true;STBS.flashMessage=STBS:L("BUNDLE_IMPORTED");STBS.flashKind="success" else STBS.flashMessage=STBS:L("BUNDLE_IMPORT_FAILED").." ("..tostring(result.code)..")";STBS.flashKind="error" end
    STBS:ShowProfiles("transfer")
  end},{label=self:L("BACK"),fn=function()STBS.pendingAddonBundle=nil;STBS:ShowProfiles("transfer")end}},self:L("REVIEW_READY"),{pageKey="profiles",statusKind="warning"})
end

function STBS:OpenImport()
  StaticPopupDialogs["STBS_IMPORT"]={text=self:L("IMPORT_PROMPT"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=STBS.MAX_IMPORT_BYTES,EditBoxOnEnterPressed=popupAcceptOnEnter,EditBoxOnTextChanged=StaticPopup_StandardNonEmptyTextHandler,OnAccept=function(p)local box=popupEditBox(p);local payload,why=STBS:ImportProfile(box and box:GetText());if not payload or not payload.selectedModules.graphics then STBS:SetPage(STBS:L("IMPORT"),STBS:L("INVALID_IMPORT").." ("..tostring(why or "graphics")..")",{{label=STBS:L("BACK"),fn=function()STBS:ShowProfiles()end}},STBS:L("ACTION_FAILED"),{pageKey="profiles",statusKind="error"});return end;STBS.pendingImport=payload;STBS:ShowImportPreview(payload)end,OnShow=function(p)local box=popupEditBox(p);if box then box:SetText("");box:SetFocus() end end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_IMPORT")
end

function STBS:ApplyPendingImport(graphicsMode)
  local plan,settings=self:PlanImport(self.pendingImport,{graphics=true},graphicsMode);if not plan then return end
  local mode=graphicsMode=="profile" and self.pendingImport.profile.sections.graphics.mode or self:GetSelectedMode();self.pendingImport=nil;self:ApplyGraphicsWithFPS(settings,"profile-import",mode)
end

function STBS:ShowImportPreview(payload)
  local plan=self:PlanImport(payload,{graphics=true},"profile");local changed=0;for _,entry in ipairs(plan or {}) do if entry.status=="changed" then changed=changed+1 end end
  local actions={{label=self:L("IMPORT_GRAPHICS")..": "..self:L("USE_PROFILE_MODE"),fn=function()STBS:ApplyPendingImport("profile")end,style="primary",wide=true}}
  if self:GetSelectedMode() then table.insert(actions,{label=self:L("IMPORT_GRAPHICS")..": "..self:L("KEEP_MODE"),fn=function()STBS:ApplyPendingImport("current")end}) end
  table.insert(actions,{label=self:L("BACK"),fn=function()STBS.pendingImport=nil;STBS:ShowProfiles()end})
  self:SetPage(self:L("IMPORT"),"|cff65cfff"..self:L("PROFILE_SUMMARY").."|r\n"..self:SafeText(payload.profile.displayName).."\n"..self:L("CHANGED")..": "..changed.."\n\n"..self:FormatDiff(plan).."\n\n"..self:L("IMPORT_CONFIRMATION"),actions,nil,{pageKey="profiles"})
end

function STBS:ShowReport(result)
  if result.code=="queued" or result.code=="pending-exists" then self.flashMessage=self:L("PENDING");self:ShowGraphics();return end
  if not result.ok and not result.data then self:SetPage(self:L("GRAPHICS"),self:L("APPLY_FAILED").." ("..tostring(result.code)..")",{{label=self:L("BACK"),fn=function()STBS:ShowGraphics()end}},nil,{pageKey="graphics"});return end
  local warning=not result.ok and "|cffff6666"..self:L("TRANSACTION_ROLLED_BACK").."|r\n\n" or ""
  self:SetPage(self:L("GRAPHICS"),warning.."|cff35e6ad"..self:L("REPORT_GRAPHICS").."|r\n"..resultSummary(result.data and result.data.graphics),{{label=self:L("BACK"),fn=function()STBS:ShowGraphics()end}},nil,{pageKey="graphics"})
end
