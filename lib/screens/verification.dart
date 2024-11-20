// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:chatapp/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:chatapp/model/user.dart';

class Verification extends StatefulWidget {
  final String userId;
  final String email;

  const Verification(
      {Key? key,
      required this.userId,
      required this.email,
      })
      : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final Logger _logger = Logger();
  late TextEditingController _otpController;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initialize Firestore

  @override
  void initState() {
    _otpController = TextEditingController();
    super.initState();
    _logger.i(
        "Initializing Verification widget for userId: ${widget.userId}, email: ${widget.email}");
    // Initialize email
    _initializeEmail();
  }

  void _initializeEmail() {
    if (widget.email.isNotEmpty) {
      _logger.i('Final email set to: ${widget.email}');
    } else {
      _logger.e('Email is not set for userId: ${widget.userId}');
      _showSnackBar('Error: Email not provided.');
      Future.delayed(Duration.zero, () {
        _logger.i(
            "Navigating back due to missing email for userId: ${widget.userId}.");
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _logger.i("Disposing OTP controller for userId: ${widget.userId}");
    _otpController.dispose();
    super.dispose();
  }

  void verifyOtp() async {
    _logger.i(
        "💡 Starting OTP verification for userId: ${widget.userId}, email: ${widget.email}");

    // Get the OTP from the controller
    final otp = _otpController.text;
    if (otp.isEmpty) {
      _logger.w(
          'OTP input is empty for userId: ${widget.userId}, email: ${widget.email}');
      _showSnackBar('Please enter OTP.');
      return;
    }

    _logger.i(
        "💡 OTP entered: $otp for userId: ${widget.userId}, email: ${widget.email}");

    try {
      // Validate the OTP
      _logger.i(
          "💡 Validating OTP for userId: ${widget.userId}, email: ${widget.email}...");
      bool isVerified = await validateOtp(otp);
      _logger.i(
          "💡 OTP validation result for userId: ${widget.userId}, email: ${widget.email}: $isVerified");

      if (isVerified) {
        _logger.i(
            "💡 OTP is verified. Saving user to Firestore for userId: ${widget.userId}, email: ${widget.email}...");
        await _saveUserToFirestore();
        _logger.i(
            "💡 User saved to Firestore for userId: ${widget.userId}, email: ${widget.email}. Navigating to Home...");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        _logger.w(
            'OTP verification failed for userId: ${widget.userId}, email: ${widget.email}.');
        _showSnackBar('OTP verification failed. Please try again.');
      }
    } catch (error) {
      _logger.e(
          'Error during OTP verification for userId: ${widget.userId}, email: ${widget.email}: $error');
      _showSnackBar('An error occurred during verification. Please try again.');
    }
  }

  Future<bool> validateOtp(String otp) async {
    _logger.i(
        "💡 Validating OTP for userId: ${widget.userId}, email: ${widget.email}.");
    _logger.i(
        "💡 OTP being validated: $otp for userId: ${widget.userId}, email: ${widget.email}");

    try {
      // Fetch the stored OTP from Firestore using userId
      String? storedOtp = await fetchOtp(widget.userId);

      if (storedOtp == null) {
        _logger.e(
            'No stored OTP found for userId: ${widget.userId}, email: ${widget.email}.');
        return false;
      }

      _logger.i(
          "💡 Comparing stored OTP: $storedOtp with user OTP: $otp for userId: ${widget.userId}, email: ${widget.email}");

      // Check if the user-provided OTP matches the stored OTP
      if (storedOtp == otp) {
        _logger.i(
            'OTP validated successfully for userId: ${widget.userId}, email: ${widget.email}.');
        return true;
      } else {
        _logger.e(
            'Invalid OTP entered for userId: ${widget.userId}, email: ${widget.email}.');
        _showSnackBar('Invalid OTP. Please try again.');
        return false;
      }
    } catch (e) {
      _logger.e(
          'Error validating OTP for userId: ${widget.userId}, email: ${widget.email}: $e');
      return false;
    }
  }

  // Function to fetch OTP from Firestore using userId
  Future<String?> fetchOtp(String userId) async {
    try {
      final doc = await _firestore.collection('otps').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['otp'] as String?;
      } else {
        _logger.e('No OTP found for userId: $userId, email: ${widget.email}.');
        return null;
      }
    } catch (e) {
      _logger.e(
          'Error fetching OTP for userId: ${widget.userId}, email: ${widget.email}: $e');
      return null;
    }
  }

  Future<void> _saveUserToFirestore() async {
    _logger.i(
        "💡 Attempting to save user to Firestore for userId: ${widget.userId}, email: ${widget.email}.");
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        UserModel newUser = UserModel(
          uid: widget.userId,
          username: currentUser.displayName ?? 'New User',
          email: currentUser.email ?? '',
          createdAt: DateTime.now(),
        );

        _logger.i(
            "💡 Saving user details: ${newUser.toMap()} for userId: ${widget.userId}, email: ${widget.email}");

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .set(newUser.toMap());

        _showSnackBar(
            'User details saved to Database');
      } else {
        _logger.e(
            'No user found during save operation for userId: ${widget.userId}, email: ${widget.email}.');
        _showSnackBar('Error: No current user found.');
      }
    } catch (e) {
      _logger.e(
          'Failed to save user to Firestore for userId: ${widget.userId}, email: ${widget.email}: $e');
      _showSnackBar('Error saving user: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      _logger.i(
          "💡 Showing snackbar with message: $message for userId: ${widget.userId}, email: ${widget.email}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      _logger.w(
          'Attempted to show snackbar, but widget is unmounted for userId: ${widget.userId}, email: ${widget.email}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.i(
        "Building Verification widget UI for userId: ${widget.userId}, email: ${widget.email}.");
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 224),
      appBar: AppBar(
        title: const Text('Account Verification'),
        backgroundColor: const Color.fromARGB(255, 110, 39, 176),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _logger.i(
                "Navigating back from Verification screen for userId: ${widget.userId}, email: ${widget.email}.");
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 110, 39, 176),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
