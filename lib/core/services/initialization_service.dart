import 'package:injectable/injectable.dart';
import '../../data/services/mock_categories_service.dart';
import '../../data/services/mock_products_service.dart';

/// Service responsible for initializing all required services
/// when the application starts
@injectable
class InitializationService {
  final MockCategoriesService _categoriesService;
  final MockProductsService _productsService;

  InitializationService(
    this._categoriesService,
    this._productsService,
  );

  /// Initialize all services that require async setup
  Future<void> initialize() async {
    await _categoriesService.init();
    await _productsService.init();
  }
}