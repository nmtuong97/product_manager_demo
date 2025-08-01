import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'injection.dart';
import 'core/services/initialization_service.dart';
import 'presentation/blocs/category/category_barrel.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // Đợi tất cả dependencies async sẵn sàng
  await getIt.allReady();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        375,
        812,
      ), // Updated to iPhone X size for better modern device support
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true, // Ensure screen size is properly calculated
      builder: (_, child) {
        return FutureBuilder<List<dynamic>>(
          future: getIt.getAsync<InitializationService>().then((initService) => 
            initService.initialize().then((_) => Future.wait([
              getIt.getAsync<CategoryBloc>(),
              getIt.getAsync<ProductBloc>(),
            ]))
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                ),
              );
            }

            final categoryBloc = snapshot.data![0] as CategoryBloc;
            final productBloc = snapshot.data![1] as ProductBloc;

            return MultiBlocProvider(
              providers: [
                BlocProvider<CategoryBloc>.value(value: categoryBloc),
                BlocProvider<ProductBloc>.value(value: productBloc),
              ],
              child: MaterialApp(
                title: 'Product Manager Demo',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                  ),
                  useMaterial3: true,
                ),
                home: const HomePage(),
              ),
            );
          },
        );
      },
    );
  }
}
