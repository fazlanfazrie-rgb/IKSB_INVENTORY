# STOREPH3 Excel → Native Parity Manifest

Gold source: `BINCARD_STOREPH3_FINAL.xlsx`.

## FINAL DEFINITION — LOCKED

STOREPH3 is considered **FINAL / PRODUCTION-LOCKED** only when the native Android/Windows application reproduces the approved Gold Excel workbook **sheet-by-sheet**, with the same business logic, formulas/rules, source-data semantics, calculated outputs, validation/status behavior, and user workflow.

### Mandatory gates

1. **19/19 sheets** are represented by the correct native screen, data layer, engine, report, master/reference layer, or other appropriate native implementation. A menu item alone is not completion.
2. **Logic parity:** every defined Excel business rule has a native implementation.
3. **Formula parity:** formula-derived outputs are reproduced by deterministic native calculations; Gold Excel remains the oracle.
4. **Data parity:** approved Gold Excel data preserves field meaning, transaction mapping, ordering, filtering, and aggregation.
5. **Output parity:** native output matches Gold Excel for the **full approved dataset**, not a hand-picked sample.
6. **Golden parity:** `MasterParityHarness` performs row/value comparison and reports **0 unexplained mismatches** for every certified module.
7. **SQLite/UI contract:** persistence, calculation engines, and UI use the same normalized business contract; no duplicate calculation logic in UI.
8. **Flutter analyzer:** 0 analyzer errors/warnings violating the project gate.
9. **Flutter tests:** 0 failures.
10. **Android release:** APK builds successfully and is installable.
11. **Windows release:** EXE builds successfully and is runnable.
12. **Final artifacts:** exact release artifacts are verified after build.

## Certification rule

A module is **LOCKED** only when its native result matches the Gold Excel contract with **zero unexplained mismatches**. Build success alone is not parity certification.

## Native mapping

| Excel named logic | Native implementation | Gate |
|---|---|---|
| DT_PERIOD / DT_WEEK | `DateEngine` | test |
| TRX_TYPE / TRX_ORDER / TRX_QTY | `TransactionEngine` | test |
| ITM_NAME / ITM_GROUP / ITM_UOM | item/master lookup layer | test |
| FRT_ITEM / FRT_NAME / FRT_GROUP / FRT_SUPPLIER / FRT_KG | `FertilizerEngine` | test |
| OPENING_MONTH / MONTH_RECEIVE / MONTH_ISSUE / MONTH_CLOSING | `MonthEngine` | test |
| STK_BALANCE | `InventoryEngine.stockTakeBalance` | golden test |
| STK_ENGINE | Stock Take aggregation layer | golden test |
| BC_ENGINE | `BinCardEngine` | golden test |
| FW_OPENING / FW_RECEIVE / FW_ISSUE / FW_BALANCE | `FertilizerWeeklyEngine` | test |
| MNR_ISSUE / MNR_BALANCE / MNR_PROGRESS | `ManuringEngine` | test |
| FUL_CHARGING / FUL_ISSUE | `FuelEngine` | test |
| RCV_ENGINE / ISS_ENGINE | `ReportEngine` | test |
| CF_CONTROL | `ControlEngine` | test |
| Master parity | `MasterParityHarness` | **0 mismatch** |

## Current certification state

- Final definition: **LOCKED**
- Full Excel module parity: **NOT YET CERTIFIED**
- Production replacement of Excel: **NOT YET LOCKED**

## Non-negotiable rule

Do not report 100% or Production LOCK merely because an APK builds, a screen opens, or unit tests pass. Final certification requires **full Gold Excel comparison with 0 mismatch** plus all release gates above.
