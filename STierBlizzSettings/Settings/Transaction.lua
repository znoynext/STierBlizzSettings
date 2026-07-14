local _, STBS = ...
function STBS:ApplySettings(settings, modules, trigger, options)
  options = options == true and { skipBackup = true } or options or {}
  if InCombatLockdown and InCombatLockdown() then
    if self.pending then return self:Result(false,"pending-exists") end
    self.pending={settings=self:Copy(settings),modules=self:Copy(modules),trigger=trigger,options=self:Copy(options)}; return self:Result(false,"queued")
  end
  local valid, why=self:ValidateSettings(settings,false);if not valid then return self:Result(false,why) end
  local plan=self:BuildDiff(settings);local backup = options.skipBackup and self:Result(true,"skipped") or self:CreateBackup(modules,trigger);if not backup.ok then return backup end
  local result={graphics={changed=0,identical=0,skipped=0,failed=0,unavailable=0,categories={}},interfaceGameplay={changed=0,identical=0,skipped=0,failed=0,unavailable=0,categories={}},backup=backup.data}
  for _,entry in ipairs(plan) do local target=entry.setting.module;if modules[target] then
    local category = result[target].categories[entry.setting.category] or {changed=0,identical=0,skipped=0,failed=0,unavailable=0}; result[target].categories[entry.setting.category]=category
    local status=entry.status;if status=="changed" then local ok,writeStatus=self:WriteSetting(entry.setting,entry.value);status=ok and writeStatus or "failed" end
    result[target][status]=(result[target][status]or 0)+1;category[status]=(category[status]or 0)+1
  end end
  local db=self:InitializeDatabase();table.insert(db.transactions,1,{time=time(),trigger=trigger,modules=self:Copy(modules),result=self:Copy(result)});while #db.transactions>20 do table.remove(db.transactions) end;return self:Result(true,"applied",result)
end
function STBS:CancelPendingOperation() if not self.pending then return self:Result(false,"no-pending") end; self.pending=nil; return self:Result(true,"cancelled") end
function STBS:ApplyOfficial(kind)
  local modules=kind=="graphics" and {graphics=true} or kind=="interface" and {interfaceGameplay=true} or {graphics=true,interfaceGameplay=true};local settings={}
  if modules.graphics then local mode=self:GetSelectedMode();if not mode then return self:Result(false,"mode") end;settings=self:FlattenProfile(self:GetOfficialGraphics(mode),{graphics=true}) end
  if modules.interfaceGameplay then local interface=self:FlattenProfile(self:GetOfficialInterface(),{interfaceGameplay=true});for k,v in pairs(interface) do settings[k]=v end end
  return self:ApplySettings(settings,modules,"official-"..kind)
end
