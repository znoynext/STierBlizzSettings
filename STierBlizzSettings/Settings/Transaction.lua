local _, STBS = ...

local pendingPriorities={
  ["zone-auto"]=1,
  ["graphics-user"]=2,
  ["zone-manual"]=2,
  ["ui-tweaks"]=2,
  recovery=3,
}

function STBS:InferPendingOperationKind(trigger,modules)
  if trigger=="zone-change" then return "zone-auto" end
  if trigger=="zone-enabled" or trigger=="zone-manual" or trigger=="zone-graphics" then return "zone-manual" end
  if trigger=="ui-tweaks" or modules and modules.uiTweaks and not modules.graphics then return "ui-tweaks" end
  if trigger=="restore" or trigger=="fps-compare-restore" or trigger=="fps-compare-cancel-restore" then return "recovery" end
  return "graphics-user"
end

function STBS:GetPendingOperation()
  return self.pendingOperation and self:Copy(self.pendingOperation) or nil
end

function STBS:CanReplacePendingOperation(current,incoming)
  local incomingKind=type(incoming)=="table" and incoming.kind or incoming
  local incomingPriority=pendingPriorities[incomingKind];if not incomingPriority then return false,"kind" end
  if current==nil then return true,"empty" end
  local currentKind=type(current)=="table" and current.kind or current;local currentPriority=pendingPriorities[currentKind]
  if not currentPriority then return false,"kind" end
  if currentKind=="zone-auto" and incomingKind=="zone-auto" then return true,"latest-zone-state" end
  if incomingPriority>currentPriority then return true,"higher-priority" end
  return false,incomingPriority==currentPriority and "same-priority" or "lower-priority"
end

function STBS:QueuePendingOperation(kind,settings,modules,trigger,options,context)
  if not pendingPriorities[kind] or type(settings)~="table" or type(modules)~="table" or type(trigger)~="string" or type(options)~="table" or type(context)~="table" then return self:Result(false,"pending-operation") end
  local operation={kind=kind,settings=self:Copy(settings),modules=self:Copy(modules),trigger=trigger,options=self:Copy(options),context=self:Copy(context)}
  local current=self:GetPendingOperation();local allowed,reason=self:CanReplacePendingOperation(current,operation)
  if not allowed then return self:Result(false,"pending-exists",{pending=current and self:Copy(current) or nil,reason=reason}) end
  self.pendingOperation=operation
  return self:Result(true,current and "replaced" or "queued",{operation=self:Copy(operation),replaced=current and self:Copy(current) or nil,reason=reason})
end

function STBS:CancelPendingOperation(expectedKind)
  local operation=self:GetPendingOperation();if not operation then return self:Result(false,"no-pending") end
  if expectedKind and operation.kind~=expectedKind then return self:Result(false,"pending-kind",{operation=self:Copy(operation)}) end
  self.pendingOperation=nil;return self:Result(true,"cancelled",self:Copy(operation))
end

function STBS:ApplySettings(settings, modules, trigger, options, pending)
  options = options == true and { skipBackup = true } or options or {}
  local _,databaseFailure=self:RequireWritableDatabase();if databaseFailure then return databaseFailure end
  if not options.skipBackup and options.backupSource~=nil and not self:IsBackupSource(options.backupSource) then return self:Result(false,"backup-source") end
  if not options.skipBackup and options.backupSource=="fps-comparison-temp" and not self:IsFPSComparisonSessionId(options.backupSessionId) then return self:Result(false,"backup-session") end
  if options.backupSessionId~=nil and options.backupSource~="fps-comparison-temp" then return self:Result(false,"backup-session") end
  local validModules, modulesWhy=self:ValidateModules(modules);if not validModules then return self:Result(false,modulesWhy) end
  local valid, why=self:ValidateSettings(settings,false);if not valid then return self:Result(false,why) end
  local selectedSettings=0;for key in pairs(settings)do local setting=self.RegistryByKey[key];if setting and modules[setting.module]then selectedSettings=selectedSettings+1 end end;if selectedSettings==0 then return self:Result(false,"no-settings") end
  if InCombatLockdown and InCombatLockdown() then
    pending=type(pending)=="table" and pending or {};local kind=pending.kind or self:InferPendingOperationKind(trigger,modules);local queued=self:QueuePendingOperation(kind,settings,modules,trigger,options,type(pending.context)=="table" and pending.context or {})
    return self:Result(false,queued.ok and "queued" or queued.code,queued.data)
  end
  local plan=self:BuildDiff(settings);local backup = options.skipBackup and self:Result(true,"skipped") or self:CreateBackup(modules,trigger,options.backupSource or "legacy",options.deferBackupTrim==true,options.backupSessionId);if not backup.ok then return backup end
  local result={backup=backup.data}
  for module,selected in pairs(modules) do if selected then result[module]={changed=0,identical=0,skipped=0,failed=0,unavailable=0,categories={}} end end
  local attempted={}
  for _,entry in ipairs(plan) do local target=entry.setting.module;if modules[target] then
    local category = result[target].categories[entry.setting.category] or {changed=0,identical=0,skipped=0,failed=0,unavailable=0}; result[target].categories[entry.setting.category]=category
    local status=entry.status;if status=="changed" then
      table.insert(attempted,entry)
      local ok,writeStatus=self:WriteSetting(entry.setting,entry.value);status=ok and writeStatus or "failed"
    end
    result[target][status]=(result[target][status]or 0)+1;category[status]=(category[status]or 0)+1
    if status=="failed" then
      local rollback={attempted=#attempted,restored=0,failed=0}
      for index=#attempted,1,-1 do
        local applied=attempted[index]
        local current=self:ReadSetting(applied.setting)
        if self:SettingValuesEqual(applied.setting,current,applied.current) then rollback.restored=rollback.restored+1
        else
          local restored=self:WriteSetting(applied.setting,applied.current)
          if restored then rollback.restored=rollback.restored+1 else rollback.failed=rollback.failed+1 end
        end
      end
      result.rollback=rollback
      local db=self:InitializeDatabase();table.insert(db.transactions,1,{time=time(),trigger=trigger,modules=self:Copy(modules),result=self:Copy(result),code=rollback.failed==0 and "rolled-back" or "rollback-failed"});while #db.transactions>20 do table.remove(db.transactions) end
      return self:Result(false,rollback.failed==0 and "rolled-back" or "rollback-failed",result)
    end
  end end
  local db=self:InitializeDatabase();table.insert(db.transactions,1,{time=time(),trigger=trigger,modules=self:Copy(modules),result=self:Copy(result),code="applied"});while #db.transactions>20 do table.remove(db.transactions) end;return self:Result(true,"applied",result)
end

function STBS:CompletePendingOperation()
  local operation=self:GetPendingOperation();if not operation then return self:Result(false,"no-pending") end
  self.pendingOperation=nil
  local result=self:ApplySettings(operation.settings,operation.modules,operation.trigger,operation.options,{kind=operation.kind,context=operation.context})
  return self:Result(result.ok,result.code,{operation=operation,result=result})
end

function STBS:ApplyOfficial(kind, options)
  local modules=kind=="graphics" and {graphics=true} or kind=="interface" and {interfaceGameplay=true} or {graphics=true,interfaceGameplay=true};local settings={};local mode,preset
  if modules.graphics then mode=self:GetSelectedMode();preset=self:GetSelectedPreset();if not mode then return self:Result(false,"mode") end;settings=self:FlattenProfile(self:GetOfficialGraphics(mode,preset),{graphics=true}) end
  if modules.interfaceGameplay then local interface=self:FlattenProfile(self:GetOfficialInterface(),{interfaceGameplay=true});for k,v in pairs(interface) do settings[k]=v end end
  local officialValid, officialWhy=self:ValidateSettings(settings,true);if not officialValid then return self:Result(false,officialWhy) end
  options=type(options)=="table" and self:Copy(options) or options==true and {skipBackup=true} or {};if not options.skipBackup then options.backupSource="manual-preset" end
  local result=self:ApplySettings(settings,modules,"official-"..kind,options,{kind="graphics-user",context={source="official-"..kind,mode=mode,preset=preset}})
  if result.ok and modules.graphics then self:CommitAppliedGraphicsState(mode,preset) end
  return result
end
