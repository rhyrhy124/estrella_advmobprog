import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/theme_model.dart';


/// This screen changes the app theme.
/// It uses Provider because all app can use the theme.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Get theme data.
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Theme Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // This lets the screen scroll.
      // No more yellow overflow.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 20),

              // Big title.
              const Text(
                "Choose Your Theme",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Small text.
              const Text(
                "Pick what you like",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              // ===========================
              // Light Mode Card
              // ===========================
              Card(
                elevation: 5,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: SwitchListTile(

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),

                  secondary: Container(

                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      color: Colors.orange.withValues(alpha: .2),

                    ),

                    child: const Icon(
                      Icons.light_mode,
                      color: Colors.orange,
                    ),
                  ),

                  title: const Text(
                    "Light Mode",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Bright and happy",
                  ),

                  // ON if light mode.
                  value: themeModel.isLight,

                  onChanged: (value) {

                    if (value) {

                      // Turn on light mode.
                      themeModel.setLightMode();

                    } else {

                      // Turn on dark mode.
                      themeModel.setDarkMode();

                    }

                  },
                ),
              ),

              const SizedBox(height: 20),

              // ===========================
              // Dark Mode Card
              // ===========================
              Card(
                elevation: 5,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: SwitchListTile(

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),

                  secondary: Container(

                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      color: Colors.indigo.withValues(alpha: .2),

                    ),

                    child: const Icon(
                      Icons.dark_mode,
                      color: Colors.indigo,
                    ),
                  ),

                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Cool and easy eyes",
                  ),

                  // ON if dark mode.
                  value: themeModel.isDark,

                  onChanged: (value) {

                    if (value) {

                      // Turn on dark mode.
                      themeModel.setDarkMode();

                    } else {

                      // Turn on light mode.
                      themeModel.setLightMode();

                    }

                  },
                ),
              ),

              const SizedBox(height: 35),

              // Theme status card.
              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(20),

                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,

                ),

                child: Column(

                  children: [

                    Icon(

                      themeModel.isDark
                          ? Icons.dark_mode
                          : Icons.light_mode,

                      size: 60,

                    ),

                    const SizedBox(height: 15),

                    Text(

                      themeModel.isDark
                          ? "Dark Mode is ON"
                          : "Light Mode is ON",

                      style: const TextStyle(

                        fontSize: 22,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 8),

                    Text(

                      themeModel.isDark
                          ? "Good for night."
                          : "Good for day.",

                      style: const TextStyle(
                        fontSize: 16,
                      ),

                    ),

                  ],

                ),

              ),

              const SizedBox(height: 40),

              // Back button.
              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  onPressed: () {

                    // Go back.
                    Navigator.pop(context);

                  },

                  icon: const Icon(Icons.arrow_back),

                  label: const Text(
                    "Back",
                  ),

                  style: ElevatedButton.styleFrom(

                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),

                    shape: RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(15),

                    ),

                  ),

                ),

              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}