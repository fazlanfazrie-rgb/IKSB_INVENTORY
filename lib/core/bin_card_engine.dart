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
    final rows = source.where((row) =>
        row.itemCode == itemCode &&
        !row.date.isBefore(start) &&
        row.date.isBefore(next) &&
        row.type != TransactionType.cf).toList();

    // The workbook uses the last balance before the period as LastBalance.
    final before = source.where((row) =>
        row.itemCode == itemCode && row.date.isBefore(start)).toList();
    final lastBalance = before.isEmpty ? 0.0 : _lastKnownBalance(before);

    rows.sort((a, b) {
      final date = a.date.compareTo(b.date);
      if (date != 0) return date;
      return transactionOrder(a.type).compareTo(transactionOrder(b.type));
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
    for (final row in rows) {
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
    final rows = [...input]..sort((a, b) {
      final date = a.date.compareTo(b.date);
      if (date != 0) return date;
      return transactionOrder(a.type).compareTo(transactionOrder(b.type));
    });
    var balance = 0.0;
    return rows.map((row) {
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
