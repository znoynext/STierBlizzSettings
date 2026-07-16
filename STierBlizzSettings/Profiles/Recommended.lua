local _, STBS = ...
local presets={
  pro={name="S-Tier PRO",base={graphicsShadowQuality="1",graphicsLiquidDetail="1",graphicsParticleDensity="3",graphicsSSAO="0",graphicsDepthEffects="0",graphicsComputeEffects="0",graphicsOutlineMode="2",graphicsTextureResolution="2",graphicsSpellDensity="1",graphicsProjectedTextures="1",graphicsViewDistance="4",graphicsEnvironmentDetail="3",graphicsGroundClutter="2",textureFilteringMode="5",shadowrt="0",msaaAlphaTest="0"},raid={raidGraphicsShadowQuality="0",raidGraphicsLiquidDetail="1",raidGraphicsParticleDensity="3",raidGraphicsSSAO="0",raidGraphicsDepthEffects="0",raidGraphicsComputeEffects="0",raidGraphicsOutlineMode="2",raidGraphicsTextureResolution="2",raidGraphicsSpellDensity="1",raidGraphicsProjectedTextures="1",raidGraphicsViewDistance="3",raidGraphicsEnvironmentDetail="2",raidGraphicsGroundClutter="1"}},
  optimized={name="S-Tier Optimized",base={graphicsShadowQuality="2",graphicsLiquidDetail="2",graphicsParticleDensity="4",graphicsSSAO="1",graphicsDepthEffects="1",graphicsComputeEffects="1",graphicsOutlineMode="2",graphicsTextureResolution="2",graphicsSpellDensity="2",graphicsProjectedTextures="1",graphicsViewDistance="6",graphicsEnvironmentDetail="4",graphicsGroundClutter="3",textureFilteringMode="5",shadowrt="0",msaaAlphaTest="0"},raid={raidGraphicsShadowQuality="0",raidGraphicsLiquidDetail="1",raidGraphicsParticleDensity="4",raidGraphicsSSAO="0",raidGraphicsDepthEffects="0",raidGraphicsComputeEffects="0",raidGraphicsOutlineMode="2",raidGraphicsTextureResolution="2",raidGraphicsSpellDensity="1",raidGraphicsProjectedTextures="1",raidGraphicsViewDistance="4",raidGraphicsEnvironmentDetail="3",raidGraphicsGroundClutter="2"}},
  quality={name="S-Tier Quality",base={graphicsShadowQuality="3",graphicsLiquidDetail="3",graphicsParticleDensity="5",graphicsSSAO="2",graphicsDepthEffects="2",graphicsComputeEffects="2",graphicsOutlineMode="2",graphicsTextureResolution="2",graphicsSpellDensity="2",graphicsProjectedTextures="1",graphicsViewDistance="8",graphicsEnvironmentDetail="7",graphicsGroundClutter="6",textureFilteringMode="5",shadowrt="0",msaaAlphaTest="0"},raid={raidGraphicsShadowQuality="2",raidGraphicsLiquidDetail="2",raidGraphicsParticleDensity="4",raidGraphicsSSAO="1",raidGraphicsDepthEffects="1",raidGraphicsComputeEffects="1",raidGraphicsOutlineMode="2",raidGraphicsTextureResolution="2",raidGraphicsSpellDensity="2",raidGraphicsProjectedTextures="1",raidGraphicsViewDistance="6",raidGraphicsEnvironmentDetail="4",raidGraphicsGroundClutter="3"}},
}
function STBS:IsGraphicsPreset(preset) return presets[preset]~=nil end
function STBS:GetSelectedPreset() return self:InitializeDatabase().preferences.graphicsPreset end
function STBS:SetSelectedPreset(preset) if not self:IsGraphicsPreset(preset) then return false end;self:InitializeDatabase().preferences.graphicsPreset=preset;return true end
function STBS:GetOfficialGraphics(mode,preset)
  preset=self:IsGraphicsPreset(preset) and preset or self:GetSelectedPreset();if not self:IsGraphicsPreset(preset) then preset=self.GRAPHICS_PRESET_OPTIMIZED end;local source=presets[preset]
  local p=self:NewProfile("official_"..preset,"recommended",source.name);p.description="A verified built-in WoW graphics baseline that preserves combat readability and hardware-dependent settings.";p.research={status="expert_baseline_unbenchmarked",lastReviewedAt=0,benchmarkRevision=2};local b=self:Copy(source.base);local aa=self:GetPreferredAntiAliasing();if aa then for k,v in pairs(aa) do b[k]=v end end;p.sections.graphics={mode=mode,base=b,raid=mode==self.GRAPHICS_MODE_SPLIT and self:Copy(source.raid) or nil};return p
end
function STBS:GetOfficialInterface()
  local p=self:NewProfile("official_interface_gameplay","recommended","S-Tier Interface & Gameplay")
  p.description="Recommended built-in Blizzard settings for combat readability without replacing the default interface."
  p.sections.camera={cameraSmoothStyle="0"}
  p.sections.interface={countdownForCooldowns="1"}
  p.sections.combat={showTargetOfTarget="1",occludedSilhouettePlayer="1"}
  p.sections.nameplates={nameplateShowEnemies="1",nameplateShowAll="1",nameplateShowOffscreen="1"}
  return p
end
function STBS:GetDemoProfessional() local p=self:NewProfile("example_competitive_tank","professionalPlayer","Example Competitive Tank"); p.description="Demonstration profile — not affiliated with a real player."; p.authorName="S-Tier Demonstration"; p.role="Tank"; p.contentType="Raid"; p.verification={status="unverified",permissionConfirmed=false}; return p end
