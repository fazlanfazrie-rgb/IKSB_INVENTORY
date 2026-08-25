import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class StoreDb {
  static final StoreDb instance = StoreDb._();
  StoreDb._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getDatabasesPath();
    final path = join(dir, 'storeph3.db');
    _db = await openDatabase(path, version: 3, onCreate: (db, _) async {
      await _schema(db);
      await _seed(db);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      await _schema(db);
    });
    return _db!;
  }

  Future<void> _schema(Database db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS items(
      item_code TEXT PRIMARY KEY, item_name TEXT NOT NULL, item_group TEXT,
      uom TEXT, active INTEGER NOT NULL DEFAULT 1)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS transactions(
      id INTEGER PRIMARY KEY AUTOINCREMENT, date_text TEXT, period TEXT, week TEXT,
      item_code TEXT NOT NULL, item_name TEXT NOT NULL, item_group TEXT, uom TEXT,
      tranx TEXT NOT NULL, doc_no TEXT NOT NULL, charging TEXT, category TEXT,
      reference TEXT, opening REAL NOT NULL DEFAULT 0, receive REAL NOT NULL DEFAULT 0,
      issue REAL NOT NULL DEFAULT 0, remark TEXT, created_at INTEGER NOT NULL,
      created_by TEXT NOT NULL DEFAULT 'SYSTEM', device_id TEXT NOT NULL DEFAULT 'OFFLINE-DEVICE',
      CHECK(opening>=0 AND receive>=0 AND issue>=0), CHECK(receive=0 OR issue=0))''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_item ON transactions(item_code)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_doc ON transactions(doc_no)');
    await db.execute('''CREATE TABLE IF NOT EXISTS stock_take(
      id INTEGER PRIMARY KEY AUTOINCREMENT, item_code TEXT NOT NULL, period TEXT NOT NULL,
      system_balance REAL NOT NULL, physical_count REAL NOT NULL, variance REAL NOT NULL,
      status TEXT NOT NULL, updated_at INTEGER NOT NULL, updated_by TEXT NOT NULL DEFAULT 'SYSTEM',
      UNIQUE(item_code,period))''');
    await db.execute('''CREATE TABLE IF NOT EXISTS audit_log(
      id INTEGER PRIMARY KEY AUTOINCREMENT, action TEXT NOT NULL, entity TEXT NOT NULL,
      entity_id TEXT, details TEXT, created_at INTEGER NOT NULL,
      created_by TEXT NOT NULL DEFAULT 'SYSTEM', device_id TEXT NOT NULL DEFAULT 'OFFLINE-DEVICE')''');
    await db.execute('''CREATE TABLE IF NOT EXISTS users(
      user_id TEXT PRIMARY KEY, display_name TEXT NOT NULL, role TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS app_settings(
      key TEXT PRIMARY KEY, value TEXT NOT NULL)''');
    await db.insert('users', {'user_id':'SYSTEM','display_name':'System User','role':'ADMIN','active':1}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('app_settings', {'key':'schema_version','value':'3'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('app_settings', {'key':'app_status','value':'OFFLINE-FIRST'}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _seed(Database db) async {
    final ic = jsonDecode(await rootBundle.loadString('assets/data/items.json')) as List;
    final txPayload = jsonDecode(await rootBundle.loadString('assets/data/transactions.json')) as Map<String,dynamic>;
    final rows = List<List<dynamic>>.from(txPayload['rows']);
    if ((await db.query('items')).isEmpty) {
      final batch = db.batch();
      for (final x in ic) {
        final m = Map<String,dynamic>.from(x);
        if ((m['code'] ?? '').toString().trim().isEmpty || (m['name'] ?? '').toString().trim().isEmpty) continue;
        batch.insert('items', {'item_code':m['code'].toString().trim(),'item_name':m['name'].toString().trim(),'item_group':m['group'],'uom':m['uom'],'active':1}, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult:true);
    }
    if ((await db.query('transactions')).isEmpty) {
      final batch = db.batch();
      for (final r in rows) {
        if (r.length < 15) continue;
        String s(int i) => i < r.length && r[i] != null ? r[i].toString() : '';
        double n(int i) => double.tryParse(s(i)) ?? 0;
        final code = s(3), name = s(4), tranx = s(7);
        final opening=n(12), receive=n(13), issue=n(14);
        if (code.trim().isEmpty || name.trim().isEmpty) continue;
        if (opening==0 && receive==0 && issue==0 && tranx.trim().isEmpty) continue;
        final doc = s(8).trim().isEmpty ? 'LEGACY-${s(0)}-$code' : s(8).trim();
        batch.insert('transactions', {
          'date_text':s(0),'period':s(1),'week':s(2),'item_code':code,'item_name':name,
          'item_group':s(5),'uom':s(6),'tranx':tranx,'doc_no':doc,'charging':s(9),
          'category':s(10),'reference':s(11),'opening':opening < 0 ? 0 : opening,
          'receive':receive < 0 ? 0 : receive,'issue':issue < 0 ? 0 : issue,'remark':s(16),
          'created_at':DateTime.now().millisecondsSinceEpoch,'created_by':'MIGRATION','device_id':'OFFLINE-DEVICE'
        });
      }
      await batch.commit(noResult:true);
    }
    await audit('MIGRATION','DATABASE','seed','items=${(await db.query('items')).length};transactions=${(await db.query('transactions')).length}');
  }

  Future<void> audit(String action,String entity,String id,String details) async {
    final d = await db;
    await d.insert('audit_log', {'action':action,'entity':entity,'entity_id':id,'details':details,'created_at':DateTime.now().millisecondsSinceEpoch,'created_by':'SYSTEM','device_id':'OFFLINE-DEVICE'});
  }

  Future<double> balance(String code) async {
    final d = await db;
    final r = await d.rawQuery('SELECT COALESCE(SUM(opening),0)+COALESCE(SUM(receive),0)-COALESCE(SUM(issue),0) AS b FROM transactions WHERE item_code=?',[code]);
    return (r.first['b'] as num?)?.toDouble() ?? 0;
  }

  Future<void> insertTransaction({required String itemCode, required String itemName, required String tranx, required String docNo, double opening=0, double receive=0, double issue=0, String charging='', String remark=''}) async {
    if (itemCode.trim().isEmpty) throw Exception('Item code is required');
    if (docNo.trim().isEmpty) throw Exception('Document No. is required');
    if (opening < 0 || receive < 0 || issue < 0) throw Exception('Quantity cannot be negative');
    final movements = (opening>0?1:0)+(receive>0?1:0)+(issue>0?1:0);
    if (movements != 1) throw Exception('Transaction must contain exactly one movement type');
    if (issue>0 && await balance(itemCode) < issue) throw Exception('Issue exceeds current system balance');
    final d = await db;
    final id = await d.insert('transactions', {'date_text':DateTime.now().toIso8601String(),'period':'CURRENT','week':'','item_code':itemCode,'item_name':itemName,'item_group':'','uom':'','tranx':tranx,'doc_no':docNo,'charging':charging,'category':'','reference':'','opening':opening,'receive':receive,'issue':issue,'remark':remark,'created_at':DateTime.now().millisecondsSinceEpoch,'created_by':'SYSTEM','device_id':'OFFLINE-DEVICE'});
    await audit('CREATE','TRANSACTION','$id','$tranx $itemCode receive=$receive issue=$issue');
  }
}
