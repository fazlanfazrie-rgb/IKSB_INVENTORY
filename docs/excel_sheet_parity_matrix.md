# STOREPH3 — Excel Sheet-by-Sheet Parity Matrix

Gold Oracle: `BINCARD_STOREPH3_FINAL.xlsx`

## Certification rule

A sheet is **100% certified** only when its native STOREPH3 implementation reproduces the Excel sheet's defined structure, business rules, calculations, validation, and expected outputs with **0 unexplained mismatches**.

The workbook contains 19 sheets. Formula counts below were extracted from the Gold workbook with formulas preserved.

| # | Excel sheet | Rows | Columns | Formula cells | STOREPH3 target | Gate |
|---:|---|---:|---:|---:|---|---|
| 1 | 01_TRANX_DB | 1190 | 17 | 3497 | Transaction/DB engine + SQLite | GOLDEN |
| 2 | 02_TRANX_WB | 81 | 20 | 316 | Weighbridge receive engine | GOLDEN |
| 3 | 03_FERT_LAYOUT | 42 | 23 | 28 | Fertilizer layout/planning | GOLDEN |
| 4 | 11_FUEL_REPORT | 50 | 35 | 138 | Fuel engine/report | GOLDEN |
| 5 | 12_FERTILIZER_WEEKLY | 28 | 18 | 27 | Fertilizer weekly engine | GOLDEN |
| 6 | 13_MANURING_REPORT | 258 | 11 | 256 | Manuring engine/report | GOLDEN |
| 7 | 14_BIN_CARD | 320 | 8 | 1 | Bin Card engine/UI | GOLDEN |
| 8 | 15_STOCK_TAKE | 89 | 8 | 170 | Stock Take engine/UI | GOLDEN |
| 9 | 16_RECEIVE_REPORT | 21 | 8 | 0 | Receive report | GOLDEN |
| 10 | 17_ISSUE_REPORT | 490 | 17 | 0 | Issue report | GOLDEN |
| 11 | 20_ITEM_MASTER | 86 | 4 | 0 | Item master | MASTER |
| 12 | 21_TRANX_MASTER | 4 | 2 | 0 | Transaction rules | MASTER |
| 13 | 22_CHARGING_MASTER | 205 | 3 | 0 | Charging master | MASTER |
| 14 | 23_REMARK_MASTER | 27 | 3 | 0 | Remark master | MASTER |
| 15 | 24_FERTILIZER_MASTER | 14 | 5 | 0 | Fertilizer master | MASTER |
| 16 | 25_BLOCK_MASTER | 81 | 3 | 0 | Block master | MASTER |
| 17 | 26_MACHINE_MASTER | 42 | 17 | 0 | Machine master | MASTER |
| 18 | 27_TRAILER_MASTER | 48 | 17 | 0 | Trailer master | MASTER |
| 19 | 28_DROPDOWN | 13 | 5 | 0 | Validation/dropdown source | MASTER |

## Native engine mapping

| Excel logic | Native target |
|---|---|
| DT_PERIOD / DT_WEEK | DateEngine |
| TRX_TYPE / TRX_ORDER / TRX_QTY | TransactionEngine |
| ITM_NAME / ITM_GROUP / ITM_UOM | Item master lookup |
| FRT_ITEM / FRT_NAME / FRT_GROUP / FRT_SUPPLIER / FRT_KG | FertilizerEngine |
| OPENING_MONTH / MONTH_RECEIVE / MONTH_ISSUE / MONTH_CLOSING | MonthEngine |
| STK_BALANCE / STK_ENGINE | InventoryEngine + Stock Take layer |
| BC_ENGINE | BinCardEngine |
| FW_OPENING / FW_RECEIVE / FW_ISSUE / FW_BALANCE | FertilizerWeeklyEngine |
| MNR_ISSUE / MNR_BALANCE / MNR_PROGRESS | ManuringEngine |
| FUL_CHARGING / FUL_ISSUE | FuelEngine |
| RCV_ENGINE / ISS_ENGINE | ReportEngine |
| CF_CONTROL | ControlEngine |

## Critical Excel contracts captured

### Transaction master
`21_TRANX_MASTER` defines `CF -> OPENING`, `IN -> RECEIVE`, and `OUT -> ISSUE`. This mapping is a core rule and must be enforced by the native engine.

### Stock Take
`15_STOCK_TAKE` requires PERIOD, ITEM CODE, ITEM NAME, ITEM GROUP, UOM, SYSTEM BALANCE, PHYSICAL COUNT, VARIANCE, and STATUS. System balance must follow the Gold `STK_BALANCE` contract.

### Bin Card
`14_BIN_CARD` is a running ledger with CF/IN/OUT transactions and running balance. The native result must preserve the Excel transaction ordering and balance progression.

### Weighbridge
`02_TRANX_WB` includes supplier/estate gross, tare and net weights, differences, percentage, transport and lorry fields. These are not optional UI decoration; they are part of the sheet contract.

### Manuring
`13_MANURING_REPORT` includes CATEGORY, DIV, CHARGING, REMARK, FERT GROUP, SIZE, PROGRAMME, ISSUE, BALANCE, STATUS and PROGRESS. Progress is certified as an issue/programme ratio, not a raw issue quantity.

## Final 100% gate

The project cannot be marked production-ready until:

1. Every one of the 19 sheets has a native equivalent or explicit master/validation source.
2. Every formula cell that affects business output is represented by a tested native rule.
3. Golden fixtures are derived from the Gold workbook.
4. Master Parity Harness reports **0 mismatches** for all certified sheets.
5. SQLite and UI call the same native engines.
6. `flutter analyze` is clean.
7. `flutter test` passes.
8. Android release build passes.
9. Windows release build passes.
10. Final Android/Windows artifacts are installable and verified.

**Important:** This matrix is a specification and audit control. It does not itself claim that all 19 sheets are already certified.
