/// Service class for handling product list business logic
class ProductListService {
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

  /// Simulate loading products from API
  Future<List<Map<String, dynamic>>> loadProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return empty list for now - this would be replaced with actual API call
    return [];
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