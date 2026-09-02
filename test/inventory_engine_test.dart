import 'package:flutter_test/flutter_test.dart';
import 'package:tranx_store/core/inventory_engine.dart';
import 'package:tranx_store/core/transaction_engine.dart';

void main() {
  test('running balance preserves CF -> IN -> OUT order', () {
    final rows = [
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: 'X', type: TransactionType.cf, opening: 100, receive: 0, issue: 0, balance: 100),
      InventoryRow(date: DateTime(2026, 8, 2), itemCode: 'X', type: TransactionType.inTxn, opening: 0, receive: 50, issue: 0, balance: 150),
      InventoryRow(date: DateTime(2026, 8, 2), itemCode: 'X', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 20, balance: 130),
    ];
    expect(InventoryEngine.runningBalances(rows), [100, 150, 130]);
    expect(InventoryEngine.closingBalance(rows), 130);
  });

  test('monthly receive and issue are period scoped', () {
    final rows = [
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: 'X', type: TransactionType.inTxn, opening: 0, receive: 100, issue: 0, balance: 100),
      InventoryRow(date: DateTime(2026, 8, 2), itemCode: 'X', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 25, balance: 75),
      InventoryRow(date: DateTime(2026, 9, 1), itemCode: 'X', type: TransactionType.inTxn, opening: 0, receive: 50, issue: 0, balance: 125),
    ];
    expect(InventoryEngine.monthReceive(rows, 'AUG-26'), 100);
    expect(InventoryEngine.monthIssue(rows, 'AUG-26'), 25);
    expect(InventoryEngine.monthReceive(rows, 'SEP-26'), 50);
  });
}
