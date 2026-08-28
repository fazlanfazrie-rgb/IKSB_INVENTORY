import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production seed manifest is present', () {
    final file = File('assets/production_seed.json');
    expect(file.existsSync(), isTrue);
    final text = file.readAsStringSync();
    expect(text, contains('BINCARD_STOREPH3_FINAL.xlsx'));
    expect(text, contains('01_TRANX_DB'));
    expect(text, contains('20_ITEM_MASTER'));
  });
}
