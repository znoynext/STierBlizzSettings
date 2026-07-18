local _, STBS = ...
-- Hex is deliberately used instead of a library: it is printable, deterministic and lossless on WoW's Lua 5.1.
function STBS:Base64Encode(data) return (data:gsub(".", function(byte) return string.format("%02x", byte:byte()) end)) end
function STBS:Base64Decode(data)
  if #data % 2 ~= 0 or data:find("[^0-9a-fA-F]") then return nil,"encoding" end
  return (data:gsub("%x%x", function(pair) return string.char(tonumber(pair, 16)) end))
end
-- Lua 5.1 compatible deterministic integrity check (not cryptography).
function STBS:Checksum(data) local h=2166136261; for i=1,#data do h=(h*31 + data:byte(i)) % 4294967296 end; return string.format("%08x",h) end
function STBS:ExportProfile(profile, modules)
  modules = modules or { graphics=true, interfaceGameplay=true }
  local selected = { graphics = modules.graphics == true, interfaceGameplay = modules.interfaceGameplay == true }
  local payload={exportVersion=self.EXPORT_VERSION,profileSchemaVersion=profile.schemaVersion,addonVersion=self.VERSION,gameFlavor="retail",clientBuild=self:GetBuild(),selectedModules=selected,profile=profile}; local raw=self:Serialize(payload); return self.EXPORT_PREFIX..self:Checksum(raw)..":"..self:Base64Encode(raw)
end

function STBS:ExportAddonBundle()
  local db=self:InitializeDatabase();local graphics=self:CaptureModules({graphics=true})
  if type(graphics)~="table" or not next(graphics) then return nil,"graphics" end
  local profiles={};local count=0
  for _,profile in ipairs(self:ListPersonalProfiles()) do
    count=count+1;if count>self.MAX_BUNDLE_PROFILES then return nil,"profiles" end
    profiles[profile.id]=self:Copy(profile)
  end
  local preferences={
    graphicsPreset=db.preferences.graphicsPreset,
    graphicsMode=db.preferences.graphicsMode,
    benchmarkMode=db.preferences.benchmarkMode,
    performanceWidgetEnabled=db.preferences.performanceWidgetEnabled,
    zoneGraphics=self:Copy(db.preferences.zoneGraphics),
  }
  local payload={bundleVersion=self.ADDON_EXPORT_VERSION,addonVersion=self.VERSION,gameFlavor="retail",clientBuild=self:GetBuild(),preferences=preferences,graphicsSettings=graphics,profiles=profiles}
  local raw=self:Serialize(payload);local output=self.ADDON_EXPORT_PREFIX..self:Checksum(raw)..":"..self:Base64Encode(raw)
  if #output>self.MAX_IMPORT_BYTES then return nil,"size" end
  return output
end
