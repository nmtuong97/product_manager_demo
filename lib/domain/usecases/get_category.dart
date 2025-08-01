import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case for retrieving a single category by its ID
///
/// This use case encapsulates the business logic for fetching a specific category.
/// It validates the input and delegates to the repository for data access.
@injectable
class GetCategory {
  final CategoryRepository _repository;

  const GetCategory(this._repository);

  /// Retrieves a category by its ID
  ///
  /// [id] must be a positive integer representing the category ID
  ///
  /// Returns the [Category] if found
  /// Throws [ArgumentError] if [id] is invalid
  /// Throws [Exception] if category is not found or other errors occur
  Future<Category> call(int id) async {
    if (id <= 0) {
      throw ArgumentError('Category ID must be a positive integer');
    }

    try {
      return await _repository.getCategory(id);
    } catch (e) {
      throw Exception('Failed to retrieve category with ID $id: $e');
    }
  }
}
