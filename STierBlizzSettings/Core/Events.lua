local _, STBS = ...
local frame=CreateFrame("Frame");frame:RegisterEvent("ADDON_LOADED");frame:RegisterEvent("PLAYER_REGEN_ENABLED");frame:RegisterEvent("PLAYER_ENTERING_WORLD");frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent",function(_,event,arg)
  if event=="ADDON_LOADED" and arg==STBS.ADDON then
    local db=STBS:InitializeDatabase();if db.graphicsStateNeedsSync then STBS:SyncAppliedGraphicsState() end;STBS:CreateMinimapButton();STBS:InitializePerformanceWidget();STBS:Print("WELCOME")
    SLASH_STIERBLIZZSETTINGS1="/stier";SLASH_STIERBLIZZSETTINGS2="/stbs"
    SlashCmdList.STIERBLIZZSETTINGS=function(msg)
      msg=(msg or ""):lower()
      if msg=="profiles" or msg=="backup" or msg=="restore" or msg=="save" or msg=="export" or msg=="import" then STBS:ShowProfiles()
      elseif msg=="zone" then STBS:ShowZoneGraphics()
      elseif msg=="tweaks" or msg=="ui" then STBS:ShowUITweaks()
      elseif msg=="fps" or msg=="test" then STBS:ShowFPSTest()
      elseif msg=="about" then STBS:ShowAbout()
      elseif msg=="debug" then STBS:ShowDiagnostics()
      elseif msg=="reset" then STBS:ResetUILayoutAndShow()
      else STBS:ShowGraphics() end
    end
  end
  if (event=="PLAYER_ENTERING_WORLD" or event=="ZONE_CHANGED_NEW_AREA") and STBS.ADDON then
    if C_Timer and type(C_Timer.After)=="function" then C_Timer.After(0.8,function()if STBS:GetZoneGraphicsConfig().enabled then STBS:ApplyZoneGraphics("zone-change") end end)
    elseif STBS:GetZoneGraphicsConfig().enabled then STBS:ApplyZoneGraphics("zone-change") end
  end
  if event=="PLAYER_REGEN_ENABLED" and STBS:GetPendingOperation() then
    STBS:CompletePendingAfterCombat()
  end
end)
