import '../../domain/entities/product.dart';

/// Abstract interface for remote product data operations
///
/// This interface defines the contract for remote API operations
/// following the Repository pattern and Clean Architecture principles.
abstract class ProductRemoteDataSource {
  /// Retrieves all products from remote API
  ///
  /// Returns a list of all products from the server.
  /// May throw network-related exceptions.
  Future<List<Product>> getProducts();

  /// Retrieves a specific product by ID from remote API
  ///
  /// [id] The unique identifier of the product to retrieve
  /// Throws an exception if the product is not found or network error occurs
  Future<Product> getProduct(int id);

  /// Creates a new product on the remote server
  ///
  /// [product] The product entity to create
  /// Returns the created product with server-generated ID
  Future<Product> createProduct(Product product);

  /// Updates an existing product on the remote server
  ///
  /// [product] The product entity with updated information
  /// The product must have a valid ID
  /// Returns the updated product
  Future<Product> updateProduct(Product product);

  /// Removes a product from the remote server
  ///
  /// [id] The unique identifier of the product to delete
  Future<void> deleteProduct(int id);

  /// Searches for products based on query parameters
  ///
  /// [query] Search query string
  /// [categoryId] Optional category filter
  /// Returns a list of products matching the search criteria
  Future<List<Product>> searchProducts(String query, {int? categoryId});

  /// Retrieves products by category from remote API
  ///
  /// [categoryId] The category identifier to filter products
  /// Returns a list of products in the specified category
  Future<List<Product>> getProductsByCategory(int categoryId);
}
