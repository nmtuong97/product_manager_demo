import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'injection.dart';
import 'presentation/blocs/category/category_barrel.dart';
import 'presentation/pages/home_page.dart';
import 'package:product_manager_demo/presentation/blocs/counter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Đợi tất cả dependencies async sẵn sàng
  await getIt.allReady();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return FutureBuilder<CategoryBloc>(
          future: getIt.getAsync<CategoryBloc>(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            
            if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ),
              );
            }
            
            return MultiBlocProvider(
              providers: [
                BlocProvider<CategoryBloc>.value(
                  value: snapshot.data!,
                ),
              ],
              child: FutureBuilder<CounterBloc>(
                future: getIt.getAsync<CounterBloc>(),
                builder: (context, counterSnapshot) {
                  if (counterSnapshot.connectionState == ConnectionState.waiting) {
                    return const MaterialApp(
                      home: Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  if (counterSnapshot.hasError) {
                    return MaterialApp(
                      home: Scaffold(
                        body: Center(
                          child: Text('Error: ${counterSnapshot.error}'),
                        ),
                      ),
                    );
                  }

                  return BlocProvider<CounterBloc>.value(
                    value: counterSnapshot.data!,
                    child: MaterialApp(
                      title: 'Product Manager Demo',
                      theme: ThemeData(
                        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                        useMaterial3: true,
                      ),
                      home: const HomePage(),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
