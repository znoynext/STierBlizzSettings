local _, STBS = ...

STBS.DIFF_SUMMARY_KEYS={"changed","identical","skipped","unavailable","failed"}
local knownDiffStatus={changed=true,identical=true,skipped=true,unavailable=true,failed=true}

function STBS:NewDiffSummary()
  return {changed=0,identical=0,skipped=0,unavailable=0,failed=0}
end

function STBS:CopyDiffSummary(source)
  local summary=self:NewDiffSummary();source=type(source)=="table" and source or {}
  for _,key in ipairs(self.DIFF_SUMMARY_KEYS) do summary[key]=math.max(0,tonumber(source[key]) or 0) end
  return summary
end

function STBS:AddDiffSummaryCount(summary,status,count)
  if type(summary)~="table" or not knownDiffStatus[status] then return false end
  summary[status]=(tonumber(summary[status]) or 0)+(tonumber(count) or 1)
  return true
end

function STBS:MergeDiffSummary(summary,source)
  if type(summary)~="table" then return nil end
  source=type(source)=="table" and source or {}
  for _,key in ipairs(self.DIFF_SUMMARY_KEYS) do self:AddDiffSummaryCount(summary,key,tonumber(source[key]) or 0) end
  return summary
end

function STBS:MoveDiffSummaryStatus(summary,fromStatus,toStatus,count)
  count=tonumber(count) or 1
  if type(summary)~="table" or not knownDiffStatus[fromStatus] or not knownDiffStatus[toStatus] or count<0 or (tonumber(summary[fromStatus]) or 0)<count then return false end
  summary[fromStatus]=(tonumber(summary[fromStatus]) or 0)-count
  summary[toStatus]=(tonumber(summary[toStatus]) or 0)+count
  return true
end

function STBS:SummarizeDiff(plan,modules)
  local summary=self:NewDiffSummary()
  for _,entry in ipairs(type(plan)=="table" and plan or {}) do
    local setting=type(entry)=="table" and entry.setting or nil
    if setting and (modules==nil or modules[setting.module]) then self:AddDiffSummaryCount(summary,entry.status) end
  end
  return summary
end

function STBS:GetResultDiffSummary(result,module)
  local data=type(result)=="table" and type(result.data)=="table" and result.data or type(result)=="table" and result or {}
  return self:CopyDiffSummary(module and data[module] or data.summary)
end

function STBS:BuildDiff(settings,modules)
  local plan = {}
  for key, value in pairs(settings or {}) do
    local setting = self.RegistryByKey[key]
    if setting and (modules==nil or modules[setting.module]) then
      local valid, why = self:ValidateValue(setting, value)
      local current, readWhy = self:ReadSetting(setting)
      local writable, writeWhy = self:CanUseCVar(setting.key)
      local status = not valid and (why == "unsupported" and "skipped" or "failed") or (not current and "unavailable") or (self:SettingValuesEqual(setting,current,value) and "identical") or (not writable and "unavailable") or "changed"
      table.insert(plan, { setting=setting, current=current, value=value, status=status, reason=why or readWhy or writeWhy })
    end
  end
  local order={graphics=1,raidGraphics=2,recommendedTweaks=3,optionalTweaks=4,camera=5,interface=6,combat=7,nameplates=8,gameplay=9,controls=10,chat=11}
  table.sort(plan, function(a,b) local ac,bc=order[a.setting.category]or 99,order[b.setting.category]or 99;if ac~=bc then return ac<bc end;return a.setting.key<b.setting.key end)
  return plan,self:SummarizeDiff(plan)
end
