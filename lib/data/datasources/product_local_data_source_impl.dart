import 'package:injectable/injectable.dart';

import '../../domain/entities/product.dart';
import 'database_helper.dart';
import 'product_local_data_source.dart';

/// Local data source implementation for products using SQLite database
///
/// This implementation handles all local storage operations for products,
/// including CRUD operations and batch processing.
@Injectable(as: ProductLocalDataSource)
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ProductLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final maps = await _databaseHelper.getProducts();
      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách sản phẩm từ local storage: $e');
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      final map = await _databaseHelper.getProduct(id);
      if (map == null) {
        throw Exception('Không tìm thấy sản phẩm với ID: $id');
      }
      return Product.fromMap(map);
    } catch (e) {
      throw Exception('Lỗi khi lấy sản phẩm từ local storage: $e');
    }
  }

  @override
  Future<void> insertProduct(Product product) async {
    try {
      await _databaseHelper.insertProduct(product.toMap());
    } catch (e) {
      throw Exception('Lỗi khi thêm sản phẩm vào local storage: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw Exception('ID sản phẩm không được để trống khi cập nhật');
      }
      await _databaseHelper.updateProduct(product.toMap());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật sản phẩm trong local storage: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _databaseHelper.deleteProduct(id);
    } catch (e) {
      throw Exception('Lỗi khi xóa sản phẩm từ local storage: $e');
    }
  }

  @override
  Future<void> clearProducts() async {
    try {
      await _databaseHelper.clearProducts();
    } catch (e) {
      throw Exception('Lỗi khi xóa tất cả sản phẩm từ local storage: $e');
    }
  }

  @override
  Future<void> insertProducts(List<Product> products) async {
    try {
      final maps = products.map((product) => product.toMap()).toList();
      await _databaseHelper.insertProducts(maps);
    } catch (e) {
      throw Exception('Lỗi khi thêm nhiều sản phẩm vào local storage: $e');
    }
  }
}
