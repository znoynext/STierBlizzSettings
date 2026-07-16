# UI/UX research

Reviewed 2026-07-16. The addon keeps a custom lightweight dashboard but follows established WoW interaction conventions instead of copying another addon's visual identity.

## Sources and adopted patterns

- Blizzard Retail Settings uses native categories, localized global labels, explicit Apply semantics and controls that disable unsupported graphics choices. S-Tier uses a dedicated Settings canvas launcher, Blizzard's localized labels and the same graphics capability validators.
- [AdvancedInterfaceOptions](https://github.com/Stanzilla/AdvancedInterfaceOptions) groups settings by category, exposes search/browser-style navigation, uses inline tooltips and integrates with Blizzard options. S-Tier adopts clear category grouping and scalable scrolling, while intentionally avoiding a raw CVar browser because only curated documented settings may be applied.
- [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) demonstrates fast access through slash commands and a minimap entry point, compact option presentation and immediate feedback. S-Tier retains slash/minimap access and concise pages, but keeps every apply operation behind preview and confirmation because it changes a coordinated set of settings.

## Product-specific decisions

- First use is two steps: choose unified or split graphics, then review and confirm.
- Graphics and Interface & Gameplay are always separate scopes; the combined action creates one backup and one transaction.
- Change previews are grouped by Blizzard category and use the client's localized setting labels.
- Unsupported values are visibly skipped; failed writes trigger rollback and a separate result state.
- Profile and backup lists never cap selection to the first items; actions scroll inside a fixed-size dashboard.
- Imported names are treated as untrusted display text so WoW color/hyperlink markup cannot spoof the UI.
- Destructive profile deletion requires confirmation. Settings restore remains reversible because it creates a safety backup first.

## Intentionally not adopted

- No generic CVar editor, undocumented toggles or hidden console commands.
- No Ace3 dependency solely for configuration UI.
- No automation, alerts, combat assistance, telemetry, advertising, donations or premium UI.
- No direct Edit Mode or keybinding writes until their complete transactional behavior is validated in the live Retail client.
