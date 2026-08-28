enum ParityStatus { pass, fail }

class ParityResult {
  const ParityResult({required this.engine, required this.expectedRows, required this.actualRows, required this.mismatches});
  final String engine;
  final int expectedRows;
  final int actualRows;
  final List<String> mismatches;
  ParityStatus get status => mismatches.isEmpty && expectedRows == actualRows ? ParityStatus.pass : ParityStatus.fail;
}

/// Deterministic comparator for Excel-oracle versus native app output.
class MasterParityHarness {
  static ParityResult compare({
    required String engine,
    required List<Map<String, Object?>> expected,
    required List<Map<String, Object?>> actual,
    List<String>? keys,
    double tolerance = 0.000001,
  }) {
    final compareKeys = keys ?? _inferKeys(expected, actual);
    final mismatches = <String>[];
    final exp = _index(expected, compareKeys);
    final act = _index(actual, compareKeys);
    for (final key in {...exp.keys, ...act.keys}) {
      final e = exp[key];
      final a = act[key];
      if (e == null) { mismatches.add('$key: missing in Excel oracle'); continue; }
      if (a == null) { mismatches.add('$key: missing in app'); continue; }
      for (final column in {...e.keys, ...a.keys}) {
        if (!_equal(e[column], a[column], tolerance)) {
          mismatches.add('$key.$column: expected=${e[column]} actual=${a[column]}');
        }
      }
    }
    return ParityResult(engine: engine, expectedRows: expected.length, actualRows: actual.length, mismatches: mismatches);
  }

  static List<String> _inferKeys(List<Map<String, Object?>> a, List<Map<String, Object?>> b) {
    final sample = [...a, ...b];
    const candidates = ['DATE', 'ITEM CODE', 'TRANX', 'DOC NO', 'CHARGING', 'REFERENCE', 'index'];
    return candidates.where((c) => sample.any((r) => r.containsKey(c))).toList();
  }

  static Map<String, Map<String, Object?>> _index(List<Map<String, Object?>> rows, List<String> keys) {
    final out = <String, Map<String, Object?>>{};
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      final id = keys.isEmpty ? '$i' : keys.map((k) => '${r[k] ?? ''}').join('|');
      var unique = id;
      var n = 2;
      while (out.containsKey(unique)) unique = '$id|#$n++';
      out[unique] = r;
    }
    return out;
  }

  static bool _equal(Object? a, Object? b, double tolerance) {
    if (a == b) return true;
    final da = double.tryParse('$a');
    final db = double.tryParse('$b');
    if (da != null && db != null) return (da - db).abs() <= tolerance;
    return '$a'.trim() == '$b'.trim();
  }
}
