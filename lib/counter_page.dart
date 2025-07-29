import 'package:flutter/material.dart';
import 'package:product_manager_demo/database_helper.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late Future<int?> _counterFuture;

  @override
  void initState() {
    super.initState();
    _counterFuture = _loadCounter();
  }

  Future<int?> _loadCounter() async {
    int? storedCounter = await DatabaseHelper.instance.getCounter();
    if (storedCounter == null) {
      await DatabaseHelper.instance.saveCounter(0);
      return 0;
    }
    return storedCounter;
  }

  void _incrementCounter() async {
    setState(() {
      _counterFuture = _updateCounter((currentCount) => currentCount + 1);
    });
  }

  void _decrementCounter() async {
    setState(() {
      _counterFuture = _updateCounter((currentCount) => currentCount - 1);
    });
  }

  Future<int?> _updateCounter(int Function(int) updateFunction) async {
    int currentCount = (await _counterFuture) ?? 0;
    int newCount = updateFunction(currentCount);
    await DatabaseHelper.instance.saveCounter(newCount);
    return newCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have pushed the button this many times:'),
          _buildCounterDisplay(context),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay(BuildContext context) {
    return FutureBuilder<int?>(
      future: _counterFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Text(
            '${snapshot.data ?? 0}',
            style: Theme.of(context).textTheme.headlineMedium,
          );
        }
      },
    );
  }

  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: _decrementCounter,
          tooltip: 'Decrement',
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}