// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'auth_button.dart'; // Assuming this is the button file you'll create

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
                  minWidth: 25, // Adjust constraints for spacing
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
                  minWidth: 25, // Adjust constraints for spacing
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
                  minWidth: 25, // Adjust constraints for spacing
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
                  minWidth: 25, // Adjust constraints for spacing
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
            const SizedBox(height: 40),

            // Sign Up Button
            AuthButton(
              text: 'Sign Up',
              color: Colors.purple,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Handle sign up logic here
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
