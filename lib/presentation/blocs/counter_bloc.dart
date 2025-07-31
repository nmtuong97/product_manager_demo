import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/save_counter.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CounterEvent {}

class IncrementCounter extends CounterEvent {}

class DecrementCounter extends CounterEvent {}

class LoadCounter extends CounterEvent {}

@immutable
abstract class CounterState {}

class CounterInitial extends CounterState {}

class CounterLoaded extends CounterState {
  final int counter;

  CounterLoaded(this.counter);
}

class CounterError extends CounterState {
  final String message;

  CounterError(this.message);
}

@injectable
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  final GetCounter _getCounter;
  final SaveCounter _saveCounter;

  @factoryMethod
  CounterBloc(this._getCounter, this._saveCounter) : super(CounterInitial()) {
    on<LoadCounter>(_onLoadCounter);
    on<IncrementCounter>(_onIncrementCounter);
    on<DecrementCounter>(_onDecrementCounter);
  }

  Future<void> _onLoadCounter(
    LoadCounter event,
    Emitter<CounterState> emit,
  ) async {
    try {
      int? storedCounter = await _getCounter();
      if (storedCounter == null) {
        await _saveCounter(0);
        emit(CounterLoaded(0));
      } else {
        emit(CounterLoaded(storedCounter));
      }
    } catch (e) {
      emit(CounterError('Failed to load counter: ${e.toString()}'));
    }
  }

  Future<void> _onIncrementCounter(
    IncrementCounter event,
    Emitter<CounterState> emit,
  ) async {
    if (state is CounterLoaded) {
      final currentCounter = (state as CounterLoaded).counter;
      final newCounter = currentCounter + 1;
      await _saveCounter(newCounter);
      emit(CounterLoaded(newCounter));
    }
  }

  Future<void> _onDecrementCounter(
    DecrementCounter event,
    Emitter<CounterState> emit,
  ) async {
    if (state is CounterLoaded) {
      final currentCounter = (state as CounterLoaded).counter;
      final newCounter = currentCounter - 1;
      await _saveCounter(newCounter);
      emit(CounterLoaded(newCounter));
    }
  }
}
