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
      expect(transactionQuantity(TransactionType.cf, 10), 10);
      expect(transactionQuantity(TransactionType.inTxn, 10), 10);
      expect(transactionQuantity(TransactionType.outTxn, 10), -10);
    });

    test('running balance is deterministic', () {
      expect(runningBalance(100, [10, -20, 5]), 95);
      expect(runningBalance(0, [10, -5]), 5);
    });

    test('period key uses first day of month', () {
      expect(periodKey(DateTime(2026, 8, 28)), DateTime(2026, 8, 1));
      expect(periodKey(DateTime(2026, 1, 15)), DateTime(2026, 1, 1));
    });

    test('week key follows 1ST to 4TH rule', () {
      expect(weekKey(DateTime(2026, 8, 1)), '1ST');
      expect(weekKey(DateTime(2026, 8, 8)), '2ND');
      expect(weekKey(DateTime(2026, 8, 15)), '3RD');
      expect(weekKey(DateTime(2026, 8, 22)), '4TH');
    });
  });
}
