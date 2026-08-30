class FertilizerWeeklyEngine {
  /// Excel FW_OPENING: sum the latest BALANCE before the requested period
  /// for every fertilizer item in the requested item group, in metric tonnes.
  static double opening({
    required Iterable<Map<String, Object?>> rows,
    required String itemGroup,
    required DateTime period,
  }) {
    final periodStart = DateTime(period.year, period.month);
    final byItem = <String, List<Map<String, Object?>>>{};

    for (final row in rows) {
      final code = _text(row, const ['ITEM CODE', 'item_code']);
      final group = _text(row, const ['ITEM GROUP', 'item_group']);
      final date = _date(row);
      if (code.isEmpty || group != itemGroup || date == null) continue;
      byItem.putIfAbsent(code, () => <Map<String, Object?>>[]).add(row);
    }

    var total = 0.0;
    for (final itemRows in byItem.values) {
      Map<String, Object?>? latest;
      for (final row in itemRows) {
        final date = _date(row)!;
        if (date.isBefore(periodStart) &&
            (latest == null || date.isAfter(_date(latest)!))) {
          latest = row;
        }
      }
      total += _number(latest?['BALANCE'] ?? latest?['balance']);
    }
    return total / 1000;
  }

  /// Excel FW_RECEIVE: IN movement for the requested month, group and week,
  /// converted from kg to metric tonnes.
  static double receive({
    required Iterable<Map<String, Object?>> rows,
    required String itemGroup,
    required String week,
    required DateTime period,
  }) {
    return _movement(
      rows: rows,
      itemGroup: itemGroup,
      week: week,
      period: period,
      tranx: 'IN',
      field: 'RECEIVE',
    );
  }

  /// Excel FW_ISSUE: OUT movement for the requested month, group, week and
  /// category, converted from kg to metric tonnes.
  static double issue({
    required Iterable<Map<String, Object?>> rows,
    required String itemGroup,
    required String week,
    required String category,
    required DateTime period,
  }) {
    return _movement(
      rows: rows,
      itemGroup: itemGroup,
      week: week,
      period: period,
      tranx: 'OUT',
      field: 'ISSUE',
      category: category,
    );
  }

  /// Excel FW_BALANCE: opening + receive - issue3A - issue3B.
  static Object balance({
    required double opening,
    required double receive,
    required double issue3A,
    required double issue3B,
  }) {
    final value = opening + receive - issue3A - issue3B;
    if (value == 0) return '-';
    return double.parse(value.toStringAsFixed(2));
  }

  static double _movement({
    required Iterable<Map<String, Object?>> rows,
    required String itemGroup,
    required String week,
    required DateTime period,
    required String tranx,
    required String field,
    String? category,
  }) {
    final p = DateTime(period.year, period.month);
    var total = 0.0;

    for (final row in rows) {
      final date = _date(row);
      if (date == null || date.year != p.year || date.month != p.month) {
        continue;
      }
      if (_text(row, const ['ITEM GROUP', 'item_group']) != itemGroup) {
        continue;
      }

      final storedWeek = _text(row, const ['WEEK', 'week']);
      final rowWeek = storedWeek.isEmpty ? _week(date) : storedWeek;
      if (rowWeek != week) continue;

      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != tranx) {
        continue;
      }
      if (category != null &&
          _text(row, const ['CATEGORY', 'category']) != category) {
        continue;
      }

      total += _number(row[field] ?? row[field.toLowerCase()]);
    }
    return total / 1000;
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

  static String _week(DateTime date) {
    if (date.day <= 7) return '1ST';
    if (date.day <= 14) return '2ND';
    if (date.day <= 21) return '3RD';
    return '4TH';
  }
}
