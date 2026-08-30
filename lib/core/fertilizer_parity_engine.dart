import 'fertilizer_engine.dart';

class FertilizerLedgerResult {
  const FertilizerLedgerResult({required this.item, required this.receive, required this.issue});
  final FertilizerItem item;
  final double receive;
  final double issue;
  double get balance => receive - issue;
}

/// Deterministic fertilizer aggregation over normalized TBL_DB rows.
class FertilizerParityEngine {
  static List<FertilizerLedgerResult> aggregate({
    required List<Map<String, Object?>> rows,
    required List<FertilizerItem> master,
  }) {
    final totals = <String, List<double>>{};
    for (final row in rows) {
      final code = '${row['ITEM CODE'] ?? row['item_code'] ?? ''}'.trim();
      if (code.isEmpty) continue;
      final bucket = totals.putIfAbsent(code, () => [0, 0]);
      bucket[0] += _number(row['RECEIVE'] ?? row['receive']);
      bucket[1] += _number(row['ISSUE'] ?? row['issue']);
    }
    final result = <FertilizerLedgerResult>[];
    for (final entry in totals.entries) {
      final item = FertilizerEngine.find(master, entry.key);
      if (item == null) continue;
      result.add(FertilizerLedgerResult(item: item, receive: entry.value[0], issue: entry.value[1]));
    }
    result.sort((a, b) => a.item.code.compareTo(b.item.code));
    return result;
  }

  static double _number(Object? value) => double.tryParse('${value ?? 0}') ?? 0;
}
