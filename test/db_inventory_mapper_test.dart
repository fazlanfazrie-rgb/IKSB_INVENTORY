import 'package:flutter_test/flutter_test.dart';
import 'package:tranx_store/core/db_inventory_mapper.dart';
import 'package:tranx_store/core/inventory_engine.dart';

void main() {
  test('SQLite rows map and preserve Excel CF → IN → OUT order', () {
    final rows = DbInventoryMapper.ordered([
      {'date': '2026-08-02', 'item_code': 'ITEM-A', 'tranx': 'OUT', 'opening': 0, 'receive': 0, 'issue': 20},
      {'date': '2026-08-01', 'item_code': 'ITEM-A', 'tranx': 'CF', 'opening': 100, 'receive': 0, 'issue': 0},
      {'date': '2026-08-02', 'item_code': 'ITEM-A', 'tranx': 'IN', 'opening': 0, 'receive': 50, 'issue': 0},
    ]);

    expect(rows.map((r) => r.type.name), ['cf', 'inTxn', 'outTxn']);
    expect(InventoryEngine.closingBalance(rows), 130);
  });

  test('Excel-style aliases map into the same engine contract', () {
    final rows = DbInventoryMapper.ordered([
      {'DATE': '2026-08-01', 'ITEM CODE': 'X', 'TRANX TYPE': 'OPENING', 'OPENING': 25},
      {'DATE': '2026-08-01', 'ITEM CODE': 'X', 'TRANX TYPE': 'RECEIVE', 'RECEIVE': 10},
      {'DATE': '2026-08-01', 'ITEM CODE': 'X', 'TRANX TYPE': 'ISSUE', 'ISSUE': 5},
    ]);
    expect(InventoryEngine.closingBalance(rows), 30);
  });
}
