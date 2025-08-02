import '../../domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts([bool forceRefresh = false]);
  Future<Product> getProduct(int id);
  Future<Product> addProduct(Product product);
  Future<void> addMultipleProducts(List<Product> products);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);

  /// Searches for products based on query parameters
  ///
  /// [query] Search query string
  /// [categoryId] Optional category filter
  /// Returns a list of products matching the search criteria
  Future<List<Product>> searchProducts(String query, {int? categoryId});

  /// Retrieves products by category
  ///
  /// [categoryId] The category identifier to filter products
  /// Returns a list of products in the specified category
  Future<List<Product>> getProductsByCategory(int categoryId);
}
