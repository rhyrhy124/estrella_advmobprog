import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_busy) return;

    _busy = true;

    if (mounted) {
      setState(() => _error = null);
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 1500),
    );

    if (!mounted) return;

    final cart = context.read<CartProvider>();
    final service = UserService();

    try {
      if (!await service.isLoggedIn()) {
        if (!mounted) return;

        cart.resetSession();

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/signin',
          (_) => false,
        );

        return;
      }

      final data = await service.refreshUser();

      if (!mounted) return;

      if (data['loginType'] == 'firebase') {
        cart.setFirebaseUser(
          data['uid'] as String,
        );
      } else {
        await cart.setUser(
          (data['id'] as num).toInt(),
        );
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (_) => false,
        arguments: data,
      );
    } catch (error) {
      // Do not remove a valid session because of a network error.
      if (mounted) {
        setState(() {
          _error =
              UserService.errorMessage(error);
        });
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _loginInstead() async {
    if (_busy) return;

    final cart = context.read<CartProvider>();

    setState(() => _busy = true);

    try {
      await UserService().logout();

      if (!mounted) return;

      cart.resetSession();

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              UserService.errorMessage(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  height: 110.h,
                  errorBuilder:
                      (context, error, trace) {
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
                    fontWeight: FontWeight.bold,
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

                if (_error == null)
                  const CircularProgressIndicator()
                else ...[
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed:
                        _busy ? null : _initialize,
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed:
                        _busy ? null : _loginInstead,
                    child: const Text(
                      'Go to login',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}