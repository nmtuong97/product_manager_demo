import 'package:injectable/injectable.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../datasources/category_remote_data_source.dart';

/// Implementation of CategoryRepository following Clean Architecture principles
///
/// This repository coordinates between local and remote data sources,
/// implementing caching strategies and offline-first approach.
@Injectable(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;
  final CategoryRemoteDataSource _remoteDataSource;

  const CategoryRepositoryImpl({
    required CategoryLocalDataSource localDataSource,
    required CategoryRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<void> addCategory(Category category) async {
    try {
      // Add to remote first for data consistency
      final remoteCategory = await _remoteDataSource.addCategory(category);

      // Cache the result locally
      await _localDataSource.insertCategory(remoteCategory);
    } catch (e) {
      // Fallback to local storage if remote fails (offline support)
      try {
        await _localDataSource.insertCategory(category);
      } catch (localError) {
        throw Exception(
          'Failed to add category: Remote error: $e, Local error: $localError',
        );
      }
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      // Delete from remote first for data consistency
      await _remoteDataSource.deleteCategory(id);

      // Remove from local cache
      await _localDataSource.deleteCategory(id);
    } catch (e) {
      // Fallback to local deletion if remote fails (offline support)
      try {
        await _localDataSource.deleteCategory(id);
      } catch (localError) {
        throw Exception(
          'Failed to delete category: Remote error: $e, Local error: $localError',
        );
      }
    }
  }

  @override
  Future<List<Category>> getCategories([bool forceRefresh = false]) async {
    if (!forceRefresh) {
      // Offline-first approach: try local cache first
      try {
        final localCategories = await _localDataSource.getCategories();
        if (localCategories.isNotEmpty) {
          return localCategories;
        }
      } catch (e) {
        // Continue to remote if local fails
      }
    }

    // Fetch from remote and update local cache
    try {
      final remoteCategories = await _remoteDataSource.getCategories();

      // Update local cache with fresh data
      await _localDataSource.batchInsertCategories(remoteCategories);

      return remoteCategories;
    } catch (e) {
      // Fallback to local cache if remote fails
      try {
        return await _localDataSource.getCategories();
      } catch (localError) {
        throw Exception(
          'Failed to get categories: Remote error: $e, Local error: $localError',
        );
      }
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      // Update remote first for data consistency
      final updatedCategory = await _remoteDataSource.updateCategory(category);

      // Update local cache with the result
      await _localDataSource.updateCategory(updatedCategory);
    } catch (e) {
      // Fallback to local update if remote fails (offline support)
      try {
        await _localDataSource.updateCategory(category);
      } catch (localError) {
        throw Exception(
          'Failed to update category: Remote error: $e, Local error: $localError',
        );
      }
    }
  }

  @override
  Future<Category> getCategory(int id) async {
    try {
      // Try local cache first for better performance
      final localCategory = await _localDataSource.getCategory(id);
      return localCategory;
    } catch (e) {
      // Fallback to remote if not found locally
      try {
        final remoteCategory = await _remoteDataSource.getCategory(id);

        // Cache the result locally for future requests
        await _localDataSource.insertCategory(remoteCategory);

        return remoteCategory;
      } catch (remoteError) {
        throw Exception(
          'Failed to get category with ID $id: Local error: $e, Remote error: $remoteError',
        );
      }
    }
  }
}
