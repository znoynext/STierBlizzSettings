local _, STBS = ...

local ASSET = "Interface\\AddOns\\STierBlizzSettings\\Assets\\"
local categoryNames={graphics="BASE_GRAPHICS",raidGraphics="RAID_GRAPHICS"}
local categoryOrder={"graphics","raidGraphics"}

local function button(parent,text,x,y,width,callback,style)
  local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
  b:SetSize(width or 200,34);b:SetPoint("TOPLEFT",x,y)
  b:SetText(text);b.label=b:GetFontString();b.label:SetFontObject(style=="primary" and GameFontNormal or GameFontHighlight)
  b.label:SetTextColor(style=="danger" and 1 or style=="primary" and 1 or 0.92,style=="danger" and 0.36 or style=="primary" and 0.82 or 0.82,style=="danger" and 0.3 or style=="primary" and 0 or 0.68)
  local highlight=b:GetHighlightTexture();local hoverGroup=highlight and highlight:CreateAnimationGroup();if hoverGroup then local hover=hoverGroup:CreateAnimation("Alpha");hover:SetFromAlpha(0.35);hover:SetToAlpha(1);hover:SetDuration(0.14);hover:SetSmoothing("OUT") end
  b:SetScript("OnClick",callback)
  b:SetScript("OnEnter",function(self)if not self.disabled and hoverGroup then hoverGroup:Stop();hoverGroup:Play()end end)
  function b:SetActive(active)self.active=active;if active then self:LockHighlight();self.label:SetTextColor(1,0.82,0) else self:UnlockHighlight();self.label:SetTextColor(style=="danger" and 1 or style=="primary" and 1 or 0.92,style=="danger" and 0.36 or style=="primary" and 0.82 or 0.82,style=="danger" and 0.3 or style=="primary" and 0 or 0.68) end end
  function b:SetDisabled(disabled)self.disabled=disabled;self:SetEnabled(not disabled);self:SetAlpha(disabled and 0.42 or 1)end
  return b
end

local function navButton(parent,text,icon,y,pageKey,callback)
  local b=button(parent,text,14,y,170,callback);b:SetSize(170,44);b.pageKey=pageKey
  b.label:ClearAllPoints();b.label:SetPoint("LEFT",44,0);b.label:SetJustifyH("LEFT");b.label:SetFontObject(GameFontNormal)
  b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetTexture(icon);b.icon:SetSize(24,24);b.icon:SetPoint("LEFT",12,0)
  return b
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

function STBS:CreateUI()
  if self.ui then return end
  local f=CreateFrame("Frame","STierBlizzSettingsFrame",UIParent,"BackdropTemplate")
  f:SetSize(960,650);f:SetPoint("CENTER");f:SetMovable(true);f:SetClampedToScreen(true);f:EnableMouse(true);f:RegisterForDrag("LeftButton");f:SetScript("OnDragStart",f.StartMoving);f:SetScript("OnDragStop",f.StopMovingOrSizing);f:Hide()
  f:SetBackdrop({bgFile="Interface\\FrameGeneral\\UI-Background-Rock",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=256,edgeSize=32,insets={left=11,right=12,top=12,bottom=11}});f:SetBackdropColor(0.42,0.42,0.42,1);f:SetBackdropBorderColor(1,1,1,1)
  local fade=f:CreateAnimationGroup();fade:SetToFinalAlpha(true);local alpha=fade:CreateAnimation("Alpha");alpha:SetFromAlpha(0);alpha:SetToAlpha(1);alpha:SetDuration(0.18);alpha:SetSmoothing("OUT");f.fade=fade
  f:SetScript("OnShow",function(self)self:SetAlpha(1);self.fade:Stop();self.fade:Play()end)
  f:SetScript("OnHide",function()STBS:StopFPSBaselineSampling()end)

  local top=CreateFrame("Frame",nil,f,"BackdropTemplate");top:SetPoint("TOPLEFT",18,-18);top:SetSize(924,62);top:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});top:SetBackdropColor(0.05,0.04,0.025,0.98);top:SetBackdropBorderColor(0.72,0.52,0.2,1)
  f.logo=top:CreateTexture(nil,"ARTWORK");f.logo:SetTexture(ASSET.."STierIcon");f.logo:SetSize(48,48);f.logo:SetPoint("LEFT",12,0)
  f.title=top:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.title:SetPoint("LEFT",68,8);f.title:SetText(self:L("TITLE"));f.title:SetTextColor(1,0.82,0)
  f.version=top:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");f.version:SetPoint("LEFT",69,-15);f.version:SetText("v"..self.VERSION);f.version:SetTextColor(0.68,0.62,0.5)
  local close=CreateFrame("Button",nil,f,"UIPanelCloseButton");close:SetPoint("TOPRIGHT",3,3)

  local side=CreateFrame("Frame",nil,f,"BackdropTemplate");side:SetPoint("TOPLEFT",18,-92);side:SetSize(194,538);side:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});side:SetBackdropColor(0.035,0.028,0.018,0.98);side:SetBackdropBorderColor(0.52,0.4,0.2,0.95)
  local panel=CreateFrame("Frame",nil,f,"BackdropTemplate");panel:SetPoint("TOPLEFT",222,-92);panel:SetSize(720,538);panel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});panel:SetBackdropColor(0.035,0.028,0.018,0.98);panel:SetBackdropBorderColor(0.52,0.4,0.2,0.95)

  f.header=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.header:SetPoint("TOPLEFT",22,-20);f.header:SetTextColor(1,0.82,0)
  f.status=panel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");f.status:SetPoint("TOPLEFT",24,-50);f.status:SetTextColor(0.78,0.72,0.58)
  local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate");scroll:SetPoint("TOPLEFT",18,-76);scroll:SetSize(675,350)
  local content=CreateFrame("Frame",nil,scroll);content:SetWidth(644);content:SetHeight(350);scroll:SetScrollChild(content);f.scroll,f.content=scroll,content
  f.previewBorder=CreateFrame("Frame",nil,content,"BackdropTemplate");f.previewBorder:SetPoint("TOPLEFT",61,-2);f.previewBorder:SetSize(512,262);f.previewBorder:SetBackdrop({edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=14,insets={left=3,right=3,top=3,bottom=3}});f.previewBorder:SetBackdropBorderColor(0.72,0.52,0.2,1);f.previewBorder:Hide()
  f.preview=f.previewBorder:CreateTexture(nil,"ARTWORK");f.preview:SetTexture(ASSET.."GraphicsPreview");f.preview:SetPoint("TOPLEFT",6,-6);f.preview:SetSize(500,250)
  f.previewShade=content:CreateTexture(nil,"OVERLAY");f.previewShade:SetPoint("BOTTOMLEFT",f.preview,"BOTTOMLEFT");f.previewShade:SetPoint("BOTTOMRIGHT",f.preview,"BOTTOMRIGHT");f.previewShade:SetHeight(54);f.previewShade:SetColorTexture(0.004,0.015,0.028,0.72);f.previewShade:Hide()
  f.previewTitle=content:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.previewTitle:SetPoint("BOTTOMLEFT",f.preview,"BOTTOMLEFT",16,18);f.previewTitle:SetText(self:L("VISUAL_PREVIEW"));f.previewTitle:SetTextColor(1,0.82,0);f.previewTitle:Hide()
  f.metricCard=CreateFrame("Frame",nil,content,"BackdropTemplate");f.metricCard:SetSize(625,66);f.metricCard:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});f.metricCard:SetBackdropColor(0.045,0.038,0.022,0.98);f.metricCard:SetBackdropBorderColor(0.72,0.52,0.2,1);f.metricCard:Hide()
  f.metricTitle=f.metricCard:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");f.metricTitle:SetPoint("TOPLEFT",14,-10);f.metricTitle:SetText(self:L("FPS_ESTIMATE"));f.metricTitle:SetTextColor(0.78,0.72,0.58)
  f.metricValue=f.metricCard:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.metricValue:SetPoint("BOTTOMLEFT",14,12);f.metricValue:SetTextColor(0.45,1,0.72)
  f.body=content:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");f.body:SetWidth(625);f.body:SetJustifyH("LEFT");f.body:SetJustifyV("TOP")

  local rule=panel:CreateTexture(nil,"ARTWORK");rule:SetColorTexture(0.55,0.4,0.18,0.75);rule:SetPoint("TOPLEFT",22,-436);rule:SetSize(672,1)
  local actionScroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate");actionScroll:SetPoint("TOPLEFT",18,-446);actionScroll:SetSize(675,82)
  local actionContent=CreateFrame("Frame",nil,actionScroll);actionContent:SetWidth(644);actionContent:SetHeight(82);actionScroll:SetScrollChild(actionContent);f.actionScroll,f.actionContent=actionScroll,actionContent
  f.pageButtons={};f.navButtons={};self.ui=f
  table.insert(f.navButtons,navButton(side,self:L("GRAPHICS"),"Interface\\Icons\\INV_Misc_EngGizmos_30",-16,"graphics",function()STBS:ShowGraphics()end))
  table.insert(f.navButtons,navButton(side,self:L("PROFILES"),"Interface\\Icons\\INV_Misc_Book_09",-68,"profiles",function()STBS:ShowProfiles()end))
end

function STBS:SetPage(title,text,actions,status,options)
  self:CreateUI();local f=self.ui;options=options or {};f.currentPageKey=options.pageKey
  f.header:SetText(title);f.status:SetText(status or "")
  if f.copyBox then f.copyBox:Hide() end;f.scroll:Show();f.previewBorder:Hide();f.previewShade:Hide();f.previewTitle:Hide();f.metricCard:Hide()
  local bodyY=-6
  if options.preview then
    f.previewBorder:Show();f.previewShade:Show();f.previewTitle:Show();f.metricCard:ClearAllPoints();f.metricCard:SetPoint("TOPLEFT",5,-272);f.metricCard:Show();bodyY=-352
    f.metricValue:SetText(options.metricText or self:L("FPS_UNAVAILABLE"));f.metricValue:SetTextColor(options.metricPositive==false and 1 or 0.45,options.metricPositive==false and 0.42 or 1,options.metricPositive==false and 0.4 or 0.72)
  end
  f.body:ClearAllPoints();f.body:SetPoint("TOPLEFT",7,bodyY);f.body:SetText(text or "")
  f.content:SetHeight(math.max(350,-bodyY+f.body:GetStringHeight()+20));f.scroll:SetVerticalScroll(0);f.actionScroll:SetVerticalScroll(0);f:Show()
  for _,nav in ipairs(f.navButtons) do nav:SetActive(nav.pageKey==options.pageKey) end
  for _,old in ipairs(f.pageButtons) do old:Hide() end;f.pageButtons={}
  local row,col=0,0
  for _,action in ipairs(actions or {}) do
    if action.wide and col>0 then row=row+1;col=0 end
    local width=action.wide and 625 or 305;local x=action.wide and 0 or col*318
    local created=button(f.actionContent,action.label,x,-row*40,width,action.fn,action.style);created:SetDisabled(action.disabled);created:SetActive(action.active);table.insert(f.pageButtons,created)
    if action.wide then row=row+1;col=0 else col=col+1;if col==2 then row=row+1;col=0 end end
  end
  if col>0 then row=row+1 end;f.actionContent:SetHeight(math.max(82,row*40));f.actionScroll:SetVerticalScroll(0)
end

function STBS:FormatDiff(plan)
  local lines={"|cff65cfff"..self:L("DIFF_HEADER").."|r"};local lastCategory
  for _,entry in ipairs(plan or {}) do
    local category=entry.setting.category
    if category~=lastCategory then table.insert(lines,"\n|cffffd36b"..self:L(categoryNames[category] or "BASE_GRAPHICS").."|r");lastCategory=category end
    local color=entry.status=="changed" and "|cff35e6ad" or entry.status=="failed" and "|cffff6666" or "|cff9aa7b8"
    table.insert(lines,color..self:GetSettingLabel(entry.setting)..":|r "..tostring(entry.current or self:L("UNAVAILABLE")).." → "..entry.value.."  |cff718096("..self:L(string.upper(entry.status))..")|r")
  end
  return table.concat(lines,"\n")
end

function STBS:ShowHome() return self:ShowGraphics() end
function STBS:ShowInterface() return self:ShowGraphics() end

function STBS:ShowGraphics()
  self:StartFPSBaselineSampling()
  local mode=self:GetSelectedMode();local modeName=mode==self.GRAPHICS_MODE_UNIFIED and self:L("UNIFIED") or mode==self.GRAPHICS_MODE_SPLIT and self:L("SPLIT") or self:L("MODE_UNSET")
  local modeHelp=mode==self.GRAPHICS_MODE_UNIFIED and self:L("MODE_UNIFIED_HELP") or mode==self.GRAPHICS_MODE_SPLIT and self:L("MODE_SPLIT_HELP") or self:L("GRAPHICS_TEXT")
  local metric=self:GetLastFPSMetric();local metricText=self.fpsAfterMeasurement and self:L("FPS_MEASURING") or self:FormatFPSMetric(metric)
  local text="|cffffd36b"..self:L("MODE")..":|r "..modeName.."\n"..modeHelp.."\n\n"..self:L("VISUAL_PREVIEW_NOTE").."\n\n|cff8295a8"..self:L("FPS_MEASURE_HELP").."|r\n\n"..self:L("HARDWARE_PRESERVED").."\n"..self:L("GRAPHICS_ONLY_NOTICE")
  local latest=self:GetLatestBackupIndex("graphics")
  local actions={
    {label=self:L("UNIFIED"),fn=function()STBS:SetSelectedMode(STBS.GRAPHICS_MODE_UNIFIED);STBS:ShowGraphics()end,active=mode==self.GRAPHICS_MODE_UNIFIED},
    {label=self:L("SPLIT"),fn=function()STBS:SetSelectedMode(STBS.GRAPHICS_MODE_SPLIT);STBS:ShowGraphics()end,active=mode==self.GRAPHICS_MODE_SPLIT},
    {label=self:L("APPLY_AND_MEASURE"),fn=function()STBS:ShowOfficialPreview("graphics")end,style="primary",wide=true,disabled=not mode},
    {label=self:L("UNDO"),fn=function()STBS:ConfirmUndoGraphics()end,disabled=not latest},
    {label=self:L("PROFILES"),fn=function()STBS:ShowProfiles()end},
  }
  local status=self.flashMessage or (self.fpsAfterMeasurement and self:L("FPS_MEASURING") or metric and self:L("MEASURED_LOCALLY") or "");self.flashMessage=nil
  self:SetPage(self:L("GRAPHICS"),text,actions,status,{pageKey="graphics",preview=true,metricText=metricText,metricPositive=not metric or (metric.delta or 0)>=0})
  if not self.settingsRegistered then self.settingsRegistered=self:RegisterBlizzardSettings() end
end

function STBS:ShowOfficialPreview()
  local mode=self:GetSelectedMode();if not mode then self:ShowGraphics();return end
  local settings=self:FlattenProfile(self:GetOfficialGraphics(mode),{graphics=true});local plan=self:BuildDiff(settings)
  self:SetPage(self:L("PREVIEW"),self:FormatDiff(plan),{
    {label=self:L("APPLY_AND_MEASURE"),fn=function()STBS:ConfirmApplyGraphics(#plan)end,style="primary",wide=true},
    {label=self:L("BACK"),fn=function()STBS:ShowGraphics()end},
  },self:L("STATUS")..": "..#plan.." "..self:L("SETTINGS_COUNT"),{pageKey="graphics"})
end

function STBS:ConfirmApplyGraphics(count)
  StaticPopupDialogs["STBS_APPLY_GRAPHICS"]={text=self:L("APPLY_CONFIRM"),subText=string.format(self:L("APPLY_CONFIRM_TEXT"),count or 0),button1=ACCEPT,button2=CANCEL,OnAccept=function()STBS:ApplyGraphicsWithFPS()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3}
  StaticPopup_Show("STBS_APPLY_GRAPHICS")
end

function STBS:ApplyGraphicsWithFPS(settings,trigger,selectedMode)
  local before=self:TakeFPSBaseline();local result
  if settings then result=self:ApplySettings(settings,{graphics=true},trigger or "personal-graphics",{fpsBefore=before}) else result=self:ApplyOfficial("graphics",{fpsBefore=before}) end
  if result.ok then
    if selectedMode then self:SetSelectedMode(selectedMode) end
    local measuring=self:StartFPSPostMeasurement(before,function()if STBS.ui and STBS.ui:IsShown() then STBS:ShowGraphics() end end)
    self.flashMessage=measuring and self:L("SETTINGS_APPLIED") or (self:L("REPORT_GRAPHICS").." | "..self:L("FPS_UNAVAILABLE"))
    self:ShowGraphics()
  elseif result.code=="queued" then
    if selectedMode then self:SetSelectedMode(selectedMode) end
    self.flashMessage=self:L("PENDING_FPS");self:ShowGraphics()
  else self:ShowReport(result) end
  return result
end

function STBS:ConfirmUndoGraphics()
  local index=self:GetLatestBackupIndex("graphics");if not index then self.flashMessage=self:L("UNDO_UNAVAILABLE");self:ShowGraphics();return end
  StaticPopupDialogs["STBS_UNDO_GRAPHICS"]={text=self:L("UNDO_CONFIRM"),subText=self:L("UNDO_CONFIRM_TEXT"),button1=ACCEPT,button2=CANCEL,OnAccept=function()local result=STBS:RestoreBackup(index,{graphics=true});STBS.flashMessage=result.ok and STBS:L("RESTORE_COMPLETE") or STBS:L("APPLY_FAILED");STBS:ShowGraphics()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3}
  StaticPopup_Show("STBS_UNDO_GRAPHICS")
end

function STBS:OpenSaveDialog()
  if not self:GetSelectedMode() then self:ShowGraphics();return end
  StaticPopupDialogs["STBS_SAVE"]={text=self:L("PROFILE_NAME"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=self.MAX_PROFILE_NAME_BYTES,OnAccept=function(p)local profile=STBS:SaveCurrent(p.editBox:GetText(),{graphics=true});if profile then STBS.selectedItemType="profile";STBS.selectedProfileId=profile.id end;STBS:ShowProfiles()end,OnShow=function(p)p.editBox:SetText("");p.editBox:SetFocus()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_SAVE")
end

function STBS:OpenRenameDialog(profile)
  StaticPopupDialogs["STBS_RENAME"]={text=self:L("PROFILE_NAME"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=self.MAX_PROFILE_NAME_BYTES,OnAccept=function(p)STBS:RenameProfile(profile.id,p.editBox:GetText());STBS:ShowProfiles()end,OnShow=function(p)p.editBox:SetText(profile.displayName);p.editBox:SetFocus();p.editBox:HighlightText()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_RENAME")
end

function STBS:ConfirmDeleteProfile(profile)
  StaticPopupDialogs["STBS_DELETE_PROFILE"]={text=self:L("DELETE")..": "..self:SafeText(profile.displayName).."?",button1=ACCEPT,button2=CANCEL,OnAccept=function()STBS:DeleteProfile(profile.id);STBS.selectedProfileId=nil;STBS.selectedItemType=nil;STBS:ShowProfiles()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_DELETE_PROFILE")
end

function STBS:ConfirmDeleteBackup(index)
  StaticPopupDialogs["STBS_DELETE_BACKUP"]={text=self:L("DELETE_BACKUP"),subText=self:L("DELETE_BACKUP_CONFIRM"),button1=ACCEPT,button2=CANCEL,OnAccept=function()STBS:DeleteBackup(index);STBS.selectedBackupIndex=nil;STBS.selectedItemType=nil;STBS:ShowProfiles()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_DELETE_BACKUP")
end

function STBS:ConfirmRestoreBackup(index)
  StaticPopupDialogs["STBS_RESTORE_BACKUP"]={text=self:L("RESTORE_SELECTED"),button1=ACCEPT,button2=CANCEL,OnAccept=function()local result=STBS:RestoreBackup(index,{graphics=true});STBS.flashMessage=result.ok and STBS:L("RESTORE_COMPLETE") or STBS:L("APPLY_FAILED");STBS:ShowGraphics()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_RESTORE_BACKUP")
end

function STBS:GetGraphicsProfiles()
  local result={}
  for _,profile in ipairs(self:ListPersonalProfiles()) do
    local graphics=profile.sections and profile.sections.graphics
    if type(graphics)=="table" and (graphics.mode==self.GRAPHICS_MODE_UNIFIED or graphics.mode==self.GRAPHICS_MODE_SPLIT) then table.insert(result,profile) end
  end
  return result
end

function STBS:ShowProfiles()
  self:StartFPSBaselineSampling()
  local profiles=self:GetGraphicsProfiles();local backups=self:InitializeDatabase().backups
  local selectedProfile;for _,profile in ipairs(profiles) do if profile.id==self.selectedProfileId then selectedProfile=profile end end
  local selectedBackup=backups[self.selectedBackupIndex or 0]
  if selectedBackup and not self:BackupHasModule(selectedBackup,"graphics") then selectedBackup=nil end
  if self.selectedItemType=="profile" and not selectedProfile then self.selectedItemType=nil end
  if self.selectedItemType=="backup" and not selectedBackup then self.selectedItemType=nil end
  if not self.selectedItemType then
    if selectedProfile or profiles[1] then
      selectedProfile=selectedProfile or profiles[1];self.selectedProfileId=selectedProfile.id;self.selectedItemType="profile"
    else
      local firstGraphicsBackup=self:GetLatestBackupIndex("graphics")
      if firstGraphicsBackup then self.selectedBackupIndex=firstGraphicsBackup;selectedBackup=backups[firstGraphicsBackup];self.selectedItemType="backup" end
    end
  end
  local lines={"|cff65cfff"..self:L("PERSONAL_PROFILES").."|r"}
  if #profiles==0 then table.insert(lines,self:L("NO_GRAPHICS_PROFILES")) else for i,profile in ipairs(profiles) do table.insert(lines,(self.selectedItemType=="profile" and profile.id==self.selectedProfileId and "|cff35e6ad> " or "  ")..i..". "..self:SafeText(profile.displayName).."|r") end end
  table.insert(lines,"\n|cff65cfff"..self:L("BACKUP_HISTORY").."|r")
  local graphicsBackups=0
  for i,backup in ipairs(backups) do if self:BackupHasModule(backup,"graphics") then graphicsBackups=graphicsBackups+1;table.insert(lines,(self.selectedItemType=="backup" and i==self.selectedBackupIndex and "|cff35e6ad> " or "  ").."#"..i.." · "..self:SafeText(backup.trigger or "backup").." · "..date("%Y-%m-%d %H:%M",backup.timestamp).."|r") end end
  if graphicsBackups==0 then table.insert(lines,self:L("NO_BACKUPS")) end
  local actions={
    {label=self:L("SAVE_GRAPHICS"),fn=function()STBS:OpenSaveDialog()end,style="primary"},
    {label=self:L("CREATE_GRAPHICS_BACKUP"),fn=function()STBS:CreateBackup({graphics=true},"manual");STBS.selectedBackupIndex=1;STBS.selectedItemType="backup";STBS:ShowProfiles()end},
    {label=self:L("IMPORT"),fn=function()STBS:OpenImport()end},
  }
  if self.selectedItemType=="profile" and selectedProfile then
    table.insert(actions,{label=self:L("APPLY_PROFILE"),fn=function()STBS:ShowProfilePreview(selectedProfile)end,style="primary",wide=true})
    table.insert(actions,{label=self:L("EXPORT"),fn=function()STBS:ShowExport(selectedProfile)end});table.insert(actions,{label=self:L("RENAME"),fn=function()STBS:OpenRenameDialog(selectedProfile)end});table.insert(actions,{label=self:L("DELETE"),fn=function()STBS:ConfirmDeleteProfile(selectedProfile)end,style="danger"})
  elseif self.selectedItemType=="backup" and selectedBackup then
    table.insert(actions,{label=self:L("RESTORE_SELECTED"),fn=function()STBS:ConfirmRestoreBackup(STBS.selectedBackupIndex)end,style="primary",wide=true})
    table.insert(actions,{label=self:L("DELETE_BACKUP"),fn=function()STBS:ConfirmDeleteBackup(STBS.selectedBackupIndex)end,style="danger"})
  end
  for _,profile in ipairs(profiles) do local current=profile;table.insert(actions,{label=self:L("PROFILE_LABEL")..": "..self:SafeText(current.displayName),fn=function()STBS.selectedItemType="profile";STBS.selectedProfileId=current.id;STBS:ShowProfiles()end}) end
  for i,backup in ipairs(backups) do if self:BackupHasModule(backup,"graphics") then local index=i;table.insert(actions,{label=self:L("BACKUP_LABEL").." #"..index.." · "..date("%m-%d %H:%M",backup.timestamp),fn=function()STBS.selectedItemType="backup";STBS.selectedBackupIndex=index;STBS:ShowProfiles()end}) end end
  self:SetPage(self:L("BACKUPS_AND_PROFILES"),table.concat(lines,"\n"),actions,self:L("SELECT_ITEM"),{pageKey="profiles"})
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

function STBS:ShowCopyBox(text)
  self:CreateUI();local f=self.ui;local box=f.copyBox
  if not box then box=CreateFrame("EditBox",nil,f.content,"InputBoxTemplate");box:SetMultiLine(true);box:SetAutoFocus(false);box:SetFontObject(ChatFontNormal);box:SetWidth(620);box:SetHeight(330);box:SetPoint("TOPLEFT",7,-6);box:SetScript("OnEscapePressed",function(x)x:ClearFocus()end);f.copyBox=box end
  f.previewBorder:Hide();f.previewShade:Hide();f.previewTitle:Hide();f.metricCard:Hide();f.body:SetText("");box:SetText(text);box:Show();box:SetFocus();box:HighlightText();f:Show()
end

function STBS:ShowExport(profile)
  local output=self:ExportProfile(profile,{graphics=true});self:SetPage(self:L("EXPORT"),self:L("EXPORT_HELP").."\n\n"..self:L("SELECTED")..": "..self:SafeText(profile.displayName).."\n"..self:L("SIZE")..": "..#output.." bytes",{{label=self:L("COPY"),fn=function()STBS:ShowCopyBox(output)end},{label=self:L("BACK"),fn=function()STBS:ShowProfiles()end}},nil,{pageKey="profiles"})
end

function STBS:OpenImport()
  StaticPopupDialogs["STBS_IMPORT"]={text=self:L("IMPORT_PROMPT"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=STBS.MAX_IMPORT_BYTES,OnAccept=function(p)local payload,why=STBS:ImportProfile(p.editBox:GetText());if not payload or not payload.selectedModules.graphics then STBS:SetPage(STBS:L("IMPORT"),STBS:L("INVALID_IMPORT").." ("..tostring(why or "graphics")..")",{{label=STBS:L("BACK"),fn=function()STBS:ShowProfiles()end}},nil,{pageKey="profiles"});return end;STBS.pendingImport=payload;STBS:ShowImportPreview(payload)end,OnShow=function(p)p.editBox:SetText("");p.editBox:SetFocus()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_IMPORT")
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
