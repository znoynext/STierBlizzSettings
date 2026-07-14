local _, STBS = ...
function STBS:BuildDiff(settings)
  local plan, summary = {}, { changed=0, identical=0, skipped=0, failed=0, unavailable=0 }
  for key, value in pairs(settings or {}) do
    local setting = self.RegistryByKey[key]
    if setting then
      local valid, why = self:ValidateValue(setting, value)
      local current, readWhy = self:ReadSetting(setting)
      local status = not valid and (why == "unsupported" and "skipped" or "failed") or (not current and "unavailable") or (current == value and "identical" or "changed")
      summary[status] = (summary[status] or 0) + 1; table.insert(plan, { setting=setting, current=current, value=value, status=status, reason=why or readWhy })
    end
  end
  table.sort(plan, function(a,b) return a.setting.key < b.setting.key end); return plan, summary
end
