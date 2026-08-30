import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/control_engine.dart';

void main() {
  test('negative balance creates high severity finding', () {
    final findings = ControlEngine.validateBalance(-8);
    expect(findings.single.code, 'NEGATIVE_STOCK');
    expect(findings.single.severity, 'HIGH');
  });

  test('valid balance has no finding', () {
    expect(ControlEngine.validateBalance(8), isEmpty);
  });

  test('mixed receive and issue is flagged', () {
    final findings = ControlEngine.validateQuantity(receive: 10, issue: 2);
    expect(findings.single.code, 'MIXED_MOVEMENT');
  });
}
