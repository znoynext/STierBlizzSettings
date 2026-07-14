local _, STBS = ...
function STBS:InitializeDatabase()
  local db = _G.STierBlizzSettingsDB
  if type(db) ~= "table" then db = {} end
  db.schemaVersion = self.DB_SCHEMA; db.preferences = db.preferences or {}; db.preferences.backupLimit = tonumber(db.preferences.backupLimit) or self.DEFAULT_BACKUP_LIMIT
  db.profiles = db.profiles or {}; db.backups = db.backups or {}; db.log = db.log or {}; db.transactions = db.transactions or {}
  _G.STierBlizzSettingsDB = db; _G.STierBlizzSettingsCharDB = _G.STierBlizzSettingsCharDB or {}
  return db
end
