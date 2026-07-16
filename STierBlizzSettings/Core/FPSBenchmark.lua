local _, STBS = ...

local SAMPLE_INTERVAL = 0.5
local BASELINE_SAMPLES = 16
local AFTER_SAMPLES = 16

local function finitePositive(value)
  return type(value) == "number" and value == value and value > 0 and value < math.huge
end

local function rounded(value)
  if value >= 0 then return math.floor(value + 0.5) end
  return math.ceil(value - 0.5)
end

function STBS:ReadFramerate()
  if type(_G.GetFramerate) ~= "function" then return nil end
  local ok, value = pcall(_G.GetFramerate)
  if not ok or not finitePositive(value) then return nil end
  return value
end

function STBS:AverageFramerate(samples)
  if type(samples) ~= "table" then return nil end
  local total, count = 0, 0
  for _, value in ipairs(samples) do
    if finitePositive(value) then total, count = total + value, count + 1 end
  end
  if count == 0 then return nil end
  return total / count, count
end

function STBS:CalculateFPSMetric(beforeSamples, afterSamples)
  local before, beforeCount = self:AverageFramerate(beforeSamples)
  local after, afterCount = self:AverageFramerate(afterSamples)
  if not before or not after then return nil end
  local delta = after - before
  return {
    before = before,
    after = after,
    delta = delta,
    percent = before > 0 and (delta / before) * 100 or 0,
    beforeSamples = beforeCount,
    afterSamples = afterCount,
    measuredAt = time and time() or 0,
  }
end

function STBS:FormatFPSMetric(metric)
  if type(metric) ~= "table" then return self:L("FPS_UNAVAILABLE") end
  return string.format(self:L("FPS_RESULT_FORMAT"), rounded(metric.before or 0), rounded(metric.after or 0), rounded(metric.delta or 0), rounded(metric.percent or 0))
end

function STBS:GetLastFPSMetric()
  local db = type(_G.STierBlizzSettingsCharDB) == "table" and _G.STierBlizzSettingsCharDB or nil
  return db and type(db.lastFPSMetric) == "table" and db.lastFPSMetric or nil
end

function STBS:StopFPSBaselineSampling()
  if self.fpsBaselineTicker and self.fpsBaselineTicker.Cancel then self.fpsBaselineTicker:Cancel() end
  self.fpsBaselineTicker = nil
end

function STBS:StartFPSBaselineSampling()
  if self.fpsAfterMeasurement or self.fpsBaselineTicker then return end
  self.fpsBaselineSamples = {}
  local function sample()
    local value = self:ReadFramerate()
    if value then table.insert(self.fpsBaselineSamples, value);while #self.fpsBaselineSamples > BASELINE_SAMPLES do table.remove(self.fpsBaselineSamples,1) end end
  end
  sample()
  if not C_Timer or type(C_Timer.NewTicker) ~= "function" then return end
  self.fpsBaselineTicker = C_Timer.NewTicker(SAMPLE_INTERVAL,sample)
end

function STBS:TakeFPSBaseline()
  self:StopFPSBaselineSampling()
  local samples = self.fpsBaselineSamples or {}
  if #samples == 0 then
    local value = self:ReadFramerate()
    if value then samples = { value } end
  end
  self.fpsBaselineSamples = nil
  return samples
end

function STBS:StartFPSPostMeasurement(beforeSamples, callback)
  if type(beforeSamples) ~= "table" or #beforeSamples == 0 then return false end
  if self.fpsAfterTicker and self.fpsAfterTicker.Cancel then self.fpsAfterTicker:Cancel() end
  self.fpsAfterMeasurement = true
  local afterSamples, count = {}, 0
  local function finish()
    self.fpsAfterTicker = nil
    self.fpsAfterMeasurement = nil
    local metric = self:CalculateFPSMetric(beforeSamples, afterSamples)
    if metric then
      local db = type(_G.STierBlizzSettingsCharDB) == "table" and _G.STierBlizzSettingsCharDB or {}
      _G.STierBlizzSettingsCharDB = db
      db.lastFPSMetric = metric
    end
    if callback then callback(metric) end
    self:StartFPSBaselineSampling()
  end
  local function sample(ticker)
    local value = self:ReadFramerate()
    if value then table.insert(afterSamples, value) end
    count = count + 1
    if count >= AFTER_SAMPLES then
      if ticker and ticker.Cancel then ticker:Cancel() end
      finish()
    end
  end
  if not C_Timer or type(C_Timer.NewTicker) ~= "function" then
    sample(nil)
    if count < AFTER_SAMPLES then finish() end
    return true
  end
  self.fpsAfterTicker = C_Timer.NewTicker(SAMPLE_INTERVAL, sample, AFTER_SAMPLES)
  return true
end
