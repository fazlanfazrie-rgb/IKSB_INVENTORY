import 'inventory_engine.dart';
import 'transaction_engine.dart';

class DbInventoryMapper {
  static InventoryRow fromRow(Map<String, Object?> row) {
    final rawDate = row['date'] ?? row['DATE'];
    final date = rawDate is DateTime ? rawDate : DateTime.tryParse('$rawDate');
    if (date == null) throw ArgumentError('Invalid transaction date: $rawDate');
    final type = parseTransactionType('${row['tranx'] ?? row['TRANX'] ?? row['TRANX TYPE'] ?? ''}');
    return InventoryRow(
      date: date,
      itemCode: '${row['item_code'] ?? row['ITEM CODE'] ?? ''}'.trim(),
      type: type,
      opening: _number(row['opening'] ?? row['OPENING']),
      receive: _number(row['receive'] ?? row['RECEIVE']),
      issue: _number(row['issue'] ?? row['ISSUE']),
      balance: _number(row['balance'] ?? row['BALANCE']),
    );
  }

  static List<InventoryRow> ordered(Iterable<Map<String, Object?>> rows) {
    final mapped = rows.map(fromRow).toList();
    mapped.sort((a, b) {
      final date = a.date.compareTo(b.date);
      if (date != 0) return date;
      final item = a.itemCode.compareTo(b.itemCode);
      if (item != 0) return item;
      return transactionOrder(a.type).compareTo(transactionOrder(b.type));
    });
    return mapped;
  }

  static double _number(Object? value) => double.tryParse('${value ?? 0}') ?? 0;
}
