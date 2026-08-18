import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

// This is the main screen of the application.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

// This state controls the selected page in the home screen.
class _HomeScreenState
    extends State<HomeScreen> {

  // This stores the currently selected bottom navigation item.
  int _selectedIndex = 0;

  // This controller is used to control the pages.
  final PageController _pageController =
      PageController();

  @override
  void dispose() {
    // This removes the page controller when the screen is closed.
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // These are the titles for each page.
    final titles = [
      'Shop',
      'Cart',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            Image.asset(
              'assets/images/nubdexchange_logo.png',
              height: 32.h,
              errorBuilder:
                  (_, __, ___) {
                return const Icon(
                  Icons.storefront,
                );
              },
            ),

            SizedBox(width: 8.w),

            Text(
              titles[_selectedIndex],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),

        actions: [
          // This button opens the settings screen.
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 24.sp,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // This contains the main pages of the application.
      body: PageView(
        controller: _pageController,

        physics:
            const NeverScrollableScrollPhysics(),

        children: const [
          ProductScreen(),
          CartScreen(),
          ProfileScreen(),
        ],
      ),

      // This is the bottom navigation bar of the application.
      bottomNavigationBar:
          Consumer<CartProvider>(
        builder:
            (context, cart, child) {

          return BottomNavigationBar(
            currentIndex:
                _selectedIndex,

            // This changes the selected page.
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });

              _pageController.jumpToPage(
                index,
              );
            },

            items: [
              const BottomNavigationBarItem(
                icon:
                    Icon(Icons.storefront),
                label: 'Shop',
              ),

              // This shows the number of items in the cart.
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible:
                      cart.itemCount > 0,
                  label: Text(
                    '${cart.itemCount}',
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                  ),
                ),
                label: 'Cart',
              ),

              const BottomNavigationBarItem(
                icon:
                    Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}