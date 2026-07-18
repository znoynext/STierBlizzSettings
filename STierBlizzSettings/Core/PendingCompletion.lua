local _, STBS = ...

local handlers={}

local function resultChanged(result,module)
  local data=type(result.data)=="table" and result.data or nil
  local stats=data and type(data[module])=="table" and data[module] or nil
  return result.ok and stats and tonumber(stats.changed) or 0
end

local function visible(self,page,section)
  return self.ui and self.ui:IsShown() and self.ui.currentPageKey==page and (not section or self.ui.currentGraphicsSection==section)
end

local function failedMessage(self,key,result)
  return string.format(self:L(key),tostring(result.code or "failed"))
end

handlers["graphics-user"]=function(self,operation,result)
  local context=type(operation.context)=="table" and operation.context or {}
  if context.automaticFPS then self:ResetFPSBaselineSampling() end
  if result.ok then
    if context.mode then self:CommitAppliedGraphicsState(context.mode,context.preset) end
    self.flashMessage=result.code=="unchanged" and self:L("SETTINGS_UNCHANGED") or context.automaticFPS and self:L("SETTINGS_APPLIED_DELAYED_NO_MEASURE") or self:L("SETTINGS_APPLIED_NO_MEASURE");self.flashKind="success"
  else
    self.flashMessage=failedMessage(self,"PENDING_GRAPHICS_FAILED",result);self.flashKind="error"
  end
  if visible(self,"graphics") then self:ShowGraphics() end
  if result.ok and result.code~="unchanged" and operation.modules and operation.modules.graphics then self:ConfirmReloadUI() end
end

local function handleZone(self,operation,result)
  local context=type(operation.context)=="table" and operation.context or {};local previous=type(self.zoneStatus)=="table" and self.zoneStatus or {}
  local category=context.category or previous.category or self:GetZoneCategory();local preset=context.preset or previous.preset
  local changed=result.code=="unchanged" and 0 or resultChanged(result,"graphics")
  self.zoneStatus={ok=result.ok==true,code=result.code,category=category,preset=preset,changed=changed}
  if result.ok then self:CommitActiveZoneGraphicsState(category,preset);if context.mode then self:CommitAppliedGraphicsState(context.mode,preset) end else self:ClearActiveZoneGraphicsState() end
  if visible(self,"graphics","zones") then self:ShowZoneGraphics() end
end

handlers["zone-auto"]=handleZone
handlers["zone-manual"]=handleZone

handlers["ui-tweaks"]=function(self,operation,result)
  if result.ok then self.uiTweaksDraft=nil;self.flashMessage=result.code=="unchanged" and self:L("UI_TWEAK_ALREADY") or string.format(self:L("UI_TWEAK_APPLIED"),resultChanged(result,"uiTweaks"));self.flashKind="success"
  else self.flashMessage=self:L("APPLY_FAILED").." ("..tostring(result.code or "failed")..")";self.flashKind="error" end
  if visible(self,"uiTweaks") then self:ShowUITweaks() end
end

handlers.recovery=function(self,operation,result)
  local context=type(operation.context)=="table" and operation.context or {};local reason=context.reason or operation.trigger
  local fpsRestore=reason=="fps-compare-restore" or reason=="fps-compare-cancel-restore"
  if fpsRestore then
    self:FinalizeFPSComparisonRestore(result,context.comparisonSessionId)
    if result.ok and operation.modules and operation.modules.graphics then self:SyncAppliedGraphicsState() end
    if reason=="fps-compare-restore" then local comparison=self:GetLastPresetFPSComparison();if comparison then comparison.restoreQueued=false;comparison.restoreFailed=not result.ok;self:StorePresetFPSComparison(comparison) end end
    self.fpsPresetRestorePending=nil;self.flashMessage=result.ok and self:L("FPS_COMPARE_RESTORED") or self:L("FPS_COMPARE_RESTORE_FAILED");self.flashKind=result.ok and "success" or "error"
    if visible(self,"fpsTest") then self:ShowFPSTest() end
    return
  end
  local restoreResult=type(result.data)=="table" and type(result.data.restore)=="table";local message,kind
  if restoreResult then message,kind=self:GetBackupRestoreFeedback(result)
  elseif result.ok then message,kind=self:L(result.code=="unchanged" and "SETTINGS_UNCHANGED" or "RESTORE_COMPLETE"),"success"
  else message,kind=failedMessage(self,"PENDING_RECOVERY_FAILED",result),"error" end
  if result.ok then
    if operation.modules and operation.modules.uiTweaks then self.uiTweaksDraft=nil end
    self.flashMessage=message;self.flashKind=kind
  else self.flashMessage=message;self.flashKind=kind end
  if operation.modules and operation.modules.uiTweaks and not operation.modules.graphics then
    if visible(self,"uiTweaks") then self:ShowUITweaks() end
  elseif visible(self,"graphics") then self:ShowGraphics() end
end

function STBS:HandlePendingOperationCompletion(operation,result)
  if type(operation)~="table" or type(result)~="table" then return self:Result(false,"pending-completion") end
  if result.code=="queued" then return self:Result(false,"queued",{operation=operation,result=result}) end
  local context=type(operation.context)=="table" and operation.context or {}
  if operation.kind=="recovery" and context.reason=="backup-restore" and type(context.restoreOmitted)=="table" then result=self:FinalizeBackupRestoreResult(context.backupId,operation.modules or {},context.restoreOmitted,result) end
  local handler=handlers[operation.kind];if not handler then return self:Result(false,"pending-kind",{operation=operation,result=result}) end
  handler(self,operation,result)
  return self:Result(result.ok==true,result.code,{operation=operation,result=result})
end

function STBS:CompletePendingAfterCombat()
  local operation=self:GetPendingOperation();if not operation then return self:Result(false,"no-pending") end
  local result
  if operation.kind=="zone-auto" then
    local category=self:GetZoneCategory();local config=self:GetZoneGraphicsConfig();operation.context={category=category,preset=config.assignments[category],mode=self.GRAPHICS_MODE_UNIFIED}
    self:CancelPendingOperation("zone-auto");result=self:ApplyZoneGraphics("zone-change")
  else
    local completed=self:CompletePendingOperation();local data=type(completed.data)=="table" and completed.data or {};operation=data.operation or operation;result=data.result or completed
  end
  return self:HandlePendingOperationCompletion(operation,result)
end
