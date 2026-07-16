local _, STBS = ...
function STBS:MigrateProfile(profile)
  if type(profile) ~= "table" then return nil,"schema" end
  if type(profile.schemaVersion) == "number" and profile.schemaVersion > self.PROFILE_SCHEMA then return nil,"future" end
  if not profile.schemaVersion then profile.schemaVersion=1 end
  if type(profile.sections) ~= "table" then return nil,"schema" end
  if profile.sections.graphics == nil then profile.sections.graphics = {} end
  if type(profile.sections.graphics) ~= "table" then return nil,"schema" end
  return profile
end
