local _, STBS = ...
local function button(parent,text,x,y,fn) local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate");b:SetSize(190,24);b:SetPoint("TOPLEFT",x,y);b:SetText(text);b:SetScript("OnClick",fn);return b end
function STBS:ShowText(title,text)
  self:CreateUI();self.ui.title:SetText(title);self.ui.body:SetText(text);self.ui:Show()
end
function STBS:ShowExport(profile)
  self:CreateUI()
  local encoded = self:ExportProfile(profile, { graphics=true, interfaceGameplay=true })
  self.ui.title:SetText(self:L("EXPORT")); self.ui.body:SetText(self:L("EXPORT_HELP").."\nSize: "..#encoded.." bytes")
  local box = self.ui.exportBox
  if not box then
    box=CreateFrame("EditBox",nil,self.ui,"InputBoxTemplate");box:SetMultiLine(true);box:SetAutoFocus(false);box:SetFontObject(ChatFontNormal);box:SetWidth(590);box:SetHeight(135);box:SetPoint("TOPLEFT",18,-145);box:SetScript("OnEscapePressed",function(x)x:ClearFocus()end);self.ui.exportBox=box
    button(self.ui,self:L("COPY"),220,-285,function() box:SetFocus();box:HighlightText() end)
  end
  box:SetText(encoded);box:Show();self.ui:Show()
end
function STBS:OpenImport()
  StaticPopupDialogs["STBS_IMPORT"] = StaticPopupDialogs["STBS_IMPORT"] or {
    text = "Paste an STBS1 profile string:", button1 = ACCEPT, button2 = CANCEL, hasEditBox = true, maxLetters = STBS.MAX_IMPORT_BYTES,
    OnAccept = function(popup)
      local payload, why = STBS:ImportProfile(popup.editBox:GetText())
      if not payload then STBS:ShowText(STBS:L("IMPORT"),STBS:L("INVALID_IMPORT").." ("..tostring(why)..")"); return end
      local modules = payload.selectedModules or { graphics=true, interfaceGameplay=true }
      local settings = STBS:FlattenProfile(payload.profile, modules)
      STBS:ShowReport(STBS:ApplySettings(settings, modules, "profile-import"))
    end,
    OnShow = function(popup) popup.editBox:SetText(""); popup.editBox:SetFocus() end,
    EditBoxOnEscapePressed = function(editBox) editBox:GetParent():Hide() end,
    timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
  }
  StaticPopup_Show("STBS_IMPORT")
end
function STBS:CreateUI()
  if self.ui then return end;local f=CreateFrame("Frame","STierBlizzSettingsFrame",UIParent,"BasicFrameTemplateWithInset");f:SetSize(650,520);f:SetPoint("CENTER");f:SetMovable(true);f:EnableMouse(true);f:RegisterForDrag("LeftButton");f:SetScript("OnDragStart",f.StartMoving);f:SetScript("OnDragStop",f.StopMovingOrSizing);f:Hide();f.TitleText:SetText(self:L("TITLE"));local title=f:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge");title:SetPoint("TOPLEFT",18,-42);local body=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");body:SetPoint("TOPLEFT",18,-75);body:SetPoint("BOTTOMRIGHT",-18,18);body:SetJustifyH("LEFT");body:SetJustifyV("TOP");body:SetText("");f.title=title;f.body=body;self.ui=f
  button(f,self:L("APPLY_ALL"),18,-320,function() local r=STBS:ApplyOfficial("all");STBS:ShowReport(r) end);button(f,self:L("APPLY_GRAPHICS"),220,-320,function() local r=STBS:ApplyOfficial("graphics");STBS:ShowReport(r) end);button(f,self:L("APPLY_INTERFACE"),422,-320,function() local r=STBS:ApplyOfficial("interface");STBS:ShowReport(r) end)
  button(f,self:L("SPLIT"),18,-354,function() STBS:SetSelectedMode(STBS.GRAPHICS_MODE_SPLIT);STBS:ShowHome() end);button(f,self:L("UNIFIED"),220,-354,function() STBS:SetSelectedMode(STBS.GRAPHICS_MODE_UNIFIED);STBS:ShowHome() end);button(f,self:L("CREATE_BACKUP"),422,-354,function() STBS:CreateBackup({graphics=true,interfaceGameplay=true},"manual");STBS:Print("BACKUP_CREATED") end)
end
function STBS:ShowHome() self:ShowText(self:L("HOME"),self:L("HOME_TEXT").."\n\n"..self:L("MODE")..": "..(self:GetSelectedMode()==self.GRAPHICS_MODE_UNIFIED and self:L("UNIFIED") or self:GetSelectedMode()==self.GRAPHICS_MODE_SPLIT and self:L("SPLIT") or self:L("MODE_UNSET"))); if not self.settingsRegistered then self.settingsRegistered=self:RegisterBlizzardSettings(self.ui) end end
function STBS:ShowReport(r) if not r.ok then self:ShowText(self:L("TITLE"),r.code=="queued" and self:L("APPLY_QUEUED") or (r.code=="mode" and self:L("MODE_UNSET") or self:L("INVALID_IMPORT")));return end;local d=r.data;local function s(x)return self:L("CHANGED")..": "..(x.changed or 0).."\n"..self:L("IDENTICAL")..": "..(x.identical or 0).."\n"..self:L("SKIPPED")..": "..(x.skipped or 0).."\n"..self:L("FAILED")..": "..(x.failed or 0) end;self:ShowText(self:L("TITLE"),self:L("REPORT_GRAPHICS").."\n"..s(d.graphics).."\n\n"..self:L("REPORT_INTERFACE").."\n"..s(d.interfaceGameplay)) end
