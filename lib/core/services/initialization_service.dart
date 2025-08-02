import 'package:injectable/injectable.dart';
import '../../data/services/mock_categories_service.dart';
import '../../data/services/mock_products_service.dart';
import '../../domain/repositories/category_repository.dart';

/// Service responsible for initializing all required services
/// when the application starts
@injectable
class InitializationService {
  final MockCategoriesService _categoriesService;
  final MockProductsService _productsService;
  final CategoryRepository _categoryRepository;

  InitializationService(
    this._categoriesService,
    this._productsService,
    this._categoryRepository,
  );

  /// Initialize all services that require async setup
  Future<void> initialize() async {
    // Initialize mock services first
    await _categoriesService.init();
    await _productsService.init();

    // Sync initial categories to local database if empty
    await _syncInitialCategories();
  }

  /// Sync initial categories from mock data to local database
  /// This ensures categories are available in local database on first app launch
  Future<void> _syncInitialCategories() async {
    try {
      // Check if local database already has categories
      final localCategories = await _categoryRepository.getCategories();

      // If no categories in local database, sync from mock data
      if (localCategories.isEmpty) {
        // Sync from remote if local is empty
        await _categoryRepository.getCategories(true);
      }
    } catch (e) {
      // If there's an error, try to force sync anyway
      try {
        await _categoryRepository.getCategories(true);
      } catch (syncError) {
        // Log error but don't throw to prevent app crash
      }
    }
  }
}
