import 'package:product_manager_demo/data/datasources/database_helper.dart';
import 'package:product_manager_demo/domain/repositories/counter_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CounterRepository)
class CounterRepositoryImpl implements CounterRepository {
  final DatabaseHelper databaseHelper;

  CounterRepositoryImpl(this.databaseHelper);

  @override
  Future<int?> getCounter() {
    return databaseHelper.getCounter();
  }

  @override
  Future<void> saveCounter(int counter) {
    return databaseHelper.saveCounter(counter);
  }
}