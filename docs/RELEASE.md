# Release

1. Run `lua Tests/run.lua` and static checks; inspect the final diff for secrets.
2. Build locally with `./build-release.ps1 -Version 1.0.0`.
3. Inspect the ZIP: it must contain exactly the `STierBlizzSettings/` addon folder and no Tests, CI, source-control or documentation files.
4. Test it in the current Retail client, then tag `v1.0.0` (or a semver prerelease such as `v1.1.0-beta.1`).
5. GitHub Actions invokes the maintained BigWigs packager. Publishing integrations use repository secrets `CF_API_KEY`, `WAGO_API_TOKEN` and `WOWI_API_TOKEN`; never commit these values.

Project IDs for CurseForge, Wago and WoWInterface are intentionally absent until real projects exist; do not add fake metadata.
