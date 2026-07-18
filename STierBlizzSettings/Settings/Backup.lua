local _, STBS = ...
local undoableBackupSources={
  ["manual-preset"]=true,
  ["personal-profile"]=true,
  ["profile-import"]=true,
  ["zone-manual"]=true,
  ["addon-import"]=true,
}

function STBS:CreateBackup(modules, trigger, source, deferTrim, sessionId)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  if type(source)=="boolean" and deferTrim==nil then deferTrim=source;source=nil end
  if source~=nil and not self:IsBackupSource(source) then return self:Result(false,"backup-source") end
  source=source or "legacy"
  if source=="fps-comparison-temp" then if not self:IsFPSComparisonSessionId(sessionId) then return self:Result(false,"backup-session") end
  elseif sessionId~=nil then return self:Result(false,"backup-session") end
  local validModules, modulesWhy = self:ValidateModules(modules); if not validModules then return self:Result(false,modulesWhy) end
  local values, failures = self:CaptureModules(modules)
  local build = self:GetBuild(); local backup = { id=self:AllocateBackupId(db),timestamp=time(), addonVersion=self.VERSION, clientBuild=build, trigger=trigger, source=source, sessionId=sessionId, affectedModules=self:Copy(modules), values=values, readFailures=failures }
  table.insert(db.backups, 1, backup); if not deferTrim then while #db.backups > db.preferences.backupLimit do table.remove(db.backups) end end
  return self:Result(true,"created",backup)
end
function STBS:FinalizeBackupLimit()
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  while #db.backups>db.preferences.backupLimit do table.remove(db.backups) end;return self:Result(true,"finalized")
end
function STBS:GetBackupById(id)
  if not self:IsBackupId(id) then return nil,nil end
  for index,backup in ipairs(self:InitializeDatabase().backups) do if backup.id==id then return backup,index end end
  return nil,nil
end

local function emptyRestoreSummary()
  return {restored=0,changed=0,identical=0,skipped=0,unavailable=0,failed=0}
end

local function selectedBackupCoversUnknownKeys(backup,modules)
  local affected=type(backup.affectedModules)=="table" and backup.affectedModules or {};local total,selected=0,0
  for module,enabled in pairs(affected) do if enabled then total=total+1;if modules[module] then selected=selected+1 end end end
  return total>0 and total==selected
end

function STBS:BuildBackupRestorePayload(backup,modules)
  local settings,omitted,counted={},emptyRestoreSummary(),{};local includeUnknown=selectedBackupCoversUnknownKeys(backup,modules)
  for key,value in pairs(type(backup.values)=="table" and backup.values or {}) do
    local setting=self.RegistryByKey[key]
    if setting and modules[setting.module] then settings[key]=value
    elseif not setting and includeUnknown then omitted.unavailable=omitted.unavailable+1;counted[key]=true end
  end
  for key in pairs(type(backup.readFailures)=="table" and backup.readFailures or {}) do if not counted[key] and settings[key]==nil then
    local setting=self.RegistryByKey[key]
    if setting and modules[setting.module] or not setting and includeUnknown then omitted.unavailable=omitted.unavailable+1;counted[key]=true end
  end end
  return settings,omitted
end

function STBS:FinalizeBackupRestoreResult(id,modules,omitted,result)
  if type(result)~="table" then result=self:Result(false,"restore-failed") end
  result.data=type(result.data)=="table" and result.data or {};result.data.backupId=id
  if result.code=="queued" then return result end
  local transactionSummary=type(result.data.summary)=="table" and self:Copy(result.data.summary) or {};local summary=emptyRestoreSummary()
  for _,key in ipairs({"identical","skipped","unavailable","failed"}) do summary[key]=tonumber(transactionSummary[key]) or 0 end
  local transactionChanged=tonumber(transactionSummary.changed) or 0
  for _,key in ipairs({"skipped","unavailable","failed"}) do summary[key]=summary[key]+(tonumber(type(omitted)=="table" and omitted[key]) or 0) end
  local compatible=transactionChanged+summary.identical;local blocked=summary.skipped+summary.unavailable
  if result.ok then summary.restored=transactionChanged;summary.changed=transactionChanged end
  result.data.restore=summary;result.data.transactionSummary=transactionSummary;result.data.transactionCode=result.code
  if summary.failed==0 and compatible==0 and blocked>0 then result.ok=false;result.code="restore-unavailable";result.data.restoreStatus="unavailable"
  elseif summary.failed==0 and (result.ok or result.code=="unavailable" and compatible>0) then
    result.ok=true;result.code=blocked>0 and "restore-partial" or "restore-complete";result.data.restoreStatus=blocked>0 and "partial" or "complete"
    result.data.safetyBackup=result.data.backup
    if modules.graphics then self:SyncAppliedGraphicsState() end
  else
    result.data.restoreStatus="failed"
  end
  result.data.summary=self:Copy(summary)
  return result
end

function STBS:GetBackupRestoreFeedback(result)
  local summary=type(result)=="table" and type(result.data)=="table" and type(result.data.restore)=="table" and result.data.restore or emptyRestoreSummary()
  if result and result.code=="restore-complete" then
    if summary.restored==0 then return self:L("SETTINGS_UNCHANGED"),"success" end
    return string.format(self:L("RESTORE_COMPLETE_SUMMARY"),summary.restored,summary.identical),"success"
  end
  if result and result.code=="restore-partial" then return string.format(self:L("RESTORE_PARTIAL_SUMMARY"),summary.restored,summary.skipped+summary.unavailable),"warning" end
  if result and result.code=="restore-unavailable" then return string.format(self:L("RESTORE_ALL_UNAVAILABLE"),summary.skipped+summary.unavailable),"warning" end
  if result and result.code=="rollback-failed" then return self:L("RESTORE_ROLLBACK_FAILED"),"error" end
  if result and result.code=="rolled-back" then return self:L("RESTORE_ROLLED_BACK"),"error" end
  return string.format(self:L("RESTORE_FAILED_SUMMARY"),tostring(result and result.code or "failed")),"error"
end

function STBS:RestoreBackupById(id, modules)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  local backup;for _,candidate in ipairs(db.backups) do if candidate.id==id then backup=candidate;break end end;if not backup then return self:Result(false,"missing") end
  modules = modules or backup.affectedModules
  local validModules, modulesWhy = self:ValidateModules(modules); if not validModules then return self:Result(false,modulesWhy) end
  local settings,omitted=self:BuildBackupRestorePayload(backup,modules)
  if not next(settings) then local omittedCount=omitted.skipped+omitted.unavailable+omitted.failed;return self:FinalizeBackupRestoreResult(id,modules,omitted,self:Result(false,omittedCount>0 and "unavailable" or "no-settings",{summary=emptyRestoreSummary()})) end
  local validSettings, settingsWhy = self:ValidateSettings(settings, false); if not validSettings then return self:FinalizeBackupRestoreResult(id,modules,omitted,self:Result(false,"restore-failed",{reason=settingsWhy,summary={failed=1}})) end
  local context={reason="backup-restore",backupId=id,restoreOmitted=omitted}
  local result = self:ApplySettings(settings, modules, "restore", { backupSource = "restore-safety" }, { kind="recovery",context=context })
  return self:FinalizeBackupRestoreResult(id,modules,omitted,result)
end
function STBS:RestoreBackup(id, modules)
  return self:RestoreBackupById(id,modules)
end
function STBS:BackupHasModule(backup, module)
  if type(backup) ~= "table" or type(backup.values) ~= "table" then return false end
  for key in pairs(backup.values) do local setting=self.RegistryByKey[key];if setting and setting.module==module then return true end end
  return false
end

function STBS:GetLatestBackupId(module)
  for _, backup in ipairs(self:InitializeDatabase().backups) do
    if not module or self:BackupHasModule(backup, module) then return backup.id end
  end
  return nil
end

function STBS:IsUndoableBackup(backup, module)
  return type(backup)=="table" and undoableBackupSources[backup.source]==true and (not module or self:BackupHasModule(backup,module))
end

function STBS:GetLatestUndoableBackup(module)
  for _,backup in ipairs(self:InitializeDatabase().backups) do if self:IsUndoableBackup(backup,module) then return backup end end
  return nil
end

function STBS:DeleteBackupById(id)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  if not self:IsBackupId(id) then return self:Result(false,"missing") end
  for index,backup in ipairs(db.backups) do if backup.id==id then return self:Result(true,"deleted",table.remove(db.backups,index)) end end
  return self:Result(false,"missing")
end
function STBS:DeleteBackup(id)
  return self:DeleteBackupById(id)
end
