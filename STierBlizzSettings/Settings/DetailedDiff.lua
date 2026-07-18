local _, STBS = ...

local detailedStatuses={changed=true,unavailable=true,skipped=true,failed=true}

function STBS:BuildDetailedDiffModel(plan,summary)
  local model={summary=summary and self:CopyDiffSummary(summary) or self:SummarizeDiff(plan),changed={},unavailable={},skipped={},failed={}}
  for _,entry in ipairs(type(plan)=="table" and plan or {}) do
    local setting=type(entry)=="table" and entry.setting or nil
    if setting and detailedStatuses[entry.status] then
      table.insert(model[entry.status],{
        status=entry.status,technicalKey=setting.key,labelKey=setting.labelKey,blizzardLabel=setting.blizzardLabel,
        explanationKey=setting.diffExplanationKey or "DIFF_EXPLAIN_GENERIC",valueType=setting.valueType,
        category=setting.category,current=entry.current,target=entry.value,reason=entry.reason,setting=setting,
      })
    end
  end
  return model
end

function STBS:FormatDetailedDiffValue(item,value)
  if value==nil then return self:L("DIFF_VALUE_UNAVAILABLE") end
  value=tostring(value);local setting=item and item.setting or nil
  if setting and (setting.key=="graphicsSpellDensity" or setting.key=="raidGraphicsSpellDensity") then
    local labels={['0']="DIFF_VALUE_ESSENTIAL",['1']="DIFF_VALUE_REDUCED",['2']="DIFF_VALUE_EVERYTHING"};return self:L(labels[value] or "DIFF_VALUE_UNKNOWN")
  end
  if setting and setting.key=="RAIDsettingsEnabled" then return self:L(value=="1" and "DIFF_VALUE_SEPARATE" or value=="0" and "DIFF_VALUE_UNIFIED" or "DIFF_VALUE_UNKNOWN") end
  if item and item.valueType=="booleanString" then return self:L(value=="1" and "DIFF_VALUE_ENABLED" or value=="0" and "DIFF_VALUE_DISABLED" or "DIFF_VALUE_UNKNOWN") end
  if setting and setting.key=="cameraDistanceMaxZoomFactor" then return string.format(self:L("DIFF_VALUE_FACTOR"),tonumber(value) or 0) end
  if setting and setting.numericTolerance then return value end
  if tonumber(value) then return string.format(self:L("DIFF_VALUE_LEVEL"),value) end
  return self:L("DIFF_VALUE_UNKNOWN")
end

function STBS:GetDetailedDiffReason(item)
  if item.status=="unavailable" then return self:L("DIFF_REASON_UNAVAILABLE") end
  if item.status=="skipped" then return self:L(item.reason=="unsupported" and "DIFF_REASON_UNSUPPORTED" or "DIFF_REASON_SKIPPED") end
  if item.status=="failed" then return self:L("DIFF_REASON_FAILED") end
  return self:L("DIFF_EXPLAIN_GENERIC")
end

function STBS:FormatDetailedDiff(model)
  model=type(model)=="table" and model or self:BuildDetailedDiffModel({})
  local lines={self:L("DETAILED_DIFF_HELP")}
  local function addGroup(titleKey,items,color)
    if type(items)~="table" or #items==0 then return end
    table.insert(lines,"");table.insert(lines,color..string.format(self:L(titleKey),#items).."|r")
    for _,item in ipairs(items) do
      local label=self:GetSettingLabel(item.setting)
      table.insert(lines,"\n|cffffd36b"..label.."|r")
      if item.status=="changed" then
        table.insert(lines,string.format(self:L("DIFF_CURRENT_TO_TARGET"),self:FormatDetailedDiffValue(item,item.current),self:FormatDetailedDiffValue(item,item.target)))
        table.insert(lines,"|cff9aa7b8"..self:L(item.explanationKey).."|r")
      else table.insert(lines,"|cff9aa7b8"..self:GetDetailedDiffReason(item).."|r") end
    end
  end
  addGroup("DETAILED_DIFF_CHANGED",model.changed,"|cff59ff9f")
  addGroup("DETAILED_DIFF_UNAVAILABLE",model.unavailable,"|cffffc65c")
  addGroup("DETAILED_DIFF_SKIPPED",model.skipped,"|cff65cfff")
  addGroup("DETAILED_DIFF_FAILED",model.failed,"|cffff6154")
  if #model.changed==0 and #model.unavailable==0 and #model.skipped==0 and #model.failed==0 then table.insert(lines,"\n\n|cff59ff9f"..self:L("DETAILED_DIFF_EMPTY").."|r") end
  return table.concat(lines,"\n")
end
