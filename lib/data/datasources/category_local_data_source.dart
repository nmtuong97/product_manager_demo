import '../../domain/entities/category.dart';

abstract class CategoryLocalDataSource {
  Future<List<Map<String, dynamic>>> getCategories();

  Future<Map<String, dynamic>> getCategory(int id);

  Future<void> insertCategory(Map<String, dynamic> map);

  Future<void> updateCategory(Map<String, dynamic> map);

  Future<void> deleteCategory(int id);

  Future<void> batchInsertCategories(List<Category> categories);
}
