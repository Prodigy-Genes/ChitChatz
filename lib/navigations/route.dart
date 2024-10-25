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
    _navigateToSignup(); // Start by navigating to Signup on app start or hot reload
    
    // Subscribe to auth state changes
    Auth().authStateChanges.listen((User? currentUser) {
      if (currentUser != null) {
        user = currentUser;
        _checkEmailAndUserData();
      } else {
        // If no user is authenticated, navigate to Signup
        setState(() {
          isLoading = false;
        });
        _navigateToSignup();
      }
    });
  }

  // Navigate to Signup screen
  void _navigateToSignup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signup()),
      );
    });
  }

  Future<void> _checkEmailAndUserData() async {
    try {
      // Reload user to get the latest status
      await user!.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null) {
        setState(() {
          isEmailVerified = refreshedUser.emailVerified;
        });

        if (isEmailVerified) {
          // Only check user data if email is verified
          hasValidUserData = await Auth().isUserDataValid(refreshedUser.uid);
        }

        setState(() {
          isLoading = false;
        });

        // Navigate based on the email and data checks
        if (isEmailVerified) {
          if (hasValidUserData) {
            _navigateToHome(); // Go to Home if email is verified and user data is valid
          } else {
            _navigateToSignup(); // Go to Signup if user data is not valid
          }
        } else {
          _navigateToVerification(); // Go to Verification if email is not verified
        }
      }
    } catch (e) {
      // Handle specific FirebaseAuth exceptions such as user not found
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        // Navigate to Signup if the user is not found
        _navigateToSignup();
      } else {
        // Handle other errors if necessary (show an error message)
        print('Error checking user data: $e');
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  void _navigateToVerification() {
  if (user != null) { // Check if the user is not null
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Verification(userId: user!.uid)), 
    );
  } else {
    // Handle the case where user is null (optional)
    print('User is not authenticated.');
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
