local _, STBS = ...
local frame=CreateFrame("Frame");frame:RegisterEvent("ADDON_LOADED");frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent",function(_,event,arg)
  if event=="ADDON_LOADED" and arg==STBS.ADDON then STBS:InitializeDatabase();SLASH_STIERBLIZZSETTINGS1="/stier";SLASH_STIERBLIZZSETTINGS2="/stbs";SlashCmdList.STIERBLIZZSETTINGS=function(msg) msg=(msg or ""):lower();if msg=="graphics" then STBS:ShowGraphics() elseif msg=="interface" then STBS:ShowInterface() elseif msg=="apply" then STBS:ShowHome() elseif msg=="save" then STBS:OpenSaveDialog() elseif msg=="export" then STBS:ShowProfiles() elseif msg=="import" then STBS:OpenImport() elseif msg=="backup" then STBS:CreateBackup({graphics=true,interfaceGameplay=true},"manual");STBS:ShowBackups() elseif msg=="restore" then STBS:ShowBackups() elseif msg=="debug" then STBS:ShowDiagnostics() else STBS:ShowHome() end end
  end
  if event=="PLAYER_REGEN_ENABLED" and STBS.pending then local p=STBS.pending;STBS.pending=nil;STBS:ApplySettings(p.settings,p.modules,p.trigger,p.options) end
end)
