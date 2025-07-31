import 'package:injectable/injectable.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../datasources/category_remote_data_source.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource local;
  final CategoryRemoteDataSource remote;

  CategoryRepositoryImpl(this.local, this.remote);

  @override
  Future<void> addCategory(Category category) async {
    try {
      final newCategory = await remote.addCategory(category);
      await local.insertCategory(newCategory.toMap());
    } catch (e) {
      await local.insertCategory(category.toMap());
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await remote.deleteCategory(id);
      await local.deleteCategory(id);
    } catch (e) {
      await local.deleteCategory(id);
    }
  }

  @override
  Future<Category> getCategory(int id) async {
    final categoryMap = await local.getCategory(id);
    return Category.fromMap(categoryMap);
  }

  @override
  Future<List<Category>> getCategories([bool forceRefresh = false]) async {
    if (forceRefresh) {
      try {
        final remoteCategories = await remote.getCategories();
        await local.batchInsertCategories(remoteCategories);
        return remoteCategories;
      } catch (e) {
        // Log the error
        final localCategories = await local.getCategories();
        return localCategories.map((map) => Category.fromMap(map)).toList();
      }
    }

    try {
      final localCategories = await local.getCategories();
      if (localCategories.isNotEmpty) {
        return localCategories.map((map) => Category.fromMap(map)).toList();
      }
    } catch (e) {
      // Local cache is empty or error, fetch from remote
    }

    final remoteCategories = await remote.getCategories();
    await local.batchInsertCategories(remoteCategories);
    return remoteCategories;
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      final updatedCategory = await remote.updateCategory(category);
      await local.updateCategory(updatedCategory.toMap());
    } catch (e) {
      await local.updateCategory(category.toMap());
    }
  }
}
