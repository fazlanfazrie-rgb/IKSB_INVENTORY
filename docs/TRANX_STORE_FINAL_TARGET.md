# TranX_Store v1.0 — Final Target Lock

TranX_Store is the native offline plantation inventory application target.

- Android APK + Windows desktop
- SQLite local-first storage
- Plantation dark-green UI
- Excel is reference/import/export only, never required for daily transactions
- UI → Transaction Service → Inventory Engine → SQLite

## Required release gates
- Flutter analyze: PASS
- Flutter test: PASS
- Android release APK: PASS
- Windows release build: PASS
- Android artifact: `TranX_Store-v1.0.apk`
- Android artifact group: `TranX_Store-android`
- Windows artifact group: `TranX_Store-windows`
- Receive/Issue validation and insufficient-stock protection
- Inventory and Bin Card use the same native ledger/engine

Build success is technical release readiness; full 19-sheet Excel parity remains a separate certification gate requiring zero unexplained golden mismatches.
