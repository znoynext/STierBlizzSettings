local _, STBS = ...
function STBS:InitializeDatabase()
  local db = _G.STierBlizzSettingsDB
  if type(db) ~= "table" then db = {} end
  db.schemaVersion = self.DB_SCHEMA
  if type(db.preferences) ~= "table" then db.preferences = {} end
  db.preferences.backupLimit = math.max(1, math.min(50, math.floor(tonumber(db.preferences.backupLimit) or self.DEFAULT_BACKUP_LIMIT)))
  local validPreset={ [self.GRAPHICS_PRESET_PRO]=true,[self.GRAPHICS_PRESET_OPTIMIZED]=true,[self.GRAPHICS_PRESET_QUALITY]=true }
  if not validPreset[db.preferences.graphicsPreset] then db.preferences.graphicsPreset=self.GRAPHICS_PRESET_OPTIMIZED end
  if db.preferences.graphicsMode~=self.GRAPHICS_MODE_UNIFIED and db.preferences.graphicsMode~=self.GRAPHICS_MODE_SPLIT then db.preferences.graphicsMode=self.GRAPHICS_MODE_SPLIT end
  if db.preferences.benchmarkMode~=self.BENCHMARK_QUICK and db.preferences.benchmarkMode~=self.BENCHMARK_ACCURATE then db.preferences.benchmarkMode=self.BENCHMARK_QUICK end
  db.preferences.performanceWidgetEnabled=db.preferences.performanceWidgetEnabled==true
  if type(db.preferences.zoneGraphics)~="table" then db.preferences.zoneGraphics={} end
  local zone=db.preferences.zoneGraphics;zone.enabled=zone.enabled==true
  if type(zone.assignments)~="table" then zone.assignments={} end
  local defaults={world=self.GRAPHICS_PRESET_OPTIMIZED,party=self.GRAPHICS_PRESET_OPTIMIZED,raid=self.GRAPHICS_PRESET_PRO,pvp=self.GRAPHICS_PRESET_PRO,scenario=self.GRAPHICS_PRESET_OPTIMIZED}
  for category,preset in pairs(defaults) do if not validPreset[zone.assignments[category]] then zone.assignments[category]=preset end end
  if type(db.profiles) ~= "table" then db.profiles = {} end
  if type(db.backups) ~= "table" then db.backups = {} end
  for index=#db.backups,1,-1 do local backup=db.backups[index];if type(backup)~="table" or type(backup.timestamp)~="number" or type(backup.values)~="table" or type(backup.affectedModules)~="table" then table.remove(db.backups,index) end end
  while #db.backups > db.preferences.backupLimit do table.remove(db.backups) end
  if type(db.log) ~= "table" then db.log = {} end
  if type(db.transactions) ~= "table" then db.transactions = {} end
  db.profileSequence = math.max(0, math.floor(tonumber(db.profileSequence) or 0))
  _G.STierBlizzSettingsDB = db; if type(_G.STierBlizzSettingsCharDB) ~= "table" then _G.STierBlizzSettingsCharDB = {} end
  return db
end
