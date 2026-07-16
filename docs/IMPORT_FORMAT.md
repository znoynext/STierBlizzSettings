# STBS1 import format

An export is `STBS1:<eight-hex-checksum>:<hex-encoded-data>`. The decoded payload is deterministic data containing export version, profile schema, addon/client metadata, selected modules and a profile. Hex encoding is intentionally embedded rather than adding a library; it is printable and lossless on WoW Lua 5.1. Compression is a future compatibility improvement, not a requirement for correctness.

The importer accepts only the serializer's keyed-table subset: finite numbers, strings with explicit escapes, booleans, nil and keyed tables. It has byte, string, nesting and entry limits; verifies prefix, exact checksum width and schema metadata; rejects duplicate keys, malformed sections, unsafe metadata, foreign game flavor, unknown CVars and invalid values. Parsing, migration and validation fail closed if malformed data reaches an unexpected edge. It never uses `loadstring`, executes text, follows links or communicates over the network.

Import preview and application are module-selectable: Graphics only, Interface & Gameplay only, or Everything. A graphics import can honor its mode or preserve the user's current mode; inactive raid values remain stored in the profile. Hardware, sound, accessibility, Edit Mode and bindings are excluded by default.
