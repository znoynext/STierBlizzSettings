local _, STBS = ...
function STBS:ApplySettings(settings, modules, trigger, restoring)
  if InCombatLockdown and InCombatLockdown() then self.pending={settings=self:Copy(settings),modules=self:Copy(modules),trigger=trigger,restoring=restoring}; return self:Result(false,"queued") end
  local valid, why=self:ValidateSettings(settings,false);if not valid then return self:Result(false,why) end
  local plan=self:BuildDiff(settings);local backup=self:CreateBackup(modules,trigger,restoring);if not backup.ok then return backup end
  local result={graphics={changed=0,identical=0,skipped=0,failed=0},interfaceGameplay={changed=0,identical=0,skipped=0,failed=0},backup=backup.data}
  for _,entry in ipairs(plan) do local target=entry.setting.module;if modules[target] then if entry.status=="changed" then local ok,status=self:WriteSetting(entry.setting,entry.value);if ok then result[target][status]=(result[target][status]or 0)+1 else result[target].failed=result[target].failed+1 end else result[target][entry.status]=(result[target][entry.status]or 0)+1 end end end
  local db=self:InitializeDatabase();table.insert(db.transactions,1,{time=time(),trigger=trigger,modules=self:Copy(modules),result=self:Copy(result)});while #db.transactions>20 do table.remove(db.transactions) end;return self:Result(true,"applied",result)
end
function STBS:ApplyOfficial(kind)
  local modules=kind=="graphics" and {graphics=true} or kind=="interface" and {interfaceGameplay=true} or {graphics=true,interfaceGameplay=true};local settings={}
  if modules.graphics then local mode=self:GetSelectedMode();if not mode then return self:Result(false,"mode") end;settings=self:FlattenProfile(self:GetOfficialGraphics(mode),{graphics=true}) end
  if modules.interfaceGameplay then local interface=self:FlattenProfile(self:GetOfficialInterface(),{interfaceGameplay=true});for k,v in pairs(interface) do settings[k]=v end end
  return self:ApplySettings(settings,modules,"official-"..kind)
end
