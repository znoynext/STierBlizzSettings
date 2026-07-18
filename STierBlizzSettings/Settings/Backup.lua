local _, STBS = ...
function STBS:CreateBackup(modules, trigger, source, deferTrim)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  if type(source)=="boolean" and deferTrim==nil then deferTrim=source;source=nil end
  if source~=nil and not self:IsBackupSource(source) then return self:Result(false,"backup-source") end
  source=source or "legacy"
  local validModules, modulesWhy = self:ValidateModules(modules); if not validModules then return self:Result(false,modulesWhy) end
  local values, failures = self:CaptureModules(modules)
  local build = self:GetBuild(); local backup = { id=self:AllocateBackupId(db),timestamp=time(), addonVersion=self.VERSION, clientBuild=build, trigger=trigger, source=source, affectedModules=self:Copy(modules), values=values, readFailures=failures }
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
function STBS:RestoreBackupById(id, modules)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  local backup;for _,candidate in ipairs(db.backups) do if candidate.id==id then backup=candidate;break end end;if not backup then return self:Result(false,"missing") end
  modules = modules or backup.affectedModules
  local validModules, modulesWhy = self:ValidateModules(modules); if not validModules then return self:Result(false,modulesWhy) end
  local settings = {}
  for key, value in pairs(type(backup.values)=="table" and backup.values or {}) do
    local setting = self.RegistryByKey[key]
    if setting and modules[setting.module] then settings[key] = value end
  end
  if not next(settings) then return self:Result(false,"no-settings") end
  local validSettings, settingsWhy = self:ValidateSettings(settings, false); if not validSettings then return self:Result(false,settingsWhy) end
  local safety = self:CreateBackup(modules, "restore-safety", "restore-safety")
  if not safety.ok then return safety end
  local result = self:ApplySettings(settings, modules, "restore", { skipBackup = true }, { kind="recovery",context={reason="backup-restore",backupId=id,safetyBackupId=safety.data.id} })
  if result.ok then result.data.safetyBackup = safety.data;if modules.graphics then self:SyncAppliedGraphicsState() end end
  return result
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

function STBS:DeleteBackupById(id)
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return databaseFailure end
  if not self:IsBackupId(id) then return self:Result(false,"missing") end
  for index,backup in ipairs(db.backups) do if backup.id==id then return self:Result(true,"deleted",table.remove(db.backups,index)) end end
  return self:Result(false,"missing")
end
function STBS:DeleteBackup(id)
  return self:DeleteBackupById(id)
end
