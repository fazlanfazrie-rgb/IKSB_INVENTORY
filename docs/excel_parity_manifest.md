# STOREPH3 Excel → Native Parity Manifest

Gold source: `BINCARD_STOREPH3_FINAL.xlsx`.

Certification rule: a module is **LOCKED** only when its native result matches the Gold Excel contract with zero unexplained mismatches.

| Excel named logic | Native implementation | Gate |
|---|---|---|
| DT_PERIOD | `DateEngine` | test |
| DT_WEEK | `DateEngine` | test |
| TRX_TYPE | `TransactionEngine.parseTransactionType` | test |
| TRX_ORDER | `TransactionEngine.transactionOrder` | test |
| TRX_QTY | `TransactionEngine.transactionQuantity` | test |
| ITM_NAME / ITM_GROUP / ITM_UOM | item/master lookup layer | test |
| FRT_ITEM | fertilizer master normalization layer | test |
| FRT_NAME / FRT_GROUP / FRT_SUPPLIER / FRT_KG | `FertilizerEngine` | test |
| OPENING_MONTH | `MonthEngine.opening` | test |
| MONTH_RECEIVE | `MonthEngine.receive` | test |
| MONTH_ISSUE | `MonthEngine.issue` | test |
| MONTH_CLOSING | `MonthEngine.closing` | test |
| STK_BALANCE | `InventoryEngine.stockTakeBalance` | golden test |
| STK_ENGINE | Stock Take aggregation layer | golden test |
| BC_ENGINE | `BinCardEngine` | golden test |
| FW_OPENING | `FertilizerWeeklyEngine.opening` | test |
| FW_RECEIVE | `FertilizerWeeklyEngine.receive` | test |
| FW_ISSUE | `FertilizerWeeklyEngine.issue` | test |
| FW_BALANCE | `FertilizerWeeklyEngine.balance` | test |
| MNR_ISSUE | `ManuringEngine.issueFromDb` | test |
| MNR_BALANCE | `ManuringEngine` balance | test |
| MNR_PROGRESS | `ManuringResult.progress` | test |
| FUL_CHARGING | `FuelEngine.chargingList` | test |
| FUL_ISSUE | `FuelEngine.issue` | test |
| RCV_ENGINE | `ReportEngine.receive` | test |
| ISS_ENGINE | `ReportEngine.issue` | test |
| CF_CONTROL | `ControlEngine` | test |
| Master parity | `MasterParityHarness` | 0 mismatch |

## Current certification state

- CI analyzer: PASS
- Base Flutter test gate: PASS in Run #126
- Android release build: running in Run #126
- Windows release build: running in Run #126
- Full Excel module parity: NOT YET CERTIFIED
- Production replacement of Excel: NOT YET LOCKED

## Final lock criteria

1. All defined business logic has a native implementation.
2. Golden fixtures are derived from the approved Excel file, not hand-invented values.
3. Master Parity Harness reports zero mismatches for every certified module.
4. SQLite and UI use the same engine contract.
5. Flutter analyze is clean.
6. Flutter tests pass.
7. Android release build passes.
8. Windows release build passes.
9. Final artifacts are installable and verified.
