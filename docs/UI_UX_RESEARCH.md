# UI/UX research

Reviewed 2026-07-16. The addon keeps a custom lightweight dashboard but follows established WoW interaction conventions instead of copying another addon's visual identity.

## Sources and adopted patterns

- Blizzard Retail Settings uses native categories, localized global labels, explicit Apply semantics and controls that disable unsupported graphics choices. S-Tier uses a dedicated Settings canvas launcher, Blizzard's localized labels and the same graphics capability validators.
- [AdvancedInterfaceOptions](https://github.com/Stanzilla/AdvancedInterfaceOptions) groups settings by category, exposes search/browser-style navigation, uses inline tooltips and integrates with Blizzard options. S-Tier adopts clear category grouping and scalable scrolling, while intentionally avoiding a raw CVar browser because only curated documented settings may be applied.
- [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) demonstrates fast access through slash commands and a minimap entry point, compact option presentation and immediate feedback. S-Tier retains slash/minimap access and concise pages, but keeps every apply operation behind preview and confirmation because it changes a coordinated set of settings.
- [EnhanceQoL](https://github.com/R41z0r/EnhanceQoL) uses a large title/body hierarchy, generous card spacing, concise dashboard copy and clearly separated status tiles. S-Tier adopts those information-hierarchy principles without copying its navigation art, layout code or visual identity.
- [Hyperframe](https://www.curseforge.com/wow/addons/hyperframe), Graphics Presets: Smart Switching and DynamicGraphicsSettings demonstrate demand for content-aware profiles. S-Tier adopts explicit content mappings, but keeps them opt-in, transaction-backed and limited to actual zone transitions so the picture does not pump continuously.
- [FPS & Latency Meter](https://github.com/nailuj1992/FpsLatencyMeter) confirms the maintained Retail pattern of `GetFramerate()` plus Home/World values from `GetNetStats()`. S-Tier uses one compact optional indicator, throttles it to twice per second and colors FPS and ping independently.
- WoW performance benchmark guidance and frame-time methodology informed the accurate 1% Low calculation: the slowest frame times are averaged before conversion back to FPS, instead of treating one sampled minimum as 1% Low.

## Product-specific decisions

- First use is two explicit decisions: choose one of three presets, then review and confirm in a native popup. Unified/split mode is a compact secondary toggle; FPS diagnostics live on their own page.
- The dashboard has four top-level destinations: Graphics, Test FPS, Profiles and About. Graphics uses Blizzard `PanelTabButtonTemplate` sub-tabs for Graphics Settings and the complete Zone Graphics Switcher, avoiding a duplicate top-level destination.
- Change previews report counts and user-visible outcomes instead of listing every CVar.
- Unsupported values are visibly skipped; failed writes trigger rollback and a separate result state.
- Profile and backup lists never cap selection to the first items; actions scroll inside a fixed-size dashboard. Both kinds support explicit deletion confirmation.
- Imported names are treated as untrusted display text so WoW color/hyperlink markup cannot spoof the UI.
- A visible Undo action restores the latest graphics backup. Settings restore remains reversible because it creates a safety backup first.
- The FPS card shows the current value live in a large font and keeps the last before/after average as a smaller local estimate. The dedicated 20-second Test FPS page reports average, frame-time-based 1% Low, their stability ratio, adaptive spikes and worst-frame time. A separate bottom-screen FPS/ping indicator is optional.
- Every user action produces an in-window success, warning or error state. Choosing a mode explicitly says that nothing has been applied yet; apply, reload, save, backup, restore, delete, rename and export have distinct completion copy.
- The About page explains evidence, scope, backup/undo behavior, preserved hardware controls and the limits of the FPS claim.
- Motion is limited to short window/page fades, status feedback and button hover feedback so the UI feels responsive without distracting from the decision flow.
- Visual styling stays inside Blizzard's native vocabulary: `UIPanelButtonTemplate`, `GameFontNormalHuge2`, other game font objects, rock/dialog backgrounds, tooltip borders, gold headings and the standard minimap tracking border. Custom art is limited to the addon emblem.

## Graphics preview decision

- Hyperframe publishes separate benchmark screenshots in its CurseForge gallery; they are documentation artifacts, not a second live world rendered inside its settings frame.
- Screenshoter temporarily changes real graphics for a capture and then restores them. ScreenPlus likewise enters a camera mode, hides UI, takes the real screenshot and restores state.
- The reviewed Retail API exposes `Screenshot()` as an action but no addon-readable framebuffer or render-to-texture API for the current world, and there is no supported way to render the world twice with different unapplied CVars. A static texture labelled as a live preset preview would therefore be misleading.

S-Tier now uses the same honest product principle: show concise setting outcomes before confirmation, apply through a backup-first transaction, then let the player hide the window and inspect the actual game scene. Undo remains one click away.

## Texture and control audit

The only custom bitmap is the 128×128 gold S emblem, rendered at 48 px in the header and 36 px on the minimap, so it is already sampled down rather than stretched up. The former 640×360 preview texture was removed from the addon. Window rock, dialog borders, buttons, resize handle, checkbox marks, highlights and minimap border all use Blizzard-owned textures/templates. Responsive button widths are rounded to whole UI pixels to avoid soft edges after resizing.

Boolean states use a fixed 24x24 `UICheckButtonTemplate` inside a full-width clickable row, matching Blizzard's square control without stretching its artwork. Mutually exclusive presets and zone mappings remain buttons because a checkbox would communicate the wrong interaction. All visible labels use the native `GameFontNormalLarge` / `GameFontHighlightLarge` family, preserving the selected WoW typeface and existing colors.

## Intentionally not adopted

- No generic CVar editor, undocumented toggles or hidden console commands.
- No Ace3 dependency solely for configuration UI.
- No automation, alerts, combat assistance, telemetry, advertising, donations or premium UI.
- No direct Edit Mode or keybinding writes until their complete transactional behavior is validated in the live Retail client.
