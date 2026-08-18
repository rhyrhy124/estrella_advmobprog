import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';

// This is the starting point of the Flutter application.
Future<void> main() async {
  // This makes sure Flutter is ready before using other services.
  WidgetsFlutterBinding.ensureInitialized();

  // This loads the values from the .env file.
  await dotenv.load(fileName: '.env');

  // This makes the application use portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // This starts the Bulldogs Exchange application.
  runApp(
    MultiProvider(
      // These providers are available throughout the application.
      providers: [
        // This provider manages the app theme.
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        // This provider manages the shopping cart.
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],

      child: const BulldogsExchangeApp(),
    ),
  );
}

// This is the main widget of the Bulldogs Exchange application.
class BulldogsExchangeApp extends StatelessWidget {
  const BulldogsExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This listens for changes made to the theme.
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final theme = context.watch<ThemeProvider>();

        // This creates the main MaterialApp of the application.
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bulldogs Exchange',

          // This is the light theme of the application.
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor:
                const Color(0xFFFFF8FF),
          ),

          // This is the dark theme of the application.
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
          ),

          // This selects the theme based on the ThemeProvider value.
          themeMode: theme.isDark
              ? ThemeMode.dark
              : ThemeMode.light,

          // This is the first screen shown when the app starts.
          home: const LoginScreen(),
        );
      },
    );
  }
}