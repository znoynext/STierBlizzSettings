local _, STBS = ...
local function button(parent,text,x,y,fn)
  local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate"); b:SetSize(190,24); b:SetPoint("TOPLEFT",x,y); b:SetText(text); b:SetScript("OnClick",fn); return b
end
local function summary(data)
  local lines={"Changed: "..(data.changed or 0),"Already configured: "..(data.identical or 0),"Skipped: "..(data.skipped or 0),"Unavailable: "..(data.unavailable or 0),"Failed: "..(data.failed or 0)}
  for _,category in ipairs({"graphics","raidGraphics","interface","camera","gameplay","controls","combat","nameplates","chat"}) do local item=data.categories and data.categories[category];if item then table.insert(lines,category..": changed "..(item.changed or 0)..", skipped "..(item.skipped or 0)..", unavailable "..(item.unavailable or 0)..", failed "..(item.failed or 0))end end
  return table.concat(lines,"\n")
end
function STBS:CreateUI()
  if self.ui then return end
  local f=CreateFrame("Frame","STierBlizzSettingsFrame",UIParent,"BasicFrameTemplateWithInset");f:SetSize(700,560);f:SetPoint("CENTER");f:SetMovable(true);f:EnableMouse(true);f:RegisterForDrag("LeftButton");f:SetScript("OnDragStart",f.StartMoving);f:SetScript("OnDragStop",f.StopMovingOrSizing);f:Hide();f.TitleText:SetText(self:L("TITLE"))
  local title=f:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge");title:SetPoint("TOPLEFT",18,-42);local body=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");body:SetPoint("TOPLEFT",18,-77);body:SetWidth(660);body:SetJustifyH("LEFT");body:SetJustifyV("TOP");f.title=title;f.body=body;f.buttons={};self.ui=f
  local nav={{"Home",function()STBS:ShowHome()end},{"Graphics",function()STBS:ShowGraphics()end},{"Interface",function()STBS:ShowInterface()end},{"Profiles",function()STBS:ShowProfiles()end},{"Backups",function()STBS:ShowBackups()end},{"Diagnostics",function()STBS:ShowDiagnostics()end}}
  for i,item in ipairs(nav)do button(f,STBS:L(item[1]:upper()),18+(i-1)*112,-510,item[2]):SetWidth(105)end
end
function STBS:SetPage(title,text,actions)
  self:CreateUI(); local f=self.ui;f.title:SetText(title);f.body:SetText(text);f:Show()
  for _,old in ipairs(f.buttons)do old:Hide()end;f.buttons={}
  for i,action in ipairs(actions or {})do local b=button(f,action.label,18+((i-1)%3)*222,-400-math.floor((i-1)/3)*30,action.fn);b:SetWidth(210);table.insert(f.buttons,b)end
end
function STBS:ShowHome()
  local mode=self:GetSelectedMode()==self.GRAPHICS_MODE_UNIFIED and self:L("UNIFIED") or self:GetSelectedMode()==self.GRAPHICS_MODE_SPLIT and self:L("SPLIT") or self:L("MODE_UNSET")
  self:SetPage(self:L("HOME"),self:L("HOME_TEXT").."\n\n"..self:L("MODE")..": "..mode,{{label=self:L("APPLY_ALL"),fn=function()STBS:ShowReport(STBS:ApplyOfficial("all"))end},{label=self:L("APPLY_GRAPHICS"),fn=function()STBS:ShowReport(STBS:ApplyOfficial("graphics"))end},{label=self:L("APPLY_INTERFACE"),fn=function()STBS:ShowReport(STBS:ApplyOfficial("interface"))end},{label="Cancel Pending Operation",fn=function()STBS:CancelPendingOperation();STBS:ShowHome()end}})
  if self.pending then self.ui.body:SetText(self.ui.body:GetText().."\n\nPending operation is queued for after combat.") end
  if not self.settingsRegistered then self.settingsRegistered=self:RegisterBlizzardSettings(self.ui) end
end
function STBS:ShowGraphics()
  self:SetPage(self:L("GRAPHICS"),self:L("GRAPHICS_TEXT").."\n\nIncluded: base graphics, optional raid/battleground graphics, visibility safeguards and supported image AA.\nPreserved: display device, resolution, refresh rate, V-Sync, FPS limits and latency settings.",{{label=self:L("SPLIT"),fn=function()STBS:SetSelectedMode(STBS.GRAPHICS_MODE_SPLIT);STBS:ShowGraphics()end},{label=self:L("UNIFIED"),fn=function()STBS:SetSelectedMode(STBS.GRAPHICS_MODE_UNIFIED);STBS:ShowGraphics()end},{label=self:L("APPLY_GRAPHICS"),fn=function()STBS:ShowReport(STBS:ApplyOfficial("graphics"))end}})
end
function STBS:ShowInterface()
  self:SetPage(self:L("INTERFACE"),"The current official profile contains exactly one verified recommendation:\n\nCamera Follow Style: Never Adjust Camera\n\nAccessibility, sound, mouse controls, UI scale, keybindings and other personal choices are preserved.",{{label=self:L("APPLY_INTERFACE"),fn=function()STBS:ShowReport(STBS:ApplyOfficial("interface"))end}})
end
function STBS:OpenSaveDialog()
  StaticPopupDialogs["STBS_SAVE"]={text="Name this personal profile:",button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=80,OnAccept=function(p)local name=p.editBox:GetText();local profile=STBS:SaveCurrent(name,{graphics=true,interfaceGameplay=true});STBS.selectedProfileId=profile.id;STBS:ShowProfiles()end,OnShow=function(p)p.editBox:SetText("");p.editBox:SetFocus()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_SAVE")
end
function STBS:ShowProfiles()
  local profiles=self:ListPersonalProfiles();local lines={"Personal profiles:"};for i,p in ipairs(profiles)do table.insert(lines,i..". "..p.displayName.." ("..p.id..")")end;if #profiles==0 then table.insert(lines,"No saved personal profiles yet.")end
  local selected=self:InitializeDatabase().profiles[self.selectedProfileId] or profiles[1];if selected then self.selectedProfileId=selected.id end
  local actions={{label=self:L("SAVE"),fn=function()STBS:OpenSaveDialog()end},{label=self:L("IMPORT"),fn=function()STBS:OpenImport()end}}
  if selected then table.insert(actions,{label=self:L("EXPORT"),fn=function()STBS:ShowExport(selected)end});table.insert(actions,{label="Delete selected",fn=function()STBS:DeleteProfile(selected.id);STBS.selectedProfileId=nil;STBS:ShowProfiles()end})end
  for i=1,math.min(#profiles,3) do local profile=profiles[i];table.insert(actions,{label="Select: "..profile.displayName,fn=function()STBS.selectedProfileId=profile.id;STBS:ShowProfiles()end})end
  self:SetPage(self:L("PROFILES"),table.concat(lines,"\n")..(selected and "\n\nSelected: "..selected.displayName or ""),actions)
end
function STBS:ShowBackups()
  local backups=self:InitializeDatabase().backups;local lines={"Backup history:"};for i,b in ipairs(backups)do table.insert(lines,i..". "..tostring(b.trigger).." — "..date("%Y-%m-%d %H:%M",b.timestamp))end;if #backups==0 then table.insert(lines,"No backups yet.")end
  local actions={{label=self:L("CREATE_BACKUP"),fn=function()STBS:CreateBackup({graphics=true,interfaceGameplay=true},"manual");STBS:ShowBackups()end}}
  if backups[1] then table.insert(actions,{label=self:L("RESTORE_ALL"),fn=function()STBS:ShowReport(STBS:RestoreBackup(1,{graphics=true,interfaceGameplay=true}))end});table.insert(actions,{label=self:L("RESTORE_GRAPHICS"),fn=function()STBS:ShowReport(STBS:RestoreBackup(1,{graphics=true}))end});table.insert(actions,{label=self:L("RESTORE_INTERFACE"),fn=function()STBS:ShowReport(STBS:RestoreBackup(1,{interfaceGameplay=true}))end})end
  self:SetPage(self:L("BACKUPS"),table.concat(lines,"\n"),actions)
end
function STBS:ShowDiagnostics() self:SetPage(self:L("DIAGNOSTICS"),self:DiagnosticReport(),{{label=self:L("COPY"),fn=function()STBS:ShowCopyBox(STBS:DiagnosticReport())end}}) end
function STBS:ShowCopyBox(text)
  self:CreateUI();local box=self.ui.copyBox;if not box then box=CreateFrame("EditBox",nil,self.ui,"InputBoxTemplate");box:SetMultiLine(true);box:SetAutoFocus(false);box:SetFontObject(ChatFontNormal);box:SetWidth(650);box:SetHeight(220);box:SetPoint("TOPLEFT",18,-145);box:SetScript("OnEscapePressed",function(x)x:ClearFocus()end);self.ui.copyBox=box end;box:SetText(text);box:Show();box:SetFocus();box:HighlightText();self.ui:Show()
end
function STBS:ShowExport(profile) self:SetPage(self:L("EXPORT"),self:L("EXPORT_HELP").."\n\nProfile: "..profile.displayName,{{label=self:L("COPY"),fn=function()STBS:ShowCopyBox(STBS:ExportProfile(profile,{graphics=true,interfaceGameplay=true}))end}}) end
function STBS:OpenImport()
  StaticPopupDialogs["STBS_IMPORT"]={text="Paste an STBS1 profile string:",button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=STBS.MAX_IMPORT_BYTES,OnAccept=function(p)local payload,why=STBS:ImportProfile(p.editBox:GetText());if not payload then STBS:SetPage(STBS:L("IMPORT"),STBS:L("INVALID_IMPORT").." ("..tostring(why)..")");return end;STBS.pendingImport=payload;STBS:ShowImportPreview(payload)end,OnShow=function(p)p.editBox:SetText("");p.editBox:SetFocus()end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3};StaticPopup_Show("STBS_IMPORT")
end
function STBS:ApplyPendingImport(modules, graphicsMode)
  local plan,settings=self:PlanImport(self.pendingImport,modules,graphicsMode);if not plan then return end;self.pendingImport=nil;self:ShowReport(self:ApplySettings(settings,modules,"profile-import"))
end
function STBS:ShowImportPreview(payload)
  local plan=self:PlanImport(payload,payload.selectedModules,"profile");local changed=0;for _,entry in ipairs(plan or {})do if entry.status=="changed"then changed=changed+1 end end
  self:SetPage(self:L("IMPORT"),"Profile Summary\nName: "..tostring(payload.profile.displayName).."\nChanges planned: "..changed.."\n\nChoose what to import. Nothing has been applied yet.",{{label="Graphics only",fn=function()STBS:ApplyPendingImport({graphics=true,interfaceGameplay=false},"profile")end},{label="Interface & Gameplay only",fn=function()STBS:ApplyPendingImport({graphics=false,interfaceGameplay=true},"profile")end},{label="Everything",fn=function()STBS:ApplyPendingImport({graphics=true,interfaceGameplay=true},"profile")end},{label="Graphics: keep current mode",fn=function()STBS:ApplyPendingImport({graphics=true,interfaceGameplay=false},"current")end}})
end
function STBS:ShowReport(r)
  if not r.ok then self:SetPage(self:L("TITLE"),r.code=="queued" and self:L("APPLY_QUEUED") or r.code=="pending-exists" and "An operation is already queued." or self:L("INVALID_IMPORT"));return end
  local d=r.data;self:SetPage(self:L("TITLE"),self:L("REPORT_GRAPHICS").."\n"..summary(d.graphics).."\n\n"..self:L("REPORT_INTERFACE").."\n"..summary(d.interfaceGameplay))
end
