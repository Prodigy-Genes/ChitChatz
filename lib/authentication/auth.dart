// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:chatapp/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signinWithEmailAndPassword({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting to sign in with email: $email');

      // Sign in with Firebase Authentication
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user data exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        _logger.w('User document not found in Firestore for email: $email');

        // Alert the user to sign up
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found. Please sign up to continue.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.i('User document found in Firestore for email: $email');
        _logger.i('Sign-in successful for email: $email');

        // Navigate to Home and remove all previous routes (no back button)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Home(userId: userCredential.user!.uid)),
          (Route<dynamic> route) => false, // Remove all previous screens
        );
      }
      await updateOneSignalUserId();
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthErrors(e);
      switch (e.code) {
        case 'user-not-found':
          _logger.w('No user found for email: $email');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user found for this email.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 'wrong-password':
          _logger.w('Wrong password provided for email: $email');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect password. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 'invalid-email':
          _logger.w('Invalid email format for: $email');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email format.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        default:
          _logger.e('An unexpected error occurred: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
      }
      rethrow;
    } catch (e, stacktrace) {
      _logger.e('An unknown error occurred during sign-in, $e, $stacktrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unknown error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  Future<UserCredential> createWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _logger.i('Attempting to sign up user with email: $email');

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty.');
      }

      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      _logger.i('User created with UID: ${userCredential.user!.uid}');

      // Save user details to Firestore
      _logger.i('Adding user to database');

      await _saveUserToFirestore(userCredential.user, username);

      // Navigate to the home screen directly
      String userId = userCredential.user!.uid;
      _logger.i('Navigating to Home with user ID: $userId');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => Home(userId: userCredential.user!.uid)),
        (Route<dynamic> route) => false,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthErrors(e);
      rethrow;
    } on FirebaseException catch (e) {
      _logger.e(
          'FirebaseException occurred when saving user to Firestore: ${e.code}: ${e.message}');
      if (e.code == 'permission-denied') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to perform this action.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception('Firestore error: ${e.message}');
      }
    } on Exception catch (e) {
      _logger.e('An unknown error occurred: $e');
      throw Exception('Unknown error: $e');
    }

    throw Exception('Unexpected error occurred in createWithEmailAndPassword');
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      _logger.i('Attempting to sign in with Google');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google sign-in aborted by user');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      _logger.i(
          'Google sign-in successful for email: ${userCredential.user!.email}');

      String username = googleUser.displayName ?? 'User';

      // Save user to Firestore
      await _saveUserToFirestore(userCredential.user, username);

      await _updateUserOnlineStatus(true);

      await updateOneSignalUserId();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => Home(userId: userCredential.user!.uid)),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthErrors(e);
    } catch (e) {
      _logger.e('An error occurred during Google sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to save user to Firestore
  Future<void> _saveUserToFirestore(User? user, String username) async {
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot userDoc = await userRef.get();

      if (!userDoc.exists) {
        // If the user doesn't exist, create new data
        final userData = {
          'username': username,
          'email': user.email,
          'profilePictureUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await userRef.set(userData);
        _logger.i('User data saved to Firestore for UID: ${user.uid}');
      } else {
        // Optionally update user data, but only update if necessary
        await userRef.update({
          'username': user.displayName,
          // Update other fields if necessary
        });
        _logger.i('User data updated in Firestore for UID: ${user.uid}');
      }
    }
  }

  // Update user online status
  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'isUserOnline': isOnline});
      } catch (e) {
        _logger.e("Failed to update online status: $e");
      }
    }
  }

  // Error handling for FirebaseAuthException
  void _handleFirebaseAuthErrors(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _logger.w('No user found for this email.');
        throw Exception('No user found for this email.');
      case 'wrong-password':
        _logger.w('Wrong password provided for this user.');
        throw Exception('Wrong password provided for this user.');
      case 'invalid-email':
        _logger.w('The email address is not valid.');
        throw Exception('The email address is not valid.');
      case 'email-already-in-use':
        _logger.w('The email address is already in use.');
        throw Exception(
            'The email address is already in use. Please log in instead.');
      default:
        _logger.e('An unexpected error occurred: ${e.message}');
        throw Exception('An unexpected error occurred: ${e.message}');
    }
  }

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

    // Reset OneSignal external user ID
    await OneSignal.logout();
  }

  Future<void> updateOneSignalUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Remove previous subscription
      await OneSignal.logout();

      // Set new external user ID
      await OneSignal.login(currentUser.uid);

      // Prompt for notification permission if not already granted
      await OneSignal.Notifications.requestPermission(true);
    }
  }
}
