import 'package:flutter_test/flutter_test.dart';
import 'package:tranx_store/core/date_engine.dart';
import 'package:tranx_store/core/transaction_engine.dart';

void main() {
  group('Transaction engine golden rules', () {
    test('CF, IN, OUT order is 1, 2, 3', () {
      expect(transactionOrder(TransactionType.cf), 1);
      expect(transactionOrder(TransactionType.inTxn), 2);
      expect(transactionOrder(TransactionType.outTxn), 3);
    });

    test('transaction quantities have correct signs', () {
      expect(transactionQuantity(type: TransactionType.cf, opening: 10), 10);
      expect(transactionQuantity(type: TransactionType.inTxn, receive: 10), 10);
      expect(transactionQuantity(type: TransactionType.outTxn, issue: 10), -10);
    });

    test('running balance is deterministic', () {
      expect(runningBalance([100, 10, -20, 5]), 95);
      expect(runningBalance([10, -5]), 5);
    });

    test('period key uses month period label', () {
      expect(periodKey(DateTime(2026, 8, 28)), 'AUG-26');
      expect(periodKey(DateTime(2026, 1, 15)), 'JAN-26');
    });

    test('week key follows 1ST to 4TH rule', () {
      expect(weekKey(DateTime(2026, 8, 1)), '1ST');
      expect(weekKey(DateTime(2026, 8, 8)), '2ND');
      expect(weekKey(DateTime(2026, 8, 15)), '3RD');
      expect(weekKey(DateTime(2026, 8, 22)), '4TH');
    });
  });
}
