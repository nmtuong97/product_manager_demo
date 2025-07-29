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
import 'data/repositories/counter_repository_impl.dart' as _i86;
import 'domain/repositories/counter_repository.dart' as _i123;
import 'domain/usecases/get_counter.dart' as _i825;
import 'domain/usecases/save_counter.dart' as _i647;
import 'presentation/blocs/counter_bloc.dart' as _i565;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingletonAsync<_i443.DatabaseHelper>(
      () => _i443.DatabaseHelper.create(),
    );
    gh.lazySingletonAsync<_i123.CounterRepository>(
      () async =>
          _i86.CounterRepositoryImpl(await getAsync<_i443.DatabaseHelper>()),
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
