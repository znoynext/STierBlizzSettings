local _, STBS = ...
local frame=CreateFrame("Frame");frame:RegisterEvent("ADDON_LOADED");frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent",function(_,event,arg)
  if event=="ADDON_LOADED" and arg==STBS.ADDON then
    STBS:InitializeDatabase();STBS:CreateMinimapButton();STBS:Print("WELCOME")
    SLASH_STIERBLIZZSETTINGS1="/stier";SLASH_STIERBLIZZSETTINGS2="/stbs"
    SlashCmdList.STIERBLIZZSETTINGS=function(msg)
      msg=(msg or ""):lower()
      if msg=="profiles" or msg=="backup" or msg=="restore" or msg=="save" or msg=="export" or msg=="import" then STBS:ShowProfiles()
      elseif msg=="debug" then STBS:ShowDiagnostics()
      else STBS:ShowGraphics() end
    end
  end
  if event=="PLAYER_REGEN_ENABLED" and STBS.pending then
    local pending=STBS.pending;STBS.pending=nil
    local result=STBS:ApplySettings(pending.settings,pending.modules,pending.trigger,pending.options)
    if result.ok and pending.options and pending.options.fpsBefore then
      STBS:StartFPSPostMeasurement(pending.options.fpsBefore,function()if STBS.ui and STBS.ui:IsShown() then STBS:ShowGraphics() end end)
    end
  end
end)
