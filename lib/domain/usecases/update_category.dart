import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case for updating an existing category
///
/// This use case encapsulates the business logic for modifying a category.
/// It validates the input and delegates to the repository for data persistence.
@injectable
class UpdateCategory {
  final CategoryRepository _repository;

  const UpdateCategory(this._repository);

  /// Updates an existing category in the data source
  ///
  /// [category] must be a valid Category object with a valid ID and non-empty name
  ///
  /// Updates the category
  /// Throws [ArgumentError] if [category] is invalid
  /// Throws [Exception] if update fails or category is not found
  Future<void> call(Category category) async {
    _validateCategory(category);

    try {
      await _repository.updateCategory(category);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Validates the category before updating
  void _validateCategory(Category category) {
    if (category.id == null || category.id! <= 0) {
      throw ArgumentError('Category ID must be a positive integer for updates');
    }

    if (category.name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }

    if (category.name.trim().length < 2) {
      throw ArgumentError('Category name must be at least 2 characters long');
    }

    if (category.name.trim().length > 50) {
      throw ArgumentError('Category name cannot exceed 50 characters');
    }
  }
}
