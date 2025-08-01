// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'data/datasources/category_local_data_source.dart' as _i77;
import 'data/datasources/category_local_data_source_impl.dart' as _i983;
import 'data/datasources/category_remote_data_source.dart' as _i173;
import 'data/datasources/category_remote_data_source_impl.dart' as _i46;
import 'data/datasources/database_helper.dart' as _i443;
import 'data/repositories/category_repository_impl.dart' as _i1032;
import 'data/services/mock_categories_service.dart' as _i1017;
import 'data/services/mock_category_interceptor.dart' as _i0;
import 'domain/repositories/category_repository.dart' as _i615;
import 'domain/usecases/add_category.dart' as _i945;
import 'domain/usecases/delete_category.dart' as _i425;
import 'domain/usecases/get_categories.dart' as _i664;
import 'domain/usecases/get_category.dart' as _i677;
import 'domain/usecases/update_category.dart' as _i173;
import 'injection.dart' as _i464;
import 'presentation/blocs/category/category_bloc.dart' as _i815;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singletonAsync<_i443.DatabaseHelper>(
      () => _i443.DatabaseHelper.create(),
    );
    gh.lazySingleton<_i1017.MockCategoriesService>(
      () => _i1017.MockCategoriesService(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(gh<_i1017.MockCategoriesService>()),
    );
    gh.factoryAsync<_i77.CategoryLocalDataSource>(
      () async => _i983.CategoryLocalDataSourceImpl(
        await getAsync<_i443.DatabaseHelper>(),
      ),
    );
    gh.factory<_i173.CategoryRemoteDataSource>(
      () => _i46.CategoryRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i0.MockCategoryInterceptor>(
      () => _i0.MockCategoryInterceptor(gh<_i1017.MockCategoriesService>()),
    );
    gh.factoryAsync<_i615.CategoryRepository>(
      () async => _i1032.CategoryRepositoryImpl(
        localDataSource: await getAsync<_i77.CategoryLocalDataSource>(),
        remoteDataSource: gh<_i173.CategoryRemoteDataSource>(),
      ),
    );
    gh.factoryAsync<_i677.GetCategory>(
      () async => _i677.GetCategory(await getAsync<_i615.CategoryRepository>()),
    );
    gh.factoryAsync<_i173.UpdateCategory>(
      () async =>
          _i173.UpdateCategory(await getAsync<_i615.CategoryRepository>()),
    );
    gh.factoryAsync<_i664.GetCategories>(
      () async =>
          _i664.GetCategories(await getAsync<_i615.CategoryRepository>()),
    );
    gh.factoryAsync<_i945.AddCategory>(
      () async => _i945.AddCategory(await getAsync<_i615.CategoryRepository>()),
    );
    gh.factoryAsync<_i425.DeleteCategory>(
      () async =>
          _i425.DeleteCategory(await getAsync<_i615.CategoryRepository>()),
    );
    gh.factoryAsync<_i815.CategoryBloc>(
      () async => _i815.CategoryBloc(
        getCategories: await getAsync<_i664.GetCategories>(),
        getCategory: await getAsync<_i677.GetCategory>(),
        addCategory: await getAsync<_i945.AddCategory>(),
        updateCategory: await getAsync<_i173.UpdateCategory>(),
        deleteCategory: await getAsync<_i425.DeleteCategory>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}
