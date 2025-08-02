import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'mock_categories_service.dart';
import '../../domain/entities/category.dart';

const _basePath = '/api/categories';
const _categoriesFile = 'categories.json';

@injectable
class MockCategoryInterceptor extends Interceptor {
  final MockCategoriesService _mockService;
  int _nextId = 9;

  MockCategoryInterceptor(this._mockService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    if (!options.path.startsWith(_basePath)) {
      return super.onRequest(options, handler);
    }

    final segments = options.path.split('/');
    final isCollection = segments.length == 3; // ['', 'api', 'categories']

    if (isCollection) {
      return _handleCollectionRequest(options, handler);
    }

    final id = int.tryParse(segments.last);
    if (id == null) {
      return handler.reject(_badRequest(options, 'Invalid category ID'));
    }

    return _handleResourceRequest(id, options, handler);
  }

  Future<void> _handleCollectionRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    switch (options.method) {
      case 'GET':
        return _getCategories(options, handler);
      case 'POST':
        return _createCategory(options, handler);
      default:
        return super.onRequest(options, handler);
    }
  }

  Future<void> _handleResourceRequest(
    int id,
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    switch (options.method) {
      case 'PUT':
        return _updateCategory(id, options, handler);
      case 'DELETE':
        return _deleteCategory(id, options, handler);
      default:
        return super.onRequest(options, handler);
    }
  }

  Future<void> _getCategories(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final categories = await _mockService.readData(_categoriesFile);
    handler.resolve(
      Response(requestOptions: options, data: categories, statusCode: 200),
    );
  }

  Future<void> _createCategory(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final data = options.data as Map<String, dynamic>;
    final newCategory = Category(
      id: _nextId++,
      name: data['name'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final categories = await _mockService.readData(_categoriesFile);
    categories.add(newCategory.toMap());
    await _mockService.writeData(_categoriesFile, categories);
    handler.resolve(
      Response(
        requestOptions: options,
        data: newCategory.toMap(),
        statusCode: 201,
      ),
    );
  }

  Future<void> _updateCategory(
    int id,
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final data = options.data as Map<String, dynamic>;
    final categories = await _mockService.readData(_categoriesFile);
    final index = categories.indexWhere((c) => c['id'] == id);

    if (index == -1) {
      return handler.reject(_notFound(options));
    }

    final updatedCategory = Category(
      id: id,
      name: data['name'],
      createdAt: DateTime.parse(
        categories[index]['createdAt'],
      ), // Keep original creation date
      updatedAt: DateTime.now(),
    );

    categories[index] = updatedCategory.toMap();
    await _mockService.writeData(_categoriesFile, categories);

    handler.resolve(
      Response(
        requestOptions: options,
        data: updatedCategory.toMap(),
        statusCode: 200,
      ),
    );
  }

  Future<void> _deleteCategory(
    int id,
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final categories = await _mockService.readData(_categoriesFile);
    final index = categories.indexWhere((c) => c['id'] == id);

    if (index == -1) {
      return handler.reject(_notFound(options));
    }

    categories.removeAt(index);
    await _mockService.writeData(_categoriesFile, categories);
    handler.resolve(Response(requestOptions: options, statusCode: 204));
  }

  DioException _badRequest(RequestOptions options, String message) {
    return DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        data: {'message': message},
        statusCode: 400,
      ),
    );
  }

  DioException _notFound(RequestOptions options) {
    return DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        data: {'message': 'Category not found'},
        statusCode: 404,
      ),
    );
  }
}
