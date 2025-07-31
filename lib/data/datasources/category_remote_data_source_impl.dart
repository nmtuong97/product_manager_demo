import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/category.dart';
import 'category_remote_data_source.dart';

@LazySingleton(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio _dio;

  CategoryRemoteDataSourceImpl(this._dio);

  @override
  Future<Category> addCategory(Category category) async {
    final response = await _dio.post('/categories', data: category.toMap());
    return Category.fromMap(response.data);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _dio.delete('/categories/$id');
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/categories');
    return (response.data as List).map((e) => Category.fromMap(e)).toList();
  }

  @override
  Future<Category> getCategory(int id) async {
    // This method might not be needed on the remote side depending on the API design.
    // For now, we'll assume it exists.
    final response = await _dio.get('/categories/$id');
    return Category.fromMap(response.data);
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final response = await _dio.put(
      '/categories/${category.id}',
      data: category.toMap(),
    );
    return Category.fromMap(response.data);
  }
}
