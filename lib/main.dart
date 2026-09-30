import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated configuration.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(
    fileName: '.env',
  );

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
      child: const BulldogMarketApp(),
    ),
  );
}

class BulldogMarketApp extends StatelessWidget {
  const BulldogMarketApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final theme = context.watch<ThemeProvider>();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bulldog Market',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: const Color(0xFFFFF8FF),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
            fontFamily: 'Poppins',
          ),
          themeMode: theme.isDark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const SplashScreen(),
          routes: {
            '/signin': (_) => const LoginScreen(),
            '/home': (_) => const HomeScreen(),
          },
        );
      },
    );
  }
}