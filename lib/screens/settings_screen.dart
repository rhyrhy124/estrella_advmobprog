import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

// This screen contains the settings of the application.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // This gets the current theme provider.
    final theme =
        Provider.of<ThemeProvider>(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),

      body: ListView(
        children: [
          // This allows the user to switch
          // between light mode and dark mode.
          SwitchListTile(
            title: const Text(
              'Dark Mode',
            ),

            // This shows the current theme status.
            subtitle: Text(
              theme.isDark
                  ? 'Dark theme enabled'
                  : 'Light theme enabled',
            ),

            // This shows the current switch value.
            value: theme.isDark,

            // This changes the theme.
            onChanged: (_) {
              theme.toggleTheme();
            },

            // This changes the icon depending
            // on the selected theme.
            secondary: Icon(
              theme.isDark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),

          const Divider(),

          // Enhancement 3:
          // Logout now uses UserService to remove
          // the saved user authentication data.
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),

            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            onTap: () async {
              // Show a confirmation dialog before logout.
              final shouldLogout =
                  await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Logout',
                    ),

                    content: const Text(
                      'Are you sure you want to logout?',
                    ),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            false,
                          );
                        },

                        child: const Text(
                          'Cancel',
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
                          );
                        },

                        child: const Text(
                          'Logout',
                        ),
                      ),
                    ],
                  );
                },
              );

              // Stop if the user cancelled.
              if (shouldLogout != true) {
                return;
              }

              try {
                // Enhancement 3:
                // Clear the saved user data from
                // SharedPreferences.
                await UserService().logout();

                if (!context.mounted) {
                  return;
                }

                // Clear the current cart from the app.
                context
                    .read<CartProvider>()
                    .clearCart();

                // Go back to the Login screen.
                Navigator.pushAndRemoveUntil(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const LoginScreen(),
                  ),

                  // This removes all previous screens.
                  (route) => false,
                );
              } catch (e) {
                if (!context.mounted) {
                  return;
                }

                // Show an error if logout fails.
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Logout failed: $e',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}