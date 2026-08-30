class FuelResult {
  const FuelResult({required this.charging, required this.daily});

  final String charging;
  final Map<int, double> daily;

  double get total => daily.values.fold(0, (sum, value) => sum + value);

  /// Excel AH formula: total / COUNT(day cells). Zero-use days are rendered
  /// as "-" by the sheet and therefore are not counted in the average.
  double get avg {
    final used = daily.values.where((value) => value > 0).length;
    return used == 0 ? 0 : total / used;
  }

  String get status {
    if (total == 0) return 'NO ISSUE';
    return avg >= 50 ? 'HIGH' : 'NORMAL';
  }
}

/// Native equivalent of FUL_CHARGING + FUL_ISSUE + fuel report totals.
class FuelEngine {
  static FuelResult calculate({
    required String charging,
    required Map<int, double> daily,
  }) {
    final normalized = <int, double>{};
    for (var day = 1; day <= 31; day++) {
      normalized[day] = daily[day] ?? 0;
    }
    return FuelResult(charging: charging.trim(), daily: normalized);
  }

  /// Excel FUL_CHARGING: UNIQUE charging values where REFERENCE is MACHINE
  /// or CONTRACTOR and CHARGING is not blank, preserving first-seen order.
  static List<String> chargingList(Iterable<Map<String, Object?>> rows) {
    final result = <String>[];
    final seen = <String>{};
    for (final row in rows) {
      final reference =
          _text(row, const ['REFERENCE', 'reference']).toUpperCase();
      final charging = _text(row, const ['CHARGING', 'charging']);
      if ((reference == 'MACHINE' || reference == 'CONTRACTOR') &&
          charging.isNotEmpty &&
          seen.add(charging)) {
        result.add(charging);
      }
    }
    return result;
  }

  /// Excel FUL_ISSUE: Diesel (010001), OUT, exact date and charging.
  static double issue({
    required Iterable<Map<String, Object?>> rows,
    required DateTime period,
    required int day,
    required String charging,
  }) {
    final p = DateTime(period.year, period.month);
    final target = DateTime(p.year, p.month, day);
    var total = 0.0;
    for (final row in rows) {
      final date = _date(row);
      if (date == null || !_sameDate(date, target)) {
        continue;
      }
      if (_text(row, const ['ITEM CODE', 'item_code']) != '010001') {
        continue;
      }
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != 'OUT') {
        continue;
      }
      if (_text(row, const ['CHARGING', 'charging']) != charging.trim()) {
        continue;
      }
      total += _number(row['ISSUE'] ?? row['issue']);
    }
    return total;
  }

  static FuelResult fromRows({
    required Iterable<Map<String, Object?>> rows,
    required DateTime period,
    required String charging,
  }) {
    final daily = <int, double>{};
    for (var day = 1; day <= 31; day++) {
      daily[day] = issue(
        rows: rows,
        period: period,
        day: day,
        charging: charging,
      );
    }
    return calculate(charging: charging, daily: daily);
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

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
