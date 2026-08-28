import 'package:storeph3/core/inventory_engine.dart';
import 'package:storeph3/core/transaction_engine.dart';

/// Small deterministic TBL_DB fixture representing the Excel ledger rules.
const tblDbFixture = <InventoryRow>[
  InventoryRow(
    date: DateTime(2026, 8, 1),
    itemCode: 'ITEM-A',
    type: TransactionType.cf,
    opening: 100,
    receive: 0,
    issue: 0,
    balance: 100,
  ),
  InventoryRow(
    date: DateTime(2026, 8, 2),
    itemCode: 'ITEM-A',
    type: TransactionType.inTxn,
    opening: 0,
    receive: 50,
    issue: 0,
    balance: 150,
  ),
  InventoryRow(
    date: DateTime(2026, 8, 2),
    itemCode: 'ITEM-A',
    type: TransactionType.outTxn,
    opening: 0,
    receive: 0,
    issue: 20,
    balance: 130,
  ),
  InventoryRow(
    date: DateTime(2026, 8, 3),
    itemCode: 'ITEM-A',
    type: TransactionType.outTxn,
    opening: 0,
    receive: 0,
    issue: 30,
    balance: 100,
  ),
  InventoryRow(
    date: DateTime(2026, 8, 1),
    itemCode: 'ITEM-B',
    type: TransactionType.cf,
    opening: 500,
    receive: 0,
    issue: 0,
    balance: 500,
  ),
  InventoryRow(
    date: DateTime(2026, 8, 5),
    itemCode: 'ITEM-B',
    type: TransactionType.inTxn,
    opening: 0,
    receive: 100,
    issue: 0,
    balance: 600,
  ),
  InventoryRow(
    date: DateTime(2026, 8, 5),
    itemCode: 'ITEM-B',
    type: TransactionType.outTxn,
    opening: 0,
    receive: 0,
    issue: 75,
    balance: 525,
  ),
];

List<InventoryRow> orderedFixture() {
  final rows = [...tblDbFixture];
  rows.sort((a, b) {
    final date = a.date.compareTo(b.date);
    if (date != 0) return date;
    final item = a.itemCode.compareTo(b.itemCode);
    if (item != 0) return item;
    return transactionOrder(a.type).compareTo(transactionOrder(b.type));
  });
  return rows;
}
