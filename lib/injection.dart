import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'data/services/mock_categories_service.dart';
import 'data/services/mock_category_interceptor.dart';

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
  Dio dio(MockCategoriesService localDataService) {
    final dio = Dio();
    dio.interceptors.add(MockCategoryInterceptor(localDataService));
    return dio;
  }
}
