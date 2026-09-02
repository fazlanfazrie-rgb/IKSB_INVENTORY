import 'package:flutter_test/flutter_test.dart';
import 'package:tranx_store/core/bin_card_engine.dart';
import 'package:tranx_store/core/inventory_engine.dart';
import 'package:tranx_store/core/transaction_engine.dart';

void main() {
  test('bin card sorts same-day transactions CF -> IN -> OUT', () {
    final rows = [
      InventoryRow(date: DateTime(2026, 8, 2), itemCode: 'X', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 20, balance: 0),
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: 'X', type: TransactionType.cf, opening: 100, receive: 0, issue: 0, balance: 0),
      InventoryRow(date: DateTime(2026, 8, 2), itemCode: 'X', type: TransactionType.inTxn, opening: 0, receive: 50, issue: 0, balance: 0),
    ];

    final result = BinCardEngine.build(rows);
    expect(result.map((e) => e.type), [
      TransactionType.cf,
      TransactionType.inTxn,
      TransactionType.outTxn,
    ]);
    expect(result.map((e) => e.balance), [100, 150, 130]);
    expect(result.map((e) => e.quantity), [100, 50, -20]);
  });
}
