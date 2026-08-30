class ReportEngine {
  /// Generic filter used by the report UI.
  static List<Map<String, Object?>> filter({
    required List<Map<String, Object?>> rows,
    String? itemCode,
    String? supplier,
    String? charging,
    DateTime? from,
    DateTime? to,
  }) {
    return rows.where((row) {
      final rowItem = _text(row, const ['ITEM CODE', 'item_code']);
      final rowSupplier = _text(row, const ['SUPPLIER', 'supplier']);
      final rowCharging = _text(row, const ['CHARGING', 'charging']);
      final date = _date(row);

      if (itemCode != null && itemCode.isNotEmpty && rowItem != itemCode.trim()) {
        return false;
      }
      if (supplier != null && supplier.isNotEmpty && rowSupplier != supplier.trim()) {
        return false;
      }
      if (charging != null && charging.isNotEmpty && rowCharging != charging.trim()) {
        return false;
      }
      if (from != null && (date == null || date.isBefore(from))) {
        return false;
      }
      if (to != null && (date == null || date.isAfter(to))) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Exact native equivalent of Excel RCV_ENGINE.
  static List<Map<String, Object?>> receive({
    required Iterable<Map<String, Object?>> rows,
    required DateTime period,
    Iterable<Map<String, Object?>> itemMaster = const [],
  }) {
    return _transactionReport(
      rows: rows,
      period: period,
      transaction: 'IN',
      quantityField: 'RECEIVE',
      itemMaster: itemMaster,
    );
  }

  /// Exact native equivalent of Excel ISS_ENGINE.
  static List<Map<String, Object?>> issue({
    required Iterable<Map<String, Object?>> rows,
    required DateTime period,
    Iterable<Map<String, Object?>> itemMaster = const [],
  }) {
    return _transactionReport(
      rows: rows,
      period: period,
      transaction: 'OUT',
      quantityField: 'ISSUE',
      itemMaster: itemMaster,
    );
  }

  static double total(List<Map<String, Object?>> rows, String column) =>
      rows.fold(0, (sum, row) => sum + _number(row[column]));

  static List<Map<String, Object?>> _transactionReport({
    required Iterable<Map<String, Object?>> rows,
    required DateTime period,
    required String transaction,
    required String quantityField,
    required Iterable<Map<String, Object?>> itemMaster,
  }) {
    final p = DateTime(period.year, period.month);
    final next = DateTime(p.year, p.month + 1);
    final master = <String, Map<String, Object?>>{};
    for (final row in itemMaster) {
      final code = _text(row, const ['ITEM CODE', 'item_code']);
      if (code.isNotEmpty) master[code] = row;
    }

    final result = <Map<String, Object?>>[];
    for (final row in rows) {
      final date = _date(row);
      if (date == null || date.isBefore(p) || !date.isBefore(next)) continue;
      if (_text(row, const ['TRANX', 'tranx']).toUpperCase() != transaction) {
        continue;
      }

      final code = _text(row, const ['ITEM CODE', 'item_code']);
      final m = master[code];
      result.add({
        'DATE': date,
        'ITEM CODE': code,
        'ITEM NAME': m == null
            ? _text(row, const ['ITEM NAME', 'item_name'])
            : _text(m, const ['ITEM NAME', 'item_name']),
        'ITEM GROUP': m == null
            ? _text(row, const ['ITEM GROUP', 'item_group'])
            : _text(m, const ['ITEM GROUP', 'item_group']),
        'UOM': m == null
            ? _text(row, const ['UOM', 'uom'])
            : _text(m, const ['UOM', 'uom']),
        'DOC NO': _text(row, const ['DOC NO', 'doc_no']),
        'CHARGING': _text(row, const ['CHARGING', 'charging']),
        quantityField: _number(
          row[quantityField] ?? row[quantityField.toLowerCase()],
        ),
      });
    }

    result.sort((a, b) {
      final date = (a['DATE'] as DateTime).compareTo(b['DATE'] as DateTime);
      if (date != 0) return date;
      final code = '${a['ITEM CODE']}'.compareTo('${b['ITEM CODE']}');
      if (code != 0) return code;
      return '${a['DOC NO']}'.compareTo('${b['DOC NO']}');
    });
    return result;
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
