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
    final balances = runningBalances(rows);
    return balances.isEmpty ? 0 : balances.last;
  }

  /// Native equivalent of the Gold Excel STK_BALANCE LAMBDA.
  static double stockTakeBalance({
    required Iterable<InventoryRow> rows,
    required String itemCode,
    required DateTime period,
  }) {
    final monthStart = DateTime(period.year, period.month);
    final nextPeriod = DateTime(period.year, period.month + 1);
    final itemRows = rows.where((r) => r.itemCode == itemCode).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final cfRows = itemRows.where((r) =>
        r.type == TransactionType.cf &&
        r.opening >= 0 &&
        !r.date.isAfter(monthStart));

    DateTime? startDate;
    double opening = 0;
    if (cfRows.isNotEmpty) {
      startDate = cfRows.map((r) => r.date).reduce(
            (a, b) => a.isAfter(b) ? a : b,
          );
      opening = itemRows
          .where((r) =>
              r.type == TransactionType.cf &&
              r.opening >= 0 &&
              _sameDate(r.date, startDate!))
          .fold(0, (sum, r) => sum + r.opening);
    } else {
      final dates = itemRows
          .where((r) => r.date.isBefore(nextPeriod))
          .map((r) => r.date)
          .toList();
      if (dates.isNotEmpty) {
        startDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
      }
    }

    if (startDate == null) return 0;
    final receive = itemRows
        .where((r) =>
            !r.date.isBefore(startDate!) && r.date.isBefore(nextPeriod))
        .fold(0.0, (sum, r) => sum + r.receive);
    final issue = itemRows
        .where((r) =>
            !r.date.isBefore(startDate!) && r.date.isBefore(nextPeriod))
        .fold(0.0, (sum, r) => sum + r.issue);
    return opening + receive - issue;
  }

  static double monthReceive(Iterable<InventoryRow> rows, String period) =>
      rows.where((r) => _period(r.date) == period)
          .fold(0, (sum, r) => sum + r.receive);

  static double monthIssue(Iterable<InventoryRow> rows, String period) =>
      rows.where((r) => _period(r.date) == period)
          .fold(0, (sum, r) => sum + r.issue);

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _period(DateTime date) =>
      '${_months[date.month - 1]}-${date.year.toString().substring(2)}';

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];
}
