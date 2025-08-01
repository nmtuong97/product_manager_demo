import 'package:injectable/injectable.dart';

import '../repositories/category_repository.dart';

/// Use case for deleting a category
///
/// This use case encapsulates the business logic for removing a category.
/// It validates the input and delegates to the repository for data removal.
@injectable
class DeleteCategory {
  final CategoryRepository _repository;

  const DeleteCategory(this._repository);

  /// Deletes a category by its ID
  ///
  /// [id] must be a positive integer representing the category ID
  ///
  /// Throws [ArgumentError] if [id] is invalid
  /// Throws [Exception] if deletion fails or category is not found
  Future<void> call(int id) async {
    if (id <= 0) {
      throw ArgumentError('Category ID must be a positive integer');
    }

    try {
      await _repository.deleteCategory(id);
    } catch (e) {
      throw Exception('Failed to delete category with ID $id: $e');
    }
  }
}
