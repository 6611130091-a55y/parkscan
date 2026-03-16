// lib/features/receipt_scan/data/datasources/local/app_database.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/receipt_model.dart';
import '../../models/parking_session_model.dart';

abstract class AppDatabase {
  Future<void> saveReceipt(ReceiptModel m);
  Future<List<ReceiptModel>> getReceiptsByDate(DateTime date);
  Future<List<ReceiptModel>> getAllReceipts();
  Future<void> deleteReceipt(String id);
  Future<void> saveParkingSession(ParkingSessionModel s);
  Future<ParkingSessionModel?> getActiveParkingSession();
  Future<List<ParkingSessionModel>> getAllParkingSessions();
  Future<void> updateParkingSession(ParkingSessionModel s);
}

class AppDatabaseImpl implements AppDatabase {
  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'parkscan_v1.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int v) async {
    await db.execute('''
      CREATE TABLE receipts (
        id TEXT PRIMARY KEY,
        storeName TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        receiptDate TEXT NOT NULL,
        category TEXT NOT NULL,
        rawText TEXT DEFAULT '',
        imagePath TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE parking_sessions (
        id TEXT PRIMARY KEY,
        entryTime TEXT NOT NULL,
        exitTime TEXT,
        totalSpend REAL NOT NULL DEFAULT 0,
        freeHours INTEGER NOT NULL DEFAULT 1,
        usedHours INTEGER NOT NULL DEFAULT 0,
        chargeAmount REAL NOT NULL DEFAULT 0,
        receiptIds TEXT NOT NULL DEFAULT '[]'
      )
    ''');
  }

  @override
  Future<void> saveReceipt(ReceiptModel m) async {
    final db = await _database;
    await db.insert('receipts', m.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<ReceiptModel>> getReceiptsByDate(DateTime date) async {
    final db = await _database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final rows = await db.query('receipts',
        where: 'receiptDate LIKE ?', whereArgs: ['$dateStr%'],
        orderBy: 'createdAt DESC');
    return rows.map((r) => ReceiptModel.fromJson(r)).toList();
  }

  @override
  Future<List<ReceiptModel>> getAllReceipts() async {
    final db = await _database;
    final rows = await db.query('receipts', orderBy: 'createdAt DESC');
    return rows.map((r) => ReceiptModel.fromJson(r)).toList();
  }

  @override
  Future<void> deleteReceipt(String id) async {
    final db = await _database;
    await db.delete('receipts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> saveParkingSession(ParkingSessionModel s) async {
    final db = await _database;
    final map = s.toJson()..['receiptIds'] = jsonEncode(s.receiptIds);
    await db.insert('parking_sessions', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<ParkingSessionModel?> getActiveParkingSession() async {
    final db = await _database;
    final rows = await db.query('parking_sessions',
        where: 'exitTime IS NULL', limit: 1);
    if (rows.isEmpty) return null;
    return _rowToModel(rows.first);
  }

  @override
  Future<List<ParkingSessionModel>> getAllParkingSessions() async {
    final db = await _database;
    final rows = await db.query('parking_sessions',
        orderBy: 'entryTime DESC');
    return rows.map(_rowToModel).toList();
  }

  @override
  Future<void> updateParkingSession(ParkingSessionModel s) async {
    final db = await _database;
    final map = s.toJson()..['receiptIds'] = jsonEncode(s.receiptIds);
    await db.update('parking_sessions', map,
        where: 'id = ?', whereArgs: [s.id]);
  }

  ParkingSessionModel _rowToModel(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['receiptIds'] =
        List<String>.from(jsonDecode(map['receiptIds'] as String));
    return ParkingSessionModel.fromJson(map);
  }
}
