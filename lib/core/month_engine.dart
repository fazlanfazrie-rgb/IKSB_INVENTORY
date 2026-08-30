class MonthEngine {
  /// Excel OPENING_MONTH: use the first CF date for the item, sum CF opening
  /// in that CF month, then add movements between that month and target period.
  static double? opening({
    required Iterable<Map<String, Object?>> rows,
    required String itemCode,
    required DateTime period,
  }) {
    final p = DateTime(period.year, period.month);
    final itemRows = rows.where(
      (row) => _text(row, const ['ITEM CODE', 'item_code']) == itemCode.trim(),
    );
    DateTime? cfDate;
    for (final row in itemRows) {
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != 'CF') {
        continue;
      }
      final date = _date(row);
      if (date == null) continue;
      if (cfDate == null || date.isBefore(cfDate)) cfDate = date;
    }
    if (cfDate == null) return null;

    final start = DateTime(cfDate.year, cfDate.month);
    if (p.isBefore(start)) return null;
    final nextStart = DateTime(start.year, start.month + 1);

    var initial = 0.0;
    var receiveBefore = 0.0;
    var issueBefore = 0.0;
    for (final row in itemRows) {
      final date = _date(row);
      if (date == null) continue;
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() == 'CF' &&
          !date.isBefore(start) &&
          date.isBefore(nextStart)) {
        initial += _number(row['OPENING'] ?? row['opening']);
      }
      if (!date.isBefore(start) && date.isBefore(p)) {
        receiveBefore += _number(row['RECEIVE'] ?? row['receive']);
        issueBefore += _number(row['ISSUE'] ?? row['issue']);
      }
    }
    return initial + receiveBefore - issueBefore;
  }

  static double receive({
    required Iterable<Map<String, Object?>> rows,
    required String itemCode,
    required DateTime period,
  }) =>
      _monthMovement(rows, itemCode, period, 'RECEIVE');

  static double issue({
    required Iterable<Map<String, Object?>> rows,
    required String itemCode,
    required DateTime period,
  }) =>
      _monthMovement(rows, itemCode, period, 'ISSUE');

  /// Excel MONTH_CLOSING: blank when opening is blank, else opening + receive - issue.
  static double? closing({
    required Iterable<Map<String, Object?>> rows,
    required String itemCode,
    required DateTime period,
  }) {
    final openingValue = opening(rows: rows, itemCode: itemCode, period: period);
    if (openingValue == null) return null;
    return openingValue +
        receive(rows: rows, itemCode: itemCode, period: period) -
        issue(rows: rows, itemCode: itemCode, period: period);
  }

  static double _monthMovement(
    Iterable<Map<String, Object?>> rows,
    String itemCode,
    DateTime period,
    String field,
  ) {
    final p = DateTime(period.year, period.month);
    final next = DateTime(p.year, p.month + 1);
    var total = 0.0;
    for (final row in rows) {
      if (_text(row, const ['ITEM CODE', 'item_code']) != itemCode.trim()) {
        continue;
      }
      final date = _date(row);
      if (date == null || date.isBefore(p) || !date.isBefore(next)) continue;
      total += _number(row[field] ?? row[field.toLowerCase()]);
    }
    return total;
  }

  static String _text(Map<String, Object?> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value != null) return '$value'.trim();
    }
    return '';
  }

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static DateTime? _date(Map<String, Object?> row) {
    final value = row['DATE'] ?? row['date'];
    if (value is DateTime) return value;
    return DateTime.tryParse('$value');
  }
}
