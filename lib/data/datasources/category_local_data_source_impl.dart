import 'package:injectable/injectable.dart';

import '../../domain/entities/category.dart';
import 'category_local_data_source.dart';
import 'database_helper.dart';

@LazySingleton(as: CategoryLocalDataSource)
class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseHelper databaseHelper;

  CategoryLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<void> batchInsertCategories(List<Category> categories) async {
    await databaseHelper.batchInsertCategories(categories);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await databaseHelper.deleteCategory(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await databaseHelper.getCategories();
  }

  @override
  Future<Map<String, dynamic>> getCategory(int id) async {
    return await databaseHelper.getCategory(id);
  }

  @override
  Future<void> insertCategory(Map<String, dynamic> map) async {
    await databaseHelper.insertCategory(map);
  }

  @override
  Future<void> updateCategory(Map<String, dynamic> map) async {
    await databaseHelper.updateCategory(map);
  }
}
