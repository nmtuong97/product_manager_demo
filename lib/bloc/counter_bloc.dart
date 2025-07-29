import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:product_manager_demo/database_helper.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<LoadCounter>(_onLoadCounter);
    on<IncrementCounter>(_onIncrementCounter);
    on<DecrementCounter>(_onDecrementCounter);
  }

  Future<void> _onLoadCounter(LoadCounter event, Emitter<CounterState> emit) async {
    try {
      int? storedCounter = await DatabaseHelper.instance.getCounter();
      if (storedCounter == null) {
        await DatabaseHelper.instance.saveCounter(0);
        emit(CounterLoaded(0));
      } else {
        emit(CounterLoaded(storedCounter));
      }
    } catch (e) {
      emit(CounterError('Failed to load counter: ${e.toString()}'));
    }
  }

  Future<void> _onIncrementCounter(IncrementCounter event, Emitter<CounterState> emit) async {
    if (state is CounterLoaded) {
      final currentCounter = (state as CounterLoaded).counter;
      final newCounter = currentCounter + 1;
      await DatabaseHelper.instance.saveCounter(newCounter);
      emit(CounterLoaded(newCounter));
    }
  }

  Future<void> _onDecrementCounter(DecrementCounter event, Emitter<CounterState> emit) async {
    if (state is CounterLoaded) {
      final currentCounter = (state as CounterLoaded).counter;
      final newCounter = currentCounter - 1;
      await DatabaseHelper.instance.saveCounter(newCounter);
      emit(CounterLoaded(newCounter));
    }
  }
}