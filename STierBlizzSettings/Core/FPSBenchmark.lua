local _, STBS = ...

local QUICK_INTERVAL=0.25
local QUICK_SAMPLES=20
local ACCURATE_PHASE_SECONDS=10
local STANDALONE_TEST_SECONDS=20

local function finitePositive(value) return type(value)=="number" and value==value and value>0 and value<math.huge end
local function rounded(value) if value>=0 then return math.floor(value+0.5) end return math.ceil(value-0.5) end

function STBS:ReadFramerate()
  if type(_G.GetFramerate)~="function" then return nil end
  local ok,value=pcall(_G.GetFramerate);if not ok or not finitePositive(value) then return nil end;return value
end

function STBS:AverageFramerate(samples)
  if type(samples)~="table" then return nil end
  local total,count=0,0;for _,value in ipairs(samples) do if finitePositive(value) then total,count=total+value,count+1 end end
  if count==0 then return nil end;return total/count,count
end

function STBS:FrametimeStats(frameTimes)
  if type(frameTimes)~="table" then return nil end
  local values,total={},0
  for _,elapsed in ipairs(frameTimes) do if finitePositive(elapsed) then values[#values+1]=elapsed;total=total+elapsed end end
  if #values==0 or total<=0 then return nil end
  table.sort(values,function(a,b)return a>b end)
  local lowCount=math.max(1,math.ceil(#values*0.01));local worstTotal=0
  for index=1,lowCount do worstTotal=worstTotal+values[index] end
  local average=#values/total;local onePercentLow=lowCount/worstTotal;local median=values[math.ceil(#values/2)];local spikeThreshold=math.max(0.05,median*2.5);local spikes=0
  for _,elapsed in ipairs(values) do if elapsed>spikeThreshold then spikes=spikes+1 end end
  return {average=average,onePercentLow=onePercentLow,stability=math.min(100,onePercentLow/average*100),spikes=spikes,worstFrameMs=values[1]*1000,spikeThresholdMs=spikeThreshold*1000,frames=#values,duration=total}
end

function STBS:CalculateFPSMetric(beforeSamples,afterSamples,beforeFrameTimes,afterFrameTimes)
  local before,beforeCount=self:AverageFramerate(beforeSamples);local after,afterCount=self:AverageFramerate(afterSamples)
  local beforeStats=self:FrametimeStats(beforeFrameTimes);local afterStats=self:FrametimeStats(afterFrameTimes)
  if beforeStats then before,beforeCount=beforeStats.average,beforeStats.frames end;if afterStats then after,afterCount=afterStats.average,afterStats.frames end
  if not before or not after then return nil end
  local delta=after-before
  return {before=before,after=after,delta=delta,percent=before>0 and delta/before*100 or 0,beforeSamples=beforeCount,afterSamples=afterCount,beforeOnePercentLow=beforeStats and beforeStats.onePercentLow or nil,afterOnePercentLow=afterStats and afterStats.onePercentLow or nil,mode=beforeStats and self.BENCHMARK_ACCURATE or self.BENCHMARK_QUICK,measuredAt=time and time() or 0}
end

function STBS:FormatFPSMetric(metric)
  if type(metric)~="table" then return self:L("FPS_UNAVAILABLE") end
  local result=string.format(self:L("FPS_RESULT_FORMAT"),rounded(metric.before or 0),rounded(metric.after or 0),rounded(metric.delta or 0),rounded(metric.percent or 0))
  if finitePositive(metric.beforeOnePercentLow) and finitePositive(metric.afterOnePercentLow) then result=result.."\n"..string.format(self:L("FPS_LOW_RESULT_FORMAT"),rounded(metric.beforeOnePercentLow),rounded(metric.afterOnePercentLow)) end
  return result
end

function STBS:GetLastFPSMetric() local db=type(_G.STierBlizzSettingsCharDB)=="table" and _G.STierBlizzSettingsCharDB or nil;return db and type(db.lastFPSMetric)=="table" and db.lastFPSMetric or nil end
function STBS:StoreFPSMetric(metric) if not metric then return end;local db=type(_G.STierBlizzSettingsCharDB)=="table" and _G.STierBlizzSettingsCharDB or {};_G.STierBlizzSettingsCharDB=db;db.lastFPSMetric=metric end
function STBS:GetLastStandaloneFPSTest() local db=type(_G.STierBlizzSettingsCharDB)=="table" and _G.STierBlizzSettingsCharDB or nil;return db and type(db.lastStandaloneFPSTest)=="table" and db.lastStandaloneFPSTest or nil end
function STBS:StoreStandaloneFPSTest(result) if not result then return end;local db=type(_G.STierBlizzSettingsCharDB)=="table" and _G.STierBlizzSettingsCharDB or {};_G.STierBlizzSettingsCharDB=db;result.measuredAt=time and time() or 0;db.lastStandaloneFPSTest=result end
function STBS:GetBenchmarkMode() return self:InitializeDatabase().preferences.benchmarkMode end
function STBS:SetBenchmarkMode(mode) if mode~=self.BENCHMARK_QUICK and mode~=self.BENCHMARK_ACCURATE then return false end;self:InitializeDatabase().preferences.benchmarkMode=mode;return true end

function STBS:SetLiveFPSCallback(callback) self.liveFPSCallback=type(callback)=="function" and callback or nil;if self.liveFPSCallback then self.liveFPSCallback(self:ReadFramerate()) end end
function STBS:NotifyLiveFPS(value) if self.liveFPSCallback then self.liveFPSCallback(value) end end
function STBS:StopFPSBaselineSampling() if self.fpsBaselineTicker and self.fpsBaselineTicker.Cancel then self.fpsBaselineTicker:Cancel() end;self.fpsBaselineTicker=nil end
function STBS:StartFPSBaselineSampling()
  if self.fpsAfterMeasurement or self.fpsAccurateMeasurement or self.fpsTestMeasurement or self.fpsBaselineTicker then return end;self.fpsBaselineSamples={}
  local function sample()local value=self:ReadFramerate();self:NotifyLiveFPS(value);if value then table.insert(self.fpsBaselineSamples,value);while #self.fpsBaselineSamples>QUICK_SAMPLES do table.remove(self.fpsBaselineSamples,1) end end end
  sample();if C_Timer and type(C_Timer.NewTicker)=="function" then self.fpsBaselineTicker=C_Timer.NewTicker(QUICK_INTERVAL,sample) end
end
function STBS:TakeFPSBaseline() self:StopFPSBaselineSampling();local samples=self.fpsBaselineSamples or {};if #samples==0 then local value=self:ReadFramerate();if value then samples={value} end end;self.fpsBaselineSamples=nil;return samples end

function STBS:StartFPSPostMeasurement(beforeSamples,callback)
  if type(beforeSamples)~="table" or #beforeSamples==0 then return false end
  if self.fpsAfterTicker and self.fpsAfterTicker.Cancel then self.fpsAfterTicker:Cancel() end;self.fpsAfterMeasurement=true;local afterSamples,count={},0
  local function finish()self.fpsAfterTicker=nil;self.fpsAfterMeasurement=nil;local metric=self:CalculateFPSMetric(beforeSamples,afterSamples);self:StoreFPSMetric(metric);if callback then callback(metric) end;self:StartFPSBaselineSampling()end
  local function sample(ticker)local value=self:ReadFramerate();self:NotifyLiveFPS(value);if value then afterSamples[#afterSamples+1]=value end;count=count+1;if count>=QUICK_SAMPLES then if ticker and ticker.Cancel then ticker:Cancel() end;finish() end end
  if not C_Timer or type(C_Timer.NewTicker)~="function" then sample(nil);if count<QUICK_SAMPLES then finish() end;return true end
  self.fpsAfterTicker=C_Timer.NewTicker(QUICK_INTERVAL,sample,QUICK_SAMPLES);return true
end

function STBS:CaptureFrameTimes(duration,phase,callback)
  if type(_G.CreateFrame)~="function" then return false end
  local frame=CreateFrame("Frame");local elapsedTotal,displayElapsed,frameTimes=0,0,{};self.fpsAccuratePhase=phase
  if self.ui and self.ui:IsShown() and self.ui.currentPageKey=="graphics" then self:ShowGraphics() end
  frame:SetScript("OnUpdate",function(self,elapsed)
    if finitePositive(elapsed) then frameTimes[#frameTimes+1]=elapsed;elapsedTotal=elapsedTotal+elapsed;displayElapsed=displayElapsed+elapsed;if phase=="standalone" then STBS.fpsTestElapsed=elapsedTotal end end
    if displayElapsed>=QUICK_INTERVAL then STBS:NotifyLiveFPS(STBS:ReadFramerate());if phase=="standalone" and STBS.ui and STBS.ui:IsShown() and STBS.ui.currentPageKey=="fpsTest" then STBS.ui.status:SetText(string.format(STBS:L("FPS_TEST_PROGRESS"),math.min(duration,math.floor(elapsedTotal+0.5)),duration)) end;displayElapsed=0 end
    if elapsedTotal>=duration then self:SetScript("OnUpdate",nil);callback(frameTimes) end
  end);return true
end

function STBS:StartStandaloneFPSTest(doneCallback)
  if self.fpsTestMeasurement or self.fpsAfterMeasurement or self.fpsAccurateMeasurement then return false end
  self:StopFPSBaselineSampling();self.fpsTestMeasurement=true;self.fpsTestElapsed=0
  local started=self:CaptureFrameTimes(STANDALONE_TEST_SECONDS,"standalone",function(frameTimes)
    self.fpsTestMeasurement=nil;self.fpsTestElapsed=nil;self.fpsAccuratePhase=nil;local result=self:FrametimeStats(frameTimes);self:StoreStandaloneFPSTest(result)
    if doneCallback then doneCallback(result) end
  end)
  if not started then self.fpsTestMeasurement=nil;self.fpsTestElapsed=nil;self.fpsAccuratePhase=nil end
  return started
end

function STBS:StartAccurateFPSComparison(applyCallback,doneCallback)
  if self.fpsAccurateMeasurement or type(applyCallback)~="function" then return false end
  self:StopFPSBaselineSampling();self.fpsAccurateMeasurement=true
  local started=self:CaptureFrameTimes(ACCURATE_PHASE_SECONDS,"before",function(beforeTimes)
    local result=applyCallback();if not result or not result.ok then self.fpsAccurateMeasurement=nil;self.fpsAccuratePhase=nil;if doneCallback then doneCallback(nil,result) end;return end
    self:CaptureFrameTimes(ACCURATE_PHASE_SECONDS,"after",function(afterTimes)
      self.fpsAccurateMeasurement=nil;self.fpsAccuratePhase=nil;local metric=self:CalculateFPSMetric(nil,nil,beforeTimes,afterTimes);self:StoreFPSMetric(metric);if doneCallback then doneCallback(metric,result) end;self:StartFPSBaselineSampling()
    end)
  end)
  if not started then self.fpsAccurateMeasurement=nil;self.fpsAccuratePhase=nil end;return started
end
