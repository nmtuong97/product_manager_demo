import 'dart:convert';
import 'dart:io';

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
      _nextId = products.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  Future<List<Product>> _readProducts() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = '${dbDir.path}/$_fileName';
    final file = File(dbPath);

    if (await file.exists()) {
      final data = await file.readAsString();
      final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
      return jsonList.map((json) => Product.fromMap(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> _writeProducts(List<Product> products) async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = '${dbDir.path}/$_fileName';
    final file = File(dbPath);
    final jsonList = products.map((product) => product.toMap()).toList();
    await file.writeAsString(json.encode(jsonList));
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
        updatedAt: DateTime.now().toIso8601String(),
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

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query) async {
    final products = await _readProducts();
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          (product.description?.toLowerCase().contains(lowerQuery) ?? false);
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

  /// Add multiple products
  Future<void> addProducts(List<Product> products) async {
    for (final product in products) {
      await addProduct(product);
    }
  }
}
