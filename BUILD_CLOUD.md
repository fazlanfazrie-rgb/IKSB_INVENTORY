# STOREPH3 v1.0 — Cloud Build

This is the final Flutter + SQLite offline-first build pipeline.

## Outputs
- `STOREPH3.apk` — Android release APK
- `STOREPH3-Windows.zip` — Windows x64 release folder containing `storeph3.exe` and Flutter runtime files

## Build on GitHub
1. Create an empty GitHub repository.
2. Upload the CONTENTS of this folder (so `.github/workflows/release.yml` is at the repository root).
3. Open **Actions** → **STOREPH3 v1.0 Release**.
4. Select **Run workflow**.
5. Download the artifacts `STOREPH3-APK` and `STOREPH3-Windows`.

You can also push a tag such as `v1.0.0` to trigger the release workflow automatically.

## Important
Android and Windows are compiled from the same Flutter source and the same SQLite data/business-logic layer. SQLite remains local/offline; there is no cloud database dependency.
