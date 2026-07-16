local _, STBS = ...
-- A purpose-built data-only parser. It accepts only strings, numbers, booleans, nil, and keyed tables emitted by Serializer.
function STBS:ParseSerialized(input)
  local pos, count=1,0
  local function ws() while input:sub(pos,pos):match("%s") do pos=pos+1 end end
  local function value(depth)
    if depth>STBS.MAX_IMPORT_DEPTH then return nil,"depth" end; count=count+1; if count>STBS.MAX_IMPORT_ENTRIES then return nil,"entries" end; ws(); local ch=input:sub(pos,pos)
    if ch=='"' then pos=pos+1; local out=""; while pos<=#input do local c=input:sub(pos,pos); if c=='"' then pos=pos+1; return out end; if c=='\\' then local n=input:sub(pos+1,pos+1); local map={n='\n',r='\r',t='\t',['"']='"',['\\']='\\'}; if map[n] then out=out..map[n];pos=pos+2 else local digits=input:sub(pos+1,pos+3);local byte=digits:match("^%d%d%d$") and tonumber(digits);if not byte or byte>255 then return nil,"escape" end;out=out..string.char(byte);pos=pos+4 end else if c:byte()<32 or c:byte()==127 then return nil,"string" end;out=out..c;pos=pos+1 end; if #out>STBS.MAX_STRING_BYTES then return nil,"string" end end; return nil,"string" end
    if ch=='{' then pos=pos+1;local t,seenKeys={},{};ws();while input:sub(pos,pos)~='}' do if input:sub(pos,pos)~='[' then return nil,"table" end;pos=pos+1;local k,e=value(depth+1);if e or type(k)~='string' then return nil,e or "key" end;if seenKeys[k] then return nil,"duplicate" end;seenKeys[k]=true;ws();if input:sub(pos,pos)~=']' then return nil,"table" end;pos=pos+1;ws();if input:sub(pos,pos)~='=' then return nil,"table" end;pos=pos+1;local v,ve=value(depth+1);if ve then return nil,ve end;t[k]=v;ws();if input:sub(pos,pos)==',' then pos=pos+1;ws() elseif input:sub(pos,pos)~='}' then return nil,"table" end end;pos=pos+1;return t end
    local token=input:sub(pos):match("^[%-%w%.]+");if not token then return nil,"token" end;pos=pos+#token;if token=="true" then return true elseif token=="false" then return false elseif token=="nil" then return nil elseif tonumber(token) then return tonumber(token) end;return nil,"token"
  end
  local result,err=value(0);ws();if err or pos<=#input then return nil,err or "trailing" end;return result
end
function STBS:ImportProfile(text)
  if type(text)~="string" or #text>self.MAX_IMPORT_BYTES or text:sub(1,#self.EXPORT_PREFIX)~=self.EXPORT_PREFIX then return nil,"prefix" end;local checksum,encoded=text:match("^STBS1:([0-9a-f]+):(.+)$");if not checksum or #checksum~=8 then return nil,"format" end;local raw,e=self:Base64Decode(encoded);if not raw or self:Checksum(raw)~=checksum then return nil,"integrity" end;local parsed,payload,parse=pcall(self.ParseSerialized,self,raw);if not parsed then return nil,"parse" end;if not payload or type(payload)~="table" or payload.exportVersion~=self.EXPORT_VERSION or payload.profileSchemaVersion~=self.PROFILE_SCHEMA or payload.gameFlavor~="retail" then return nil,parse or "payload" end
  if type(payload.selectedModules) ~= "table" then return nil,"modules" end
  local selected, count = {}, 0
  for key, value in pairs(payload.selectedModules) do if (key ~= "graphics" and key ~= "interfaceGameplay") or type(value) ~= "boolean" then return nil,"modules" end; if value then count=count+1 end;selected[key]=value end
  if count == 0 or selected.graphics == nil or selected.interfaceGameplay == nil then return nil,"modules" end
  payload.selectedModules = selected; local migrated,profile,why=pcall(self.MigrateProfile,self,payload.profile);if not migrated or not profile then return nil,why or "profile" end;local checked,valid,reason=pcall(self.ValidateProfile,self,profile);if not checked or not valid then return nil,reason or "profile" end;payload.profile=profile;return payload
end
