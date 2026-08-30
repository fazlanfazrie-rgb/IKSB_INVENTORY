import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/fuel_engine.dart';

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

  test('Gold Aug-26 charging list has 38 unique machine/contractor entries', () {
    final rows = <Map<String, Object?>>[
      {'REFERENCE': 'MACHINE', 'CHARGING': '45-SSA4701A'},
      {'REFERENCE': 'MACHINE', 'CHARGING': '45-SSA4701A'},
      {'REFERENCE': 'CONTRACTOR', 'CHARGING': 'S. MANDIRI'},
      {'REFERENCE': 'STORE', 'CHARGING': 'IGNORED'},
    ];
    expect(FuelEngine.chargingList(rows), ['45-SSA4701A', 'S. MANDIRI']);
  });

  test('Gold Aug-26 45-SSA4701A daily issue and status', () {
    final rows = <Map<String, Object?>>[
      {
        'DATE': '2026-08-01',
        'ITEM CODE': '010001',
        'TRANX': 'OUT',
        'CHARGING': '45-SSA4701A',
        'ISSUE': 50.0,
      },
      {
        'DATE': '2026-08-03',
        'ITEM CODE': '010001',
        'TRANX': 'OUT',
        'CHARGING': '45-SSA4701A',
        'ISSUE': 60.0,
      },
      {
        'DATE': '2026-08-05',
        'ITEM CODE': '010001',
        'TRANX': 'OUT',
        'CHARGING': '45-SSA4701A',
        'ISSUE': 70.0,
      },
    ];
    expect(
      FuelEngine.issue(
        rows: rows,
        period: DateTime(2026, 8),
        day: 1,
        charging: '45-SSA4701A',
      ),
      50.0,
    );

    final result = FuelEngine.calculate(
      charging: '45-SSA4701A',
      daily: {
        1: 50,
        3: 60,
        5: 70,
        8: 50,
        10: 60,
        11: 70,
        12: 30,
        16: 20,
        24: 70,
        25: 30,
        26: 50,
      },
    );
    expect(result.total, 560);
    expect(result.avg, closeTo(560 / 11, 0.0000001));
    expect(result.status, 'HIGH');
  });
}
