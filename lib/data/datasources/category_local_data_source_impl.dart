import 'package:injectable/injectable.dart';

import '../../domain/entities/category.dart';
import 'category_local_data_source.dart';
import 'database_helper.dart';

/// Local data source implementation for categories using SQLite database
///
/// This implementation handles all local storage operations for categories,
/// including CRUD operations and batch processing.
@Injectable(as: CategoryLocalDataSource)
class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseHelper _databaseHelper;

  const CategoryLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final maps = await _databaseHelper.getCategories();
      return maps.map((map) => Category.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get categories from local storage: $e');
    }
  }

  @override
  Future<Category> getCategory(int id) async {
    try {
      final map = await _databaseHelper.getCategory(id);
      return Category.fromMap(map);
    } catch (e) {
      throw Exception(
        'Failed to get category with ID $id from local storage: $e',
      );
    }
  }

  @override
  Future<Category> insertCategory(Category category) async {
    try {
      final now = DateTime.now();
      final categoryWithTimestamps = category.copyWith(
        createdAt: category.createdAt,
        updatedAt: now,
      );

      final id = await _databaseHelper.insertCategory(
        categoryWithTimestamps.toMap(),
      );
      return categoryWithTimestamps.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to insert category into local storage: $e');
    }
  }

  @override
  Future<Category> updateCategory(Category category) async {
    try {
      final now = DateTime.now();
      final updatedCategory = category.copyWith(updatedAt: now);

      await _databaseHelper.updateCategory(updatedCategory.toMap());
      return updatedCategory;
    } catch (e) {
      throw Exception('Failed to update category in local storage: $e');
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _databaseHelper.deleteCategory(id);
    } catch (e) {
      throw Exception(
        'Failed to delete category with ID $id from local storage: $e',
      );
    }
  }

  @override
  Future<void> batchInsertCategories(List<Category> categories) async {
    try {
      final maps = categories.map((category) => category.toMap()).toList();
      await _databaseHelper.batchInsertCategories(maps);
    } catch (e) {
      throw Exception(
        'Failed to batch insert categories into local storage: $e',
      );
    }
  }
}
