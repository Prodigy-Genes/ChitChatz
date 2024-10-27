// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:chatapp/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:email_auth/email_auth.dart';
import 'package:chatapp/model/user.dart';

class Verification extends StatefulWidget {
  final String userId;
  final String email;

  const Verification({Key? key, required this.userId, required this.email}) : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final Logger _logger = Logger();
  final TextEditingController _otpController = TextEditingController();
  late EmailAuth emailAuth;
  String? _finalEmail;

  @override
  void initState() {
    super.initState();
    _logger.i("Initializing Verification widget.");
    emailAuth = EmailAuth(sessionName: 'Verify Email');

    // Initialize _finalEmail
    _initializeEmail();
  }

  void _initializeEmail() {
    if (widget.email.isNotEmpty) {
      _finalEmail = widget.email;
      _logger.i('Final email set to: $_finalEmail');
    } else {
      _logger.e('Email is not set.');
      _showSnackBar('Error: Email not provided.');
      Future.delayed(Duration.zero, () {
        _logger.i("Navigating back due to missing email.");
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _logger.i("Disposing OTP controller.");
    _otpController.dispose();
    super.dispose();
  }

  void verifyOtp() async {
    _logger.i("💡 Starting OTP verification...");

    // Check if _finalEmail is set
    if (_finalEmail == null) {
      _logger.e('Cannot verify OTP because email is not set.');
      _showSnackBar('Cannot verify OTP: Email is not set.');
      return; // Exit if _finalEmail is null
    }

    _logger.i("💡 OTP Verification: _finalEmail is $_finalEmail");

    // Get the OTP from the controller
    final otp = _otpController.text;
    if (otp.isEmpty) {
      _logger.w('OTP input is empty.');
      _showSnackBar('Please enter OTP.');
      return;
    }

    _logger.i("💡 OTP entered: $otp");

    try {
      // Validate the OTP
      _logger.i("💡 Validating OTP...");
      bool isVerified = await validateOtp(otp);
      _logger.i("💡 OTP validation result: $isVerified");

      if (isVerified) {
        _logger.i("💡 OTP is verified. Saving user to Firestore...");
        await _saveUserToFirestore();
        _logger.i("💡 User saved to Firestore. Navigating to Home...");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        _logger.w('OTP verification failed.');
        _showSnackBar('OTP verification failed. Please try again.');
      }
    } catch (error) {
      _logger.e('Error during OTP verification: $error');
      _showSnackBar('An error occurred during verification. Please try again.');
    }
  }

  Future<bool> validateOtp(String otp) async {
    _logger.i("💡 Validating OTP for email: $_finalEmail");
    if (_finalEmail == null) {
      _logger.e('Final email is null during OTP validation.');
      return false;
    }

    bool isValid = emailAuth.validateOtp(
      recipientMail: _finalEmail!,
      userOtp: otp,
    );

    if (isValid) {
      _logger.i('OTP validated successfully.');
      return true;
    } else {
      _logger.e('Invalid OTP entered.');
      _showSnackBar('Invalid OTP. Please try again.');
      return false;
    }
  }

  Future<void> _saveUserToFirestore() async {
    _logger.i("💡 Attempting to save user to Firestore.");
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        UserModel newUser = UserModel(
          uid: widget.userId,
          username: currentUser.displayName ?? 'New User',
          email: currentUser.email ?? '',
          createdAt: DateTime.now(),
        );

        _logger.i("💡 Saving user details: ${newUser.toMap()}");

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .set(newUser.toMap());

        _showSnackBar('User details saved to Firestore');
      } else {
        _logger.e('No user found during save operation.');
        _showSnackBar('Error: No current user found.');
      }
    } catch (e) {
      _logger.e('Failed to save user to Firestore: $e');
      _showSnackBar('Error saving user: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      _logger.i("💡 Showing snackbar with message: $message");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      _logger.w('Attempted to show snackbar, but widget is unmounted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.i("Building Verification widget UI.");
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 224),
      appBar: AppBar(
        title: const Text('Account Verification'),
        backgroundColor: const Color.fromARGB(255, 110, 39, 176),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _logger.i("Navigating back from Verification screen.");
            Navigator.of(context).pop();
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
            ElevatedButton(
              onPressed: verifyOtp,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
