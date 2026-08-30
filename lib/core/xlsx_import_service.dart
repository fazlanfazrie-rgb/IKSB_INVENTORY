import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class XlsxImportResult {
  const XlsxImportResult({
    required this.sheets,
    required this.items,
    required this.transactions,
    required this.errors,
  });

  final int sheets;
  final int items;
  final int transactions;
  final List<String> errors;
}

class XlsxImportService {
  static String _text(Data? cell) => '${cell?.value ?? ''}'.trim();

  static double _number(Data? cell) {
    final value = cell?.value;
    if (value is num) return (value as num).toDouble();
    return double.tryParse('${value ?? ''}'.replaceAll(',', '')) ?? 0;
  }

  static Map<String, int> _headers(List<Data?> row) {
    final map = <String, int>{};
    for (var i = 0; i < row.length; i++) {
      final key = _text(row[i]).toUpperCase();
      if (key.isNotEmpty) {
        map[key] = i;
      }
    }
    return map;
  }

  static String _at(
    List<Data?> row,
    Map<String, int> h,
    List<String> names,
  ) {
    for (final name in names) {
      final i = h[name];
      if (i != null && i < row.length) return _text(row[i]);
    }
    return '';
  }

  static double _numAt(
    List<Data?> row,
    Map<String, int> h,
    List<String> names,
  ) {
    for (final name in names) {
      final i = h[name];
      if (i != null && i < row.length) return _number(row[i]);
    }
    return 0;
  }

  static Future<XlsxImportResult> importBytes(Uint8List bytes) async {
    final book = Excel.decodeBytes(bytes);
    var items = 0;
    var transactions = 0;
    var sheets = 0;
    final errors = <String>[];
    final db = await DatabaseService.database;

    for (final entry in book.tables.entries) {
      sheets++;
      final sheetName = entry.key.toUpperCase();
      final rows = entry.value.rows;
      if (rows.isEmpty) continue;
      final h = _headers(rows.first);
      final itemCol = h['ITEM CODE'];
      if (itemCol == null) continue;

      final hasTransaction =
          h.containsKey('TRANX') ||
          h.containsKey('TRANX TYPE') ||
          h.containsKey('RECEIVE') ||
          h.containsKey('ISSUE') ||
          h.containsKey('OPENING');
      final hasItemMaster =
          h.containsKey('ITEM NAME') &&
          (h.containsKey('UOM') || h.containsKey('ITEM GROUP'));

      for (var r = 1; r < rows.length; r++) {
        final row = rows[r];
        final code = _at(row, h, const ['ITEM CODE']);
        if (code.isEmpty) continue;
        try {
          if (hasItemMaster) {
            final name = _at(row, h, const ['ITEM NAME']);
            final group = _at(row, h, const ['ITEM GROUP']);
            final uom = _at(row, h, const ['UOM']);
            await db.insert(
              'items',
              {
                'item_code': code,
                'item_name': name,
                'item_group': group,
                'uom': uom,
                'active': 1,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            items++;
          }

          if (hasTransaction) {
            final date = _at(row, h, const ['DATE']);
            if (date.isEmpty) continue;
            var tranx =
                _at(row, h, const ['TRANX', 'TRANX TYPE']).toUpperCase();
            final opening = _numAt(row, h, const ['OPENING']);
            final receive = _numAt(row, h, const ['RECEIVE']);
            final issue = _numAt(row, h, const ['ISSUE']);
            if (tranx.isEmpty) {
              tranx = opening != 0
                  ? 'CF'
                  : receive != 0
                      ? 'IN'
                      : issue != 0
                          ? 'OUT'
                          : '';
            }
            if (!const ['CF', 'IN', 'OUT'].contains(tranx)) continue;
            await db.insert('transactions', {
              'date': date,
              'item_code': code,
              'tranx': tranx,
              'doc_no': _at(row, h, const ['DOC NO', 'DOC NO.']),
              'charging': _at(row, h, const ['CHARGING']),
              'opening': opening,
              'receive': receive,
              'issue': issue,
              'remark': _at(row, h, const ['REMARK']),
              'created_at': DateTime.now().toIso8601String(),
            });
            transactions++;
          }
        } catch (e) {
          errors.add('$sheetName row ${r + 1}: $e');
        }
      }
    }

    return XlsxImportResult(
      sheets: sheets,
      items: items,
      transactions: transactions,
      errors: errors,
    );
  }
}
