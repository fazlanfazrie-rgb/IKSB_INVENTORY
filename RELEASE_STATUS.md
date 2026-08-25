# STOREPH3 Release Status

## Build target
- Flutter stable
- Android release APK
- Windows x64 release EXE
- SQLite offline database

## GitHub Actions outputs
- `STOREPH3-APK` → `STOREPH3.apk`
- `STOREPH3-EXE` → `STOREPH3.exe`
- `STOREPH3-Windows-x64` → complete Windows runtime package

## Important
The Windows `.exe` is produced by GitHub Actions on `windows-latest`, because Flutter Windows builds require the Windows desktop toolchain. The ZIP package contains the executable together with the Flutter runtime DLLs/assets required to run it.
