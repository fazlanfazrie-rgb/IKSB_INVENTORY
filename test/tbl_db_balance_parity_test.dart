import 'package:flutter_test/flutter_test.dart';
import 'package:tranx_store/core/inventory_engine.dart';
import 'package:tranx_store/core/parity_harness.dart';
import 'package:tranx_store/core/stock_take_engine.dart';
import 'package:tranx_store/core/transaction_engine.dart';

import 'fixtures/tbl_db_fixture.dart';

void main() {
  test('TBL_DB fixture produces Excel-order running balances per item', () {
    final rows = orderedFixture();
    final itemA = rows.where((r) => r.itemCode == 'ITEM-A');
    final itemB = rows.where((r) => r.itemCode == 'ITEM-B');
    expect(InventoryEngine.runningBalances(itemA), [100, 150, 130, 100]);
    expect(InventoryEngine.runningBalances(itemB), [500, 600, 525]);
  });

  test('Balance Engine closing stock matches fixture oracle per item', () {
    final rows = orderedFixture();
    final itemA = rows.where((r) => r.itemCode == 'ITEM-A');
    final itemB = rows.where((r) => r.itemCode == 'ITEM-B');
    expect(InventoryEngine.closingBalance(itemA), 100);
    expect(InventoryEngine.closingBalance(itemB), 525);
  });

  test('Stock Take uses the Excel STK_BALANCE period contract', () {
    final rows = orderedFixture();
    expect(InventoryEngine.stockTakeBalance(rows: rows, itemCode: 'ITEM-A', period: DateTime(2026, 8, 1)), 100);
    expect(InventoryEngine.stockTakeBalance(rows: rows, itemCode: 'ITEM-B', period: DateTime(2026, 8, 1)), 525);
  });

  test('Stock Take ignores a negative CF when selecting the opening CF', () {
    final rows = [
      ...orderedFixture(),
      InventoryRow(date: DateTime(2026, 7, 31), itemCode: 'ITEM-A', type: TransactionType.cf, opening: -20, receive: 0, issue: 0, balance: -20),
    ];
    expect(InventoryEngine.stockTakeBalance(rows: rows, itemCode: 'ITEM-A', period: DateTime(2026, 8, 1)), 100);
  });

  test('Stock Take variance and status are deterministic', () {
    final tally = StockTakeEngine.calculate(system: 100, physical: 100);
    final over = StockTakeEngine.calculate(system: 525, physical: 530);
    final short = StockTakeEngine.calculate(system: 100, physical: 95);
    expect(tally.variance, 0);
    expect(tally.status, 'TALLY');
    expect(over.variance, 5);
    expect(over.status, 'OVER');
    expect(short.variance, -5);
    expect(short.status, 'SHORT');
  });

  test('Master Parity Harness returns PASS for matching Excel oracle', () {
    const expected = [
      {'ITEM CODE': 'ITEM-A', 'BALANCE': 100.0, 'STATUS': 'TALLY'},
      {'ITEM CODE': 'ITEM-B', 'BALANCE': 525.0, 'STATUS': 'TALLY'},
    ];
    const actual = [
      {'ITEM CODE': 'ITEM-A', 'BALANCE': 100.0, 'STATUS': 'TALLY'},
      {'ITEM CODE': 'ITEM-B', 'BALANCE': 525.0, 'STATUS': 'TALLY'},
    ];
    final result = MasterParityHarness.compare(engine: 'TBL_DB → Balance → Stock Take', expected: expected, actual: actual, keys: ['ITEM CODE']);
    expect(result.status, ParityStatus.pass);
    expect(result.mismatches, isEmpty);
    expect(result.expectedRows, 2);
    expect(result.actualRows, 2);
  });
}
