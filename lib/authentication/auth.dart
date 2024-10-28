// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math'; // Import for generating OTP
import 'package:chatapp/screens/verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signinWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
    required BuildContext context, // Pass the context to navigate
  }) async {
    try {
      _logger.i('Attempting to sign up user with email: $email');

      // Check if email or password is null or empty
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty.');
      }

      // Create user with Firebase Authentication
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      _logger.i('User created with UID: ${userCredential.user!.uid}');

      // Request OTP
      await requestOtp(userCredential.user!.uid); // Use userId

      // Navigate to the verification screen with the user ID and email
      String userId = userCredential.user!.uid; // Use userId instead of user
      _logger.i('Navigating to Verification with email: $email');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              Verification(userId: userId, email: email), // Pass email
        ),
      );
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthErrors(e);
    } on FirebaseException catch (e) {
      _logger.e(
          'FirebaseException occurred when saving user to Firestore: ${e.code}: ${e.message}');
      throw Exception('Firestore error: ${e.message}');
    } on Exception catch (e) {
      _logger.e('An unknown error occurred: $e');
      throw Exception('Unknown error: $e');
    }
  }

  // Function to generate a random 6-digit OTP
  String generateOtp() {
    final random = Random();
    return random.nextInt(999999).toString().padLeft(6, '0');
  }

  // Function to store OTP in Firestore using userId
  Future<void> storeOtp(String userId, String otp) async {
    await _firestore.collection('otps').doc(userId).set({
      'otp': otp,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId, // Store userId directly
    });
  }

  // Function to send OTP email using EmailJS
  Future<void> sendOtpEmail(String email, String otpCode) async {
    String serviceId = dotenv.env['SERVICE_ID'] ?? '';
    String templateId = dotenv.env['TEMPLATE_ID'] ?? '';
    String userId = dotenv.env['USER_ID'] ?? '';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_email': email,
            'otp_code': otpCode,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to send OTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('Error sending OTP: $e');
      throw Exception('An error occurred while sending OTP: $e');
    }
  }

  // Function to request OTP generation and sending
  Future<void> requestOtp(String userId) async {
    String otp = generateOtp();

    // Store OTP in Firestore
    await storeOtp(userId, otp); // Use userId instead of email

    // Send OTP email
    if (currentUser != null) {
      await sendOtpEmail(
          currentUser!.email ?? '', otp); // Send email based on currentUser
      _logger.i('OTP sent to ${currentUser?.email}');
    } else {
      _logger.e('No current user found to send OTP.');
    }
  }

  

  // Method to clean up expired OTPs
  Future<void> cleanupExpiredOtps() async {
    final now = DateTime.now();
    final querySnapshot = await _firestore.collection('otps').get();

    for (var doc in querySnapshot.docs) {
      Timestamp createdAt = doc['createdAt'];
      if (now.isAfter(createdAt.toDate().add(const Duration(minutes: 10)))) {
        await doc.reference.delete(); // Delete expired OTP
      }
    }
  }

  void _handleFirebaseAuthErrors(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        _logger.e('The email is already in use by another account.');
        break;
      case 'weak-password':
        _logger.e('The password is too weak.');
        break;
      case 'invalid-email':
        _logger.e('The email address is not valid.');
        break;
      case 'operation-not-allowed':
        _logger.e(
            'Email/password accounts are not enabled. Enable them in the Firebase Console.');
        break;
      case 'user-disabled':
        _logger
            .e('The user corresponding to the given email has been disabled.');
        break;
      default:
        _logger.e('FirebaseAuthException occurred: ${e.code}');
    }
    throw Exception('Authentication failed: ${e.message}');
  }

  // Method to check if user data exists in Firestore
  Future<bool> isUserDataValid(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      _logger.e('Error checking user data validity: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
