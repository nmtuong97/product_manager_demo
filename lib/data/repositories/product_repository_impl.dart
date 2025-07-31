import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/database_helper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper databaseHelper;

  ProductRepositoryImpl(this.databaseHelper);

  @override
  Future<void> addProduct(Product product) async {
    await databaseHelper.insertProduct(product.toMap());
  }

  @override
  Future<void> deleteProduct(int id) async {
    await databaseHelper.deleteProduct(id);
  }

  @override
  Future<Product> getProduct(int id) async {
    final productMap = await databaseHelper.getProduct(id);
    return Product.fromMap(productMap);
  }

  @override
  Future<List<Product>> getProducts() async {
    final productMaps = await databaseHelper.getProducts();
    return productMaps.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Future<void> updateProduct(Product product) async {
    await databaseHelper.updateProduct(product.toMap());
  }
}
