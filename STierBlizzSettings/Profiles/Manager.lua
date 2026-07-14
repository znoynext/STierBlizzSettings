local _, STBS = ...
function STBS:GetSelectedMode() return self:InitializeDatabase().preferences.graphicsMode end
function STBS:SetSelectedMode(mode) if mode~=self.GRAPHICS_MODE_UNIFIED and mode~=self.GRAPHICS_MODE_SPLIT then return false end; self:InitializeDatabase().preferences.graphicsMode=mode; return true end
function STBS:FlattenProfile(profile, modules, keepMode)
  local out={}; local sections=profile.sections or {}; if modules.graphics then local g=sections.graphics or {}; for k,v in pairs(g.base or {}) do out[k]=v end; if (not keepMode and g.mode==self.GRAPHICS_MODE_SPLIT) or (keepMode==self.GRAPHICS_MODE_SPLIT) then for k,v in pairs(g.raid or {}) do out[k]=v end end; if not keepMode then out.RAIDsettingsEnabled=g.mode==self.GRAPHICS_MODE_SPLIT and "1" or "0" end end
  if modules.interfaceGameplay then for _,n in ipairs({"interface","camera","gameplay","controls","combat","nameplates","chat"}) do for k,v in pairs(sections[n] or {}) do out[k]=v end end end; return out
end
function STBS:SaveCurrent(name, modules)
  local p=self:NewProfile("personal_"..tostring(time()),"personal",name or (self:L("PERSONAL").." "..date("%Y-%m-%d %H:%M"))); local values=self:CaptureModules(modules); p.sections.graphics={mode=self:GetSelectedMode(),base={},raid={},storedInactiveRaidSettings={}}; for k,v in pairs(values) do local s=self.RegistryByKey[k]; if s.module=="graphics" then if s.category=="raidGraphics" then p.sections.graphics.raid[k]=v else p.sections.graphics.base[k]=v end elseif s.category=="camera" then p.sections.camera[k]=v else p.sections.interface[k]=v end end; self:InitializeDatabase().profiles[p.id]=p; return p
end
