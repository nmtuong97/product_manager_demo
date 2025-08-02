import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'core/mock/mock_category_interceptor.dart';
import 'core/mock/mock_product_interceptor.dart';
import 'data/services/mock_categories_service.dart';
import 'data/services/mock_products_service.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio(
    MockCategoriesService categoriesService,
    MockProductsService productsService,
  ) {
    final dio = Dio();
    dio.interceptors.add(MockCategoryInterceptor(categoriesService));
    dio.interceptors.add(MockProductInterceptor(productsService));
    return dio;
  }
}
