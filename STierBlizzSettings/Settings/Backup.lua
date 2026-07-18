local _, STBS = ...
function STBS:CreateBackup(modules, trigger, deferTrim)
  local validModules, modulesWhy = self:ValidateModules(modules); if not validModules then return self:Result(false,modulesWhy) end
  local db = self:InitializeDatabase(); local values, failures = self:CaptureModules(modules)
  local build = self:GetBuild(); local backup = { timestamp=time(), addonVersion=self.VERSION, clientBuild=build, trigger=trigger, affectedModules=self:Copy(modules), values=values, readFailures=failures }
  table.insert(db.backups, 1, backup); if not deferTrim then while #db.backups > db.preferences.backupLimit do table.remove(db.backups) end end
  return self:Result(true,"created",backup)
end
function STBS:FinalizeBackupLimit()
  local db=self:InitializeDatabase();while #db.backups>db.preferences.backupLimit do table.remove(db.backups) end
end
function STBS:RestoreBackup(index, modules)
  local backup = self:InitializeDatabase().backups[index]; if not backup then return self:Result(false,"missing") end
  modules = modules or backup.affectedModules
  local validModules, modulesWhy = self:ValidateModules(modules); if not validModules then return self:Result(false,modulesWhy) end
  local settings = {}
  for key, value in pairs(type(backup.values)=="table" and backup.values or {}) do
    local setting = self.RegistryByKey[key]
    if setting and modules[setting.module] then settings[key] = value end
  end
  if not next(settings) then return self:Result(false,"no-settings") end
  local validSettings, settingsWhy = self:ValidateSettings(settings, false); if not validSettings then return self:Result(false,settingsWhy) end
  local safety = self:CreateBackup(modules, "restore-safety")
  if not safety.ok then return safety end
  local result = self:ApplySettings(settings, modules, "restore", { skipBackup = true }, { kind="recovery",context={reason="backup-restore",backupIndex=index} })
  if result.ok then result.data.safetyBackup = safety.data end
  return result
end
function STBS:BackupHasModule(backup, module)
  if type(backup) ~= "table" or type(backup.values) ~= "table" then return false end
  for key in pairs(backup.values) do local setting=self.RegistryByKey[key];if setting and setting.module==module then return true end end
  return false
end

function STBS:GetLatestBackupIndex(module)
  for index, backup in ipairs(self:InitializeDatabase().backups) do
    if not module or self:BackupHasModule(backup, module) then return index end
  end
  return nil
end

function STBS:DeleteBackup(index)
  local db = self:InitializeDatabase()
  index = tonumber(index)
  if not index or index ~= math.floor(index) or index < 1 or index > #db.backups then return self:Result(false,"missing") end
  return self:Result(true,"deleted",table.remove(db.backups,index))
end
