local _, STBS = ...
function STBS:NewProfile(id, kind, name)
  local build = self:GetBuild(); return { schemaVersion=self.PROFILE_SCHEMA,id=id,profileType=kind,displayName=name,authorName="S-Tier Blizz Settings Team",description="",gameFlavor="retail",testedClientBuild=build,addonVersion=self.VERSION,createdAt=time(),updatedAt=time(),verification={status=kind=="recommended" and "official" or "unverified",permissionConfirmed=true},sections={graphics={},interface={},camera={},gameplay={},controls={},combat={},nameplates={},chat={},accessibility={},sound={}} }
end
local allowedSections = { graphics=true, interface=true, camera=true, gameplay=true, controls=true, combat=true, nameplates=true, chat=true, accessibility=true, sound=true }
local allowedProfileTypes = { recommended=true, personal=true, professionalPlayer=true }
local allowedGraphicsFields = { mode=true, base=true, raid=true, storedInactiveRaidSettings=true }
local function plainString(value, maximum, required, multiline)
  if type(value) ~= "string" or #value > maximum or (required and value == "") then return false end
  return not value:find(multiline and "[%z\1-\8\11\12\14-\31\127]" or "[%c]")
end
function STBS:ValidateProfile(profile)
  if type(profile)~="table" or type(profile.schemaVersion)~="number" or type(profile.sections)~="table" then return false,"schema" end
  if profile.schemaVersion < 1 or profile.schemaVersion ~= math.floor(profile.schemaVersion) or profile.schemaVersion > self.PROFILE_SCHEMA then return false,"future" end
  if profile.gameFlavor ~= "retail" then return false,"flavor" end
  if not plainString(profile.id, self.MAX_PROFILE_ID_BYTES, true) or not profile.id:match("^[%w%._%-]+$") then return false,"id" end
  if not allowedProfileTypes[profile.profileType] then return false,"profileType" end
  if not plainString(profile.displayName, self.MAX_PROFILE_NAME_BYTES, true) then return false,"displayName" end
  if profile.authorName ~= nil and not plainString(profile.authorName, self.MAX_PROFILE_NAME_BYTES, false) then return false,"authorName" end
  if profile.description ~= nil and not plainString(profile.description, self.MAX_PROFILE_DESCRIPTION_BYTES, false, true) then return false,"description" end
  local merged = {}
  for name, section in pairs(profile.sections) do if not allowedSections[name] or type(section) ~= "table" then return false,"section" end end
  local graphics = profile.sections.graphics or {}
  for key in pairs(graphics) do if not allowedGraphicsFields[key] then return false,"graphics-field" end end
  if graphics.mode ~= nil and graphics.mode ~= self.GRAPHICS_MODE_UNIFIED and graphics.mode ~= self.GRAPHICS_MODE_SPLIT then return false,"mode" end
  for _, name in ipairs({"base", "raid", "storedInactiveRaidSettings"}) do if graphics[name] ~= nil and type(graphics[name]) ~= "table" then return false,"graphics" end end
  for key, value in pairs(graphics.base or {}) do merged[key] = value end
  for key, value in pairs(graphics.raid or {}) do merged[key] = value end
  if (next(graphics.base or {}) or next(graphics.raid or {})) and graphics.mode == nil then return false,"mode" end
  for key, value in pairs(graphics.storedInactiveRaidSettings or {}) do
    local setting = self.RegistryByKey[key]; if not setting or setting.category ~= "raidGraphics" then return false,"inactive:"..tostring(key) end
    local ok, why = self:ValidateValue(setting, value); if not ok and why ~= "unsupported" then return false,why..":"..key end
  end
  for name, section in pairs(profile.sections) do
    if name ~= "graphics" and type(section) == "table" then
      for key, value in pairs(section) do merged[key] = value end
    end
  end
  return self:ValidateSettings(merged, profile.profileType == "recommended")
end
