import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/product.dart';
import 'product_remote_data_source.dart';

/// Remote data source implementation for products using REST API
///
/// This implementation handles all remote API operations for products,
/// including CRUD operations and search functionality.
@Injectable(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = '/api/products';

  ProductRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get(_baseUrl);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Product.fromMap(json)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi lấy danh sách sản phẩm từ server: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi lấy danh sách sản phẩm: $e');
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id');
      return Product.fromMap(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy sản phẩm với ID: $id');
      }
      throw Exception('Lỗi khi lấy sản phẩm từ server: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi lấy sản phẩm: $e');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _dio.post(_baseUrl, data: product.toMap());
      return Product.fromMap(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Lỗi khi tạo sản phẩm trên server: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi tạo sản phẩm: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw Exception('ID sản phẩm không được để trống khi cập nhật');
      }
      final response = await _dio.put(
        '$_baseUrl/${product.id}',
        data: product.toMap(),
      );
      return Product.fromMap(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy sản phẩm với ID: ${product.id}');
      }
      throw Exception('Lỗi khi cập nhật sản phẩm trên server: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi cập nhật sản phẩm: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('$_baseUrl/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy sản phẩm với ID: $id');
      }
      throw Exception('Lỗi khi xóa sản phẩm trên server: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi xóa sản phẩm: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query, {int? categoryId}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'search': query,
        if (categoryId != null) 'category_id': categoryId,
      };

      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Product.fromMap(json)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi tìm kiếm sản phẩm trên server: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi tìm kiếm sản phẩm: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'category_id': categoryId},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Product.fromMap(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Lỗi khi lấy sản phẩm theo danh mục từ server: ${e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định khi lấy sản phẩm theo danh mục: $e');
    }
  }
}
