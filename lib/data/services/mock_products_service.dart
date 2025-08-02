import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/product.dart';
import '../../presentation/services/image_url_generator.dart';

/// Service for managing mock product data
///
/// This service provides persistent storage and management of product data
/// for development and testing purposes.
@lazySingleton
class MockProductsService {
  static const String _fileName = 'products.json';
  int _nextId = 1;

  // Completer để đảm bảo chỉ có 1 file operation tại 1 thời điểm
  Completer<void>? _fileOperationCompleter;

  MockProductsService();

  /// Initialize the service by creating empty products file if not exists
  Future<void> init() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = '${dbDir.path}/$_fileName';
    final file = File(dbPath);

    if (!await file.exists()) {
      // Create empty products array
      await file.writeAsString('[]');
      _nextId = 1;
    } else {
      // Update next ID based on existing products
      await _updateNextId();
    }
  }

  Future<void> _updateNextId() async {
    final products = await _readProducts();
    if (products.isNotEmpty) {
      _nextId =
          products.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  /// Thread-safe file read với retry mechanism
  Future<List<Product>> _readProducts() async {
    // Đợi operation trước đó hoàn thành
    while (_fileOperationCompleter != null &&
        !_fileOperationCompleter!.isCompleted) {
      await _fileOperationCompleter!.future;
    }

    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = '${dbDir.path}/$_fileName';
    final file = File(dbPath);

    if (await file.exists()) {
      // Retry mechanism cho việc đọc file
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          final data = await file.readAsString();

          final List<dynamic> jsonList = json.decode(data) as List<dynamic>;

          final products =
              jsonList.map((json) {
                final productMap = json as Map<String, dynamic>;
                return Product.fromMap(productMap);
              }).toList();

          return products;
        } catch (e) {
          if (attempt == 2) {
            return [];
          }
          // Đợi một chút trước khi retry
          await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
        }
      }
    }

    return [];
  }

  /// Thread-safe file write với atomic operation
  Future<void> _writeProducts(List<Product> products) async {
    // Đợi operation trước đó hoàn thành
    while (_fileOperationCompleter != null &&
        !_fileOperationCompleter!.isCompleted) {
      await _fileOperationCompleter!.future;
    }

    // Tạo completer mới cho operation này
    _fileOperationCompleter = Completer<void>();

    try {
      final dbDir = await getApplicationDocumentsDirectory();
      final dbPath = '${dbDir.path}/$_fileName';
      final tempPath = '${dbPath}.tmp';

      final jsonList = products.map((product) => product.toMap()).toList();
      final jsonString = json.encode(jsonList);

      // Atomic write: ghi vào file tạm trước
      final tempFile = File(tempPath);
      await tempFile.writeAsString(jsonString);

      // Sau đó rename để thay thế file gốc (atomic operation)
      await tempFile.rename(dbPath);
    } catch (e) {
      rethrow;
    } finally {
      // Hoàn thành operation
      _fileOperationCompleter!.complete();
    }
  }

  /// Get all products
  Future<List<Product>> getAllProducts() async {
    return await _readProducts();
  }

  /// Get product by ID
  Future<Product?> getProductById(int id) async {
    final products = await _readProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new product
  Future<Product> addProduct(Product product) async {
    final products = await _readProducts();
    final now = DateTime.now();
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
    products.add(newProduct);
    await _writeProducts(products);
    return newProduct;
  }

  /// Update existing product
  Future<Product?> updateProduct(Product product) async {
    final products = await _readProducts();
    final index = products.indexWhere((p) => p.id == product.id);
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
        updatedAt: DateTime.now(),
      );
      products[index] = updatedProduct;
      await _writeProducts(products);
      return updatedProduct;
    }
    return null;
  }

  /// Delete product by ID
  Future<bool> deleteProduct(int id) async {
    final products = await _readProducts();
    final index = products.indexWhere((product) => product.id == id);
    if (index != -1) {
      products.removeAt(index);
      await _writeProducts(products);
      return true;
    }
    return false;
  }

  /// Search products by name only
  Future<List<Product>> searchProducts(String query) async {
    final products = await _readProducts();
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get products by category ID
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final products = await _readProducts();
    return products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  /// Clear all products
  Future<void> clearProducts() async {
    await _writeProducts([]);
  }

  /// Add multiple products với batch operation để tránh race condition
  Future<void> addProducts(List<Product> products) async {
    if (products.isEmpty) return;

    // Đọc products hiện tại một lần
    final existingProducts = await _readProducts();
    final now = DateTime.now();

    // Tạo tất cả products mới với ID tăng dần
    final newProducts = <Product>[];
    for (final product in products) {
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
      newProducts.add(newProduct);
    }

    // Thêm tất cả vào danh sách hiện tại
    existingProducts.addAll(newProducts);

    // Ghi một lần duy nhất
    await _writeProducts(existingProducts);
  }

  /// Clear all products (for testing/debugging)
  Future<void> clearAllProducts() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = '${dbDir.path}/$_fileName';
    final file = File(dbPath);

    await file.writeAsString('[]');
    _nextId = 1;
  }

  /// Upload images for a product and return updated image URLs
  Future<List<String>?> uploadProductImages(
    int productId, {
    int imageCount = 1,
  }) async {
    final products = await _readProducts();
    final index = products.indexWhere((p) => p.id == productId);

    if (index == -1) {
      return null; // Product not found
    }

    final product = products[index];

    // Generate new sample image URLs for the uploaded images
    final newImageUrls = ImageUrlGenerator.generateImageListForProduct(
      product.name,
      count: imageCount, // Generate URLs based on actual uploaded image count
    );

    // Update the product with new image URLs
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      quantity: product.quantity,
      categoryId: product.categoryId,
      images: newImageUrls,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );

    products[index] = updatedProduct;
    await _writeProducts(products);

    return newImageUrls;
  }
}
