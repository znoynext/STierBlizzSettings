local _, STBS = ...
function STBS:BuildDiff(settings)
  local plan, summary = {}, { changed=0, identical=0, skipped=0, failed=0, unavailable=0 }
  for key, value in pairs(settings or {}) do
    local setting = self.RegistryByKey[key]
    if setting then
      local valid, why = self:ValidateValue(setting, value)
      local current, readWhy = self:ReadSetting(setting)
      local writable, writeWhy = self:CanUseCVar(setting.key)
      local status = not valid and (why == "unsupported" and "skipped" or "failed") or (not current and "unavailable") or (self:SettingValuesEqual(setting,current,value) and "identical") or (not writable and "unavailable") or "changed"
      summary[status] = (summary[status] or 0) + 1; table.insert(plan, { setting=setting, current=current, value=value, status=status, reason=why or readWhy or writeWhy })
    end
  end
  local order={graphics=1,raidGraphics=2,recommendedTweaks=3,optionalTweaks=4,camera=5,interface=6,combat=7,nameplates=8,gameplay=9,controls=10,chat=11}
  table.sort(plan, function(a,b) local ac,bc=order[a.setting.category]or 99,order[b.setting.category]or 99;if ac~=bc then return ac<bc end;return a.setting.key<b.setting.key end); return plan, summary
end
