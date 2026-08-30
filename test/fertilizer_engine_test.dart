import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/fertilizer_engine.dart';
import 'package:storeph3/core/fertilizer_weekly_engine.dart';

void main() {
  final items = [
    const FertilizerItem(code: '80058', name: 'FERT A', group: 'GROUP A', supplier: 'SUPPLIER A', uom: 'KG'),
  ];

  test('fertilizer lookup is code based', () {
    expect(FertilizerEngine.find(items, '80058')?.name, 'FERT A');
    expect(FertilizerEngine.find(items, 'UNKNOWN'), isNull);
  });

  test('fertilizer kg calculation', () {
    expect(FertilizerEngine.kg(quantity: 10, kgPerUnit: 50), 500);
  });

  test('Gold Aug-26 fertilizer weekly balance semantics', () {
    expect(
      FertilizerWeeklyEngine.balance(
        opening: 20.5,
        receive: 56.0,
        issue3A: 0,
        issue3B: 0,
      ),
      76.5,
    );
    expect(
      FertilizerWeeklyEngine.balance(
        opening: 76.5,
        receive: 84.0,
        issue3A: 0,
        issue3B: 0,
      ),
      160.5,
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
}
