import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// Enhancement 2:
// This screen handles user login using UserService.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  // Username controller.
  final _usernameController =
      TextEditingController();

  // Password controller.
  final _passwordController =
      TextEditingController();

  // This controls password visibility.
  bool _obscurePassword = true;

  // This controls the loading state.
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // Enhancement 2:
  // This handles the login process.
  Future<void> _login() async {
    if (_usernameController.text
            .trim()
            .isEmpty ||
        _passwordController.text
            .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your username and password.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userService =
        UserService();

    try {
      // Enhancement 2:
      // Login through the API.
      final response =
          await userService.loginUser(
        _usernameController.text
            .trim(),
        _passwordController.text,
      );

      // Enhancement 3:
      // Get the logged-in user's ID.
      final userId =
          response['id'] ?? 1;

      // Enhancement 3:
      // Load the cart belonging to the
      // currently logged-in user.
      context
          .read<CartProvider>()
          .setUser(userId);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      // Enhancement 2:
      // Go to the Home screen after successful login.
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: response,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      // Extract a user-friendly message from the
      // exception so we never show raw stack
      // traces or the entire response body.
      final raw =
          e.toString();

      String friendly;

      if (raw.contains(
        'SocketException',
      ) ||
          raw.contains(
        'Failed host lookup',
      ) ||
          raw.contains(
        'Network is unreachable',
      )) {
        friendly =
            'No internet connection. Please check your network and try again.';
      } else if (raw.contains(
        'TimeoutException',
      ) ||
          raw.contains(
        'timed out',
      )) {
        friendly =
            'The server took too long to respond. Please try again.';
      } else if (raw.contains(
        '400',
      ) ||
          raw.contains(
        '401',
      ) ||
          raw.contains(
        'Invalid credentials',
      )) {
        friendly =
            'Invalid username or password.';
      } else {
        friendly =
            'Login failed. Please try again later.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            friendly,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(
            horizontal: 28.w,
            vertical: 40.h,
          ),

          child: Column(
            children: [
              SizedBox(height: 35.h),

              Image.asset(
                'assets/images/nubdexchange_logo.png',
                height: 100.h,
                errorBuilder:
                    (_, __, ___) {
                  return Icon(
                    Icons.storefront,
                    size: 90.sp,
                  );
                },
              ),

              SizedBox(height: 25.h),

              CustomText(
                text:
                    'Bulldog Market',
                fontSize: 30.sp,
                fontweight:
                    FontWeight.bold,
                textAlign:
                    TextAlign.center,
                letterSpacing: 0.5,
              ),

              SizedBox(height: 6.h),

              CustomText(
                text:
                    'Welcome back, Bulldog! Shop your favorites today.',
                fontSize: 13.sp,
                textAlign:
                    TextAlign.center,
              ),

              SizedBox(height: 35.h),

              // Enhancement 2:
              // Username field used by the authentication API.
              TextField(
                controller:
                    _usernameController,
                decoration:
                    InputDecoration(
                  labelText:
                      'Username',

                  prefixIcon:
                      const Icon(
                    Icons.person_outline,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
                    ),
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
                    ),
                    borderSide:
                        BorderSide(
                      color: Colors
                          .grey
                          .shade300,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
                    ),
                    borderSide:
                        BorderSide(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary,
                      width: 1.5,
                    ),
                  ),

                  contentPadding:
                      EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 14.w,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              TextField(
                controller:
                    _passwordController,

                obscureText:
                    _obscurePassword,

                decoration:
                    InputDecoration(
                  labelText:
                      'Password',

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),

                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
                    ),
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
                    ),
                    borderSide:
                        BorderSide(
                      color: Colors
                          .grey
                          .shade300,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
                    ),
                    borderSide:
                        BorderSide(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary,
                      width: 1.5,
                    ),
                  ),

                  contentPadding:
                      EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 14.w,
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              SizedBox(
                width:
                    double.infinity,

                height: 52.h,

                child:
                    ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _login,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(
                      context,
                    )
                            .colorScheme
                            .primary,
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        Theme.of(
                      context,
                    )
                            .colorScheme
                            .primary
                            .withOpacity(
                              0.5,
                            ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12.r,
                      ),
                    ),
                    elevation: 0,
                  ),

                  child:
                      _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style:
                                  TextStyle(
                                fontFamily:
                                    'Poppins',
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors
                                    .white,
                                letterSpacing:
                                    0.5,
                              ),
                            ),
                ),
              ),

              SizedBox(height: 20.h),

              CustomText(
                text:
                    "Don't have an account? Sign Up",
                fontSize: 13.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}