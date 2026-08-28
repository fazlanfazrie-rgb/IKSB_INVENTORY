import 'inventory_engine.dart';
import 'transaction_engine.dart';

class BinCardEntry {
  const BinCardEntry({
    required this.date,
    required this.itemCode,
    required this.type,
    required this.quantity,
    required this.balance,
  });

  final DateTime date;
  final String itemCode;
  final TransactionType type;
  final double quantity;
  final double balance;
}

class BinCardEngine {
  /// Produces a deterministic ledger: date first, then CF -> IN -> OUT.
  /// The returned balance is the running balance at each ledger row.
  static List<BinCardEntry> build(Iterable<InventoryRow> input) {
    final rows = [...input]..sort((a, b) {
      final date = a.date.compareTo(b.date);
      if (date != 0) return date;
      return transactionOrder(a.type).compareTo(transactionOrder(b.type));
    });

    var balance = 0.0;
    return rows.map((row) {
      balance += transactionQuantity(
        type: row.type,
        opening: row.opening,
        receive: row.receive,
        issue: row.issue,
      );
      return BinCardEntry(
        date: row.date,
        itemCode: row.itemCode,
        type: row.type,
        quantity: transactionQuantity(
          type: row.type,
          opening: row.opening,
          receive: row.receive,
          issue: row.issue,
        ),
        balance: balance,
      );
    }).toList();
  }
}
