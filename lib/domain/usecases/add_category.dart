import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case for adding a new category
///
/// This use case encapsulates the business logic for creating a new category.
/// It validates the input and delegates to the repository for data persistence.
@injectable
class AddCategory {
  final CategoryRepository _repository;

  const AddCategory(this._repository);

  /// Adds a new category to the data source
  ///
  /// [category] must be a valid Category object with a non-empty name
  ///
  /// Adds a new category
  /// Throws [ArgumentError] if [category] is invalid
  /// Throws [Exception] if creation fails
  Future<void> call(Category category) async {
    _validateCategory(category);

    try {
      await _repository.addCategory(category);
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  /// Validates the category before adding
  void _validateCategory(Category category) {
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
