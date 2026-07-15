local ADDON, STBS = ...
STBS = STBS or {}
_G[ADDON] = STBS
STBS.ADDON = ADDON
STBS.VERSION = "0.1.1-alpha"
STBS.DB_SCHEMA = 1
STBS.PROFILE_SCHEMA = 1
STBS.EXPORT_PREFIX = "STBS1:"
STBS.EXPORT_VERSION = 1
STBS.MAX_IMPORT_BYTES = 65536
STBS.MAX_IMPORT_DEPTH = 12
STBS.MAX_IMPORT_ENTRIES = 512
STBS.MAX_STRING_BYTES = 4096
STBS.MAX_LOG_ENTRIES = 100
STBS.DEFAULT_BACKUP_LIMIT = 10
STBS.GRAPHICS_MODE_UNIFIED = "unified"
STBS.GRAPHICS_MODE_SPLIT = "split"
STBS.Modules = { graphics = true, interfaceGameplay = true }
function STBS:Result(ok, code, data) return { ok = ok, code = code, data = data } end
function STBS:Copy(value, seen)
  if type(value) ~= "table" then return value end
  seen = seen or {}; if seen[value] then return seen[value] end
  local result = {}; seen[value] = result
  for k, v in pairs(value) do result[self:Copy(k, seen)] = self:Copy(v, seen) end
  return result
end
function STBS:Log(level, code, detail)
  local db = _G.STierBlizzSettingsDB
  if not db then return end
  db.log = db.log or {}
  table.insert(db.log, { time = time and time() or 0, level = level, code = code, detail = tostring(detail or "") })
  while #db.log > self.MAX_LOG_ENTRIES do table.remove(db.log, 1) end
end
