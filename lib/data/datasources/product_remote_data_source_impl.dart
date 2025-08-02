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
      throw Exception('Error getting product list from server: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error getting product list: $e');
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id');
      return Product.fromMap(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found with ID: $id');
      }
      throw Exception('Error getting product from server: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error getting product: $e');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _dio.post(_baseUrl, data: product.toMap());
      return Product.fromMap(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Error creating product on server: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error creating product: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw Exception('Product ID cannot be empty when updating');
      }
      final response = await _dio.put(
        '$_baseUrl/${product.id}',
        data: product.toMap(),
      );
      return Product.fromMap(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found with ID: ${product.id}');
      }
      throw Exception('Error updating product on server: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error updating product: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('$_baseUrl/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found with ID: $id');
      }
      throw Exception('Error deleting product on server: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error deleting product: $e');
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
      throw Exception('Error searching products on server: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error searching products: $e');
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
        'Error getting products by category from server: ${e.message}',
      );
    } catch (e) {
      throw Exception('Unknown error getting products by category: $e');
    }
  }
}
