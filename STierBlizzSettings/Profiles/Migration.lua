local _, STBS = ...
function STBS:MigrateProfile(profile)
  if type(profile) ~= "table" then return nil,"schema" end
  if profile.schemaVersion > self.PROFILE_SCHEMA then return nil,"future" end
  if not profile.schemaVersion then profile.schemaVersion=1 end
  profile.sections=profile.sections or {}; profile.sections.graphics=profile.sections.graphics or {}; return profile
end
