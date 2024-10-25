// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/authentication/auth_button.dart';
import 'package:chatapp/model/user.dart';
import 'package:chatapp/screens/home.dart';
import 'package:chatapp/authentication/auth.dart'; // Import the Auth class
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class Verification extends StatefulWidget {
  final User? user;

  const Verification({super.key, this.user});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final Logger _logger = Logger();
  final TextEditingController _otpController = TextEditingController();
  final Auth _auth = Auth(); // Create an instance of Auth
  bool isEmailVerified = true;

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await widget.user?.reload();
    bool verified = widget.user?.emailVerified ?? false;

    if (verified) {
      await _saveUserToFirestore();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()), // Navigate to Home
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your email to proceed.')),
      );
    }
  }

  Future<void> _saveUserToFirestore() async {
    if (widget.user != null) {
      UserModel newUser = UserModel(
        uid: widget.user!.uid,
        username: widget.user!.displayName ?? 'No Username',
        email: widget.user!.email ?? '',
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .set(newUser.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User details saved to Firestore')),
      );
    }
  }

  Future<void> validateOtp(String otp) async {
    // Use the verifyOtp method from Auth class
    bool isValid = await _auth.verifyOtp(widget.user?.email ?? '', otp);

    if (isValid) {
      _logger.i('OTP validated successfully.');
      // Mark the email as verified
      await _saveUserToFirestore();
      
      // Navigate to Home after successful validation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      _logger.e('Invalid OTP entered.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 224),
      appBar: AppBar(
        title: const Text('Account Verification'),
        backgroundColor: const Color.fromARGB(255, 110, 39, 176),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Add back arrow
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'A verification code has been sent to your email. Please verify your account to proceed.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Kavivanar',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // OTP Input (reused email input field style)
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Validate OTP button
            AuthButton(
              text: 'Verify OTP',
              color: const Color.fromARGB(255, 110, 39, 176), // Use your desired button color
              onPressed: () {
                validateOtp(_otpController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
