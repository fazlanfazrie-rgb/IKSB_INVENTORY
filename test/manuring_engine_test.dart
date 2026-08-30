import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/manuring_engine.dart';

void main() {
  test('manuring pending', () {
    final r = ManuringEngine.calculate(planned: 100, issued: 40);
    expect(r.balance, 60);
    expect(r.progress, 40);
    expect(r.status, 'PENDING');
  });

  test('manuring completed', () {
    final r = ManuringEngine.calculate(planned: 100, issued: 100);
    expect(r.balance, 0);
    expect(r.progress, 100);
    expect(r.status, 'COMPLETED');
  });

  test('manuring over applied', () {
    final r = ManuringEngine.calculate(planned: 100, issued: 110);
    expect(r.balance, -10);
    expect(r.progress, closeTo(110, 0.0000001));
    expect(r.status, 'OVER APPLIED');
  });
}
