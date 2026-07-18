local _, STBS = ...
function STBS:ApplySettings(settings, modules, trigger, options)
  options = options == true and { skipBackup = true } or options or {}
  local validModules, modulesWhy=self:ValidateModules(modules);if not validModules then return self:Result(false,modulesWhy) end
  local valid, why=self:ValidateSettings(settings,false);if not valid then return self:Result(false,why) end
  local selectedSettings=0;for key in pairs(settings)do local setting=self.RegistryByKey[key];if setting and modules[setting.module]then selectedSettings=selectedSettings+1 end end;if selectedSettings==0 then return self:Result(false,"no-settings") end
  if InCombatLockdown and InCombatLockdown() then
    if self.pending then return self:Result(false,"pending-exists") end
    self.pending={settings=self:Copy(settings),modules=self:Copy(modules),trigger=trigger,options=self:Copy(options)}; return self:Result(false,"queued")
  end
  local plan=self:BuildDiff(settings);local backup = options.skipBackup and self:Result(true,"skipped") or self:CreateBackup(modules,trigger,options.deferBackupTrim==true);if not backup.ok then return backup end
  local result={graphics={changed=0,identical=0,skipped=0,failed=0,unavailable=0,categories={}},interfaceGameplay={changed=0,identical=0,skipped=0,failed=0,unavailable=0,categories={}},backup=backup.data}
  local attempted={}
  for _,entry in ipairs(plan) do local target=entry.setting.module;if modules[target] then
    local category = result[target].categories[entry.setting.category] or {changed=0,identical=0,skipped=0,failed=0,unavailable=0}; result[target].categories[entry.setting.category]=category
    local status=entry.status;if status=="changed" then
      table.insert(attempted,entry)
      local ok,writeStatus=self:WriteSetting(entry.setting,entry.value);status=ok and writeStatus or "failed"
    end
    result[target][status]=(result[target][status]or 0)+1;category[status]=(category[status]or 0)+1
    if status=="failed" then
      local rollback={attempted=#attempted,restored=0,failed=0}
      for index=#attempted,1,-1 do
        local applied=attempted[index]
        local current=self:ReadSetting(applied.setting)
        if current==applied.current then rollback.restored=rollback.restored+1
        else
          local restored=self:WriteSetting(applied.setting,applied.current)
          if restored then rollback.restored=rollback.restored+1 else rollback.failed=rollback.failed+1 end
        end
      end
      result.rollback=rollback
      local db=self:InitializeDatabase();table.insert(db.transactions,1,{time=time(),trigger=trigger,modules=self:Copy(modules),result=self:Copy(result),code=rollback.failed==0 and "rolled-back" or "rollback-failed"});while #db.transactions>20 do table.remove(db.transactions) end
      return self:Result(false,rollback.failed==0 and "rolled-back" or "rollback-failed",result)
    end
  end end
  local db=self:InitializeDatabase();table.insert(db.transactions,1,{time=time(),trigger=trigger,modules=self:Copy(modules),result=self:Copy(result),code="applied"});while #db.transactions>20 do table.remove(db.transactions) end;return self:Result(true,"applied",result)
end
function STBS:CancelPendingOperation() if not self.pending then return self:Result(false,"no-pending") end; self.pending=nil; return self:Result(true,"cancelled") end
function STBS:ApplyOfficial(kind, options)
  local modules=kind=="graphics" and {graphics=true} or kind=="interface" and {interfaceGameplay=true} or {graphics=true,interfaceGameplay=true};local settings={}
  if modules.graphics then local mode=self:GetSelectedMode();if not mode then return self:Result(false,"mode") end;settings=self:FlattenProfile(self:GetOfficialGraphics(mode),{graphics=true}) end
  if modules.interfaceGameplay then local interface=self:FlattenProfile(self:GetOfficialInterface(),{interfaceGameplay=true});for k,v in pairs(interface) do settings[k]=v end end
  local officialValid, officialWhy=self:ValidateSettings(settings,true);if not officialValid then return self:Result(false,officialWhy) end
  return self:ApplySettings(settings,modules,"official-"..kind,options)
end
