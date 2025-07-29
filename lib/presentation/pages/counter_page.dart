import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_manager_demo/presentation/blocs/counter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, title),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButtons(context),
    );
  }

  AppBar _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have pushed the button this many times:'),
          _buildCounterDisplay(),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay() {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        if (state is CounterInitial) {
          return const CircularProgressIndicator();
        } else if (state is CounterLoaded) {
          return Text(
            '${state.counter}',
            style: Theme.of(context).textTheme.headlineMedium,
          );
        } else if (state is CounterError) {
          return Text('Error: ${state.message}');
        }
        return const Text('Unknown state');
      },
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: () => context.read<CounterBloc>().add(DecrementCounter()),
          tooltip: 'Decrement',
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: () => context.read<CounterBloc>().add(IncrementCounter()),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
