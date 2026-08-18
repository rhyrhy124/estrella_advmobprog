import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

 // This controller gets the email entered by the user.
 final _emailController =
     TextEditingController();

 // This controller gets the password entered by the user.
 final _passwordController =
     TextEditingController();

 // This controls whether the password is hidden or shown.
 bool _obscurePassword = true;

 @override
 void dispose() {
   // This removes the text controllers when the screen is closed.
   _emailController.dispose();
   _passwordController.dispose();
   super.dispose();
 }

 // This function is used when the login button is pressed.
 void _login() {
   Navigator.pushReplacement(
     context,
     MaterialPageRoute(
       builder: (_) => const HomeScreen(),
     ),
   );
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     body: SafeArea(
       child: SingleChildScrollView(
         padding: EdgeInsets.symmetric(
           horizontal: 28.w,
           vertical: 40.h,
         ),
         child: Column(
           children: [
             SizedBox(height: 30.h),

             // This displays the Bulldogs Exchange logo.
             Image.asset(
               'assets/images/nubdexchange_logo.png',
               height: 100.h,
             ),

             SizedBox(height: 25.h),

             // This displays the app name.
             CustomText(
               text: 'Bulldogs Exchange',
               fontSize: 27.sp,
               fontweight:
                   FontWeight.bold,
               textAlign: TextAlign.center,
             ),

             SizedBox(height: 8.h),

             // This displays the welcome message.
             CustomText(
               text:
                   'Welcome back, Bulldog!',
               fontSize: 14.sp,
               textAlign: TextAlign.center,
             ),

             SizedBox(height: 35.h),

             // This field is used to enter the user's email.
             TextField(
               controller: _emailController,
               keyboardType:
                   TextInputType.emailAddress,
               decoration:
                   const InputDecoration(
                 labelText: 'Email',
                 prefixIcon:
                     Icon(Icons.email_outlined),
                 border:
                     OutlineInputBorder(),
               ),
             ),

             SizedBox(height: 16.h),

             // This field is used to enter the user's password.
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

                 // This button shows or hides the password.
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

             SizedBox(height: 25.h),

             // This button starts the login action.
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

             // This displays the sign up message.
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