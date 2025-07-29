import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_manager_demo/presentation/blocs/counter_bloc.dart';

import 'package:product_manager_demo/injection.dart';
import 'package:product_manager_demo/presentation/pages/counter_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await getIt.allReady();

  final counterBloc = await getIt.getAsync<CounterBloc>();
  runApp(MyApp(counterBloc: counterBloc));
}

class MyApp extends StatelessWidget {
  final CounterBloc counterBloc;

  const MyApp({super.key, required this.counterBloc});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return BlocProvider.value(
          value: counterBloc..add(LoadCounter()),
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: const CounterPage(title: 'Flutter Demo Home Page'),
          ),
        );
      },
    );
  }
}
