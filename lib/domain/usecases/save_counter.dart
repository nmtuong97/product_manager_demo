import '../repositories/counter_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveCounter {
  final CounterRepository repository;

  SaveCounter(this.repository);

  Future<void> call(int counter) {
    return repository.saveCounter(counter);
  }
}
