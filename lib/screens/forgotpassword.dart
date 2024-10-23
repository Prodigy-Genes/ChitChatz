import 'package:flutter/material.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 224),
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color.fromARGB(255, 96, 39, 176),
        automaticallyImplyLeading: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              const Text(
                'Enter your email to receive a password reset link.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Kavivanar'
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Email input field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.purple),
                  labelText: 'Enter Email',
                  labelStyle: TextStyle(
                    color: Colors.purple,
                    fontFamily: 'Kavivanar',
                  ),
                  focusedBorder: UnderlineInputBorder(
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

              const SizedBox(height: 40),

              // Send Reset Link Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 96, 39, 176), 
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle password reset logic
                    // For example: Send a password reset email using Firebase Auth or custom backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset link sent. Please check your email.',
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Kavivanar'),
                ),
              ),
              
              const SizedBox(height: 20),

              // Back to Sign In button
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the previous screen (Sign In)
                },
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}