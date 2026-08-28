import 'inventory_engine.dart';
import 'transaction_engine.dart';

class BinCardEntry {
  const BinCardEntry({
    required this.date,
    required this.itemCode,
    required this.type,
    required this.quantity,
    required this.balance,
    this.docNo = '',
    this.charging = '',
  });

  final DateTime date;
  final String itemCode;
  final TransactionType type;
  final double quantity;
  final double balance;
  final String docNo;
  final String charging;
}

class BinCardEngine {
  /// Mirrors the workbook BC_ENGINE contract:
  /// - use the last known balance before the requested period;
  /// - include only IN/OUT rows inside the period;
  /// - sort by DATE, CF/IN/OUT order, then source row order;
  /// - expose a synthetic CF opening row for the period.
  static List<BinCardEntry> buildForPeriod({
    required String itemCode,
    required DateTime period,
    required Iterable<InventoryRow> source,
  }) {
    final start = DateTime(period.year, period.month);
    final next = DateTime(period.year, period.month + 1);
    final indexed = source.toList().asMap().entries;
    final rows = indexed
        .where((entry) {
          final row = entry.value;
          return row.itemCode == itemCode &&
              !row.date.isBefore(start) &&
              row.date.isBefore(next) &&
              row.type != TransactionType.cf;
        })
        .map((entry) => _IndexedRow(entry.key, entry.value))
        .toList();

    // The workbook uses the last balance before the period as LastBalance.
    final before = source
        .where((row) => row.itemCode == itemCode && row.date.isBefore(start))
        .toList();
    final lastBalance = before.isEmpty ? 0.0 : _lastKnownBalance(before);

    rows.sort((a, b) {
      final date = a.row.date.compareTo(b.row.date);
      if (date != 0) return date;
      final order = transactionOrder(a.row.type).compareTo(
        transactionOrder(b.row.type),
      );
      if (order != 0) return order;
      return a.index.compareTo(b.index);
    });

    final result = <BinCardEntry>[
      BinCardEntry(
        date: start,
        itemCode: itemCode,
        type: TransactionType.cf,
        quantity: lastBalance,
        balance: lastBalance,
      ),
    ];

    var balance = lastBalance;
    for (final indexedRow in rows) {
      final row = indexedRow.row;
      final qty = transactionQuantity(
        type: row.type,
        opening: row.opening,
        receive: row.receive,
        issue: row.issue,
      );
      balance += qty;
      result.add(BinCardEntry(
        date: row.date,
        itemCode: row.itemCode,
        type: row.type,
        quantity: qty,
        balance: balance,
      ));
    }
    return result;
  }

  /// Compatibility helper for a complete ledger.
  static List<BinCardEntry> build(Iterable<InventoryRow> input) {
    final indexed = input.toList().asMap().entries.toList();
    indexed.sort((a, b) {
      final date = a.value.date.compareTo(b.value.date);
      if (date != 0) return date;
      final order = transactionOrder(a.value.type).compareTo(
        transactionOrder(b.value.type),
      );
      if (order != 0) return order;
      return a.key.compareTo(b.key);
    });

    var balance = 0.0;
    return indexed.map((entry) {
      final row = entry.value;
      final qty = transactionQuantity(
        type: row.type,
        opening: row.opening,
        receive: row.receive,
        issue: row.issue,
      );
      balance += qty;
      return BinCardEntry(
        date: row.date,
        itemCode: row.itemCode,
        type: row.type,
        quantity: qty,
        balance: balance,
      );
    }).toList();
  }

  static double _lastKnownBalance(List<InventoryRow> rows) {
    final balances = InventoryEngine.runningBalances(rows);
    return balances.isEmpty ? 0.0 : balances.last;
  }
}

class _IndexedRow {
  const _IndexedRow(this.index, this.row);
  final int index;
  final InventoryRow row;
}
