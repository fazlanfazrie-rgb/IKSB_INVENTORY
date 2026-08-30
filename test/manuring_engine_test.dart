import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/manuring_engine.dart';

void main() {
  test('manuring pending follows Excel MNR_PROGRESS fraction', () {
    final r = ManuringEngine.calculate(planned: 100, issued: 40);
    expect(r.balance, 60);
    expect(r.progress, 0.4);
    expect(r.status, 'PENDING');
  });

  test('manuring completed follows Excel MNR_PROGRESS fraction', () {
    final r = ManuringEngine.calculate(planned: 100, issued: 100);
    expect(r.balance, 0);
    expect(r.progress, 1.0);
    expect(r.status, 'COMPLETED');
  });

  test('manuring over applied follows Excel MNR_PROGRESS fraction', () {
    final r = ManuringEngine.calculate(planned: 100, issued: 110);
    expect(r.balance, -10);
    expect(r.progress, closeTo(1.1, 0.0000001));
    expect(r.status, 'OVER APPLIED');
  });
}
