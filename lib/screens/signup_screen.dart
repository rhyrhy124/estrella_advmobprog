import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();

  final _fields = List.generate(
    8,
    (_) => TextEditingController(),
  );

  bool _busy = false;
  bool _hidden = true;

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }

    super.dispose();
  }

  Future<void> _signup() async {
    if (_busy || !_form.currentState!.validate()) {
      return;
    }

    final cart = context.read<CartProvider>();

    setState(() => _busy = true);

    try {
      final service = UserService();

      await service.createAccount(
        fName: _fields[0].text,
        lName: _fields[1].text,
        age: int.parse(_fields[2].text.trim()),
        contactNo: _fields[3].text,
        username: _fields[4].text,
        emailAddress: _fields[5].text,
        password: _fields[6].text,
      );

      final data = await service.getUserData();

      if (!mounted) return;

      cart.setFirebaseUser(data['uid'] as String);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (_) => false,
        arguments: data,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              UserService.errorMessage(error),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = [
      'First name',
      'Last name',
      'Age',
      'Contact number',
      'Username',
      'Email address',
      'Password',
      'Confirm password',
    ];

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create account'),
        ),
        body: Form(
          key: _form,
          child: ListView(
            padding: EdgeInsets.all(24.r),
            children: [
              Text(
                'Join Bulldog Market',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8.h),

              const Text(
                'Create your Firebase account.',
              ),

              SizedBox(height: 24.h),

              for (var i = 0; i < labels.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 16.h,
                  ),
                  child: TextFormField(
                    controller: _fields[i],
                    enabled: !_busy,
                    obscureText: i >= 6 && _hidden,
                    keyboardType: i == 2
                        ? TextInputType.number
                        : i == 3
                            ? TextInputType.phone
                            : i == 5
                                ? TextInputType.emailAddress
                                : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: labels[i],
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12.r),
                      ),
                      helperText: i == 6
                          ? '8+ chars: uppercase, lowercase, number, symbol'
                          : null,
                      suffixIcon: i == 6
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _hidden = !_hidden;
                                });
                              },
                              icon: const Icon(
                                Icons.visibility,
                              ),
                            )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Required';
                      }

                      if ((i == 0 || i == 1) &&
                          value.trim().length > 100) {
                        return 'Maximum 100 characters';
                      }

                      if (i == 2) {
                        final age =
                            int.tryParse(value.trim());

                        if (age == null ||
                            age < 1 ||
                            age > 120) {
                          return 'Enter an age from 1 to 120';
                        }
                      }

                      if (i == 3 &&
                          !RegExp(r'^\+?[0-9]{7,15}$')
                              .hasMatch(value.trim())) {
                        return 'Enter 7-15 digits, optional +';
                      }

                      if (i == 4 &&
                          (value.trim().length < 3 ||
                              value.trim().length > 100)) {
                        return 'Use 3-100 characters';
                      }

                      if (i == 5 &&
                          !RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch(value.trim())) {
                        return 'Enter a valid email';
                      }

                      if (i == 6 &&
                          !UserService.validPassword(value)) {
                        return 'Password does not meet the requirements';
                      }

                      if (i == 7 &&
                          value != _fields[6].text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),
                ),

              SizedBox(height: 8.h),

              FilledButton(
                onPressed: _busy ? null : _signup,
                child: Text(
                  _busy
                      ? 'Creating account...'
                      : 'SIGN UP',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}