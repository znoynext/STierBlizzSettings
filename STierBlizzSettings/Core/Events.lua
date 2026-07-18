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
      elseif msg=="tweaks" or msg=="ui" then STBS:ShowUITweaks()
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
  if event=="PLAYER_REGEN_ENABLED" and STBS:GetPendingOperation() then
    local current=STBS:GetPendingOperation()
    if current.kind=="zone-auto" then STBS:CancelPendingOperation("zone-auto");STBS:ApplyZoneGraphics("zone-change");return end
    local completed=STBS:CompletePendingOperation();local completedData=type(completed.data)=="table" and completed.data or {};local pending=completedData.operation;local result=completedData.result or completed
    if result.code=="queued" or type(pending)~="table" then return end
    local context=type(pending.context)=="table" and pending.context or {}
    if pending.kind=="zone-manual" then
      local data=type(result.data)=="table" and result.data or nil
      local graphics=data and type(data.graphics)=="table" and data.graphics or nil
      local changed=result.ok and graphics and tonumber(graphics.changed) or 0
      local category=context.category or STBS:GetZoneCategory();local preset=context.preset or STBS.activeZonePreset
      STBS.zoneStatus={ok=result.ok,code=result.code,category=category,preset=preset,changed=changed}
      if result.ok then STBS:CommitActiveZoneGraphicsState(category,preset);STBS:SetSelectedMode(context.mode or STBS.GRAPHICS_MODE_UNIFIED);STBS:SetSelectedPreset(preset) else STBS:ClearActiveZoneGraphicsState() end
      if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="graphics" and STBS.ui.currentGraphicsSection=="zones" then STBS:ShowZoneGraphics() end
    end
    local recovery=context.reason or pending.trigger
    if pending.kind=="recovery" and (recovery=="fps-compare-restore" or recovery=="fps-compare-cancel-restore") then
      if result.ok then STBS:DiscardTemporaryFPSRestoreBackup(recovery) else STBS:FinalizeBackupLimit() end
      if recovery=="fps-compare-restore" then local comparison=STBS:GetLastPresetFPSComparison();if comparison then comparison.restoreQueued=false;comparison.restoreFailed=not result.ok;STBS:StorePresetFPSComparison(comparison) end end
      STBS.fpsPresetRestorePending=nil;STBS.flashMessage=result.ok and STBS:L("FPS_COMPARE_RESTORED") or STBS:L("FPS_COMPARE_RESTORE_FAILED");STBS.flashKind=result.ok and "success" or "error"
      if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="fpsTest" then STBS:ShowFPSTest() end
    end
    if pending.kind=="ui-tweaks" then
      if result.ok then STBS.uiTweaksDraft=nil end
      STBS.flashMessage=result.ok and string.format(STBS:L("UI_TWEAK_APPLIED"),(result.data and result.data.uiTweaks and result.data.uiTweaks.changed) or 0) or STBS:L("APPLY_FAILED");STBS.flashKind=result.ok and "success" or "error"
      if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="uiTweaks" then STBS:ShowUITweaks() end
    end
    if pending.kind=="graphics-user" and context.automaticFPS then
      STBS:ResetFPSBaselineSampling()
      STBS.flashMessage=result.ok and STBS:L("SETTINGS_APPLIED_DELAYED_NO_MEASURE") or STBS:L("APPLY_FAILED").." ("..tostring(result.code)..")";STBS.flashKind=result.ok and "success" or "error"
      if STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="graphics" then STBS:ShowGraphics() end
      if result.ok then STBS:ConfirmReloadUI() end
    end
  end
end)
