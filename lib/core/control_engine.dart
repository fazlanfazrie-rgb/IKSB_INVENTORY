class ControlFinding {
  const ControlFinding({
    required this.code,
    required this.message,
    required this.severity,
  });

  final String code;
  final String message;
  final String severity;
}

class ControlEngine {
  static List<ControlFinding> validateBalance(double balance) {
    if (balance < 0) {
      return const [
        ControlFinding(
          code: 'NEGATIVE_STOCK',
          message: 'System balance is below zero; investigation required.',
          severity: 'HIGH',
        ),
      ];
    }
    return const [];
  }

  static List<ControlFinding> validateQuantity({
    required double receive,
    required double issue,
  }) {
    final findings = <ControlFinding>[];
    if (receive < 0) {
      findings.add(
        const ControlFinding(
          code: 'NEGATIVE_RECEIVE',
          message: 'Receive quantity cannot be negative.',
          severity: 'HIGH',
        ),
      );
    }
    if (issue < 0) {
      findings.add(
        const ControlFinding(
          code: 'NEGATIVE_ISSUE',
          message: 'Issue quantity cannot be negative.',
          severity: 'HIGH',
        ),
      );
    }
    if (receive > 0 && issue > 0) {
      findings.add(
        const ControlFinding(
          code: 'MIXED_MOVEMENT',
          message: 'Receive and issue should be separate transactions.',
          severity: 'MEDIUM',
        ),
      );
    }
    return findings;
  }

  /// Excel CF_CONTROL: determines whether an item has its initial CF and
  /// whether a monthly CF is present for the requested period.
  static String cfControl({
    required Iterable<Map<String, Object?>> rows,
    required String itemCode,
    required DateTime period,
  }) {
    final item = itemCode.trim();
    final p = DateTime(period.year, period.month);
    final next = DateTime(p.year, p.month + 1);
    DateTime? startPeriod;

    for (final row in rows) {
      if (_text(row, const ['ITEM CODE', 'item_code']) != item) continue;
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != 'CF') continue;
      final date = _date(row);
      if (date == null) continue;
      if (startPeriod == null || date.isBefore(startPeriod)) {
        startPeriod = date;
      }
    }

    if (startPeriod == null) return 'NO INITIAL CF';
    final initialPeriod = DateTime(startPeriod.year, startPeriod.month);
    if (p.isBefore(initialPeriod)) return 'NOT STARTED';
    if (_sameMonth(p, initialPeriod)) return 'INITIAL CF';

    final hasMonthlyCf = rows.any((row) {
      if (_text(row, const ['ITEM CODE', 'item_code']) != item) return false;
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != 'CF') return false;
      final date = _date(row);
      return date != null && !date.isBefore(p) && date.isBefore(next);
    });
    return hasMonthlyCf ? 'MONTHLY CF FOUND' : 'OK - AUTO';
  }

  /// Excel INITIAL_OPENING: opening quantity from CF rows in the first CF month.
  static double? initialOpening({
    required Iterable<Map<String, Object?>> rows,
    required String itemCode,
  }) {
    final item = itemCode.trim();
    DateTime? firstCf;
    for (final row in rows) {
      if (_text(row, const ['ITEM CODE', 'item_code']) != item) continue;
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != 'CF') continue;
      final date = _date(row);
      if (date == null) continue;
      if (firstCf == null || date.isBefore(firstCf)) firstCf = date;
    }
    if (firstCf == null) return null;

    final start = DateTime(firstCf.year, firstCf.month);
    final next = DateTime(start.year, start.month + 1);
    var opening = 0.0;
    for (final row in rows) {
      if (_text(row, const ['ITEM CODE', 'item_code']) != item) continue;
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != 'CF') continue;
      final date = _date(row);
      if (date == null || date.isBefore(start) || !date.isBefore(next)) continue;
      opening += _number(row['OPENING'] ?? row['opening']);
    }
    return opening;
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

  static bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
