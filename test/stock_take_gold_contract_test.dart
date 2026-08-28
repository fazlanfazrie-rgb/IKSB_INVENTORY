import 'package:flutter_test/flutter_test.dart';
import '../lib/core/stock_take_engine.dart';

void main() {
  test('stock take gold contract: variance/status rules', () {
    final cases = <({double system, double physical, double variance, String status})>[
      (system: 100, physical: 100, variance: 0, status: 'TALLY'),
      (system: 100, physical: 105, variance: 5, status: 'OVER'),
      (system: 100, physical: 95, variance: -5, status: 'SHORT'),
    ];
    for (final c in cases) {
      final r = StockTakeEngine.calculate(system: c.system, physical: c.physical);
      expect(r.variance, c.variance);
      expect(r.status, c.status);
    }
  });
}
