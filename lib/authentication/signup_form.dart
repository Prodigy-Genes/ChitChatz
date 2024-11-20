// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:chatapp/authentication/auth.dart';
import 'package:flutter/material.dart';
import 'auth_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreedToTerms = false; // Track if checkbox is checked

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                prefixIcon: Image.asset(
                  'assets/icons/username.png',
                  width: 20,
                  height: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 25,
                  minHeight: 25,
                ),
                labelText: 'Username',
                labelStyle: const TextStyle(color: Colors.purple),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

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
                  minWidth: 25,
                  minHeight: 25,
                ),
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.purple),
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
                  minWidth: 25,
                  minHeight: 25,
                ),
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.purple),
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
            const SizedBox(height: 20),

            // Confirm Password field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Image.asset(
                  'assets/icons/password.png',
                  width: 20,
                  height: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 25,
                  minHeight: 25,
                ),
                labelText: 'Confirm Password',
                labelStyle: const TextStyle(color: Colors.purple),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 2),

            // Checkbox for agreeing to Terms
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle navigation to Terms of Use page
                      Navigator.pushNamed(context, '/terms');
                    },
                    child: const Text(
                      'I agree to the Terms of Use',
                      style: TextStyle(
                        color: Colors.blueAccent, // Theme color
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Sign Up Button (disabled until checkbox is checked)
            AuthButton(
              text: 'Sign Up',
              color: Colors.purple,
              onPressed: () async {
                if (!_agreedToTerms) {
                  // Show a message if the user has not agreed to the terms
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'You need to agree to the Terms of Use to proceed.'),
                    ),
                  );
                } else if (_formKey.currentState!.validate()) {
                  // Handle sign up logic
                  _signup();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signup() async {
    final auth = Auth(); // Create an instance of the Auth class
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      // Use the new method for creating an account
      await auth.createWithEmailAndPassword(
        username: _usernameController.text,
        email: email,
        password: password,
        context: context, // Pass context to navigate
      );

      // If successful, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please check your email for the OTP.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
