import '../datasources/database_helper.dart';
import '../../domain/repositories/counter_repository.dart';
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
