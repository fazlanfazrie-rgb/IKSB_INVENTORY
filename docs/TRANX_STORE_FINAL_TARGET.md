# TranX_Store v1.0 — Final Target Lock

## Product identity
- App: TranX_Store
- Platform: Android APK + Windows desktop
- Storage: local SQLite, offline-first
- Excel: reference/import/export only; never required for daily transactions
- UI: plantation/estate dark theme

## Mandatory release gates
1. Flutter analyze passes with zero gate violations.
2. Flutter tests pass.
3. Android release APK builds successfully.
4. Windows release build succeeds.
5. Android artifact is named `TranX_Store-v1.0.apk`.
6. GitHub Actions artifacts are named `TranX_Store-android` and `TranX_Store-windows`.
7. Receive/Issue writes to SQLite and rejects invalid quantities and insufficient stock for OUT.
8. Inventory and Bin Card read from the same transaction ledger/engine.

## Architecture lock
UI → Transaction Service → Inventory Engine → SQLite.

The UI must not implement a second balance calculation. All stock calculations must use the native engine contract.

## Important certification rule
Build success means the application is technically releasable, not that all 19 Excel sheets are already parity-certified. Full Excel replacement remains a separate data/logic certification gate requiring zero unexplained golden mismatches.

## Release rule
Do not publish an artifact as production-final until the current commit's required CI gates and both platform builds are green. When green, the CI artifact is the release candidate for installation/deployment.
