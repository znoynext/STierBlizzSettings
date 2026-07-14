local _, STBS = ...
local function range(first, last) local values = {}; for i = first, last do values[tostring(i)] = true end; return values end
local function c(key, module, category, values, extra)
  local entry = {}; for k, v in pairs(extra or {}) do entry[k] = v end
  entry.key = key; entry.module = module; entry.category = category; entry.valueType = "numberString"; entry.readable = true; entry.writable = true; entry.portable = true; entry.validValues = values; entry.verifiedClientBuild = "12.0.7.68453"; return entry
end
local entries = {
  c("RAIDsettingsEnabled", "graphics", "graphics", { ["0"]=true,["1"]=true }, { valueType="booleanString", officialProfileAllowed=true }),
  c("textureFilteringMode","graphics","graphics",range(0,5),{officialProfileAllowed=true}),
  c("shadowrt","graphics","graphics",range(0,3),{officialProfileAllowed=true}),
  c("ffxAntiAliasingMode","graphics","graphics",range(0,4),{officialProfileAllowed=true,capability="aa"}),
  c("MSAAQuality","graphics","graphics",{["0"]=true},{officialProfileAllowed=true,capability="aa"}),
  c("cameraSmoothStyle", "interfaceGameplay", "camera", { ["0"]=true,["1"]=true,["2"]=true,["4"]=true }, { officialProfileAllowed=true }),
}
local function graphicPair(base, raid, values, extra)
  table.insert(entries, c(base,"graphics","graphics",values,extra)); table.insert(entries, c(raid,"graphics","raidGraphics",values,extra))
end
graphicPair("graphicsShadowQuality","raidGraphicsShadowQuality",range(0,5),{officialProfileAllowed=true})
graphicPair("graphicsLiquidDetail","raidGraphicsLiquidDetail",range(0,3),{officialProfileAllowed=true})
graphicPair("graphicsParticleDensity","raidGraphicsParticleDensity",range(0,5),{officialProfileAllowed=true,minimum=1})
graphicPair("graphicsSSAO","raidGraphicsSSAO",range(0,4),{officialProfileAllowed=true})
graphicPair("graphicsDepthEffects","raidGraphicsDepthEffects",range(0,3),{officialProfileAllowed=true})
graphicPair("graphicsComputeEffects","raidGraphicsComputeEffects",range(0,4),{officialProfileAllowed=true})
graphicPair("graphicsOutlineMode","raidGraphicsOutlineMode",range(0,2),{officialProfileAllowed=true,minimum=1})
graphicPair("graphicsTextureResolution","raidGraphicsTextureResolution",range(0,2),{officialProfileAllowed=true})
graphicPair("graphicsSpellDensity","raidGraphicsSpellDensity",range(0,2),{officialProfileAllowed=true,feature="spellDensity"})
graphicPair("graphicsProjectedTextures","raidGraphicsProjectedTextures",range(0,1),{officialProfileAllowed=true,minimum=1})
graphicPair("graphicsViewDistance","raidGraphicsViewDistance",range(0,10),{officialProfileAllowed=true})
graphicPair("graphicsEnvironmentDetail","raidGraphicsEnvironmentDetail",range(0,10),{officialProfileAllowed=true})
graphicPair("graphicsGroundClutter","raidGraphicsGroundClutter",range(0,10),{officialProfileAllowed=true})
STBS.Registry = entries
STBS.RegistryByKey = {}; for _, setting in ipairs(STBS.Registry) do STBS.RegistryByKey[setting.key] = setting end
function STBS:GetRegistry(module) local out = {}; for _, s in ipairs(self.Registry) do if not module or s.module == module then table.insert(out,s) end end return out end
