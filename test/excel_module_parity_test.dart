import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/fertilizer_weekly_engine.dart';
import 'package:storeph3/core/fuel_engine.dart';
import 'package:storeph3/core/manuring_engine.dart';
import 'package:storeph3/core/month_engine.dart';
import 'package:storeph3/core/report_engine.dart';

void main() {
  final rows = <Map<String, Object?>>[
    {
      'DATE': '2026-07-31',
      'ITEM CODE': '80054',
      'ITEM NAME': 'UNION.H NK',
      'ITEM GROUP': 'NK 13.5/27.6+1B',
      'UOM': 'KG',
      'TRANX': 'CF',
      'OPENING': 10000,
      'RECEIVE': 0,
      'ISSUE': 0,
      'BALANCE': 10000,
      'CHARGING': '',
      'CATEGORY': '',
      'REFERENCE': '',
      'REMARK': 'CARRY FORWARD STOCK',
    },
    {
      'DATE': '2026-08-03',
      'ITEM CODE': '80054',
      'ITEM NAME': 'UNION.H NK',
      'ITEM GROUP': 'NK 13.5/27.6+1B',
      'UOM': 'KG',
      'TRANX': 'IN',
      'OPENING': 0,
      'RECEIVE': 5000,
      'ISSUE': 0,
      'BALANCE': 15000,
      'WEEK': '1ST',
      'CHARGING': '',
      'CATEGORY': '',
      'REFERENCE': '',
      'REMARK': 'RECEIVED STOCK',
    },
    {
      'DATE': '2026-08-05',
      'ITEM CODE': '80054',
      'ITEM NAME': 'UNION.H NK',
      'ITEM GROUP': 'NK 13.5/27.6+1B',
      'UOM': 'KG',
      'TRANX': 'OUT',
      'OPENING': 0,
      'RECEIVE': 0,
      'ISSUE': 2000,
      'BALANCE': 13000,
      'WEEK': '1ST',
      'CHARGING': 'A01 B/CAST',
      'CATEGORY': '3A',
      'REFERENCE': '',
      'REMARK': 'FIRST ROUND BROADCAST',
    },
    {
      'DATE': '2026-08-06',
      'ITEM CODE': '010001',
      'ITEM NAME': 'DIESEL',
      'ITEM GROUP': 'FUEL',
      'UOM': 'LTR',
      'TRANX': 'OUT',
      'OPENING': 0,
      'RECEIVE': 0,
      'ISSUE': 60,
      'BALANCE': 0,
      'CHARGING': '45-SSA4701A',
      'CATEGORY': '',
      'REFERENCE': 'MACHINE',
      'REMARK': 'VEHICLE',
    },
    {
      'DATE': '2026-08-07',
      'ITEM CODE': '80054',
      'ITEM NAME': 'UNION.H NK',
      'ITEM GROUP': 'NK 13.5/27.6+1B',
      'UOM': 'KG',
      'TRANX': 'OUT',
      'OPENING': 0,
      'RECEIVE': 0,
      'ISSUE': 1000,
      'BALANCE': 12000,
      'WEEK': '1ST',
      'CHARGING': 'A01 B/CAST',
      'CATEGORY': '3B',
      'REFERENCE': '',
      'REMARK': 'FIRST ROUND BROADCAST',
    },
  ];

  final master = <Map<String, Object?>>[
    {
      'ITEM CODE': '80054',
      'ITEM NAME': 'UNION.H NK',
      'ITEM GROUP': 'NK 13.5/27.6+1B',
      'UOM': 'KG',
    },
    {
      'ITEM CODE': '010001',
      'ITEM NAME': 'DIESEL',
      'ITEM GROUP': 'FUEL',
      'UOM': 'LTR',
    },
  ];

  test('month engine mirrors OPENING_MONTH and MONTH_CLOSING', () {
    expect(
      MonthEngine.opening(
        rows: rows,
        itemCode: '80054',
        period: DateTime(2026, 8),
      ),
      10000,
    );
    expect(
      MonthEngine.receive(
        rows: rows,
        itemCode: '80054',
        period: DateTime(2026, 8),
      ),
      5000,
    );
    expect(
      MonthEngine.issue(
        rows: rows,
        itemCode: '80054',
        period: DateTime(2026, 8),
      ),
      3000,
    );
    expect(
      MonthEngine.closing(
        rows: rows,
        itemCode: '80054',
        period: DateTime(2026, 8),
      ),
      12000,
    );
  });

  test('fertilizer weekly engine mirrors FW formulas', () {
    expect(
      FertilizerWeeklyEngine.opening(
        rows: rows,
        itemGroup: 'NK 13.5/27.6+1B',
        period: DateTime(2026, 8),
      ),
      10,
    );
    expect(
      FertilizerWeeklyEngine.receive(
        rows: rows,
        itemGroup: 'NK 13.5/27.6+1B',
        week: '1ST',
        period: DateTime(2026, 8),
      ),
      5,
    );
    expect(
      FertilizerWeeklyEngine.issue(
        rows: rows,
        itemGroup: 'NK 13.5/27.6+1B',
        week: '1ST',
        category: '3A',
        period: DateTime(2026, 8),
      ),
      2,
    );
    expect(
      FertilizerWeeklyEngine.issue(
        rows: rows,
        itemGroup: 'NK 13.5/27.6+1B',
        week: '1ST',
        category: '3B',
        period: DateTime(2026, 8),
      ),
      1,
    );
    expect(
      FertilizerWeeklyEngine.balance(
        opening: 10,
        receive: 5,
        issue3A: 2,
        issue3B: 1,
      ),
      12,
    );
    expect(
      FertilizerWeeklyEngine.balance(
        opening: 0,
        receive: 0,
        issue3A: 0,
        issue3B: 0,
      ),
      '-',
    );
  });

  test('manuring issue engine mirrors MNR_ISSUE', () {
    final issue = ManuringEngine.issueFromDb(
      rows: rows,
      charging: 'A01 B/CAST',
      fertGroup: 'NK 13.5/27.6+1B',
      remark: 'FIRST ROUND BROADCAST',
      size: 50,
      category: 'IGNORED_BY_EXCEL_FORMULA',
    );
    expect(issue, 60);
  });

  test('fuel engine mirrors FUL_CHARGING, FUL_ISSUE and status', () {
    expect(FuelEngine.chargingList(rows), ['45-SSA4701A']);
    final result = FuelEngine.fromRows(
      rows: rows,
      period: DateTime(2026, 8),
      charging: '45-SSA4701A',
    );
    expect(result.daily[6], 60);
    expect(result.total, 60);
    expect(result.avg, 60);
    expect(result.status, 'HIGH');
  });

  test('report engine mirrors Excel date/code/doc ordering', () {
    final receive = ReportEngine.receive(
      rows: rows,
      period: DateTime(2026, 8),
      itemMaster: master,
    );
    final issue = ReportEngine.issue(
      rows: rows,
      period: DateTime(2026, 8),
      itemMaster: master,
    );

    expect(receive.length, 1);
    expect(receive.single['ITEM CODE'], '80054');
    expect(receive.single['ITEM NAME'], 'UNION.H NK');
    expect(receive.single['ITEM GROUP'], 'NK 13.5/27.6+1B');
    expect(receive.single['UOM'], 'KG');
    expect(receive.single['RECEIVE'], 5000);

    expect(issue.length, 3);
    expect(issue[0]['ITEM CODE'], '80054');
    expect(issue[1]['ITEM CODE'], '010001');
    expect(issue[2]['ITEM CODE'], '80054');
  });
}
