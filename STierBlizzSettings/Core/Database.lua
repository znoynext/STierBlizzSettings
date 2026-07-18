local _, STBS = ...
function STBS:InitializeDatabase()
  local db = _G.STierBlizzSettingsDB
  if type(db) ~= "table" then db = {} end
  local previousSchema=math.max(0,math.floor(tonumber(db.schemaVersion) or 0))
  if type(db.preferences) ~= "table" then db.preferences = {} end
  db.preferences.backupLimit = math.max(1, math.min(50, math.floor(tonumber(db.preferences.backupLimit) or self.DEFAULT_BACKUP_LIMIT)))
  local validPreset={ [self.GRAPHICS_PRESET_PRO]=true,[self.GRAPHICS_PRESET_OPTIMIZED]=true,[self.GRAPHICS_PRESET_QUALITY]=true }
  local validMode={ [self.GRAPHICS_MODE_UNIFIED]=true,[self.GRAPHICS_MODE_SPLIT]=true }
  if previousSchema<3 then
    if validPreset[db.preferences.graphicsPreset] then self.graphicsPresetSelection=db.preferences.graphicsPreset end
    if validMode[db.preferences.graphicsMode] then self.graphicsModeSelection=db.preferences.graphicsMode end
    db.preferences.graphicsPreset=self.GRAPHICS_PRESET_CUSTOM
    db.preferences.graphicsMode=validMode[db.preferences.graphicsMode] and db.preferences.graphicsMode or self.GRAPHICS_MODE_UNIFIED
    db.graphicsStateNeedsSync=true
  end
  if not validPreset[db.preferences.graphicsPreset] and db.preferences.graphicsPreset~=self.GRAPHICS_PRESET_CUSTOM then db.preferences.graphicsPreset=self.GRAPHICS_PRESET_CUSTOM end
  if db.preferences.graphicsMode~=self.GRAPHICS_MODE_UNIFIED and db.preferences.graphicsMode~=self.GRAPHICS_MODE_SPLIT then db.preferences.graphicsMode=self.GRAPHICS_MODE_SPLIT end
  if db.preferences.benchmarkMode~=self.BENCHMARK_QUICK and db.preferences.benchmarkMode~=self.BENCHMARK_ACCURATE then db.preferences.benchmarkMode=self.BENCHMARK_QUICK end
  db.preferences.performanceWidgetEnabled=db.preferences.performanceWidgetEnabled==true
  local widgetPosition=db.preferences.performanceWidgetPosition
  if type(widgetPosition)~="table" or type(widgetPosition.x)~="number" or type(widgetPosition.y)~="number" or widgetPosition.x~=widgetPosition.x or widgetPosition.y~=widgetPosition.y or widgetPosition.x<0 or widgetPosition.x>1 or widgetPosition.y<0 or widgetPosition.y>1 then db.preferences.performanceWidgetPosition=nil end
  local width,height=tonumber(db.preferences.windowWidth),tonumber(db.preferences.windowHeight)
  db.preferences.windowWidth=width and width==width and math.max(900,math.min(1280,math.floor(width+0.5))) or nil
  db.preferences.windowHeight=height and height==height and math.max(640,math.min(900,math.floor(height+0.5))) or nil
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
  db.schemaVersion = self.DB_SCHEMA
  _G.STierBlizzSettingsDB = db; if type(_G.STierBlizzSettingsCharDB) ~= "table" then _G.STierBlizzSettingsCharDB = {} end
  return db
end
