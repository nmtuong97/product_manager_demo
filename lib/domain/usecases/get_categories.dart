import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case for retrieving all categories
///
/// This use case encapsulates the business logic for fetching all categories.
/// It delegates to the repository for data access and handles errors appropriately.
@injectable
class GetCategories {
  final CategoryRepository _repository;

  const GetCategories(this._repository);

  /// Retrieves all categories from the data source
  ///
  /// Returns a [List<Category>] containing all available categories
  /// Returns an empty list if no categories are found
  /// Throws [Exception] if an error occurs during data retrieval
  Future<List<Category>> call([bool forceRefresh = false]) async {
    try {
      return await _repository.getCategories(forceRefresh);
    } catch (e) {
      throw Exception('Failed to retrieve categories: $e');
    }
  }
}
