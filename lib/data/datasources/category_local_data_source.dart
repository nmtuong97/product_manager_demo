import '../../domain/entities/category.dart';

/// Abstract interface for local category data operations
///
/// This interface defines the contract for local storage operations
/// following the Repository pattern and Clean Architecture principles.
abstract class CategoryLocalDataSource {
  /// Retrieves all categories from local storage
  Future<List<Category>> getCategories();

  /// Retrieves a specific category by ID from local storage
  Future<Category> getCategory(int id);

  /// Inserts a new category into local storage
  Future<Category> insertCategory(Category category);

  /// Updates an existing category in local storage
  Future<Category> updateCategory(Category category);

  /// Deletes a category from local storage by ID
  Future<void> deleteCategory(int id);

  /// Batch inserts multiple categories into local storage
  Future<void> batchInsertCategories(List<Category> categories);
}
