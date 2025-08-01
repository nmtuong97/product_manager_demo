import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';

@singleton
class DatabaseHelper {
  static Database? _database;

  DatabaseHelper._internal();

  @factoryMethod
  static Future<DatabaseHelper> create() async {
    if (_database == null) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'app_database.db');

      _database = await openDatabase(
        path,
        version: 2,
        onCreate: DatabaseHelper._createDB,
        onUpgrade: DatabaseHelper._upgradeDB,
      );
    }

    return DatabaseHelper._internal();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    throw Exception('Database not initialized. Call create() first.');
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        categoryId INTEGER NOT NULL,
        images TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE features (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        is_enabled INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Database upgrade logic if needed
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Product methods
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert(
      'products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      throw Exception('Product not found');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query('products');
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.update(
      'products',
      product,
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearProducts() async {
    final db = await database;
    await db.delete('products');
  }

  Future<void> insertProducts(List<Map<String, dynamic>> products) async {
    final db = await database;
    final batch = db.batch();
    for (var product in products) {
      batch.insert(
        'products',
        product,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Category methods
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> batchInsertCategories(List<Map<String, dynamic>> categories) async {
    final db = await database;
    final batch = db.batch();
    for (var category in categories) {
      batch.insert(
        'categories',
        category,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, dynamic>> getCategory(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      throw Exception('Category not found');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> saveCounter(int value) async {
    final db = await database;
    final data = {
      'name': 'counter',
      'description': 'Counter value',
      'is_enabled': value,
    };

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
    final db = await database;
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
