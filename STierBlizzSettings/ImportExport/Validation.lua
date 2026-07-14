local _, STBS = ...
-- A purpose-built data-only parser. It accepts only strings, numbers, booleans, nil, and keyed tables emitted by Serializer.
function STBS:ParseSerialized(input)
  local pos, count=1,0
  local function ws() while input:sub(pos,pos):match("%s") do pos=pos+1 end end
  local function value(depth)
    if depth>STBS.MAX_IMPORT_DEPTH then return nil,"depth" end; count=count+1; if count>STBS.MAX_IMPORT_ENTRIES then return nil,"entries" end; ws(); local ch=input:sub(pos,pos)
    if ch=='"' then local start=pos; pos=pos+1; local out=""; while pos<=#input do local c=input:sub(pos,pos); if c=='"' then pos=pos+1; return out end; if c=='\\' then local n=input:sub(pos+1,pos+1); local map={n='\n',r='\r',t='\t',['"']='"',['\\']='\\'}; if not map[n] then return nil,"escape" end; out=out..map[n];pos=pos+2 else out=out..c;pos=pos+1 end; if #out>STBS.MAX_STRING_BYTES then return nil,"string" end end; return nil,"string" end
    if ch=='{' then pos=pos+1;local t={};ws();while input:sub(pos,pos)~='}' do if input:sub(pos,pos)~='[' then return nil,"table" end;pos=pos+1;local k,e=value(depth+1);if e or type(k)~='string' then return nil,e or "key" end;ws();if input:sub(pos,pos)~=']' then return nil,"table" end;pos=pos+1;ws();if input:sub(pos,pos)~='=' then return nil,"table" end;pos=pos+1;local v,ve=value(depth+1);if ve then return nil,ve end;t[k]=v;ws();if input:sub(pos,pos)==',' then pos=pos+1;ws() elseif input:sub(pos,pos)~='}' then return nil,"table" end end;pos=pos+1;return t end
    local token=input:sub(pos):match("^[%-%w%.]+");if not token then return nil,"token" end;pos=pos+#token;if token=="true" then return true elseif token=="false" then return false elseif token=="nil" then return nil elseif tonumber(token) then return tonumber(token) end;return nil,"token"
  end
  local result,err=value(0);ws();if err or pos<=#input then return nil,err or "trailing" end;return result
end
function STBS:ImportProfile(text)
  if type(text)~="string" or #text>self.MAX_IMPORT_BYTES or text:sub(1,#self.EXPORT_PREFIX)~=self.EXPORT_PREFIX then return nil,"prefix" end;local checksum,encoded=text:match("^STBS1:([0-9a-f]+):(.+)$");if not checksum then return nil,"format" end;local raw,e=self:Base64Decode(encoded);if not raw or self:Checksum(raw)~=checksum then return nil,"integrity" end;local payload,parse=self:ParseSerialized(raw);if not payload or type(payload)~="table" or payload.exportVersion~=self.EXPORT_VERSION or payload.gameFlavor~="retail" then return nil,parse or "payload" end;local profile,why=self:MigrateProfile(payload.profile);if not profile then return nil,why end;local valid,reason=self:ValidateProfile(profile);if not valid then return nil,reason end;return payload
end
