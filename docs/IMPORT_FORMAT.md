# STBS1 import format

An export is `STBS1:<eight-hex-checksum>:<hex-encoded-data>`. The decoded payload is deterministic data containing export version, profile schema, addon/client metadata, selected modules and a profile. Hex encoding is intentionally embedded rather than adding a library; it is printable and lossless on WoW Lua 5.1. Compression is a future compatibility improvement, not a requirement for correctness.

The importer accepts only the serializer's keyed-table subset: finite numbers, strings with explicit escapes, booleans, nil and keyed tables. It has byte, string, nesting and entry limits; verifies prefix, exact checksum width and schema metadata; rejects duplicate keys, malformed sections, unsafe metadata, foreign game flavor, unknown CVars and invalid values. Parsing, migration and validation fail closed if malformed data reaches an unexpected edge. It never uses `loadstring`, executes text, follows links or communicates over the network.

The 0.3 user interface previews and applies Graphics imports only. A graphics import can honor its mode or preserve the user's current mode; inactive raid values remain stored in the profile. The schema still validates legacy Interface & Gameplay payloads for backward compatibility, but interface-only imports are not exposed while that section is being redesigned. Hardware, sound, accessibility, Edit Mode and bindings are excluded by default.

## Full addon bundle (`STBSA1`)

The Profiles → Import / Export view can transfer the current built-in WoW graphics values, available UI Tweaks values, selected S-Tier preset/mode, benchmark choice, FPS/ping visibility, Zone Graphics mappings and validated personal profiles in one string. It intentionally excludes backup history, logs, transactions, window size and screen positions.

`STBSA1` uses the same deterministic serializer, checksum and data-only parser as profile exchange. Unknown keys, invalid presets or zone categories, settings outside the graphics/UI Tweaks allowlist, malformed profiles, excessive depth/entry counts, bad checksums and future versions are rejected. Import is blocked in combat and applies shared CVars through one normal transaction before stored preferences or profiles are replaced; a real CVar diff is backed up first, while an already-matching diff creates no redundant history. Older valid bundles without `uiTweaksSettings` remain accepted.
