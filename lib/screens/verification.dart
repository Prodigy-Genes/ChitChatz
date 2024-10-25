// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/authentication/auth_button.dart';
import 'package:chatapp/model/user.dart';
import 'package:chatapp/screens/home.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class Verification extends StatefulWidget {
  final String userId; // Pass userId instead of User object

  const Verification({super.key, required this.userId}); // Update constructor

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final Logger _logger = Logger();
  final TextEditingController _otpController = TextEditingController();
  bool isEmailVerified = true;
  Future<bool>? _otpValidationFuture;
  UserModel? currentUser; // To hold the current user details

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data based on userId
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // Function to fetch user data from Firestore using userId
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId) // Use userId
          .get();

      if (userDoc.exists) {
        currentUser = UserModel.fromMap(widget.userId, userDoc.data() as Map<String, dynamic>);
        checkEmailVerified(); // Check email verification after fetching user
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found.')),
        );
      }
    } catch (e) {
      _logger.e('Failed to fetch user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: ${e.toString()}')),
      );
    }
  }

  void checkEmailVerified() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isEmailVerified = user.emailVerified; // Check email verification status
      if (isEmailVerified) {
        _logger.i('User email verified');
      } else {
        _logger.w('User email not verified');
      }
    }
  }

  void verifyOtp() async {
  if (_otpController.text.isNotEmpty) {
    setState(() {
      // Optionally show loading state if needed
    });

    // Call validateOtp function
    bool isVerified = await validateOtp(_otpController.text);

    if (isVerified) {
      // If OTP is valid, navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter OTP.')),
    );
  }
}

Future<bool> validateOtp(String otp) async {
  EmailAuth emailAuth = EmailAuth(sessionName: 'Verify Email');

  // Retrieve the email using userId
  String email = await _getEmailByUserId(widget.userId); 

  bool isValid = emailAuth.validateOtp(
    recipientMail: email,
    userOtp: otp,
  );

  if (isValid) {
    _logger.i('OTP validated successfully.');
    await _saveUserToFirestore(widget.userId);  // Save user details to Firestore
    return true;
  } else {
    _logger.e('Invalid OTP entered.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid OTP. Please try again.')),
    );
    return false;
  }
}

Future<void> _saveUserToFirestore(String userId) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel newUser = UserModel(
      uid: userId,
      username: currentUser.displayName ?? 'New User', // Assuming you want to use the display name from Firebase
      email: currentUser.email ?? '', // Use email from FirebaseAuth
      createdAt: DateTime.now(),
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(newUser.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User details saved to Firestore')),
      );
    } catch (e) {
      _logger.e('Failed to save user to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving user: ${e.toString()}')),
      );
    }
  }
}

// This method retrieves the user's email from Firestore
Future<String> _getEmailByUserId(String userId) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      UserModel user = UserModel.fromDocumentSnapshot(userDoc.data() as Map<String, dynamic>, userId);
      return user.email; // Retrieve email from UserModel
    } else {
      throw Exception('User not found');
    }
  } catch (e) {
    _logger.e('Failed to retrieve email: $e');
    return '';
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

            // FutureBuilder to manage OTP validation status
            if (_otpValidationFuture != null)
              FutureBuilder<bool>(
                future: _otpValidationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const SizedBox.shrink(); // No additional UI needed
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
