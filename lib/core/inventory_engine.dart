import 'transaction_engine.dart';

class InventoryRow {
  const InventoryRow({
    required this.date,
    required this.itemCode,
    required this.type,
    required this.opening,
    required this.receive,
    required this.issue,
    required this.balance,
  });

  final DateTime date;
  final String itemCode;
  final TransactionType type;
  final double opening;
  final double receive;
  final double issue;
  final double balance;
}

class InventoryEngine {
  /// Calculates the running balance in the same CF -> IN -> OUT order
  /// used by the workbook ledger.
  static List<double> runningBalances(Iterable<InventoryRow> rows) {
    var balance = 0.0;
    final result = <double>[];
    for (final row in rows) {
      balance += transactionQuantity(
        type: row.type,
        opening: row.opening,
        receive: row.receive,
        issue: row.issue,
      );
      result.add(balance);
    }
    return result;
  }

  static double closingBalance(Iterable<InventoryRow> rows) {
    return runningBalances(rows).isEmpty ? 0 : runningBalances(rows).last;
  }

  static double monthReceive(Iterable<InventoryRow> rows, String period) =>
      rows.where((r) => r.date.month.toString().isNotEmpty).where((r) =>
          _period(r.date) == period).fold(0, (sum, r) => sum + r.receive);

  static double monthIssue(Iterable<InventoryRow> rows, String period) =>
      rows.where((r) => _period(r.date) == period)
          .fold(0, (sum, r) => sum + r.issue);

  static String _period(DateTime date) =>
      '${_months[date.month - 1]}-${date.year.toString().substring(2)}';

  static const _months = [
    'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'
  ];
}
