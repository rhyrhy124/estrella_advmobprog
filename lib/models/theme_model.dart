import 'package:flutter/material.dart';


/// This class controls the theme of the app.
/// It can change the app from light mode to dark mode.
class ThemeModel with ChangeNotifier {


  // This keeps the current theme.
  // false means light mode.
  // true means dark mode.
  bool _isDark = false;



  // This gets the dark mode value.
  bool get isDark => _isDark;



  // This checks if the app is light mode.
  bool get isLight => !_isDark;




  /// This turns the app into dark mode.
  void setDarkMode() {


    // Make dark mode true.
    _isDark = true;


    // Tell the app that something changed.
    notifyListeners();

  }





  /// This turns the app into light mode.
  void setLightMode() {


    // Make dark mode false.
    _isDark = false;


    // Update the app.
    notifyListeners();

  }





  /// This changes the theme.
  /// If dark is ON, it will become OFF.
  /// If dark is OFF, it will become ON.
  void toggleTheme() {


    // Reverse the current value.
    _isDark = !_isDark;


    // Refresh the app screen.
    notifyListeners();

  }

}