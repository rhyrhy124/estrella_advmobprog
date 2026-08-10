import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/theme_model.dart';
import 'screens/counter_screen.dart';


/// This is where the app starts.
/// It creates the ThemeModel so the app can change theme.
void main() {

  runApp(

    // Provider shares ThemeModel with all screens.
    ChangeNotifierProvider(

      create: (context) => ThemeModel(),

      child:
          const MyApp(),

    ),


  );


}

/// This is the main app widget.
/// It listens to ThemeModel.
/// When theme changes, the whole app changes.
class MyApp extends StatelessWidget {


  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {



    // Gets the current theme data.
    final themeModel =
        Provider.of<ThemeModel>(context);

    return MaterialApp(

      // Removes the debug label.
      debugShowCheckedModeBanner:false,

      title:
          "Ephemeral and App State",

      // Light Theme Design
      theme:
          ThemeData(

        useMaterial3:true,


        brightness:
            Brightness.light,



        colorScheme:
            ColorScheme.fromSeed(


          seedColor:
              Colors.blue,



        ),



        appBarTheme:
            const AppBarTheme(


          centerTitle:true,


          elevation:0,


        ),



      ),

      // Dark Theme Design
      darkTheme:
          ThemeData(

        useMaterial3:true,



        brightness:
            Brightness.dark,



        colorScheme:
            ColorScheme.fromSeed(


          seedColor:
              Colors.blue,


          brightness:
              Brightness.dark,


        ),




        appBarTheme:
            const AppBarTheme(


          centerTitle:true,


          elevation:0,


        ),



      ),


      // Choose which theme to show.
      themeMode:

          themeModel.isDark

              ? ThemeMode.dark

              : ThemeMode.light,


      // First screen of the app.
      home:
          const CounterScreen(),



    );


  }


}