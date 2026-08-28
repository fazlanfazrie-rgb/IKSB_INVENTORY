import 'package:flutter_test/flutter_test.dart';
import '../lib/core/fuel_engine.dart';

void main() {
  test('fuel matrix normalizes 31 days and calculates total', () {
    final result = FuelEngine.calculate(
      charging: '3A-SYJ5997',
      daily: {1: 100, 5: 200, 31: 50},
    );
    expect(result.daily.length, 31);
    expect(result.total, 350);
    expect(result.avg, closeTo(350 / 3, 0.000001));
  });

  test('fuel matrix with no consumption has zero total and average', () {
    final result = FuelEngine.calculate(charging: 'UNIT-A', daily: {});
    expect(result.total, 0);
    expect(result.avg, 0);
  });
}
