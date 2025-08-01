import 'package:injectable/injectable.dart';
import '../../domain/entities/product.dart';
import '../../presentation/services/image_url_generator.dart';

/// Service for managing mock product data
///
/// This service provides in-memory storage and management of product data
/// for development and testing purposes.
@injectable
class MockProductsService {
  final List<Product> _products = [];
  int _nextId = 1;

  MockProductsService() {
    _initializeMockData();
  }

  /// Initialize with some mock product data
  void _initializeMockData() {
    final now = DateTime.now().toIso8601String();

    _products.addAll([
      Product(
        id: 1,
        name: 'iPhone 15 Pro',
        description: 'Điện thoại thông minh cao cấp với chip A17 Pro',
        price: 29990000,
        quantity: 50,
        categoryId: 1,
        images: ImageUrlGenerator.generateImageUrlForProduct('iphone-15-pro'),
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: 2,
        name: 'Samsung Galaxy S24',
        description: 'Smartphone Android flagship với AI tích hợp',
        price: 24990000,
        quantity: 30,
        categoryId: 1,
        images: ImageUrlGenerator.generateImageUrlForProduct(
          'samsung-galaxy-s24',
        ),
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: 3,
        name: 'MacBook Pro M3',
        description: 'Laptop chuyên nghiệp với chip M3 mạnh mẽ',
        price: 54990000,
        quantity: 20,
        categoryId: 1,
        images: ImageUrlGenerator.generateImageUrlForProduct('macbook-pro-m3'),
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: 4,
        name: 'Áo sơ mi nam',
        description: 'Áo sơ mi công sở chất liệu cotton cao cấp',
        price: 299000,
        quantity: 100,
        categoryId: 2,
        images: ImageUrlGenerator.generateImageUrlForProduct('ao-so-mi-nam'),
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: 5,
        name: 'Quần jeans nữ',
        description: 'Quần jeans skinny fit thời trang',
        price: 599000,
        quantity: 75,
        categoryId: 2,
        images: ImageUrlGenerator.generateImageUrlForProduct('quan-jeans-nu'),
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: 6,
        name: 'Lập trình Flutter',
        description: 'Sách hướng dẫn lập trình ứng dụng di động với Flutter',
        price: 199000,
        quantity: 40,
        categoryId: 3,
        images: ImageUrlGenerator.generateImageUrlForProduct('sach-flutter'),
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: 7,
        name: 'Clean Code',
        description: 'Sách về kỹ thuật viết code sạch và dễ bảo trì',
        price: 299000,
        quantity: 25,
        categoryId: 3,
        images: ImageUrlGenerator.generateImageUrlForProduct('clean-code'),
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    _nextId = 8;
  }

  /// Get all products
  List<Product> getAllProducts() {
    return List.from(_products);
  }

  /// Get product by ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new product
  Product addProduct(Product product) {
    final now = DateTime.now().toIso8601String();
    final newProduct = Product(
      id: _nextId++,
      name: product.name,
      description: product.description,
      price: product.price,
      quantity: product.quantity,
      categoryId: product.categoryId,
      images: product.images,
      createdAt: now,
      updatedAt: now,
    );
    _products.add(newProduct);
    return newProduct;
  }

  /// Update existing product
  Product? updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        quantity: product.quantity,
        categoryId: product.categoryId,
        images: product.images,
        createdAt: product.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      _products[index] = updatedProduct;
      return updatedProduct;
    }
    return null;
  }

  /// Delete product by ID
  bool deleteProduct(int id) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index != -1) {
      _products.removeAt(index);
      return true;
    }
    return false;
  }

  /// Search products by name or description
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return getAllProducts();

    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          (product.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get products by category ID
  List<Product> getProductsByCategory(int categoryId) {
    return _products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  /// Clear all products
  void clearProducts() {
    _products.clear();
  }

  /// Add multiple products
  void addProducts(List<Product> products) {
    for (final product in products) {
      addProduct(product);
    }
  }
}
