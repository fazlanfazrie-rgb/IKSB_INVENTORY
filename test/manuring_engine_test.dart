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

  test('Gold AEX33 2nd round broadcast is completed', () {
    final rows = <Map<String, Object?>>[
      {
        'TRANX': 'OUT',
        'CHARGING': 'AEX33 B/CAST',
        'ITEM GROUP': 'NK 13.5/27.6+1B',
        'REMARK': '2nd ROUND BROADCAST',
        'ISSUE': 11750.0,
      },
    ];
    final issue = ManuringEngine.issueFromDb(
      rows: rows,
      charging: 'AEX33 B/CAST',
      fertGroup: 'NK 13.5/27.6+1B',
      remark: '2nd ROUND BROADCAST',
      size: 50,
      category: '3A',
    );
    expect(issue, 235.0);

    final result = ManuringEngine.calculate(planned: 235, issued: issue);
    expect(result.balance, 0);
    expect(result.progress, 1.0);
    expect(result.status, 'COMPLETED');
  });

  test('Gold B17 2nd round broadcast preserves Excel over-applied rule', () {
    final result = ManuringEngine.calculate(planned: 233, issued: 692);
    expect(result.balance, -459);
    expect(result.progress, closeTo(692 / 233, 0.0000001));
    expect(result.status, 'OVER APPLIED');
  });
}
