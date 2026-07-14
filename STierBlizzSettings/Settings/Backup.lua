local _, STBS = ...
function STBS:CreateBackup(modules, trigger, preventRecursive)
  if preventRecursive then return self:Result(false,"recursive") end
  local db = self:InitializeDatabase(); local values, failures = self:CaptureModules(modules)
  local build = self:GetBuild(); local backup = { timestamp=time(), addonVersion=self.VERSION, clientBuild=build, trigger=trigger, affectedModules=self:Copy(modules), values=values, readFailures=failures }
  table.insert(db.backups, 1, backup); while #db.backups > db.preferences.backupLimit do table.remove(db.backups) end
  return self:Result(true,"created",backup)
end
function STBS:RestoreBackup(index, modules)
  local backup = self:InitializeDatabase().backups[index]; if not backup then return self:Result(false,"missing") end
  modules = modules or backup.affectedModules; return self:ApplySettings(backup.values, modules, "restore", true)
end
