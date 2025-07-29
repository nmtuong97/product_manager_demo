abstract class CounterRepository {
  Future<int?> getCounter();
  Future<void> saveCounter(int counter);
}