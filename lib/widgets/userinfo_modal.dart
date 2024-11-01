import 'dart:async'; // Import Timer for OTP
import 'package:chatapp/screens/verification.dart'; // Import your verification screen
import 'package:chatapp/services/email_otp_service.dart'; // Import your EmailOtpService
import 'package:chatapp/authentication/signout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class UserInfoModal extends StatelessWidget {
  final String userId; 
  final Logger logger = Logger();

  final otpService = OtpService();

  UserInfoModal({super.key, required this.userId});

  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    try {
      logger.i('Fetching user details for userId: $userId');
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      logger.i('User details fetched successfully: ${snapshot.data()}');
      return snapshot.data();
    } catch (e) {
      logger.e("Error fetching user details: $e");
      return null; // Return null in case of an error
    }
  }

  Future<void> requestOtp(BuildContext context, String email) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      logger.i('Requesting OTP for userId: $userId, email: $email');

      if (userId == null || email.isEmpty) {
        logger.e('User ID or email is null. Cannot navigate to verification screen.');
        return;
      }

      String otp = await OtpService().generateOtp();
      await OtpService().storeOtp(userId, otp);
      await OtpService().sendOtpEmail(email, otp);

      // Log values before navigation
      logger.i('UserId: $userId, Email: $email');

      // Navigate to the Verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Verification(userId: userId, email: email),
        ),
      );
    } catch (e) {
      logger.e('Error during OTP request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.e("Error in FutureBuilder: ${snapshot.error}");
          return const Center(child: Text("Error fetching user details."));
        } else if (!snapshot.hasData || snapshot.data == null) {
          logger.w('No user found for userId: $userId');
          return const Center(child: Text("No user found."));
        }

        final userData = snapshot.data!;
        final username = userData['username'] ?? 'User';
        final email = userData['email'] ?? ''; // Get email from user data

        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username
              Text(
                username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kavivanar',
                ),
              ),
              const SizedBox(height: 16),

              // Options List
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Verify Email'),
                onTap: () async {
                  logger.i('Verify Email tapped for userId: $userId');
                  Navigator.pop(context); // Close modal
                  
                  // Show scaffold message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email verification is under development.'),
                      duration: Duration(seconds: 2), // Duration of the snackbar
                    ),
                  );
                },
              ),
              // Using Signout widget here
              ListTile(
                title: const Signout(),
                onTap: () {
                  // Prevents default onTap behavior from ListTile
                  // Signout widget handles its own tap
                  logger.i('Sign out tapped.');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
