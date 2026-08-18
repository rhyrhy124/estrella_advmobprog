import 'package:flutter/material.dart';

// This provider is used to manage the app theme.
class ThemeProvider
    extends ChangeNotifier {
  bool _isDark = false;

  // This returns the current theme mode.
  bool get isDark => _isDark;

  // This changes the theme from light mode to dark mode and vice versa.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}