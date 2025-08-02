import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/category.dart';
import 'category_remote_data_source.dart';

/// Remote data source implementation for categories using HTTP API
///
/// This implementation handles all remote API operations for categories,
/// including CRUD operations and network error handling.
@Injectable(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = '/api/categories';

  const CategoryRemoteDataSourceImpl(this._dio);

  @override
  Future<Category> addCategory(Category category) async {
    try {
      final response = await _dio.post(_baseUrl, data: category.toMap());

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Category.fromMap(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to add category: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while adding category: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while adding category: $e');
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      final response = await _dio.delete('$_baseUrl/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete category: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error while deleting category: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while deleting category: $e');
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(_baseUrl);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final categories =
            data
                .map((item) => Category.fromMap(item as Map<String, dynamic>))
                .toList();
        return categories;
      } else {
        throw Exception(
          'Failed to get categories: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error while getting categories: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while getting categories: $e');
    }
  }

  @override
  Future<Category> getCategory(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id');

      if (response.statusCode == 200) {
        return Category.fromMap(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get category: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while getting category: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while getting category: $e');
    }
  }

  @override
  Future<Category> updateCategory(Category category) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/${category.id}',
        data: category.toMap(),
      );

      if (response.statusCode == 200) {
        return Category.fromMap(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to update category: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error while updating category: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while updating category: $e');
    }
  }
}
