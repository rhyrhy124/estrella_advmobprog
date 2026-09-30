// Flutter packages used for the screen and design
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Files used for cart, user login, and custom text
import '../providers/cart_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// Sign up screen
import 'signup_screen.dart';

// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Gets the username or email entered by the user
  final _usernameController =
      TextEditingController();

  // Gets the password entered by the user
  final _passwordController =
      TextEditingController();

  // Hides the password by default
  bool _obscurePassword = true;

  // Checks if the login is still loading
  bool _isLoading = false;

  // DummyJSON is the default login type
  LoginType _loginType = LoginType.dummyJSON;

  @override
  void dispose() {
    // Clears the controllers when leaving the screen
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // Handles the login
  Future<void> _login() async {
    // Stops another login while it is still loading
    if (_isLoading) return;

    // Gets the username or email
    final identifier =
        _usernameController.text.trim();

    // Gets the password
    final password =
        _passwordController.text;

    // Checks if username/email or password is empty
    if (identifier.isEmpty || password.isEmpty) {
      _showMessage(
        _loginType == LoginType.firebase
            ? 'Please enter your email and password.'
            : 'Please enter your username and password.',
      );

      return;
    }

    // Checks if the Firebase email is valid
    if (_loginType == LoginType.firebase &&
        !RegExp(
          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
        ).hasMatch(identifier)) {
      _showMessage(
        'Please enter a valid email address.',
      );

      return;
    }

    // Gets the cart provider
    final cart = context.read<CartProvider>();

    // Creates the user service
    final service = UserService();

    // Saves the selected login type
    final type = _loginType;

    // Starts loading
    setState(() => _isLoading = true);

    try {
      // Stores the user data after login
      final Map<String, dynamic> response;

      // Login using Firebase
      if (type == LoginType.firebase) {
        await service.signIn(
          email: identifier,
          password: password,
        );

        // Gets the Firebase user data
        response = await service.getUserData();

        if (!mounted) return;

        // Sets the Firebase user for the cart
        cart.setFirebaseUser(
          response['uid'] as String,
        );
      } else {
        // Login using DummyJSON
        response = await service.loginUser(
          identifier,
          password,
        );

        // Gets the user ID
        final id = response['id'];

        // Checks if the user ID is valid
        if (id is! num) {
          throw StateError(
            'The API returned an invalid user ID.',
          );
        }

        if (!mounted) return;

        // Sets the DummyJSON user for the cart
        await cart.setUser(id.toInt());
      }

      if (!mounted) return;

      // Goes to the home screen after login
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (_) => false,
        arguments: response,
      );
    } catch (error) {
      // Shows a message if login fails
      if (mounted) {
        _showMessage(
          UserService.errorMessage(error),
        );
      }
    } finally {
      // Stops loading after login
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Handles forgot password for Firebase
  Future<void> _forgotPassword() async {
    // Gets the email from the text field
    final email =
        _usernameController.text.trim();

    // Checks if the email is valid
    if (!RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(email)) {
      _showMessage(
        'Enter your email address first.',
      );

      return;
    }

    // Starts loading
    setState(() => _isLoading = true);

    try {
      // Sends the password reset link
      await UserService().sendPasswordReset(
        email: email,
      );

      // Shows a message after sending
      if (mounted) {
        _showMessage(
          'If this email is registered, '
          'a reset link will be sent.',
        );
      }
    } catch (error) {
      // Shows an error message if something goes wrong
      if (mounted) {
        _showMessage(
          UserService.errorMessage(error),
        );
      }
    } finally {
      // Stops loading
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Shows a message at the bottom of the screen
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // Design used for the input fields
  InputDecoration _decoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,

      // Normal border
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.r),
      ),

      // Border when the field is not selected
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      // Border when the field is selected
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .primary,
          width: 1.5,
        ),
      ),

      // Space inside the input field
      contentPadding: EdgeInsets.symmetric(
        vertical: 16.h,
        horizontal: 14.w,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Checks if Firebase login is selected
    final firebase =
        _loginType == LoginType.firebase;

    return Scaffold(
      body: SafeArea(
        // Allows the page to scroll on smaller screens
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 28.w,
            vertical: 40.h,
          ),
          child: Column(
            children: [
              SizedBox(height: 35.h),

              // Bulldog Market logo
              Image.asset(
                'assets/images/nubdexchange_logo.png',
                height: 100.h,

                // Shows an icon if the logo cannot load
                errorBuilder:
                    (context, error, stackTrace) {
                  return Icon(
                    Icons.storefront,
                    size: 90.sp,
                  );
                },
              ),

              SizedBox(height: 25.h),

              // App name
              CustomText(
                text: 'Bulldog Market',
                fontSize: 30.sp,
                fontweight: FontWeight.bold,
                textAlign: TextAlign.center,
                letterSpacing: 0.5,
              ),

              SizedBox(height: 6.h),

              // Welcome message
              CustomText(
                text:
                    'Welcome back, Bulldog! Shop your favorites today.',
                fontSize: 13.sp,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 35.h),

              // Lets the user choose DummyJSON or Firebase
              DropdownButtonFormField<LoginType>(
                initialValue: _loginType,
                decoration: _decoration(
                  'Login using',
                  Icons.login,
                ),
                items: const [
                  // DummyJSON login option
                  DropdownMenuItem(
                    value: LoginType.dummyJSON,
                    child: Text('DummyJSON'),
                  ),

                  // Firebase login option
                  DropdownMenuItem(
                    value: LoginType.firebase,
                    child: Text('Firebase'),
                  ),
                ],
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value == null) return;

                        // Changes the login type and clears the fields
                        setState(() {
                          _loginType = value;
                          _usernameController.clear();
                          _passwordController.clear();
                        });
                      },
              ),

              SizedBox(height: 16.h),

              // Username or email field
              TextField(
                controller: _usernameController,
                enabled: !_isLoading,

                // Uses email keyboard for Firebase
                keyboardType: firebase
                    ? TextInputType.emailAddress
                    : TextInputType.text,

                autocorrect: false,

                // Changes the field based on the login type
                decoration: _decoration(
                  firebase
                      ? 'Email address'
                      : 'Username',
                  firebase
                      ? Icons.email_outlined
                      : Icons.person_outline,
                ),
              ),

              SizedBox(height: 16.h),

              // Password field
              TextField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: _obscurePassword,
                decoration: _decoration(
                  'Password',
                  Icons.lock_outline,

                  // Show or hide password button
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Changes password visibility
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                  ),
                ),

                // Logs in when the user presses enter
                onSubmitted: _isLoading
                    ? null
                    : (_) => _login(),
              ),

              SizedBox(height: 28.h),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context)
                            .colorScheme
                            .primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),

                  // Shows loading icon while logging in
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20.h),

              // Shows forgot password only for Firebase
              if (firebase)
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : _forgotPassword,
                  child: const Text(
                    'Forgot password?',
                  ),
                ),

              // Goes to the sign up screen
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                const SignupScreen(),
                          ),
                        );
                      },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}