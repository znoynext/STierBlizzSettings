# S-Tier Blizz Settings agent rules

## Source of truth

Before changing behavior, read the current task, inspect the affected production code and regression tests, read `docs/PROJECT_STATE.md`, and consult the relevant architecture or research documents. Use this priority when sources disagree:

1. The user's explicit current task.
2. Current production code and tests.
3. `docs/PROJECT_STATE.md`.
4. `docs/ARCHITECTURE.md`.
5. Specialist, research, and historical documentation.

Do not restore removed behavior merely because an older document still describes it. Report contradictions between documentation and the current code or project state, and update the affected documentation when that is within the task scope.

## Project and WoW safety

- Target current WoW Retail only.
- Never invent APIs, CVars, capabilities, or writable behavior. Verify every newly used API and CVar against a current authoritative Blizzard source, and add runtime availability checks.
- Fail closed when a setting is unavailable, protected, read-only, invalid, or cannot be verified.
- Do not change hardware-, display-, or device-dependent settings unless the current task explicitly requires it and the behavior has been verified.
- Preserve the project's trust boundaries: no combat or gameplay automation, telemetry, networking, ads, premium gating, donation prompts, obfuscation, or execution of untrusted data.
- Keep version-specific API, CVar, preset, and product decisions in current code and project documentation rather than treating them as permanent rules here.

## Settings transaction invariants

All settings mutations must follow this workflow:

`Validate -> Diff -> Snapshot -> Apply -> Verify -> Commit State`

- Validate the complete operation before queuing or writing it.
- Know and snapshot the previous value of every setting that may be changed before the first write.
- Apply only the validated diff and perform read-back verification.
- On any write or verification failure, roll back safely and report rollback failures explicitly.
- Do not record persistent state as applied until the whole transaction completes successfully.
- Failed, cancelled, or rolled-back operations must not leave SavedVariables claiming that requested settings were applied.
- Avoid writes and user backups for no-op operations when the current architecture can determine that no values will change.

## Delayed operations and automation

- Represent delayed work with explicit state and a controlled lifecycle.
- An automatic operation must not silently discard or overwrite an explicit user operation.
- Recovery work must not be lost or replaced by automation.
- Revalidate contextual data before delayed execution; do not treat stale zone, combat, profile, benchmark, or UI context as current.
- After completion, cancellation, or failure, clear temporary state and deliver the final result to the UI.
- Preserve these invariants without freezing the current pending-operation enums or state-machine implementation.

## Backups and Undo

- Give a backup stable identity whenever UI or delayed work refers to it; do not rely on a mutable list position as identity across intervening mutations.
- Treat user-facing Undo and Backup History as distinct concepts.
- Internal or temporary recovery backups must not unexpectedly become the ordinary user-facing Undo target.
- Do not delete recovery information until restoration has completed and read-back verification has succeeded.
- Keep Undo semantics predictable and visible to the user.
- Preserve these invariants without freezing the current backup source enums or storage layout.

## FPS and measurement integrity

- Treat FPS results as local measurements of a specific client, scene, and time, not as universal guarantees.
- Do not claim a universal FPS gain without appropriate benchmark evidence.
- Do not compare stale measurements as though they came from the same scene and conditions.
- Keep raw precision for calculations and decisions; round only for display.
- Restore temporary benchmark settings through the safe transaction workflow, including cancellation and failure paths.
- Keep measurement durations and benchmark implementation details in current code and project documentation, not in this file.

## SavedVariables and migrations

- Every schema change requires an explicit migration or backward-compatible normalization.
- Preserve valid user data, and make migrations idempotent.
- Fail closed on a future unsupported schema; never silently rewrite it as the current schema.
- Keep device-local preferences out of shared imports unless the current task explicitly defines safe import semantics for them.
- Add or update regression coverage for schema, normalization, migration, serialization, and compatibility changes.

## Import security

- Treat all imported text and display strings as untrusted data.
- Never execute imported content or parse it with `load`, `loadstring`, or an equivalent code-evaluation path.
- Enforce size, depth, entry-count, type, schema, integrity, and value limits before mutation.
- Require imported settings to pass the current registry allowlist and normal validation; unknown settings must fail closed.
- Escape or sanitize imported display strings so they cannot spoof WoW UI markup.
- Imports that mutate settings must use the normal transaction workflow and must not accidentally overwrite device-local preferences.

## UI, UX, lifecycle, and localization

- Clearly distinguish selected or drafted state from the state actually applied in the client.
- Before confirmation, show what will change; after execution, show the final success, pending, failure, cancellation, or rollback result.
- Do not present the number of inspected settings as the number that will actually change.
- Use localized user-facing descriptions rather than raw CVar names as the primary normal-user experience.
- Route every new user-visible string through the current localization system.
- Extend the project's current shared UI system instead of creating disconnected one-off patterns, unless the task explicitly replaces that UI architecture.
- Do not permanently ban a specific Blizzard template or UI API solely because the current implementation does not use it; assess current Retail support, project consistency, and the task requirements.
- Do not create unbounded persistent frames. Give tickers, `OnUpdate` handlers, callbacks, and temporary frames a controlled start, completion/cancellation path, and cleanup.
- Prefer events or debouncing over high-frequency polling when they meet the requirement.

## Documentation maintenance

Code, tests and current-state documentation should describe the same project state at task completion. After every task, perform a Documentation impact assessment before the final report; production-code, behavior, architecture, persistence, schema, and user-workflow changes require particular scrutiny. Update documentation by meaning, not mechanically: determine which documents became inaccurate because of the task, open and change only those documents, and preserve unaffected research or history.

Assess potential impact on `AGENTS.md`, `docs/PROJECT_STATE.md`, `docs/ARCHITECTURE.md`, `docs/TEST_PLAN.md`, `docs/SETTINGS_REGISTRY.md`, `docs/RECOMMENDED_PROFILE_RESEARCH.md`, `docs/UI_UX_RESEARCH.md`, `README.md`, `README.ru.md`, and `CHANGELOG.md`. A file needs to be opened or edited only when the current task can affect it.

- **`AGENTS.md`:** update only when a durable instruction for future agents changes: an engineering, safety, or security invariant; a required project-wide validation command; or a permanent contribution-workflow rule. Do not update it for an ordinary feature or a mutable current architecture/product decision.
- **`docs/PROJECT_STATE.md`:** update when shipped functionality, user workflow, subsystem behavior, a current limitation, or compatibility/release state changes. Describe the state after the task, not its history. Internal refactoring that leaves current product state unchanged may not require an update.
- **`docs/ARCHITECTURE.md`:** update when a technical contract or component interaction changes, including transactions, delayed operations, backup/Undo lifecycle, persistence or migration model, schemas, profiles, import/export boundaries, registry contracts, benchmark state machines, or UI lifecycle architecture. Pure visual or copy changes do not automatically require it.
- **`docs/TEST_PLAN.md`:** update for a new critical workflow, a new class of required live-client QA, a test-strategy change, or a subsystem that must remain in the standing manual coverage. Do not list every unit regression test.
- **`docs/SETTINGS_REGISTRY.md`:** update when managed settings, validation policy, registry metadata, documented recommended/current values, ownership, or semantics change. Keep documented values aligned with the production registry and profiles.
- **`docs/RECOMMENDED_PROFILE_RESEARCH.md`:** update only when profile evidence, rationale, authoritative sources, or the recommendation basis changes; unrelated refactoring does not require it.
- **`docs/UI_UX_RESEARCH.md`:** update for a significant UI/UX decision or when its current-implementation description becomes misleading. Preserve useful historical research but clearly separate it from current behavior.
- **`README.md` and `README.ru.md`:** update together and keep them functionally equivalent when ordinary users need to know about a feature addition/removal, workflow or command change, import/export change, installation/use change, significant limitation, navigation change, or terminology change. Internal refactoring does not require README changes.
- **`CHANGELOG.md`:** update for a release-facing user-visible fix, feature, significant behavior or compatibility change, migration, or security/safety fix. Follow the existing format; do not record every internal rename, bump a version, or create a release unless the task explicitly requires it.
- **Localization:** when user-visible strings change, update the localization tables and verify localization completeness. Update documentation only when the user workflow itself also changed.

If a production change makes an existing document factually wrong, correct that document in the same task. If verified information is insufficient, do not invent it: report the documentation debt and mark the specific point as unverified rather than asserting false current state.

Every completion report must include this block with concise reasons:

`Documentation impact:`

- `AGENTS.md`: updated / not required — reason
- `PROJECT_STATE.md`: updated / not required — reason
- `ARCHITECTURE.md`: updated / not required — reason
- `TEST_PLAN.md`: updated / not required — reason
- `README.md` / `README.ru.md`: updated / not required — reason
- `CHANGELOG.md`: updated / not required — reason
- Other docs: updated / not required — reason, when applicable

## Scope and validation

- Make the smallest coherent change that solves the current task; do not perform unrelated refactoring or automatically begin the next roadmap item.
- Report newly discovered out-of-scope problems separately instead of silently expanding the task.
- Add a regression test for a bug fix when practical, and add or update tests for architecture or behavior changes.
- Run `lua Tests/run.lua` and `git diff --check`. Run additional focused or broader checks in proportion to the affected area and risk.
- Never claim a check passed unless it was actually run and passed.
- Automated Lua tests do not replace visual and behavioral QA in a live WoW Retail client.

## Completion report

At the end of each task, report:

- the problem addressed and the chosen solution;
- files changed;
- tests added or updated;
- exact commands and checks executed, with results;
- remaining risks or unverified areas;
- newly discovered out-of-scope issues.

Stop after completing the requested task.
