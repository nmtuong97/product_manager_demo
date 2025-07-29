import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE features (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        is_enabled INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> saveCounter(int value) async {
    final db = await instance.database;
    final data = {'name': 'counter', 'description': 'Counter value', 'is_enabled': value};

    final rowsAffected = await db.update(
      'features',
      data,
      where: 'name = ?',
      whereArgs: ['counter'],
    );

    if (rowsAffected == 0) {
      return await db.insert(
        'features',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      return rowsAffected;
    }
  }

  Future<int?> getCounter() async {
    final db = await instance.database;
    final maps = await db.query(
      'features',
      where: 'name = ?',
      whereArgs: ['counter'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['is_enabled'] as int?;
    }
    return null;
  }
}