# STBS1 import format

An export is `STBS1:<eight-hex-checksum>:<hex-encoded-data>`. The decoded payload is deterministic data containing export version, profile schema, addon/client metadata, selected modules and a profile. Hex encoding is intentionally embedded rather than adding a library; it is printable and lossless on WoW Lua 5.1. Compression is a future compatibility improvement, not a requirement for correctness.

The importer accepts only the serializer's keyed-table subset: strings, numbers, booleans, nil and keyed tables. It has byte, string, nesting and entry limits; verifies prefix and checksum; rejects future schemas, foreign game flavor, unknown CVars and invalid values. It never uses `loadstring`, executes text, follows links or communicates over the network. Unknown fields in a setting section cause rejection; non-setting profile metadata is not executed.

Import preview and application are module-selectable: Graphics only, Interface & Gameplay only, or Everything. A graphics import can honor its mode or preserve the user's current mode; inactive raid values remain stored in the profile. Hardware, sound, accessibility, Edit Mode and bindings are excluded by default.
