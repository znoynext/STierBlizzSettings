local _, STBS = ...
function STBS:InitializeDatabase()
  local db = _G.STierBlizzSettingsDB
  if type(db) ~= "table" then db = {} end
  db.schemaVersion = self.DB_SCHEMA
  if type(db.preferences) ~= "table" then db.preferences = {} end
  db.preferences.backupLimit = tonumber(db.preferences.backupLimit) or self.DEFAULT_BACKUP_LIMIT
  if type(db.profiles) ~= "table" then db.profiles = {} end
  if type(db.backups) ~= "table" then db.backups = {} end
  if type(db.log) ~= "table" then db.log = {} end
  if type(db.transactions) ~= "table" then db.transactions = {} end
  _G.STierBlizzSettingsDB = db; if type(_G.STierBlizzSettingsCharDB) ~= "table" then _G.STierBlizzSettingsCharDB = {} end
  return db
end
