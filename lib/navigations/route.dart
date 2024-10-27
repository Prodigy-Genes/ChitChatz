// ignore_for_file: avoid_print

import 'package:chatapp/authentication/auth.dart';
import 'package:chatapp/screens/home.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:chatapp/screens/verification.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthRoute extends StatefulWidget {
  const AuthRoute({super.key});

  @override
  State<AuthRoute> createState() => _AuthRouteState();
}

class _AuthRouteState extends State<AuthRoute> {
  User? user;
  bool isLoading = true;
  bool isEmailVerified = false;
  bool hasValidUserData = false;

  @override
  void initState() {
    super.initState();
    
    // Subscribe to auth state changes
    Auth().authStateChanges.listen((User? currentUser) {
      if (currentUser != null) {
        user = currentUser;
        _checkEmailAndUserData();
      } else {
        // If no user is authenticated, navigate to Signup
        _navigateToSignup();
      }
    });
  }

  // Navigate to Signup screen
  void _navigateToSignup() {
    if (mounted) {
      setState(() {
        isLoading = false; // Stop loading indicator
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signup()),
      );
    }
  }

  Future<void> _checkEmailAndUserData() async {
    try {
      // Reload user to get the latest status
      await user!.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null) {
        // Update email verified status
        isEmailVerified = refreshedUser.emailVerified;

        // Only check user data if email is verified
        if (isEmailVerified) {
          hasValidUserData = await Auth().isUserDataValid(refreshedUser.uid);
        }

        // Navigate based on the email and data checks
        if (isEmailVerified) {
          if (hasValidUserData) {
            _navigateToHome(); // Go to Home if email is verified and user data is valid
          } else {
            _navigateToSignup(); // Go to Signup if user data is not valid
          }
        } else {
          _navigateToVerification(refreshedUser.email); // Pass the email to Verification
        }
      }
    } catch (e) {
      // Handle specific FirebaseAuth exceptions such as user not found
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        _navigateToSignup(); // Navigate to Signup if the user is not found
      } else {
        print('Error checking user data: $e'); // Handle other errors if necessary
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Stop loading indicator
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  // Modified to accept the email parameter
  void _navigateToVerification(String? email) {
    if (user != null && email != null && email.isNotEmpty) { // Check for null and empty email
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Verification(userId: user!.uid, email: email)),
      );
    } else {
      // Handle the case where user is null or email is null
      print('User is not authenticated or email is null.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // While loading, show a loading spinner
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // By default, show the Signup screen
    return const Signup();
  }
}
