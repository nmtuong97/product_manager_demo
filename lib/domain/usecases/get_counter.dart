import 'package:product_manager_demo/domain/repositories/counter_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCounter {
  final CounterRepository repository;

  GetCounter(this.repository);

  Future<int?> call() {
    return repository.getCounter();
  }
}