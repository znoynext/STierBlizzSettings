# S-Tier Blizz Settings rules

- Read `docs/PROJECT_STATE.md` before changing behavior or UI. Update it whenever shipped functionality, UX decisions, safety boundaries, limitations or the local continuation workflow materially changes.
- Target current WoW Retail APIs only; verify every API and CVar in Blizzard source before use.
- Do not invent APIs or undocumented CVars. Fail closed for unavailable settings.
- No combat/gameplay automation, ads, premium gating, donation prompts, telemetry or obfuscation.
- Localize all user-visible text. Treat imports as untrusted data and never execute them.
- Every apply operation must be transactional and back up affected values first.
- Keep Graphics and Interface & Gameplay separate; both graphics modes are mandatory.
- Official graphics profiles must preserve projected textures, particles and outlines; preserve hardware-dependent settings.
- Update tests and documentation for registry, imports, serialization, migration, transactions and mode logic.
