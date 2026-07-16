local _, STBS = ...
local base={ graphicsShadowQuality="2",graphicsLiquidDetail="2",graphicsParticleDensity="4",graphicsSSAO="1",graphicsDepthEffects="1",graphicsComputeEffects="1",graphicsOutlineMode="2",graphicsTextureResolution="2",graphicsSpellDensity="2",graphicsProjectedTextures="1",graphicsViewDistance="6",graphicsEnvironmentDetail="4",graphicsGroundClutter="3",textureFilteringMode="5",shadowrt="0",msaaAlphaTest="0" }
local raid={ raidGraphicsShadowQuality="0",raidGraphicsLiquidDetail="1",raidGraphicsParticleDensity="4",raidGraphicsSSAO="0",raidGraphicsDepthEffects="0",raidGraphicsComputeEffects="0",raidGraphicsOutlineMode="2",raidGraphicsTextureResolution="2",raidGraphicsSpellDensity="1",raidGraphicsProjectedTextures="1",raidGraphicsViewDistance="4",raidGraphicsEnvironmentDetail="3",raidGraphicsGroundClutter="2" }
function STBS:GetOfficialGraphics(mode)
  local p=self:NewProfile("official_balanced_midrange","recommended","S-Tier Balanced"); p.description="Recommended balance of performance, image quality, and combat visibility for mainstream 1080p and 1440p gaming PCs."; p.research={status="expert_baseline_unbenchmarked",lastReviewedAt=0,benchmarkRevision=1}; local b=self:Copy(base); local aa=self:GetPreferredAntiAliasing();if aa then for k,v in pairs(aa) do b[k]=v end end;p.sections.graphics={mode=mode,base=b,raid=mode==self.GRAPHICS_MODE_SPLIT and self:Copy(raid) or nil}; return p
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
