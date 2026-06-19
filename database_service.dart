import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/constants.dart';
import '../models/scan_record.dart';

/// Owns the single sqflite [Database] instance and exposes typed CRUD
/// methods for [ScanRecord]. Kept as a plain service (no repository
/// interface) since there's only one data source in the MVP.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, DbConstants.dbName);

    return openDatabase(
      dbPath,
      version: DbConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${DbConstants.tableScanHistory} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            format TEXT NOT NULL,
            type TEXT NOT NULL,
            scanned_at INTEGER NOT NULL,
            is_generated INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_scanned_at ON ${DbConstants.tableScanHistory}(scanned_at DESC)
        ''');
      },
    );
  }

  /// Inserts a new scan record and returns it with its assigned id.
  Future<ScanRecord> insert(ScanRecord record) async {
    final db = await _database;
    final id = await db.insert(DbConstants.tableScanHistory, record.toMap()..remove('id'));
    return record.copyWith(id: id);
  }

  /// Returns all records, most recent first. Optionally filtered by a
  /// case-insensitive substring match on content (used by History search).
  Future<List<ScanRecord>> getAll({String? searchQuery}) async {
    final db = await _database;

    final List<Map<String, dynamic>> rows;
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      rows = await db.query(
        DbConstants.tableScanHistory,
        where: 'content LIKE ?',
        whereArgs: ['%${searchQuery.trim()}%'],
        orderBy: 'scanned_at DESC',
      );
    } else {
      rows = await db.query(
        DbConstants.tableScanHistory,
        orderBy: 'scanned_at DESC',
      );
    }

    return rows.map(ScanRecord.fromMap).toList();
  }

  Future<void> deleteById(int id) async {
    final db = await _database;
    await db.delete(
      DbConstants.tableScanHistory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await _database;
    await db.delete(DbConstants.tableScanHistory);
  }
}
