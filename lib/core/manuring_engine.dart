class ManuringResult {
  const ManuringResult({required this.planned, required this.issued});

  final double planned;
  final double issued;

  double get balance => planned - issued;

  /// Excel MNR_PROGRESS returns issue / programme as a fraction.
  double get progress => planned == 0 ? 0 : _round(issued / planned);

  String get status {
    if (planned == 0) return 'NO PLAN';
    if (issued > planned) return 'OVER APPLIED';
    if (issued == planned) return 'COMPLETED';
    return 'PENDING';
  }

  static double _round(double value) => double.parse(value.toStringAsFixed(10));
}

class ManuringEngine {
  static ManuringResult calculate({
    required double planned,
    required double issued,
  }) =>
      ManuringResult(planned: planned, issued: issued);

  /// Excel MNR_ISSUE. Note: the Excel named formula accepts Category but does
  /// not use it in the SUMIFS criteria, so this method intentionally does not
  /// filter on Category in order to preserve parity.
  static double issueFromDb({
    required Iterable<Map<String, Object?>> rows,
    required String charging,
    required String fertGroup,
    required String remark,
    required double size,
    String? category,
  }) {
    if (charging.trim().isEmpty ||
        fertGroup.trim().isEmpty ||
        remark.trim().isEmpty ||
        size <= 0) {
      return double.nan;
    }

    var kg = 0.0;
    for (final row in rows) {
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != 'OUT') continue;
      if (_text(row, const ['CHARGING', 'charging']) != charging.trim()) continue;
      if (_text(row, const ['ITEM GROUP', 'item_group']) != fertGroup.trim()) continue;
      if (_text(row, const ['REMARK', 'remark']) != remark.trim()) continue;
      kg += _number(row['ISSUE'] ?? row['issue']);
    }
    return kg / size;
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
}
