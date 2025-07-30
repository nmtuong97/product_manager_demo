// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'data/datasources/database_helper.dart' as _i443;
import 'data/repositories/category_repository_impl.dart' as _i1032;
import 'data/repositories/counter_repository_impl.dart' as _i86;
import 'domain/repositories/category_repository.dart' as _i615;
import 'domain/repositories/counter_repository.dart' as _i123;
import 'domain/usecases/add_category.dart' as _i945;
import 'domain/usecases/delete_category.dart' as _i425;
import 'domain/usecases/get_categories.dart' as _i664;
import 'domain/usecases/get_category.dart' as _i677;
import 'domain/usecases/get_counter.dart' as _i825;
import 'domain/usecases/save_counter.dart' as _i647;
import 'domain/usecases/update_category.dart' as _i173;
import 'presentation/blocs/category/category_bloc.dart' as _i815;
import 'presentation/blocs/counter_bloc.dart' as _i565;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singletonAsync<_i443.DatabaseHelper>(
      () => _i443.DatabaseHelper.create(),
    );
    gh.lazySingletonAsync<_i615.CategoryRepository>(
      () async =>
          _i1032.CategoryRepositoryImpl(await getAsync<_i443.DatabaseHelper>()),
    );
    gh.lazySingletonAsync<_i123.CounterRepository>(
      () async =>
          _i86.CounterRepositoryImpl(await getAsync<_i443.DatabaseHelper>()),
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
    gh.lazySingletonAsync<_i815.CategoryBloc>(
      () async => _i815.CategoryBloc(
        await getAsync<_i664.GetCategories>(),
        await getAsync<_i677.GetCategory>(),
        await getAsync<_i945.AddCategory>(),
        await getAsync<_i173.UpdateCategory>(),
        await getAsync<_i425.DeleteCategory>(),
      ),
    );
    gh.factoryAsync<_i647.SaveCounter>(
      () async => _i647.SaveCounter(await getAsync<_i123.CounterRepository>()),
    );
    gh.factoryAsync<_i825.GetCounter>(
      () async => _i825.GetCounter(await getAsync<_i123.CounterRepository>()),
    );
    gh.factoryAsync<_i565.CounterBloc>(
      () async => _i565.CounterBloc(
        await getAsync<_i825.GetCounter>(),
        await getAsync<_i647.SaveCounter>(),
      ),
    );
    return this;
  }
}
