import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';
import 'home_screen.dart';

// This screen is used for logging in to the application.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

// This state controls the login screen inputs.
class _LoginScreenState
    extends State<LoginScreen> {
  // Email controller.
  final _emailController =
      TextEditingController();

  // Password controller.
  final _passwordController =
      TextEditingController();

  // This controls whether the password is hidden.
  bool _obscurePassword = true;

  // Selected DummyJSON user.
  int _selectedUserId = 1;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // This function runs when Login is pressed.
  void _login() {
    // Tell CartProvider which user is logged in.
    context
        .read<CartProvider>()
        .setUser(
          _selectedUserId,
        );

    // Go to HomeScreen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const HomeScreen(),
      ),
    );
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
              SizedBox(height: 30.h),

              // Bulldogs Exchange logo.
              Image.asset(
                'assets/images/nubdexchange_logo.png',
                height: 100.h,
              ),

              SizedBox(height: 25.h),

              // App name.
              CustomText(
                text:
                    'Bulldogs Exchange',
                fontSize: 27.sp,
                fontweight:
                    FontWeight.bold,
                textAlign:
                    TextAlign.center,
              ),

              SizedBox(height: 8.h),

              // Welcome message.
              CustomText(
                text:
                    'Welcome back, Bulldog!',
                fontSize: 14.sp,
                textAlign:
                    TextAlign.center,
              ),

              SizedBox(height: 35.h),

              // Email field.
              TextField(
                controller:
                    _emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration:
                    const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      Icon(
                    Icons.email_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 16.h),

              // Password field.
              TextField(
                controller:
                    _passwordController,
                obscureText:
                    _obscurePassword,
                decoration:
                    InputDecoration(
                  labelText: 'Password',
                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons
                              .visibility_off
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
                      const OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20.h),

              // Temporary user selector.
              //
              // This is only for selecting
              // which DummyJSON user will
              // own the cart.
              Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  'Select User',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              DropdownButtonFormField<int>(
                value: _selectedUserId,

                decoration:
                    const InputDecoration(
                  prefixIcon:
                      Icon(
                    Icons.person_outline,
                  ),
                  border:
                      OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child:
                        Text('User 1'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child:
                        Text('User 2'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child:
                        Text('User 3'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child:
                        Text('User 4'),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child:
                        Text('User 5'),
                  ),
                ],

                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedUserId =
                        value;
                  });
                },
              ),

              SizedBox(height: 25.h),

              // Login button.
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _login,
                  child: CustomText(
                    text: 'LOGIN',
                    fontSize: 16.sp,
                    fontweight:
                        FontWeight.bold,
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