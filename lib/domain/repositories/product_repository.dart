import '../../domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts([bool forceRefresh = false]);
  Future<Product> getProduct(int id);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}
