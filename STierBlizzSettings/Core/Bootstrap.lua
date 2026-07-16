local _, STBS = ...
function STBS:L(key) return (self.Locale[GetLocale and GetLocale() or "enUS"] or self.Locale.enUS)[key] or self.Locale.enUS[key] or key end
function STBS:Print(key) if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99STBS:|r " .. self:L(key)) end end
function STBS:SafeText(value)
  value = tostring(value or "")
  return (value:gsub("|", "||"):gsub("[%z\1-\8\11\12\14-\31\127]", ""))
end
