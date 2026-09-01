# TranX_Store v1.0 — Final Target Lock

Native offline plantation inventory application.

Android APK + Windows desktop; SQLite local-first; plantation dark-green UI; Excel is reference/import/export only.

Architecture: UI → Transaction Service → Inventory Engine → SQLite.

Release gates: Flutter analyze, Flutter test, Android release APK, Windows release build, Receive/Issue validation, insufficient-stock protection, and shared Inventory/Bin Card ledger.

Artifacts: `TranX_Store-v1.0.apk`, `TranX_Store-android`, `TranX_Store-windows`.

Build success is technical release readiness. Full 19-sheet Excel parity remains a separate certification gate requiring zero unexplained golden mismatches.
