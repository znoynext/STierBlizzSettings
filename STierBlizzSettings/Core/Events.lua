local _, STBS = ...
local frame=CreateFrame("Frame");frame:RegisterEvent("ADDON_LOADED");frame:RegisterEvent("PLAYER_REGEN_ENABLED");frame:RegisterEvent("PLAYER_ENTERING_WORLD");frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent",function(_,event,arg)
  if event=="ADDON_LOADED" and arg==STBS.ADDON then
    STBS:InitializeDatabase();STBS:CreateMinimapButton();STBS:InitializePerformanceWidget();STBS:Print("WELCOME")
    SLASH_STIERBLIZZSETTINGS1="/stier";SLASH_STIERBLIZZSETTINGS2="/stbs"
    SlashCmdList.STIERBLIZZSETTINGS=function(msg)
      msg=(msg or ""):lower()
      if msg=="profiles" or msg=="backup" or msg=="restore" or msg=="save" or msg=="export" or msg=="import" then STBS:ShowProfiles()
      elseif msg=="zone" then STBS:ShowZoneGraphics()
      elseif msg=="fps" or msg=="test" then STBS:ShowFPSTest()
      elseif msg=="about" then STBS:ShowAbout()
      elseif msg=="debug" then STBS:ShowDiagnostics()
      else STBS:ShowGraphics() end
    end
  end
  if (event=="PLAYER_ENTERING_WORLD" or event=="ZONE_CHANGED_NEW_AREA") and STBS.ADDON then
    if C_Timer and type(C_Timer.After)=="function" then C_Timer.After(0.8,function()if STBS:GetZoneGraphicsConfig().enabled then STBS:ApplyZoneGraphics("zone-change") end end)
    elseif STBS:GetZoneGraphicsConfig().enabled then STBS:ApplyZoneGraphics("zone-change") end
  end
  if event=="PLAYER_REGEN_ENABLED" and STBS.pending then
    local pending=STBS.pending;STBS.pending=nil
    local result=STBS:ApplySettings(pending.settings,pending.modules,pending.trigger,pending.options)
    if pending.trigger=="zone-change" or pending.trigger=="zone-enabled" or pending.trigger=="zone-manual" then
      STBS.zoneStatus={ok=result.ok,code=result.code,category=STBS:GetZoneCategory(),preset=STBS.activeZonePreset,changed=result.data and result.data.changed or 0}
      if result.ok then STBS.reloadRecommended=true end
      if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="graphics" and STBS.ui.currentGraphicsSection=="zones" then STBS:ShowZoneGraphics() end
    end
    if result.ok and pending.options and pending.options.fpsBefore then
      STBS.reloadRecommended=true;STBS.flashMessage=STBS:L("SETTINGS_APPLIED");STBS.flashKind="success"
      STBS:StartFPSPostMeasurement(pending.options.fpsBefore,function()if STBS.ui and STBS.ui:IsShown() then STBS:ShowGraphics() end end)
    end
  end
end)
