
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'cart_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'chat_screen.dart';

// This screen controls the main navigation of the application.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This stores the currently selected screen.
  int _selectedIndex = 0;

  // This controls the PageView.
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Open the Firebase Chat List.
  void _openChatList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Shop',
      'Cart',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,

        // Display the logo and current screen title.
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Image.asset(
                'assets/images/nubdexchange_logo.png',
                height: 26.h,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.storefront,
                    size: 22,
                  );
                },
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              titles[_selectedIndex],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // Open the Settings screen.
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 24.sp,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // Display the main screens.
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ProductScreen(),
          CartScreen(),
          ProfileScreen(),
        ],
      ),

      // Show the Chat button only on the Shop screen.
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              heroTag: 'openChatButton',
              tooltip: 'Open Chat',
              onPressed: _openChatList,
              child: const Icon(Icons.message_outlined),
            )
          : null,

      // Keep the existing Shop, Cart, and Profile navigation.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
