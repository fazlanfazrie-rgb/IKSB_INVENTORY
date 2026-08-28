import 'package:flutter_test/flutter_test.dart';
import '../lib/core/stock_take_engine.dart';

void main() {
  test('stock take parity: tally', () {
    final r = StockTakeEngine.calculate(system: 100, physical: 100);
    expect(r.variance, 0);
    expect(r.status, 'TALLY');
  });
  test('stock take parity: over', () {
    final r = StockTakeEngine.calculate(system: 100, physical: 105);
    expect(r.variance, 5);
    expect(r.status, 'OVER');
  });
  test('stock take parity: short', () {
    final r = StockTakeEngine.calculate(system: 100, physical: 95);
    expect(r.variance, -5);
    expect(r.status, 'SHORT');
  });
}
