import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/stock_take_engine.dart';

const excelAug26System = <String, double>{
  '010001': 8625, '020001': 398, '020002': 353, '020003': 0,
  '020012': 5, '020014': 4, '020015': 1, '020016': 321,
  '030013': 340, '030019': 0, '030023': 0, '030025': 0,
  '030029': 200, '030030': 0, '030038': 1702, '060003': 174,
  '070003': 4, '070005': 2, '070006': 1, '070008': 0, '070009': -8,
  '070014': 9, '070017': 10, '070018': 1, '070019': 6, '070021': 3,
  '070022': 5, '070023': 3, '070024': 2, '070025': 15, '070026': 8,
  '070027': 21, '070029': 9, '071007': 1, '071008': 8, '071017': 0,
  '080001': 14650, '080008': 5475, '080019': 0, '080035': 32450,
  '080050': 0, '080054': 104500, '080055': 0, '080056': 0,
  '080057': 128000, '080058': 78000, '080059': 137050, '080060': 4000,
  '090001': 7, '090002': 6, '090005': -2, '090009': 8, '090010': 4,
  '090011': 1, '090037': 0, '090038': 8, '090042': 10, '090043': 4,
  '090044': 15, '090045': 8, '090046': 8, '090047': 3, '090048': 10,
  '090049': 10, '090051': -1, '090052': 5, '090053': 6, '090054': 5,
  '090055': 7, '090059': 0, '090060': 10, '090061': 2, '090062': 2,
  '090063': 15, '090064': 19, '090066': 0, '090067': 0, '090068': 6,
  '090069': 5, '090070': 2, '090071': 3, '090072': 3, '990004': 6,
  '990034': 2, '990035': 2,
};

void main() {
  test('stock take gold contract: variance/status rules', () {
    final cases = <({double system, double physical, double variance, String status})>[
      (system: 100, physical: 100, variance: 0, status: 'TALLY'),
      (system: 100, physical: 105, variance: 5, status: 'OVER'),
      (system: 100, physical: 95, variance: -5, status: 'SHORT'),
    ];
    for (final c in cases) {
      final r = StockTakeEngine.calculate(system: c.system, physical: c.physical);
      expect(r.variance, c.variance);
      expect(r.status, c.status);
    }
  });

  test('August 2026 Excel Oracle contains exactly 85 stock-take items', () {
    expect(excelAug26System.length, 85);
    expect(excelAug26System['010001'], 8625);
    expect(excelAug26System['080054'], 104500);
    expect(excelAug26System['080059'], 137050);
    expect(excelAug26System.values.reduce((a, b) => a + b), 516547);
  });

  test('August 2026 Oracle values satisfy StockTakeEngine identity', () {
    for (final entry in excelAug26System.entries) {
      final r = StockTakeEngine.calculate(
        system: entry.value,
        physical: entry.value,
      );
      expect(r.variance, 0, reason: entry.key);
      expect(r.status, 'TALLY', reason: entry.key);
    }
  });
}
