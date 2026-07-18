# UI/UX research

Reviewed 2026-07-16. The addon keeps a custom lightweight dashboard but follows established WoW interaction conventions instead of copying another addon's visual identity.

The external findings below remain useful design evidence. Statements under Product-specific decisions and Texture and control audit describe the current product; older release behavior belongs in `CHANGELOG.md` and does not override `PROJECT_STATE.md` or production code.

## Sources and adopted patterns

- Blizzard Retail Settings uses native categories, localized global labels, explicit Apply semantics and controls that disable unsupported graphics choices. S-Tier uses a dedicated Settings canvas launcher, Blizzard's localized labels and the same graphics capability validators.
- [AdvancedInterfaceOptions](https://github.com/Stanzilla/AdvancedInterfaceOptions) groups settings by category, exposes search/browser-style navigation, uses inline tooltips and integrates with Blizzard options. S-Tier adopts clear category grouping and scalable scrolling, while intentionally avoiding a raw CVar browser because only curated documented settings may be applied.
- [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) demonstrates fast access through slash commands and a minimap entry point, compact option presentation and immediate feedback. S-Tier retains slash/minimap access and concise pages, but keeps every apply operation behind preview and confirmation because it changes a coordinated set of settings.
- [EnhanceQoL](https://github.com/R41z0r/EnhanceQoL) uses a large title/body hierarchy, generous card spacing, concise dashboard copy and clearly separated status tiles. S-Tier adopts those information-hierarchy principles without copying its navigation art, layout code or visual identity.
- [Hyperframe](https://www.curseforge.com/wow/addons/hyperframe), Graphics Presets: Smart Switching and DynamicGraphicsSettings demonstrate demand for content-aware profiles. S-Tier adopts explicit content mappings, but keeps them opt-in, transaction-backed and limited to actual zone transitions so the picture does not pump continuously.
- [TroyMetrics Benchmark Overlays](https://github.com/TroyMetrics/Benchmark-Overlays) presents current, average and 1% Low together, makes frame-time spikes visible and keeps benchmark overlays responsive. S-Tier adopts the compact metric hierarchy and measured spike reporting, but keeps its result inside a native WoW dashboard rather than adding a permanent benchmark HUD.
- A public [Hekili benchmark investigation](https://github.com/Hekili/hekili/issues/2624) uses repeated side-by-side runs and surfaces 1% Low because averages alone hide stutter. S-Tier therefore labels current and candidate phases explicitly and refuses to predict a preset gain without measuring both in the player's actual scene.
- [FPS & Latency Meter](https://github.com/nailuj1992/FpsLatencyMeter) confirms the maintained Retail pattern of `GetFramerate()` plus Home/World values from `GetNetStats()`. S-Tier uses one compact optional indicator, throttles it to twice per second and colors FPS and ping independently.
- WoW performance benchmark guidance and frame-time methodology informed the accurate 1% Low calculation: the slowest frame times are averaged before conversion back to FPS, instead of treating one sampled minimum as 1% Low.

## Product-specific decisions

- First use is two explicit decisions: choose one of three presets, then review and confirm in the reusable addon-owned dialog. Built-in preset application is unified and has no unified/split or lighter-raid toggle. Split mode remains only for clearly labelled legacy personal/imported profile compatibility: the primary action creates a non-destructive unified copy, while exact split apply is secondary and explicitly advanced. FPS diagnostics live on their own page and expose post-apply, standalone, and preset-comparison workflows rather than a quick/accurate mode selector.
- The dashboard has five top-level destinations: Graphics, UI Tweaks, Test FPS, Profiles and About. Graphics keeps its dedicated flat Retail sub-tab bar for Graphics Settings and the complete Zone Graphics Switcher.
- Change previews report counts and user-visible outcomes instead of listing every CVar.
- Unsupported values are visibly skipped; failed writes trigger rollback and a separate result state.
- Profile and backup lists never cap selection to the first items; actions scroll inside a fixed-size dashboard. Both kinds support explicit deletion confirmation.
- Imported names are treated as untrusted display text so WoW color/hyperlink markup cannot spoof the UI.
- A visible Undo action restores the latest graphics backup. Settings restore remains reversible because every real restore creates a safety backup first; an already-matching target creates no redundant record.
- The FPS card shows the current value live in a large font and keeps the last before/after average as a smaller local estimate. The dedicated Test FPS page reports average, frame-time-based 1% Low, their stability ratio, adaptive spikes and worst-frame time. A centered modal blocks accidental mouse camera movement, shows progress and always offers Cancel. Preset comparisons use two real 20-second runs, restore the player's graphics and describe likely causes as suggestions rather than claiming access to CPU/GPU telemetry. A separate bottom-screen FPS/ping indicator is optional.
- Every user action produces an in-window success, warning or error state. Choosing a preset explicitly says that nothing has been applied yet; apply, reload, save, backup, restore, delete, rename and export have distinct completion copy.
- The About page explains evidence, scope, backup/undo behavior, preserved hardware controls and the limits of the FPS claim.
- Motion is limited to short window/page fades, status feedback and button hover feedback so the UI feels responsive without distracting from the decision flow.
- Visual styling stays inside Blizzard's native vocabulary: the current shared buttons and checkboxes use `BackdropTemplate` with scalable `WHITE8X8` surfaces, while text, rock/dialog backgrounds, tooltip borders, resize/minimap textures and checkbox marks remain Blizzard-owned. `UIPanelButtonTemplate` is not part of the current shared Style implementation. Custom art is limited to the addon emblem.

## Graphics preview decision

- Hyperframe publishes separate benchmark screenshots in its CurseForge gallery; they are documentation artifacts, not a second live world rendered inside its settings frame.
- Screenshoter temporarily changes real graphics for a capture and then restores them. ScreenPlus likewise enters a camera mode, hides UI, takes the real screenshot and restores state.
- The reviewed Retail API exposes `Screenshot()` as an action but no addon-readable framebuffer or render-to-texture API for the current world, and there is no supported way to render the world twice with different unapplied CVars. A static texture labelled as a live preset preview would therefore be misleading.

S-Tier now uses the same honest product principle: show concise setting outcomes before confirmation, back up and apply real changes transactionally, and report an already-active selection without creating redundant history. The player can then close the addon normally and inspect the actual game scene. A dedicated action that only duplicated the close button was intentionally removed; Undo remains one click away.

## Texture and control audit

The only custom bitmap is the 128×128 gold S emblem, rendered at 48 px in the header and 36 px on the minimap, so it is already sampled down rather than stretched up. The former 640×360 preview texture was removed from the addon. Window rock, dialog borders, resize handle, checkbox marks, highlights and minimap border use Blizzard-owned textures/templates; buttons and checkbox surfaces use the client's scalable white texture with addon colors. Responsive control widths are rounded to whole UI pixels to avoid soft edges after resizing.

Boolean states use a fixed 24x24 custom `CheckButton` inside a full-width clickable row. Its scalable dark fill, bronze border, gold checked state and 0.12-second hover feedback now match the shared button system without stretching bitmap artwork; the mark remains Blizzard-owned. UI Tweaks uses the current `MinimalSliderWithSteppersTemplate` for resample sharpness and concise native tooltips on every CVar control. Mutually exclusive presets and zone mappings remain buttons because a checkbox would communicate the wrong interaction. All visible labels use the native `GameFontNormalLarge` / `GameFontHighlightLarge` family, preserving the selected WoW typeface and existing colors.

Addon confirmations no longer inherit the small generic `StaticPopup` layout. One reusable S-Tier modal owns the dark native surface, thin gold frame, addon icon, readable standard fonts, styled text input, consistent primary/cancel buttons and red destructive state. New confirmation and short-entry flows must reuse this component so they cannot drift visually. The current preset is promoted to a right-shifted `GameFontNormalLarge` header label because it is persistent decision-critical state.

## Intentionally not adopted

- No generic CVar editor or copied lists of speculative console tweaks; only the explicit runtime-verified allowlist is exposed.
- No Ace3 dependency solely for configuration UI.
- No automation, alerts, combat assistance, telemetry, advertising, donations or premium UI.
- No direct Edit Mode or keybinding writes until their complete transactional behavior is validated in the live Retail client.
