import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'mock_categories_service.dart';
import '../../domain/entities/category.dart';

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
    if (options.path == '/categories') {
      if (options.method == 'GET') {
        final categories = await _mockService.readData('categories.json');
        handler.resolve(
          Response(requestOptions: options, data: categories, statusCode: 200),
        );
      } else if (options.method == 'POST') {
        final data = options.data as Map<String, dynamic>;
        final newCategory = Category(
          id: _nextId++,
          name: data['name'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        final categories = await _mockService.readData('categories.json');
        categories.add(newCategory.toMap());
        await _mockService.writeData('categories.json', categories);
        handler.resolve(
          Response(
            requestOptions: options,
            data: newCategory.toMap(),
            statusCode: 201,
          ),
        );
      }
    } else if (options.path.startsWith('/categories/')) {
      final id = int.parse(options.path.split('/').last);
      if (options.method == 'PUT') {
        final data = options.data as Map<String, dynamic>;
        final updatedCategory = Category(
          id: id,
          name: data['name'],
          createdAt: data['createdAt'],
          updatedAt: DateTime.now().toIso8601String(),
        );
        final categories = await _mockService.readData('categories.json');
        final index = categories.indexWhere((c) => c['id'] == id);
        if (index != -1) {
          categories[index] = updatedCategory.toMap();
          await _mockService.writeData('categories.json', categories);
          handler.resolve(
            Response(
              requestOptions: options,
              data: updatedCategory.toMap(),
              statusCode: 200,
            ),
          );
        } else {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                data: {'message': 'Category not found'},
                statusCode: 404,
              ),
            ),
          );
        }
      } else if (options.method == 'DELETE') {
        final categories = await _mockService.readData('categories.json');
        final index = categories.indexWhere((c) => c['id'] == id);
        if (index != -1) {
          categories.removeAt(index);
          await _mockService.writeData('categories.json', categories);
          handler.resolve(Response(requestOptions: options, statusCode: 204));
        } else {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                data: {'message': 'Category not found'},
                statusCode: 404,
              ),
            ),
          );
        }
      }
    }
  }
}
