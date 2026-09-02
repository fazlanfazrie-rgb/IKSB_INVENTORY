import 'package:flutter_test/flutter_test.dart';
import 'package:tranx_store/core/report_engine.dart';

void main() {
  final rows = <Map<String, Object?>>[
    {'DATE': '2026-08-01', 'ITEM CODE': 'A', 'SUPPLIER': 'S1', 'CHARGING': 'C1', 'RECEIVE': 100},
    {'DATE': '2026-08-02', 'ITEM CODE': 'B', 'SUPPLIER': 'S2', 'CHARGING': 'C1', 'RECEIVE': 50},
    {'DATE': '2026-08-03', 'ITEM CODE': 'A', 'SUPPLIER': 'S1', 'CHARGING': 'C2', 'RECEIVE': 25},
  ];

  test('report filters by item and date', () {
    final result = ReportEngine.filter(rows: rows, itemCode: 'A', from: DateTime(2026, 8, 1), to: DateTime(2026, 8, 2));
    expect(result.length, 1);
    expect(result.first['RECEIVE'], 100);
  });

  test('report total is deterministic', () {
    expect(ReportEngine.total(rows, 'RECEIVE'), 175);
  });
}
