// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:chatapp/screens/verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      // Send OTP to email using EmailAuth
      bool otpSent = await sendOtp(email);
      if (!otpSent) {
        throw Exception('Failed to send OTP to $email');
      }

      _logger.i('OTP sent to $email');

      // Check if user is not null before navigating
      if (userCredential.user != null) {
        // Navigate to the verification screen with the user
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Verification(user: userCredential.user!),
          ),
        );
      } else {
        _logger.e('User is null after creation.');
        throw Exception('User creation failed: User is null.');
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthErrors(e);
    } on FirebaseException catch (e) {
      _logger.e(
          'FirebaseException occurred when saving user to Firestore: ${e.code}: ${e.message}');
      throw Exception('Firestore error: ${e.message}');
    } on FormatException catch (e) {
      _logger.e('FormatException occurred: $e');
      throw Exception('Input format error: $e');
    } on TimeoutException catch (e) {
      _logger.e('TimeoutException occurred: $e');
      throw Exception('Operation timed out: $e');
    } on Exception catch (e) {
      _logger.e('An unknown error occurred: $e');
      throw Exception('Unknown error: $e');
    } catch (e) {
      _logger.e('Unexpected error occurred: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> sendOtp(String email) async {
  EmailAuth emailAuth = EmailAuth(sessionName: 'Verify Email');
  var result = await emailAuth.sendOtp(recipientMail: email);
  return result; 
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
        _logger.e(
            'The user corresponding to the given email has been disabled.');
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
