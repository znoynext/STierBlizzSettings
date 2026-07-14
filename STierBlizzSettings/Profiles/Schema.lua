local _, STBS = ...
function STBS:NewProfile(id, kind, name)
  local build = self:GetBuild(); return { schemaVersion=self.PROFILE_SCHEMA,id=id,profileType=kind,displayName=name,authorName="S-Tier Blizz Settings Team",description="",gameFlavor="retail",testedClientBuild=build,addonVersion=self.VERSION,createdAt=time(),updatedAt=time(),verification={status=kind=="recommended" and "official" or "unverified",permissionConfirmed=true},sections={graphics={},interface={},camera={},gameplay={},controls={},combat={},nameplates={},chat={},accessibility={},sound={}} }
end
function STBS:ValidateProfile(profile)
  if type(profile)~="table" or type(profile.schemaVersion)~="number" or type(profile.sections)~="table" then return false,"schema" end
  if profile.schemaVersion > self.PROFILE_SCHEMA then return false,"future" end
  if profile.gameFlavor and profile.gameFlavor ~= "retail" then return false,"flavor" end
  local merged = {}
  local graphics = profile.sections.graphics or {}
  for key, value in pairs(graphics.base or {}) do merged[key] = value end
  for key, value in pairs(graphics.raid or {}) do merged[key] = value end
  for name, section in pairs(profile.sections) do
    if name ~= "graphics" and type(section) == "table" then
      for key, value in pairs(section) do merged[key] = value end
    end
  end
  return self:ValidateSettings(merged, profile.profileType == "recommended")
end
