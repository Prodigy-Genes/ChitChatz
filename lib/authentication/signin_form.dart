// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:chatapp/authentication/auth.dart';
import 'package:chatapp/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'auth_button.dart'; // Assuming this is the button file you'll create

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  final Logger _logger = Logger();

  Future<void> _updateUserOnlineStatus(bool isOnline) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'isUserOnline': isOnline});
    } catch (e) {
      _logger.e("Failed to update online status: $e");
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: Image.asset(
                  'assets/icons/email.png',
                  width: 20,
                  height: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 25, // Adjust constraints for spacing
                  minHeight: 25,
                ),
                labelText: '  Enter Email',
                labelStyle: const TextStyle(
                    color: Colors.purple, fontFamily: 'Kavivanar'),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Image.asset(
                  'assets/icons/password.png',
                  width: 20,
                  height: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 25, // Adjust constraints for spacing
                  minHeight: 25,
                ),
                labelText: '  Password',
                labelStyle: const TextStyle(
                    color: Colors.purple, fontFamily: 'Kavivanar'),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgotpassword');
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontFamily: 'Kavivanar',
                      fontWeight: FontWeight.w400),
                )),
            const SizedBox(height: 10),

            // Sign In Button
                AuthButton(
                    text: 'Sign In',
                    color: Colors.purple,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _signin(); // Call the sign-in method
                      }
                    },
                  )
          ],
        ),
      ),
    );
  }

  Future<void> _signin() async {
  final auth = Auth(); // Create an instance of the Auth class
  final email = _emailController.text;
  final password = _passwordController.text;

  setState(() {
    isLoading = true; // Start loading
  });

  try {
    // Use the new method for signing in
    await auth.signinWithEmailAndPassword(
      email: email,
      password: password,
      context: context,
    );

    // If successful, show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SignIn executed successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Update user's online status to true
    await _updateUserOnlineStatus(true);

    // Navigate to home after a brief delay
    await Future.delayed(const Duration(seconds: 2));

    // Force navigation to Home
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home(userId:auth.currentUser!.uid,)), // Change this to your Home widget
      );
    }
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SignIn failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      isLoading = false; // End loading
    });
  }
}

}
