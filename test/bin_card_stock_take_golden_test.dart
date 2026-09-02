import 'package:flutter_test/flutter_test.dart';
import 'package:tranx_store/core/bin_card_engine.dart';
import 'package:tranx_store/core/inventory_engine.dart';
import 'package:tranx_store/core/stock_take_engine.dart';
import 'package:tranx_store/core/transaction_engine.dart';

void main() {
  group('Gold Excel parity - Bin Card', () {
    final source = <InventoryRow>[
      InventoryRow(date: DateTime(2026, 7, 31), itemCode: '010001', type: TransactionType.cf, opening: 2876, receive: 0, issue: 0, balance: 2876),
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: '010001', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 20, balance: 2856),
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: '010001', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 20, balance: 2836),
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: '010001', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 50, balance: 2786),
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: '010001', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 50, balance: 2736),
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: '010001', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 37, balance: 2699),
      InventoryRow(date: DateTime(2026, 8, 1), itemCode: '010001', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 37, balance: 2662),
    ];

    test('matches Gold Excel opening and running balance', () {
      final actual = BinCardEngine.buildForPeriod(itemCode: '010001', period: DateTime(2026, 8, 1), source: source);
      expect(actual.first.balance, 2876);
      expect(actual.length, 7);
      expect(actual[1].balance, 2856);
      expect(actual[2].balance, 2836);
      expect(actual[3].balance, 2786);
      expect(actual[4].balance, 2736);
      expect(actual[5].balance, 2699);
      expect(actual[6].balance, 2662);
    });
  });

  group('Stock Take parity contract', () {
    test('variance and status match the Excel rule', () {
      expect(StockTakeEngine.calculate(system: 100, physical: 100).variance, 0);
      expect(StockTakeEngine.calculate(system: 100, physical: 100).status, 'TALLY');
      expect(StockTakeEngine.calculate(system: 100, physical: 105).variance, 5);
      expect(StockTakeEngine.calculate(system: 100, physical: 105).status, 'OVER');
      expect(StockTakeEngine.calculate(system: 100, physical: 95).variance, -5);
      expect(StockTakeEngine.calculate(system: 100, physical: 95).status, 'SHORT');
    });

    test('system balance follows native inventory contract', () {
      final rows = <InventoryRow>[
        InventoryRow(date: DateTime(2026, 7, 31), itemCode: '010001', type: TransactionType.cf, opening: 2876, receive: 0, issue: 0, balance: 2876),
        InventoryRow(date: DateTime(2026, 8, 1), itemCode: '010001', type: TransactionType.outTxn, opening: 0, receive: 0, issue: 214, balance: 2662),
      ];
      final system = InventoryEngine.stockTakeBalance(rows: rows, itemCode: '010001', period: DateTime(2026, 8, 1));
      expect(system, 2662);
    });
  });
}
