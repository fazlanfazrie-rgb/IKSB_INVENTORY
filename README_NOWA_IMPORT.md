# STOREPH3 — NOWA FLUTTER MIGRATION

## Purpose
This is the Flutter migration baseline derived from STOREPH3 FINAL LOCKED. It is intended to be opened/imported in Nowa Desktop and then extended into the full production UI.

## Important
The Android FINAL LOCKED project is Java/Gradle, not Flutter. Do NOT upload the Android project and expect Nowa to treat it as Flutter. Use this Flutter migration project instead.

## Baseline preserved
- 85 Item Master records
- 1,154 legacy rows inspected
- 1,104 valid transaction rows loaded by the migration filter
- 50 blank legacy rows skipped
- Negative historical exceptions are preserved as source history; new Issue transactions are blocked when they exceed current balance
- Offline SQLite database
- Ledger-first balance calculation
- Stock Take and Audit Log schema

## Open in Nowa
Nowa Desktop: New Local Project -> dropdown next to New Local Project -> Open -> choose this folder.

## First AI prompt inside Nowa
Use the prompt in `NOWA_BUILD_PROMPT.txt`.

## Build target
- Android APK: STOREPH3.apk
- Windows: STOREPH3.exe

## Offline rule
SQLite remains the primary runtime store. Do not replace it with Firebase/Supabase as a dependency for core inventory transactions.
