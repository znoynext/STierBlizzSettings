local _, STBS = ...

STBS.DEFAULT_WINDOW_WIDTH=1080
STBS.DEFAULT_WINDOW_HEIGHT=760
STBS.MIN_WINDOW_WIDTH=900
STBS.MIN_WINDOW_HEIGHT=640
STBS.MAX_WINDOW_WIDTH=1280
STBS.MAX_WINDOW_HEIGHT=900

local function finite(value)return type(value)=="number" and value==value and value~=math.huge and value~=-math.huge end

function STBS:IsValidSavedWindowSize(width,height)
  return finite(width) and finite(height) and width>=self.MIN_WINDOW_WIDTH and width<=self.MAX_WINDOW_WIDTH and height>=self.MIN_WINDOW_HEIGHT and height<=self.MAX_WINDOW_HEIGHT
end

function STBS:ResolveSavedWindowPosition(position,width,height,screenWidth,screenHeight)
  if type(position)~="table" or position.point~="CENTER" or not finite(position.x) or not finite(position.y) then return nil end
  if not finite(width) or not finite(height) or not finite(screenWidth) or not finite(screenHeight) or width<=0 or height<=0 or screenWidth<=0 or screenHeight<=0 then return nil end
  local centerX,centerY=screenWidth/2+position.x,screenHeight/2+position.y
  local left,right=centerX-width/2,centerX+width/2;local top=centerY+height/2;local headerBottom=top-80
  local visibleWidth=math.min(right,screenWidth)-math.max(left,0);local visibleHeader=math.min(top,screenHeight)-math.max(headerBottom,0)
  if visibleWidth<120 or visibleHeader<24 then return nil end
  return position.x,position.y
end

function STBS:GetSafeDefaultWindowSize()
  local screenWidth=UIParent and tonumber(UIParent:GetWidth()) or self.DEFAULT_WINDOW_WIDTH;local screenHeight=UIParent and tonumber(UIParent:GetHeight()) or self.DEFAULT_WINDOW_HEIGHT
  local maxWidth=math.max(760,math.min(self.MAX_WINDOW_WIDTH,screenWidth-24));local maxHeight=math.max(560,math.min(self.MAX_WINDOW_HEIGHT,screenHeight-24))
  return math.min(self.DEFAULT_WINDOW_WIDTH,maxWidth),math.min(self.DEFAULT_WINDOW_HEIGHT,maxHeight)
end

function STBS:SaveWindowPosition()
  if not self.ui or not UIParent then return false,"window-unavailable" end
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return false,databaseFailure.code end
  local x,y=self.ui:GetCenter();local parentX,parentY=UIParent:GetCenter();if not finite(x) or not finite(y) or not finite(parentX) or not finite(parentY) then return false,"window-position" end
  db.preferences.windowPosition={point="CENTER",x=x-parentX,y=y-parentY};return true
end

function STBS:ResetUILayout()
  local db,databaseFailure=self:RequireWritableDatabase();if not db then return false,databaseFailure.code end
  local preferences=db.preferences;local validSize=self:IsValidSavedWindowSize(preferences.windowWidth,preferences.windowHeight)
  preferences.windowPosition=nil;preferences.performanceWidgetPosition=nil
  if not validSize then preferences.windowWidth=nil;preferences.windowHeight=nil end
  if self.ui then
    self.ui:StopMovingOrSizing();self.ui:ClearAllPoints();self.ui:SetPoint("CENTER",UIParent,"CENTER",0,0)
    if not validSize then self.ui:SetSize(self:GetSafeDefaultWindowSize()) end
    if type(self.LayoutUI)=="function" then self:LayoutUI() end
  end
  if self.performanceWidget then self.performanceWidget:StopMovingOrSizing();self.performanceWidget:ClearAllPoints();self.performanceWidget:SetPoint("BOTTOM",UIParent,"BOTTOM",0,156) end
  return true,nil,{windowPosition="default",windowSize=validSize and "preserved" or "default",performanceWidgetPosition="default"}
end

function STBS:ResetUILayoutAndShow()
  local ok,why,data=self:ResetUILayout()
  if not ok then self:Print("LAYOUT_RESET_FAILED");return false,why end
  self:ShowGraphics();self:Print("LAYOUT_RESET_SUCCESS");return true,nil,data
end
