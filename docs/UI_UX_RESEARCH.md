# UI/UX research

Reviewed 2026-07-16. The addon keeps a custom lightweight dashboard but follows established WoW interaction conventions instead of copying another addon's visual identity.

## Sources and adopted patterns

- Blizzard Retail Settings uses native categories, localized global labels, explicit Apply semantics and controls that disable unsupported graphics choices. S-Tier uses a dedicated Settings canvas launcher, Blizzard's localized labels and the same graphics capability validators.
- [AdvancedInterfaceOptions](https://github.com/Stanzilla/AdvancedInterfaceOptions) groups settings by category, exposes search/browser-style navigation, uses inline tooltips and integrates with Blizzard options. S-Tier adopts clear category grouping and scalable scrolling, while intentionally avoiding a raw CVar browser because only curated documented settings may be applied.
- [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) demonstrates fast access through slash commands and a minimap entry point, compact option presentation and immediate feedback. S-Tier retains slash/minimap access and concise pages, but keeps every apply operation behind preview and confirmation because it changes a coordinated set of settings.
- [EnhanceQoL](https://github.com/R41z0r/EnhanceQoL) uses a large title/body hierarchy, generous card spacing, concise dashboard copy and clearly separated status tiles. S-Tier adopts those information-hierarchy principles without copying its navigation art, layout code or visual identity.

## Product-specific decisions

- First use is three explicit decisions: choose unified or split graphics, review a short outcome summary, then confirm in a native popup.
- The dashboard has three top-level destinations: Graphics, Profiles and About. The removed Home screen duplicated the graphics workflow; backups and profiles share one history screen while remaining distinct data types.
- Change previews report counts and user-visible outcomes instead of listing every CVar.
- Unsupported values are visibly skipped; failed writes trigger rollback and a separate result state.
- Profile and backup lists never cap selection to the first items; actions scroll inside a fixed-size dashboard. Both kinds support explicit deletion confirmation.
- Imported names are treated as untrusted display text so WoW color/hyperlink markup cannot spoof the UI.
- A visible Undo action restores the latest graphics backup. Settings restore remains reversible because it creates a safety backup first.
- The FPS card shows the current value live in a large font and keeps the last before/after average as a smaller local estimate.
- Every user action produces an in-window success, warning or error state. Choosing a mode explicitly says that nothing has been applied yet; apply, reload, save, backup, restore, delete, rename and export have distinct completion copy.
- The About page explains evidence, scope, backup/undo behavior, preserved hardware controls and the limits of the FPS claim.
- Motion is limited to a short window fade and button hover feedback so the UI feels responsive without distracting from the decision flow.
- Visual styling stays inside Blizzard's native vocabulary: `UIPanelButtonTemplate`, `GameFontNormalHuge2`, other game font objects, rock/dialog backgrounds, tooltip borders, gold headings and the standard minimap tracking border. Custom art is limited to the addon emblem and a framed real in-game screenshot.

## Intentionally not adopted

- No generic CVar editor, undocumented toggles or hidden console commands.
- No Ace3 dependency solely for configuration UI.
- No automation, alerts, combat assistance, telemetry, advertising, donations or premium UI.
- No direct Edit Mode or keybinding writes until their complete transactional behavior is validated in the live Retail client.
