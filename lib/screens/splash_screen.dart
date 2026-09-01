import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Enhancement 1:
// This screen shows the app logo before redirecting
// to the Login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _goToLogin();
  }

  // Waits for the splash duration, then navigates
  // to the Login screen.
  Future<void> _goToLogin() async {
    // This gives the splash screen time to display.
    await Future.delayed(
      const Duration(
        milliseconds: 1500,
      ),
    );

    if (!mounted) {
      return;
    }

    // Always go to the Login screen on startup so the
    // user is required to sign in every time the app is
    // opened. Previous sessions are not remembered.
    Navigator.pushReplacementNamed(
      context,
      '/signin',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                // Enhancement 1:
                // Custom splash screen logo.
                Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  height: 110.h,
                  errorBuilder:
                      (_, __, ___) {
                    return Icon(
                      Icons.storefront,
                      size: 100.sp,
                    );
                  },
                ),

                SizedBox(height: 20.h),

                Text(
                  'Bulldog Market',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26.sp,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Exchange. Shop. Connect.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 30.h),

                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}