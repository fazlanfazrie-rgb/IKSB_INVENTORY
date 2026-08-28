import 'package:flutter_test/flutter_test.dart';
import '../lib/core/fertilizer_engine.dart';

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
}
