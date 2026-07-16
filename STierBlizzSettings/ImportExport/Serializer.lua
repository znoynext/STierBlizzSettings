local _, STBS = ...
local function esc(s)
  return '"'..s:gsub("[\\\"%z\1-\31\127]", function(byte)
    if byte == "\\" then return "\\\\" elseif byte == '"' then return '\\"' elseif byte == "\n" then return "\\n" elseif byte == "\r" then return "\\r" elseif byte == "\t" then return "\\t" end
    return string.format("\\%03d", byte:byte())
  end)..'"'
end
local function serialize(v, seen, depth)
  depth=depth or 0; if depth>STBS.MAX_IMPORT_DEPTH then error("depth") end
  if type(v)=="string" then return esc(v) elseif type(v)=="number" then if v~=v or v==math.huge or v==-math.huge then error("number") end;return tostring(v) elseif type(v)=="boolean" then return v and "true" or "false" elseif type(v)~="table" then return "nil" end
  if seen[v] then error("cycle") end; seen[v]=true; local keys={}; for k in pairs(v) do table.insert(keys,k) end; table.sort(keys,function(a,b)return tostring(a)<tostring(b) end); local parts={"{"}; for _,k in ipairs(keys) do if type(k)~="string" then error("key") end; table.insert(parts,"["..esc(k).."]="..serialize(v[k],seen,depth+1)..",") end; table.insert(parts,"}"); seen[v]=nil; return table.concat(parts)
end
function STBS:Serialize(value) return serialize(value,{}) end
