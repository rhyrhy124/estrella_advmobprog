import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: const BulldogsExchangeApp(),
    ),
  );
}

class BulldogsExchangeApp extends StatelessWidget {
  const BulldogsExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final theme =
            context.watch<ThemeProvider>();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bulldogs Exchange',

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor:
                const Color(0xFFFFF8FF),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
          ),

          themeMode: theme.isDark
              ? ThemeMode.dark
              : ThemeMode.light,

          home: const LoginScreen(),
        );
      },
    );
  }
}