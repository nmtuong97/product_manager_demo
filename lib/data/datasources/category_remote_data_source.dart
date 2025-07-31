import '../../domain/entities/category.dart';

abstract class CategoryRemoteDataSource {
  Future<List<Category>> getCategories();

  Future<Category> getCategory(int id);

  Future<Category> addCategory(Category category);

  Future<Category> updateCategory(Category category);

  Future<void> deleteCategory(int id);
}
