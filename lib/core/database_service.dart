import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = p.join(await getDatabasesPath(), 'storeph3.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items (
            item_code TEXT PRIMARY KEY,
            item_name TEXT NOT NULL,
            item_group TEXT NOT NULL DEFAULT '',
            uom TEXT NOT NULL DEFAULT '',
            active INTEGER NOT NULL DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            item_code TEXT NOT NULL,
            tranx TEXT NOT NULL,
            doc_no TEXT NOT NULL DEFAULT '',
            charging TEXT NOT NULL DEFAULT '',
            opening REAL NOT NULL DEFAULT 0,
            receive REAL NOT NULL DEFAULT 0,
            issue REAL NOT NULL DEFAULT 0,
            remark TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            FOREIGN KEY(item_code) REFERENCES items(item_code)
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_transactions_item_date ON transactions(item_code, date)',
        );
        await db.execute(
          'CREATE INDEX idx_transactions_tranx ON transactions(tranx)',
        );
      },
    );
    return _database!;
  }

  static Future<List<Map<String, Object?>>> inventory() async {
    final db = await database;
    return db.rawQuery('''
      SELECT i.item_code, i.item_name, i.uom,
        COALESCE(SUM(t.opening + t.receive - t.issue), 0) AS balance
      FROM items i
      LEFT JOIN transactions t ON t.item_code = i.item_code
      WHERE i.active = 1
      GROUP BY i.item_code, i.item_name, i.uom
      ORDER BY i.item_code
    ''');
  }

  static Future<int> insertTransaction({
    required String date,
    required String itemCode,
    required String tranx,
    required double opening,
    required double receive,
    required double issue,
    String docNo = '',
    String charging = '',
    String remark = '',
  }) async {
    if (tranx != 'CF' && tranx != 'IN' && tranx != 'OUT') {
      throw ArgumentError('Transaction must be CF, IN or OUT');
    }
    if (tranx == 'OUT' && issue <= 0) {
      throw ArgumentError('Issue quantity must be greater than zero');
    }
    if (tranx == 'IN' && receive <= 0) {
      throw ArgumentError('Receive quantity must be greater than zero');
    }

    final db = await database;
    return db.transaction((txn) async {
      final item = await txn.query(
        'items',
        columns: ['item_code'],
        where: 'item_code = ?',
        whereArgs: [itemCode],
        limit: 1,
      );
      if (item.isEmpty) throw ArgumentError('Unknown item: $itemCode');

      if (tranx == 'OUT') {
        final rows = await txn.rawQuery('''
          SELECT COALESCE(SUM(opening + receive - issue), 0) AS balance
          FROM transactions WHERE item_code = ?
        ''', [itemCode]);
        final balance = (rows.first['balance'] as num).toDouble();
        if (issue > balance) {
          throw StateError('Insufficient stock: $balance available');
        }
      }

      return txn.insert('transactions', {
        'date': date,
        'item_code': itemCode,
        'tranx': tranx,
        'doc_no': docNo,
        'charging': charging,
        'opening': opening,
        'receive': receive,
        'issue': issue,
        'remark': remark,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }
}
