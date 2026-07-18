local _, STBS = ...

STBS.UI_TWEAK_KEYS={"ResampleAlwaysSharpen","ResampleSharpness","ffxGlow","ffxDeath","ffxNether","cameraDistanceMaxZoomFactor"}
STBS.UI_TWEAK_RECOMMENDED={ResampleAlwaysSharpen="1",ResampleSharpness="0.3",ffxGlow="1"}

local function displayValue(setting,value)
  if setting and setting.numericStep then return string.format("%.1f",tonumber(value) or 0) end
  if setting and setting.toggleOn and setting.toggleOff then return tostring(value)==setting.toggleOn and setting.toggleOn or setting.toggleOff end
  return value=="1" and "1" or "0"
end

function STBS:GetUITweakAvailability()
  local result={}
  for _,key in ipairs(self.UI_TWEAK_KEYS) do
    local setting=self.RegistryByKey[key]
    local value,readWhy,writable,writeWhy
    if setting then value,readWhy=self:ReadSetting(setting);writable,writeWhy=self:CanUseCVar(key) end
    result[key]={available=setting~=nil and value~=nil and writable==true,value=value,reason=readWhy or writeWhy}
  end
  return result
end

function STBS:GetUITweaksDraft(reset)
  if reset then self.uiTweaksDraft=nil end
  if self.uiTweaksDraft then return self.uiTweaksDraft end
  local availability=self:GetUITweakAvailability();local draft={}
  for _,key in ipairs(self.UI_TWEAK_KEYS) do
    local setting=self.RegistryByKey[key];local current=availability[key] and availability[key].value
    draft[key]=displayValue(setting,current or self.UI_TWEAK_RECOMMENDED[key] or "0")
  end
  self.uiTweaksDraft=draft;return draft
end

function STBS:SetUITweakDraft(key,value)
  local setting=self.RegistryByKey[key];if not setting or setting.module~="uiTweaks" then return false end
  value=tostring(value);if setting.numericStep and not tonumber(value) then return false end;value=displayValue(setting,value)
  local valid=self:ValidateValue(setting,value);if not valid then return false end
  self:GetUITweaksDraft()[key]=value;return true
end

function STBS:SelectRecommendedUITweaks()
  local draft=self:GetUITweaksDraft()
  for key,value in pairs(self.UI_TWEAK_RECOMMENDED) do draft[key]=value end
  return draft
end

function STBS:GetAvailableUITweakSettings()
  local availability=self:GetUITweakAvailability();local draft=self:GetUITweaksDraft();local settings={}
  for _,key in ipairs(self.UI_TWEAK_KEYS) do if availability[key] and availability[key].available then settings[key]=draft[key] end end
  return settings,availability
end
