# TranX_Store v1.0 — Final Blueprint

## Product target
Native Flutter Android-first offline estate inventory application. Excel is reference/import-export only and is not required for daily transactions.

## Locked identity
- App: TranX_Store
- Branch: tranx-store-app
- Theme: plantation / estate dark green with lime accents
- Database: local SQLite
- Primary platform: Android APK
- Secondary build: Windows desktop

## Core flow
UI -> Transaction Engine -> Stock Engine -> SQLite -> Bin Card / Reports

## Transaction rules
1. Every transaction is persisted locally in SQLite.
2. RECEIVE increases stock.
3. ISSUE decreases stock.
4. ISSUE is rejected when resulting stock would be negative.
5. Same-day transaction ordering must be deterministic and must not depend on accidental UI/table row order.
6. Balance is derived from the transaction ledger, not cached Excel formulas.
7. Item master data is validated before transaction posting.
8. Required transaction fields: date, item code, transaction type, quantity; optional document no, charging/location and remark.

## Minimum modules
- Dashboard
- Inventory
- Receive
- Issue
- Bin Card
- Stock Take
- Fuel
- Fertilizer
- Reports
- Settings

## Golden CI gates
All must PASS before v1.0 is called final:
- dart format
- flutter analyze
- flutter test
- Android release APK build
- Windows release build
- artifact upload

## Release naming
- TranX_Store-v1.0.apk
- TranX_Store-android
- TranX_Store-windows

## Final lock rule
A failed or partial run is never promoted. The first commit/run that passes every Golden CI gate becomes the Golden Build. No Excel dependency is allowed in the runtime path.
