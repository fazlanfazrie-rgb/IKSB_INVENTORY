import 'package:flutter_test/flutter_test.dart';
import 'package:storeph3/core/date_engine.dart';
import 'package:storeph3/core/transaction_engine.dart';

void main() {
  group('Transaction engine golden rules', () {
    test('CF, IN, OUT order is 1, 2, 3', () {
      expect(transactionOrder(TransactionType.cf), 1);
      expect(transactionOrder(TransactionType.inTxn), 2);
      expect(transactionOrder(TransactionType.outTxn), 3);
    });

    test('transaction quantity preserves Excel business logic', () {
      expect(transactionQuantity(type: TransactionType.cf, opening: 100), 100);
      expect(transactionQuantity(type: TransactionType.inTxn, receive: 250), 250);
      expect(transactionQuantity(type: TransactionType.outTxn, issue: 80), -80);
    });

    test('running balance equals opening + receive - issue', () {
      final values = <double>[
        transactionQuantity(type: TransactionType.cf, opening: 1000),
        transactionQuantity(type: TransactionType.inTxn, receive: 500),
        transactionQuantity(type: TransactionType.outTxn, issue: 200),
      ];
      expect(runningBalance(values), 1300);
    });
  });

  group('Date engine golden rules', () {
    test('period uses MMM-YY', () {
      expect(periodKey(DateTime(2026, 8, 28)), 'AUG-26');
      expect(periodKey(DateTime(2026, 1, 1)), 'JAN-26');
    });

    test('week uses 1ST, 2ND, 3RD, 4TH day bands', () {
      expect(weekKey(DateTime(2026, 8, 7)), '1ST');
      expect(weekKey(DateTime(2026, 8, 14)), '2ND');
      expect(weekKey(DateTime(2026, 8, 21)), '3RD');
      expect(weekKey(DateTime(2026, 8, 28)), '4TH');
    });
  });
}
