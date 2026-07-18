local _, STBS = ...

local migrations={}
local MAX_BACKUP_SEQUENCE=9007199254740990

local function validBackupId(value)
  return type(value)=="string" and value~="" and #value<=128 and not value:find("[%c]")
end

local function normalizedBackupSequence(value)
  value=tonumber(value)
  if not value or value~=value or value<0 or value>MAX_BACKUP_SEQUENCE then return 0 end
  return math.floor(value)
end

function STBS:IsBackupId(value)
  return validBackupId(value)
end

function STBS:AllocateBackupId(db)
  db=db or self:InitializeDatabase();local seen={};local sequence=normalizedBackupSequence(db.backupSequence)
  for _,backup in ipairs(type(db.backups)=="table" and db.backups or {}) do
    if type(backup)=="table" and validBackupId(backup.id) then
      seen[backup.id]=true;local numeric=tonumber(backup.id:match("^backup%-(%d+)$"));if numeric and numeric<=MAX_BACKUP_SEQUENCE then sequence=math.max(sequence,math.floor(numeric)) end
    end
  end
  if sequence>=MAX_BACKUP_SEQUENCE then sequence=0 end
  local candidate
  repeat sequence=sequence+1;candidate="backup-"..tostring(sequence) until not seen[candidate]
  db.backupSequence=sequence;return candidate
end

function STBS:IsBackupRecoveryRequired(backup)
  return type(backup)=="table" and backup.recoveryRequired==true
end

function STBS:ApplyBackupRetention(db)
  db=db or self:InitializeDatabase();local limit=db.preferences.backupLimit;local ordinary=0
  for _,backup in ipairs(db.backups) do if not self:IsBackupRecoveryRequired(backup) then ordinary=ordinary+1 end end
  local removed={}
  for index=#db.backups,1,-1 do
    if ordinary<=limit then break end
    if not self:IsBackupRecoveryRequired(db.backups[index]) then table.insert(removed,1,table.remove(db.backups,index));ordinary=ordinary-1 end
  end
  return removed
end

function STBS:BeginBackupRetentionDeferral()
  self.backupRetentionDeferrals=(tonumber(self.backupRetentionDeferrals) or 0)+1
end

function STBS:EndBackupRetentionDeferral()
  self.backupRetentionDeferrals=math.max(0,(tonumber(self.backupRetentionDeferrals) or 0)-1)
end

function STBS:HasDeferredBackupRetention()
  return (tonumber(self.backupRetentionDeferrals) or 0)>0 or type(self.HasDeferredFPSComparisonBackups)=="function" and self:HasDeferredFPSComparisonBackups()
end

local function validPresets(self)
  return { [self.GRAPHICS_PRESET_PRO]=true,[self.GRAPHICS_PRESET_OPTIMIZED]=true,[self.GRAPHICS_PRESET_QUALITY]=true }
end

local function validModes(self)
  return { [self.GRAPHICS_MODE_UNIFIED]=true,[self.GRAPHICS_MODE_SPLIT]=true }
end

local function separateLegacyGraphicsState(self,db)
  if type(db.preferences)~="table" then db.preferences={} end
  local presets,modes=validPresets(self),validModes(self);local preferences=db.preferences
  if presets[preferences.graphicsPreset] then self.graphicsPresetSelection=preferences.graphicsPreset end
  if modes[preferences.graphicsMode] then self.graphicsModeSelection=preferences.graphicsMode end
  preferences.graphicsPreset=self.GRAPHICS_PRESET_CUSTOM
  preferences.graphicsMode=modes[preferences.graphicsMode] and preferences.graphicsMode or self.GRAPHICS_MODE_UNIFIED
  db.graphicsStateNeedsSync=true
  return true
end

local function addStableBackupIds(self,db)
  if type(db.backups)~="table" then db.backups={} end
  local seen={}
  for _,backup in ipairs(db.backups) do
    if type(backup)=="table" then
      if validBackupId(backup.id) and not seen[backup.id] then seen[backup.id]=true else backup.id=nil end
    end
  end
  db.backupSequence=normalizedBackupSequence(db.backupSequence)
  for _,backup in ipairs(db.backups) do if type(backup)=="table" and not backup.id then backup.id=self:AllocateBackupId(db) end end
  return true
end

local legacyBackupSources={
  ["official-graphics"]="manual-preset",
  ["official-interface"]="manual-preset",
  ["official-all"]="manual-preset",
  ["fps-comparison-apply"]="manual-preset",
  ["personal-profile"]="personal-profile",
  ["personal-graphics"]="personal-profile",
  ["zone-change"]="zone-auto",
  ["zone-enabled"]="zone-manual",
  ["zone-manual"]="zone-manual",
  ["zone-graphics"]="zone-manual",
  ["profile-import"]="profile-import",
  ["addon-bundle-import"]="addon-import",
  ["restore-safety"]="restore-safety",
  manual="manual-backup",
  ["ui-tweaks"]="ui-tweaks",
}

local function inferLegacyBackupSource(trigger)
  if type(trigger)=="string" and trigger:match("^fps%-compare%-") then return "fps-comparison-temp" end
  return legacyBackupSources[trigger] or "legacy"
end

local function addBackupSources(self,db)
  if type(db.backups)~="table" then db.backups={} end
  for _,backup in ipairs(db.backups) do
    if type(backup)=="table" then
      if backup.source==nil then backup.source=inferLegacyBackupSource(backup.trigger)
      elseif not self:IsBackupSource(backup.source) then backup.source="legacy" end
    end
  end
  return true
end

-- Migrations are keyed by their real source schema and advance exactly one step.
migrations[2]=separateLegacyGraphicsState
migrations[3]=addStableBackupIds
migrations[4]=addBackupSources

function STBS:MigrateDatabase(db)
  if type(db)~="table" then db={} end
  local rawVersion=db.schemaVersion;local numericVersion=tonumber(rawVersion)
  if numericVersion and numericVersion==numericVersion and numericVersion>self.DB_SCHEMA then
    return self:Result(false,"future-schema",{schemaVersion=rawVersion})
  end
  if rawVersion==nil and next(db)==nil then
    separateLegacyGraphicsState(self,db);addStableBackupIds(self,db);addBackupSources(self,db);db.schemaVersion=self.DB_SCHEMA
    return self:Result(true,"fresh",db)
  end
  if type(rawVersion)~="number" or rawVersion~=rawVersion or rawVersion~=math.floor(rawVersion) or rawVersion<2 then
    separateLegacyGraphicsState(self,db);addStableBackupIds(self,db);addBackupSources(self,db);db.schemaVersion=self.DB_SCHEMA
    return self:Result(true,"recovered-unversioned",db)
  end
  local version=rawVersion
  for sourceVersion=version,self.DB_SCHEMA-1 do
    if type(migrations[sourceVersion])~="function" then return self:Result(false,"unsupported-schema",{schemaVersion=sourceVersion}) end
  end
  while version<self.DB_SCHEMA do
    local migration=migrations[version]
    local ok,why=migration(self,db)
    if not ok then return self:Result(false,why or "migration-failed",{schemaVersion=version}) end
    version=version+1;db.schemaVersion=version
  end
  return self:Result(true,version==rawVersion and "current" or "migrated",db)
end

local function normalizeDatabase(self,db)
  if type(db.preferences)~="table" then db.preferences={} end
  db.preferences.backupLimit=math.max(1,math.min(50,math.floor(tonumber(db.preferences.backupLimit) or self.DEFAULT_BACKUP_LIMIT)))
  local presets,modes=validPresets(self),validModes(self)
  if not presets[db.preferences.graphicsPreset] and db.preferences.graphicsPreset~=self.GRAPHICS_PRESET_CUSTOM then db.preferences.graphicsPreset=self.GRAPHICS_PRESET_CUSTOM end
  if not modes[db.preferences.graphicsMode] then db.preferences.graphicsMode=self.GRAPHICS_MODE_SPLIT end
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
  for category,preset in pairs(defaults) do if not presets[zone.assignments[category]] then zone.assignments[category]=preset end end
  if type(db.profiles)~="table" then db.profiles={} end
  if type(db.backups)~="table" then db.backups={} end
  local backupIds={};for index=#db.backups,1,-1 do local backup=db.backups[index];if type(backup)~="table" or not validBackupId(backup.id) or backupIds[backup.id] or type(backup.timestamp)~="number" or type(backup.values)~="table" or type(backup.affectedModules)~="table" then table.remove(db.backups,index) else backupIds[backup.id]=true;backup.source=self:IsBackupSource(backup.source) and backup.source or "legacy";backup.recoveryRequired=backup.recoveryRequired==true and true or nil;if backup.recoveryForBackupId~=nil and not validBackupId(backup.recoveryForBackupId) then backup.recoveryForBackupId=nil end end end
  if not self:HasDeferredBackupRetention() then self:ApplyBackupRetention(db) end
  db.backupSequence=normalizedBackupSequence(db.backupSequence)
  if type(db.log)~="table" then db.log={} end
  if type(db.transactions)~="table" then db.transactions={} end
  db.profileSequence=math.max(0,math.floor(tonumber(db.profileSequence) or 0))
  return db
end

function STBS:IsDatabaseSchemaSupported()
  return not self.databaseMigrationStatus or self.databaseMigrationStatus.supported~=false
end

function STBS:GetDatabaseMigrationStatus()
  return self.databaseMigrationStatus and self:Copy(self.databaseMigrationStatus) or {supported=true,code="uninitialized"}
end

function STBS:RequireWritableDatabase()
  local db=self:InitializeDatabase()
  if not self:IsDatabaseSchemaSupported() then return nil,self:Result(false,"database-schema-unsupported",self:GetDatabaseMigrationStatus()) end
  return db
end

function STBS:InitializeDatabase()
  local source=_G.STierBlizzSettingsDB;if type(source)~="table" then source={} end
  local migration=self:MigrateDatabase(source)
  if not migration.ok then
    local version=type(migration.data)=="table" and migration.data.schemaVersion or source.schemaVersion
    self.databaseMigrationStatus={supported=false,code=migration.code,schemaVersion=version}
    if type(self.unsupportedDatabaseView)~="table" then
      local fallback={schemaVersion=self.DB_SCHEMA};separateLegacyGraphicsState(self,fallback);fallback.graphicsStateNeedsSync=nil
      self.unsupportedDatabaseView=normalizeDatabase(self,fallback)
    end
    if type(_G.STierBlizzSettingsCharDB)~="table" then _G.STierBlizzSettingsCharDB={} end
    return self.unsupportedDatabaseView
  end
  local db=normalizeDatabase(self,migration.data)
  self.databaseMigrationStatus={supported=true,code=migration.code,schemaVersion=db.schemaVersion};self.unsupportedDatabaseView=nil
  _G.STierBlizzSettingsDB=db;if type(_G.STierBlizzSettingsCharDB)~="table" then _G.STierBlizzSettingsCharDB={} end
  return db
end
