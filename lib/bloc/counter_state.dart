part of 'counter_bloc.dart';

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