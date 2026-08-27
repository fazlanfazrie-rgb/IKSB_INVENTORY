enum TransactionType { cf, inTxn, outTxn }

TransactionType parseTransactionType(String value) {
  switch (value.trim().toUpperCase()) {
    case 'CF':
    case 'OPENING':
      return TransactionType.cf;
    case 'IN':
    case 'RECEIVE':
      return TransactionType.inTxn;
    case 'OUT':
    case 'ISSUE':
      return TransactionType.outTxn;
    default:
      throw ArgumentError('Unknown transaction type: $value');
  }
}

int transactionOrder(TransactionType type) {
  switch (type) {
    case TransactionType.cf:
      return 1;
    case TransactionType.inTxn:
      return 2;
    case TransactionType.outTxn:
      return 3;
  }
}

double transactionQuantity({
  required TransactionType type,
  double opening = 0,
  double receive = 0,
  double issue = 0,
}) {
  switch (type) {
    case TransactionType.cf:
      return opening;
    case TransactionType.inTxn:
      return receive;
    case TransactionType.outTxn:
      return -issue;
  }
}

double runningBalance(Iterable<double> quantities) {
  var balance = 0.0;
  for (final quantity in quantities) {
    balance += quantity;
  }
  return balance;
}
