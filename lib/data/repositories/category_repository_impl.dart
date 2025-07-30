import 'package:injectable/injectable.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/database_helper.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper databaseHelper;

  CategoryRepositoryImpl(this.databaseHelper);

  @override
  Future<void> addCategory(Category category) async {
    await databaseHelper.insertCategory(category.toMap());
  }

  @override
  Future<void> deleteCategory(int id) async {
    await databaseHelper.deleteCategory(id);
  }

  @override
  Future<Category> getCategory(int id) async {
    final categoryMap = await databaseHelper.getCategory(id);
    return Category.fromMap(categoryMap);
  }

  @override
  Future<List<Category>> getCategories() async {
    final categoryMaps = await databaseHelper.getCategories();
    return categoryMaps.map((map) => Category.fromMap(map)).toList();
  }

  @override
  Future<void> updateCategory(Category category) async {
    await databaseHelper.updateCategory(category.toMap());
  }
}