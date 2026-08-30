import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/control_engine.dart';

void main() {
  final rows = <Map<String, Object?>>[
    {'DATE': '2026-07-31', 'ITEM CODE': 'A', 'TRANX': 'CF', 'OPENING': 100},
    {'DATE': '2026-08-05', 'ITEM CODE': 'A', 'TRANX': 'OUT', 'ISSUE': 10},
  ];

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

  test('CF control follows Excel monthly status rules', () {
    expect(
      ControlEngine.cfControl(rows: rows, itemCode: 'A', period: DateTime(2026, 7)),
      'INITIAL CF',
    );
    expect(
      ControlEngine.cfControl(rows: rows, itemCode: 'A', period: DateTime(2026, 8)),
      'OK - AUTO',
    );
    expect(
      ControlEngine.cfControl(rows: rows, itemCode: 'A', period: DateTime(2026, 6)),
      'NOT STARTED',
    );
    expect(
      ControlEngine.cfControl(rows: rows, itemCode: 'UNKNOWN', period: DateTime(2026, 8)),
      'NO INITIAL CF',
    );
  });

  test('initial opening mirrors first CF month', () {
    expect(ControlEngine.initialOpening(rows: rows, itemCode: 'A'), 100);
    expect(ControlEngine.initialOpening(rows: rows, itemCode: 'UNKNOWN'), isNull);
  });
}
