import 'package:flutter_test/flutter_test.dart';
import '../lib/core/parity_harness.dart';

void main() {
  test('master parity passes identical normalized rows', () {
    final rows = [
      {'DATE': '2026-08-01', 'ITEM CODE': '010001', 'TRANX': 'CF', 'BALANCE': 100.0},
      {'DATE': '2026-08-02', 'ITEM CODE': '010001', 'TRANX': 'IN', 'BALANCE': 150.0},
    ];
    final result = MasterParityHarness.compare(engine: 'Bin Card', expected: rows, actual: rows.map((r) => Map<String, Object?>.from(r)).toList());
    expect(result.status, ParityStatus.pass);
    expect(result.mismatches, isEmpty);
  });

  test('master parity catches numeric mismatch', () {
    final expected = [{'DATE': '2026-08-01', 'ITEM CODE': '010001', 'TRANX': 'OUT', 'ISSUE': 20.0}];
    final actual = [{'DATE': '2026-08-01', 'ITEM CODE': '010001', 'TRANX': 'OUT', 'ISSUE': 21.0}];
    final result = MasterParityHarness.compare(engine: 'Bin Card', expected: expected, actual: actual);
    expect(result.status, ParityStatus.fail);
    expect(result.mismatches, isNotEmpty);
  });

  test('master parity catches missing row', () {
    final expected = [{'DATE': '2026-08-01', 'ITEM CODE': '010001', 'TRANX': 'OUT'}];
    final result = MasterParityHarness.compare(engine: 'Bin Card', expected: expected, actual: []);
    expect(result.status, ParityStatus.fail);
    expect(result.mismatches, isNotEmpty);
  });
}
