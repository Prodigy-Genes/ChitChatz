// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
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
                  // Handle sign in logic here
                  
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
