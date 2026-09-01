# TranX_Store v1.0 — Final Target Lock

Native offline plantation inventory application.

- Android APK + Windows desktop
- SQLite local-first storage
- Plantation dark-green UI
- Excel is reference/import/export only
- UI → Transaction Service → Inventory Engine → SQLite

## Release gates
- Flutter analyze PASS
- Flutter test PASS
- Android release APK PASS
- Windows release PASS
- Android artifact `TranX_Store-v1.0.apk`
- Artifact groups `TranX_Store-android` and `TranX_Store-windows`
- Receive/Issue validation with insufficient-stock protection
- Inventory and Bin Card use the same native ledger/engine

Build success is technical release readiness. Full 19-sheet Excel parity remains a separate certification gate requiring zero unexplained golden mismatches.
