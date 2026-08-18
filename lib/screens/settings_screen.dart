import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

// This screen contains the settings of the application.
class SettingsScreen extends StatelessWidget {
 const SettingsScreen({super.key});

 @override
 Widget build(BuildContext context) {
   // This gets the current theme provider.
   final theme =
       Provider.of<ThemeProvider>(
     context,
   );

   return Scaffold(
     appBar: AppBar(
       title:
           const Text('Settings'),
     ),

     body: ListView(
       children: [
         // ENHANCEMENT 3:
         // Added Settings page with Dark/Light mode switch.
         SwitchListTile(
           // This shows the name of the setting.
           title:
               const Text('Dark Mode'),

           // This shows the current theme status.
           subtitle: Text(
             theme.isDark
                 ? 'Dark theme enabled'
                 : 'Light theme enabled',
           ),

           // This gets the current dark mode value.
           value: theme.isDark,

           // This changes the theme when the switch is pressed.
           onChanged: (_) {
             theme.toggleTheme();
           },

           // This changes the icon depending on the current theme.
           secondary: Icon(
             theme.isDark
                 ? Icons.dark_mode
                 : Icons.light_mode,
           ),
         ),
       ],
     ),
   );
 }
}