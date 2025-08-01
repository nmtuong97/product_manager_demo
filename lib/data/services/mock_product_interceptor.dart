import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'mock_products_service.dart';
import '../../domain/entities/product.dart';

const _basePath = '/products';

@injectable
class MockProductInterceptor extends Interceptor {
  final MockProductsService _mockService;

  MockProductInterceptor(this._mockService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;

    // Check if this is a product API request
    if (!path.contains(_basePath)) {
      return handler.next(options);
    }

    try {
      switch (options.method.toUpperCase()) {
        case 'GET':
          await _handleGetRequest(options, handler);
          break;
        case 'POST':
          await _handlePostRequest(options, handler);
          break;
        case 'PUT':
          await _handlePutRequest(options, handler);
          break;
        case 'DELETE':
          await _handleDeleteRequest(options, handler);
          break;
        default:
          handler.reject(_methodNotAllowed(options));
      }
    } catch (e) {
      handler.reject(_internalServerError(options, e.toString()));
    }
  }

  Future<void> _handleClearAllProducts(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      await _mockService.clearAllProducts();
      handler.resolve(
        _successResponse(options, {
          'message': 'All products cleared successfully',
        }),
      );
    } catch (e) {
      handler.reject(_internalServerError(options, e.toString()));
    }
  }

  Future<void> _handleGetRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final queryParams = options.queryParameters;

    // Handle search endpoint: /api/products/search
    if (path.contains('/search')) {
      final query = queryParams['search'] as String? ?? '';
      final categoryId = queryParams['category_id'] as int?;

      List<Product> products;
      if (categoryId != null) {
        final categoryProducts = await _mockService.getProductsByCategory(categoryId);
        products = categoryProducts
                .where(
                  (p) =>
                      query.isEmpty ||
                      p.name.toLowerCase().contains(query.toLowerCase()) ||
                      (p.description?.toLowerCase().contains(
                            query.toLowerCase(),
                          ) ??
                          false),
                )
                .toList();
      } else {
        products = await _mockService.searchProducts(query);
      }

      handler.resolve(
        _successResponse(options, {
          'data': products.map((p) => p.toMap()).toList(),
        }),
      );
      return;
    }

    // Extract ID from path if present
    final pathSegments = path.split('/');
    final productIdIndex = pathSegments.indexOf('products') + 1;

    if (productIdIndex < pathSegments.length) {
      // Get specific product: /api/products/{id}
      final idStr = pathSegments[productIdIndex];
      final id = int.tryParse(idStr);

      if (id == null) {
        handler.reject(_badRequest(options, 'Invalid product ID'));
        return;
      }

      final product = await _mockService.getProductById(id);
      if (product == null) {
        handler.reject(_notFound(options));
        return;
      }

      handler.resolve(_successResponse(options, {'data': product.toMap()}));
    } else {
      // Get all products: /api/products
      final categoryId = queryParams['category_id'] as int?;
      List<Product> products;

      if (categoryId != null) {
        products = await _mockService.getProductsByCategory(categoryId);
      } else {
        products = await _mockService.getAllProducts();
      }

      handler.resolve(
        _successResponse(options, {
          'data': products.map((p) => p.toMap()).toList(),
        }),
      );
    }
  }

  Future<void> _handlePostRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final pathSegments = path.split('/');
    
    // Handle clear all products endpoint: /api/products/clear-all
    if (pathSegments.contains('clear-all')) {
      await _handleClearAllProducts(options, handler);
      return;
    }
    
    // Handle image upload endpoint: /api/products/{id}/images
    if (path.contains('/images')) {
      final productIdIndex = pathSegments.indexOf('products') + 1;
      
      if (productIdIndex >= pathSegments.length) {
        handler.reject(_badRequest(options, 'Product ID is required'));
        return;
      }
      
      final idStr = pathSegments[productIdIndex];
      final id = int.tryParse(idStr);
      

      
      if (id == null) {

        handler.reject(_badRequest(options, 'Invalid product ID'));
        return;
      }
      
      try {
        // Get the number of images from request data
        final data = options.data as Map<String, dynamic>?;
        final imagesList = data?['images'] as List?;
        final imageCount = imagesList?.length ?? 1;
        

        
        final updatedImages = await _mockService.uploadProductImages(id, imageCount: imageCount);
        
        if (updatedImages == null) {

          handler.reject(_notFound(options));
          return;
        }
        

        
        handler.resolve(
          _successResponse(options, {
            'data': {
              'images': updatedImages,
              'message': 'Images uploaded successfully'
            },
          }, statusCode: 200),
        );
      } catch (e) {

        handler.reject(_badRequest(options, 'Failed to upload images: $e'));
      }
      return;
    }
    
    // Handle regular product creation
    final data = options.data as Map<String, dynamic>?;

    if (data == null) {
      handler.reject(_badRequest(options, 'Request body is required'));
      return;
    }

    try {
      final product = Product.fromMap(data);
      final createdProduct = await _mockService.addProduct(product);

      handler.resolve(
        _successResponse(options, {
          'data': createdProduct.toMap(),
        }, statusCode: 201),
      );
    } catch (e) {
      handler.reject(_badRequest(options, 'Invalid product data: $e'));
    }
  }

  Future<void> _handlePutRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final pathSegments = options.path.split('/');
    final productIdIndex = pathSegments.indexOf('products') + 1;

    if (productIdIndex >= pathSegments.length) {
      handler.reject(_badRequest(options, 'Product ID is required'));
      return;
    }

    final idStr = pathSegments[productIdIndex];
    final id = int.tryParse(idStr);

    if (id == null) {
      handler.reject(_badRequest(options, 'Invalid product ID'));
      return;
    }

    final data = options.data as Map<String, dynamic>?;
    if (data == null) {
      handler.reject(_badRequest(options, 'Request body is required'));
      return;
    }

    try {
      final product = Product.fromMap({...data, 'id': id});
      final updatedProduct = await _mockService.updateProduct(product);

      if (updatedProduct == null) {
        handler.reject(_notFound(options));
        return;
      }

      handler.resolve(
        _successResponse(options, {'data': updatedProduct.toMap()}),
      );
    } catch (e) {
      handler.reject(_badRequest(options, 'Invalid product data: $e'));
    }
  }

  Future<void> _handleDeleteRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final pathSegments = options.path.split('/');
    final productIdIndex = pathSegments.indexOf('products') + 1;

    if (productIdIndex >= pathSegments.length) {
      handler.reject(_badRequest(options, 'Product ID is required'));
      return;
    }

    final idStr = pathSegments[productIdIndex];
    final id = int.tryParse(idStr);

    if (id == null) {
      handler.reject(_badRequest(options, 'Invalid product ID'));
      return;
    }

    final deleted = await _mockService.deleteProduct(id);
    if (!deleted) {
      handler.reject(_notFound(options));
      return;
    }

    handler.resolve(
      _successResponse(options, {
        'message': 'Product deleted successfully',
      }, statusCode: 204),
    );
  }

  Response _successResponse(
    RequestOptions options,
    Map<String, dynamic> data, {
    int statusCode = 200,
  }) {
    return Response(
      requestOptions: options,
      data: data,
      statusCode: statusCode,
      headers: Headers.fromMap({
        'content-type': ['application/json'],
      }),
    );
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
        data: {'message': 'Product not found'},
        statusCode: 404,
      ),
    );
  }

  DioException _methodNotAllowed(RequestOptions options) {
    return DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        data: {'message': 'Method not allowed'},
        statusCode: 405,
      ),
    );
  }

  DioException _internalServerError(RequestOptions options, String error) {
    return DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        data: {'message': 'Internal server error: $error'},
        statusCode: 500,
      ),
    );
  }
}
