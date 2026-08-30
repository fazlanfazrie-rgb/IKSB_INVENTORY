class ReportEngine {
  static List<Map<String, Object?>> filter({
    required List<Map<String, Object?>> rows,
    String? itemCode,
    String? supplier,
    String? charging,
    DateTime? from,
    DateTime? to,
  }) {
    return rows.where((row) {
      final rowItem = '${row['ITEM CODE'] ?? row['item_code'] ?? ''}'.trim();
      final rowSupplier = '${row['SUPPLIER'] ?? row['supplier'] ?? ''}'.trim();
      final rowCharging = '${row['CHARGING'] ?? row['charging'] ?? ''}'.trim();
      final rawDate = row['DATE'] ?? row['date'];
      final date = rawDate is DateTime ? rawDate : DateTime.tryParse('$rawDate');

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

  static double total(List<Map<String, Object?>> rows, String column) => rows.fold(
        0,
        (sum, row) => sum + (double.tryParse('${row[column] ?? 0}') ?? 0),
      );
}
