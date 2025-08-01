import 'package:injectable/injectable.dart';
import '../../data/services/mock_products_service.dart';
import '../../domain/entities/product.dart';

/// Service class for handling product list business logic
@injectable
class ProductListService {
  final MockProductsService _mockProductsService;

  ProductListService(this._mockProductsService);
  static const List<String> _defaultCategories = [
    'Tất cả',
    'Điện tử',
    'Thời trang',
    'Gia dụng',
    'Sách',
  ];

  /// Get available categories
  List<String> getCategories() {
    return List.from(_defaultCategories);
  }

  /// Filter products by search query
  List<Map<String, dynamic>> filterBySearch(
    List<Map<String, dynamic>> products,
    String query,
  ) {
    if (query.isEmpty) return products;

    final lowercaseQuery = query.toLowerCase();
    return products.where((product) {
      final name = (product['name'] as String? ?? '').toLowerCase();
      return name.contains(lowercaseQuery);
    }).toList();
  }

  /// Filter products by category
  List<Map<String, dynamic>> filterByCategory(
    List<Map<String, dynamic>> products,
    String category,
  ) {
    if (category == 'Tất cả') return products;

    return products.where((product) {
      final productCategory = product['category'] as String? ?? '';
      return productCategory == category;
    }).toList();
  }

  /// Apply both search and category filters
  List<Map<String, dynamic>> applyFilters(
    List<Map<String, dynamic>> products,
    String searchQuery,
    String selectedCategory,
  ) {
    var filteredProducts = filterByCategory(products, selectedCategory);
    filteredProducts = filterBySearch(filteredProducts, searchQuery);
    return filteredProducts;
  }

  /// Format price with thousand separators
  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Load products from mock service
  Future<List<Map<String, dynamic>>> loadProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get products from mock service and convert to Map format
    final products = _mockProductsService.getAllProducts();
    return products.map((product) => _convertProductToMap(product)).toList();
  }

  /// Convert Product entity to Map for UI compatibility
  Map<String, dynamic> _convertProductToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.quantity,
      'category': _getCategoryName(product.categoryId),
      'image': product.images,
      'createdAt': product.createdAt,
      'updatedAt': product.updatedAt,
    };
  }

  /// Get category name by ID
  String _getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'Điện tử';
      case 2:
        return 'Thời trang';
      case 3:
        return 'Gia dụng';
      case 4:
        return 'Sách';
      default:
        return 'Khác';
    }
  }

  /// Validate product data
  bool isValidProduct(Map<String, dynamic> product) {
    return product.containsKey('name') &&
        product.containsKey('price') &&
        product.containsKey('stock') &&
        product['name'] != null &&
        product['price'] != null &&
        product['stock'] != null;
  }
}
