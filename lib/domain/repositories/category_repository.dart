import '../../domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories([bool forceRefresh = false]);
  Future<Category> getCategory(int id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}
