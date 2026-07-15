local _, STBS = ...
local function button(parent, text, x, y, width, callback)
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(width or 200, 30); b:SetPoint("TOPLEFT", x, y)
  b:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
  b:SetBackdropColor(0.025,0.07,0.13,0.96);b:SetBackdropBorderColor(0.9,0.62,0.12,0.95)
  b.label=b:CreateFontString(nil,"OVERLAY","GameFontHighlight");b.label:SetPoint("CENTER",0,1);b.label:SetText(text);b.label:SetTextColor(1,0.78,0.16)
  b:SetScript("OnClick", callback);b:SetScript("OnEnter",function(self)self:SetBackdropColor(0.06,0.16,0.28,1);self:SetBackdropBorderColor(1,0.82,0.25,1)end);b:SetScript("OnLeave",function(self)if self.active then self:SetBackdropColor(0.08,0.17,0.3,1) else self:SetBackdropColor(0.025,0.07,0.13,0.96) end;self:SetBackdropBorderColor(0.9,0.62,0.12,0.95)end)
  function b:SetActive(active) self.active=active;self:SetBackdropColor(active and 0.08 or 0.025,active and 0.17 or 0.07,active and 0.3 or 0.13,active and 1 or 0.96);self.label:SetTextColor(active and 1 or 0.82,active and 0.8 or 0.66,active and 0.18 or 0.12) end
  return b
end
local function sidebarButton(parent, text, icon, y, callback)
  local b=button(parent,text,16,y,194,callback);b:SetSize(194,40);b.label:ClearAllPoints();b.label:SetPoint("LEFT",42,0);b.label:SetJustifyH("LEFT");b.label:SetFontObject(GameFontNormal)
  b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetTexture(icon);b.icon:SetSize(22,22);b.icon:SetPoint("LEFT",12,0)
  return b
end
local categoryNames = { graphics="BASE_GRAPHICS", raidGraphics="RAID_GRAPHICS", camera="CAMERA", interface="OTHER_INTERFACE", gameplay="OTHER_INTERFACE", controls="OTHER_INTERFACE", combat="OTHER_INTERFACE", nameplates="OTHER_INTERFACE", chat="OTHER_INTERFACE" }
local function resultSummary(data)
  local lines = { "|cff33ff99"..STBS:L("CHANGED")..":|r "..(data.changed or 0), STBS:L("IDENTICAL")..": "..(data.identical or 0), STBS:L("SKIPPED")..": "..(data.skipped or 0), "|cffffd100"..STBS:L("UNAVAILABLE")..":|r "..(data.unavailable or 0), "|cffff4040"..STBS:L("FAILED")..":|r "..(data.failed or 0) }
  for category, values in pairs(data.categories or {}) do table.insert(lines, "\n|cff82c5ff"..STBS:L(categoryNames[category] or "OTHER_INTERFACE")..":|r "..STBS:L("CHANGED").." "..(values.changed or 0)..", "..STBS:L("SKIPPED").." "..(values.skipped or 0)..", "..STBS:L("UNAVAILABLE").." "..(values.unavailable or 0)..", "..STBS:L("FAILED").." "..(values.failed or 0)) end
  return table.concat(lines, "\n")
end
function STBS:CreateUI()
  if self.ui then return end
  local f = CreateFrame("Frame", "STierBlizzSettingsFrame", UIParent, "BackdropTemplate")
  f:SetSize(980,650); f:SetPoint("CENTER"); f:SetMovable(true); f:SetClampedToScreen(true);f:EnableMouse(true); f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop", f.StopMovingOrSizing); f:Hide()
  f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=16,insets={left=6,right=6,top=6,bottom=6}});f:SetBackdropColor(0.01,0.025,0.055,0.98);f:SetBackdropBorderColor(0.92,0.65,0.16,1)
  local top=CreateFrame("Frame",nil,f,"BackdropTemplate");top:SetPoint("TOPLEFT",14,-14);top:SetSize(952,64);top:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=10,insets={left=3,right=3,top=3,bottom=3}});top:SetBackdropColor(0.015,0.02,0.035,0.98);top:SetBackdropBorderColor(0.72,0.5,0.12,1)
  f.logo=top:CreateTexture(nil,"ARTWORK");f.logo:SetTexture("Interface\\Icons\\INV_Misc_Gear_01");f.logo:SetSize(38,38);f.logo:SetPoint("LEFT",16,0)
  f.title=top:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge");f.title:SetPoint("LEFT",64,0);f.title:SetText(self:L("TITLE"));f.title:SetTextColor(1,0.84,0.48)
  f.version=top:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");f.version:SetPoint("LEFT",64,-22);f.version:SetText("v"..self.VERSION);f.version:SetTextColor(0.45,0.55,0.68)
  local close=CreateFrame("Button",nil,f,"UIPanelCloseButton");close:SetPoint("TOPRIGHT",4,4)
  local side=CreateFrame("Frame",nil,f,"BackdropTemplate");side:SetPoint("TOPLEFT",14,-88);side:SetSize(226,548);side:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=10,insets={left=3,right=3,top=3,bottom=3}});side:SetBackdropColor(0.012,0.018,0.03,0.98);side:SetBackdropBorderColor(0.35,0.28,0.13,0.9)
  local panel=CreateFrame("Frame",nil,f,"BackdropTemplate");panel:SetPoint("TOPLEFT",250,-88);panel:SetSize(716,548);panel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=10,insets={left=3,right=3,top=3,bottom=3}});panel:SetBackdropColor(0.012,0.018,0.03,0.98);panel:SetBackdropBorderColor(0.35,0.28,0.13,0.9)
  f.emblem=panel:CreateTexture(nil,"ARTWORK");f.emblem:SetTexture("Interface\\Icons\\INV_Misc_Gear_01");f.emblem:SetSize(126,126);f.emblem:SetPoint("TOPRIGHT",-36,-34);f.emblem:SetAlpha(0.2)
  f.header = panel:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge"); f.header:SetPoint("TOPLEFT",22,-22);f.header:SetTextColor(1,0.84,0.52)
  f.status = panel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall"); f.status:SetPoint("TOPLEFT",24,-55); f.status:SetTextColor(0.35,0.7,1)
  local scroll = CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate"); scroll:SetPoint("TOPLEFT",18,-82); scroll:SetSize(665,262); local content=CreateFrame("Frame",nil,scroll); content:SetWidth(635);content:SetHeight(262);scroll:SetScrollChild(content)
  f.scroll, f.content = scroll, content; f.body=content:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");f.body:SetPoint("TOPLEFT",8,-6);f.body:SetWidth(730);f.body:SetJustifyH("LEFT");f.body:SetJustifyV("TOP")
  f.pageButtons = {}; f.navButtons = {}; self.ui=f
  local nav = {{"HOME","Interface\\Icons\\INV_Misc_Gear_01",function()STBS:ShowHome()end},{"GRAPHICS","Interface\\Icons\\INV_Misc_EngGizmos_30",function()STBS:ShowGraphics()end},{"INTERFACE","Interface\\Icons\\INV_Misc_Note_01",function()STBS:ShowInterface()end},{"PROFILES","Interface\\Icons\\INV_Misc_Book_09",function()STBS:ShowProfiles()end},{"BACKUPS","Interface\\Icons\\INV_Misc_Bag_08",function()STBS:ShowBackups()end},{"DIAGNOSTICS","Interface\\Icons\\INV_Misc_QuestionMark",function()STBS:ShowDiagnostics()end}}
  for i,item in ipairs(nav) do local b=sidebarButton(side,self:L(item[1]),item[2],-18-(i-1)*48,item[3]);b.page=self:L(item[1]);table.insert(f.navButtons,b) end
end
function STBS:SetPage(title, text, actions, status)
  self:CreateUI(); local f=self.ui; f.header:SetText(title); f.status:SetText(status or "")
  if f.copyBox then f.copyBox:Hide() end
  f.body:SetText(text or "");f.body:SetWidth(620); f.content:SetHeight(math.max(262, f.body:GetStringHeight()+16)); f.scroll:SetVerticalScroll(0); f:Show()
  for _,nav in ipairs(f.navButtons) do nav:SetActive(nav.page==title) end
  for _,old in ipairs(f.pageButtons) do old:Hide() end; f.pageButtons={}
  for i,action in ipairs(actions or {}) do table.insert(f.pageButtons,button(f,action.label,270+((i-1)%2)*337,-460-math.floor((i-1)/2)*42,320,action.fn)) end
end
function STBS:FormatDiff(plan)
  local lines={"|cff82c5ff"..self:L("DIFF_HEADER").."|r"}
  for _,entry in ipairs(plan or {}) do table.insert(lines,entry.setting.key..": "..tostring(entry.current or self:L("UNAVAILABLE")).." → "..entry.value.." ("..self:L(string.upper(entry.status))..")") end
  return table.concat(lines,"\n")
end
function STBS:ShowHome()
  local selectedMode=self:GetSelectedMode()
  local mode=selectedMode==self.GRAPHICS_MODE_UNIFIED and self:L("UNIFIED") or selectedMode==self.GRAPHICS_MODE_SPLIT and self:L("SPLIT") or self:L("MODE_UNSET")
  local text="|cff82c5ff"..self:L("HOME_TEXT").."|r\n\n"..self:L("MODE")..": |cffffd100"..mode.."|r"
  local actions={}
  if not selectedMode then
    text=text.."\n\n"..self:L("GRAPHICS_TEXT")
    table.insert(actions,{label=self:L("UNIFIED"),fn=function()STBS:SetSelectedMode(STBS.GRAPHICS_MODE_UNIFIED);STBS:ShowOfficialPreview("all")end})
    table.insert(actions,{label=self:L("SPLIT"),fn=function()STBS:SetSelectedMode(STBS.GRAPHICS_MODE_SPLIT);STBS:ShowOfficialPreview("all")end})
  else
    text=text.."\n\n"..self:L("HARDWARE_PRESERVED")
    table.insert(actions,{label=self:L("PREVIEW")..": "..self:L("APPLY_ALL"),fn=function()STBS:ShowOfficialPreview("all")end})
    table.insert(actions,{label=self:L("GRAPHICS")..": "..(selectedMode==STBS.GRAPHICS_MODE_UNIFIED and self:L("SPLIT") or self:L("UNIFIED")),fn=function()STBS:SetSelectedMode(selectedMode==STBS.GRAPHICS_MODE_UNIFIED and STBS.GRAPHICS_MODE_SPLIT or STBS.GRAPHICS_MODE_UNIFIED);STBS:ShowOfficialPreview("all")end})
    table.insert(actions,{label=self:L("PREVIEW")..": "..self:L("APPLY_INTERFACE"),fn=function()STBS:ShowOfficialPreview("interface")end})
  end
  if self.pending then
    text=text.."\n\n|cffffd100"..self:L("PENDING").."|r"
    table.insert(actions,{label=self:L("CANCEL_PENDING"),fn=function()STBS:CancelPendingOperation();STBS:ShowHome()end})
  end
  self:SetPage(self:L("HOME"),text,actions)
  if not self.settingsRegistered then self.settingsRegistered=self:RegisterBlizzardSettings(self.ui) end
end
function STBS:ShowOfficialPreview(kind)
  local modules=kind=="graphics" and {graphics=true} or kind=="interface" and {interfaceGameplay=true} or {graphics=true,interfaceGameplay=true}; local settings={}
  if modules.graphics then local mode=self:GetSelectedMode();if not mode then self:ShowHome();return end;settings=self:FlattenProfile(self:GetOfficialGraphics(mode),{graphics=true}) end
  if modules.interfaceGameplay then for k,v in pairs(self:FlattenProfile(self:GetOfficialInterface(),{interfaceGameplay=true})) do settings[k]=v end end
  local plan=self:BuildDiff(settings);self:SetPage(self:L("PREVIEW"),self:FormatDiff(plan),{{label=self:L("CONFIRM")..": "..(kind=="all" and self:L("APPLY_ALL") or kind=="graphics" and self:L("APPLY_GRAPHICS") or self:L("APPLY_INTERFACE")),fn=function()STBS:ShowReport(STBS:ApplyOfficial(kind))end},{label=self:L("BACK"),fn=function()STBS:ShowHome()end}},self:L("STATUS")..": "..#plan.." settings")
end
function STBS:ShowGraphics()
  local mode=self:GetSelectedMode(); self:SetPage(self:L("GRAPHICS"),self:L("GRAPHICS_TEXT").."\n\n"..self:L("MODE")..": "..(mode==self.GRAPHICS_MODE_UNIFIED and self:L("UNIFIED") or mode==self.GRAPHICS_MODE_SPLIT and self:L("SPLIT") or self:L("MODE_UNSET")).."\n\n"..self:L("HARDWARE_PRESERVED"),{{label=self:L("SPLIT"),fn=function()STBS:SetSelectedMode(STBS.GRAPHICS_MODE_SPLIT);STBS:ShowGraphics()end},{label=self:L("UNIFIED"),fn=function()STBS:SetSelectedMode(STBS.GRAPHICS_MODE_UNIFIED);STBS:ShowGraphics()end},{label=self:L("PREVIEW"),fn=function()STBS:ShowOfficialPreview("graphics")end}})
end
function STBS:ShowInterface() self:SetPage(self:L("INTERFACE"),self:L("INTERFACE_TEXT").."\n\n"..self:L("PERSONAL_PRESERVED").."\n\n"..self:L("EDITMODE_UNAVAILABLE").."\n"..self:L("KEYBINDING_UNAVAILABLE"),{{label=self:L("PREVIEW"),fn=function()STBS:ShowOfficialPreview("interface")end}}) end
function STBS:OpenSaveDialog(modules)
  StaticPopupDialogs["STBS_SAVE"]={text=self:L("PROFILE_NAME"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=80,OnAccept=function(p)local profile=STBS:SaveCurrent(p.editBox:GetText(),modules);STBS.selectedProfileId=profile.id;STBS:ShowProfiles()end,OnShow=function(p)p.editBox:SetText("");p.editBox:SetFocus()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_SAVE")
end
function STBS:OpenRenameDialog(profile)
  StaticPopupDialogs["STBS_RENAME"]={text=self:L("PROFILE_NAME"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=80,OnAccept=function(p)STBS:RenameProfile(profile.id,p.editBox:GetText());STBS:ShowProfiles()end,OnShow=function(p)p.editBox:SetText(profile.displayName);p.editBox:SetFocus();p.editBox:HighlightText()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_RENAME")
end
function STBS:ShowProfiles()
  local profiles=self:ListPersonalProfiles();local selected=self:InitializeDatabase().profiles[self.selectedProfileId] or profiles[1];if selected then self.selectedProfileId=selected.id end
  local lines={"|cff82c5ff"..self:L("PROFILES").."|r"};if #profiles==0 then table.insert(lines,self:L("NO_PROFILES")) else for i,profile in ipairs(profiles)do table.insert(lines,(profile.id==self.selectedProfileId and "|cff33ff99> " or "  ")..i..". "..profile.displayName.."|r")end end;if selected then table.insert(lines,"\n"..self:L("SELECTED")..": |cffffd100"..selected.displayName.."|r") end
  local actions={{label=self:L("SAVE_GRAPHICS"),fn=function()STBS:OpenSaveDialog({graphics=true})end},{label=self:L("SAVE_INTERFACE"),fn=function()STBS:OpenSaveDialog({interfaceGameplay=true})end},{label=self:L("SAVE_ALL"),fn=function()STBS:OpenSaveDialog({graphics=true,interfaceGameplay=true})end},{label=self:L("IMPORT"),fn=function()STBS:OpenImport()end}}
  if selected then table.insert(actions,{label=self:L("EXPORT"),fn=function()STBS:ShowExport(selected)end});table.insert(actions,{label=self:L("RENAME"),fn=function()STBS:OpenRenameDialog(selected)end});table.insert(actions,{label=self:L("DELETE"),fn=function()STBS:DeleteProfile(selected.id);STBS.selectedProfileId=nil;STBS:ShowProfiles()end})end
  for i=1,math.min(#profiles,2)do local profile=profiles[i];table.insert(actions,{label=self:L("SELECT")..": "..profile.displayName,fn=function()STBS.selectedProfileId=profile.id;STBS:ShowProfiles()end})end
  self:SetPage(self:L("PROFILES"),table.concat(lines,"\n"),actions)
end
function STBS:ShowBackups()
  local backups=self:InitializeDatabase().backups;local selected=backups[self.selectedBackupIndex or 1];if selected then self.selectedBackupIndex=self.selectedBackupIndex or 1 end;local lines={"|cff82c5ff"..self:L("BACKUP_HISTORY").."|r"};if #backups==0 then table.insert(lines,self:L("NO_BACKUPS"))else for i,b in ipairs(backups)do table.insert(lines,(i==self.selectedBackupIndex and "|cff33ff99> " or "  ")..i..". "..tostring(b.trigger).." — "..date("%Y-%m-%d %H:%M",b.timestamp).."|r")end end
  local actions={{label=self:L("CREATE_BACKUP"),fn=function()STBS:CreateBackup({graphics=true,interfaceGameplay=true},"manual");STBS.selectedBackupIndex=1;STBS:ShowBackups()end}}
  if selected then table.insert(actions,{label=self:L("RESTORE_ALL"),fn=function()STBS:ShowReport(STBS:RestoreBackup(STBS.selectedBackupIndex,{graphics=true,interfaceGameplay=true}))end});table.insert(actions,{label=self:L("RESTORE_GRAPHICS"),fn=function()STBS:ShowReport(STBS:RestoreBackup(STBS.selectedBackupIndex,{graphics=true}))end});table.insert(actions,{label=self:L("RESTORE_INTERFACE"),fn=function()STBS:ShowReport(STBS:RestoreBackup(STBS.selectedBackupIndex,{interfaceGameplay=true}))end})end
  for i=1,math.min(#backups,2)do local index=i;table.insert(actions,{label=self:L("SELECT")..": #"..index,fn=function()STBS.selectedBackupIndex=index;STBS:ShowBackups()end})end;self:SetPage(self:L("BACKUPS"),table.concat(lines,"\n"),actions)
end
function STBS:ShowDiagnostics() self:SetPage(self:L("DIAGNOSTICS"),self:DiagnosticReport(),{{label=self:L("COPY"),fn=function()STBS:ShowCopyBox(STBS:DiagnosticReport())end}}) end
function STBS:ShowCopyBox(text)
  self:CreateUI();local f=self.ui;local box=f.copyBox;if not box then box=CreateFrame("EditBox",nil,f,"InputBoxTemplate");box:SetMultiLine(true);box:SetAutoFocus(false);box:SetFontObject(ChatFontNormal);box:SetWidth(650);box:SetHeight(235);box:SetPoint("TOPLEFT",28,-132);box:SetScript("OnEscapePressed",function(x)x:ClearFocus()end);f.copyBox=box end;box:SetText(text);box:Show();box:SetFocus();box:HighlightText();f:Show()
end
function STBS:ShowExport(profile) local output=self:ExportProfile(profile,{graphics=true,interfaceGameplay=true});self:SetPage(self:L("EXPORT"),self:L("EXPORT_HELP").."\n\n"..self:L("SELECTED")..": "..profile.displayName.."\n"..self:L("SIZE")..": "..#output.." bytes",{{label=self:L("COPY"),fn=function()STBS:ShowCopyBox(output)end},{label=self:L("BACK"),fn=function()STBS:ShowProfiles()end}}) end
function STBS:OpenImport()
  StaticPopupDialogs["STBS_IMPORT"]={text=self:L("IMPORT_PROMPT"),button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=STBS.MAX_IMPORT_BYTES,OnAccept=function(p)local payload,why=STBS:ImportProfile(p.editBox:GetText());if not payload then STBS:SetPage(STBS:L("IMPORT"),STBS:L("INVALID_IMPORT").." ("..tostring(why)..")");return end;STBS.pendingImport=payload;STBS:ShowImportPreview(payload)end,OnShow=function(p)p.editBox:SetText("");p.editBox:SetFocus()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_IMPORT")
end
function STBS:ApplyPendingImport(modules, graphicsMode) local plan,settings=self:PlanImport(self.pendingImport,modules,graphicsMode);if not plan then return end;self.pendingImport=nil;self:ShowReport(self:ApplySettings(settings,modules,"profile-import")) end
function STBS:ShowImportPreview(payload)
  local plan=self:PlanImport(payload,payload.selectedModules,"profile");local changed=0;for _,entry in ipairs(plan or {})do if entry.status=="changed"then changed=changed+1 end end;local actions={}
  if payload.selectedModules.graphics then table.insert(actions,{label=self:L("IMPORT_GRAPHICS")..": "..self:L("USE_PROFILE_MODE"),fn=function()STBS:ApplyPendingImport({graphics=true},"profile")end});table.insert(actions,{label=self:L("IMPORT_GRAPHICS")..": "..self:L("KEEP_MODE"),fn=function()STBS:ApplyPendingImport({graphics=true},"current")end})end
  if payload.selectedModules.interfaceGameplay then table.insert(actions,{label=self:L("IMPORT_INTERFACE"),fn=function()STBS:ApplyPendingImport({interfaceGameplay=true},"profile")end})end
  if payload.selectedModules.graphics and payload.selectedModules.interfaceGameplay then table.insert(actions,{label=self:L("IMPORT_ALL"),fn=function()STBS:ApplyPendingImport({graphics=true,interfaceGameplay=true},"profile")end})end;table.insert(actions,{label=self:L("BACK"),fn=function()STBS.pendingImport=nil;STBS:ShowProfiles()end})
  self:SetPage(self:L("IMPORT"),"|cff82c5ff"..self:L("PROFILE_SUMMARY").."|r\n"..tostring(payload.profile.displayName).."\n"..self:L("CHANGED")..": "..changed.."\n\n"..self:FormatDiff(plan).."\n\n"..self:L("IMPORT_CONFIRMATION"),actions)
end
function STBS:ShowReport(r)
  if not r.ok and not r.data then self:SetPage(self:L("TITLE"),r.code=="queued" and self:L("PENDING") or r.code=="pending-exists" and self:L("PENDING") or self:L("INVALID_IMPORT"));return end
  local d=r.data;local warning=not r.ok and "|cffff4040"..self:L("TRANSACTION_ROLLED_BACK").."|r\n\n" or "";self:SetPage(self:L("TITLE"),warning.."|cff33ff99"..self:L("REPORT_GRAPHICS").."|r\n"..resultSummary(d.graphics).."\n\n|cff33ff99"..self:L("REPORT_INTERFACE").."|r\n"..resultSummary(d.interfaceGameplay),{{label=self:L("HOME"),fn=function()STBS:ShowHome()end}})
end
