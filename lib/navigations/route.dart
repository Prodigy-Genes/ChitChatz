// ignore_for_file: use_build_context_synchronously, unused_element, avoid_print

import 'package:chatapp/authentication/auth.dart';
import 'package:chatapp/screens/home.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:chatapp/screens/verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class AuthRoute extends StatefulWidget {
  const AuthRoute({super.key});

  @override
  State<AuthRoute> createState() => _AuthRouteState();
}

class _AuthRouteState extends State<AuthRoute> {
  User? user;
  bool isLoading = true;

  @override
void initState() {
  super.initState();

  // Subscribe to auth state changes
  Auth().authStateChanges.listen((User? currentUser) {
    _setLoadingState(true); // Start loading when auth state changes

    if (currentUser != null) {
      user = currentUser;
      _checkEmailAndUserData();
    } else {
      print("Navigating to Signup"); // Log this line for debugging
      _navigateToSignup();
    }
  });
}


  // Check email and user data validity
  Future<void> _checkEmailAndUserData() async {
  try {
    await user!.reload();
    User? refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null) {
      bool hasValidUserData = await Auth().isUserDataValid(refreshedUser.uid);
      if (hasValidUserData) {
        print("User has valid data, navigating to Home."); // Debug log
        _navigateToHome();
      } else {
        bool isEmailVerified = refreshedUser.emailVerified;
        if (isEmailVerified) {
          print("Email verified, navigating to Signup."); // Debug log
          _navigateToSignup();
        } else {
          print("Email not verified, navigating to Verification."); // Debug log
          _navigateToVerification(refreshedUser.email);
        }
      }
    }
  } catch (e) {
    // Handle errors
    print("Error in user data check: $e"); // Debug log
    _navigateToSignup(); // Redirect to Signup if an error occurs
  } finally {
    _setLoadingState(false); // End loading regardless of outcome
  }
}



  void _handleUserDataCheck(User refreshedUser) {
    bool isEmailVerified = refreshedUser.emailVerified;
    _logger.d('Email verified: $isEmailVerified');

    if (isEmailVerified) {
      _logger
          .w('User data not found but email is verified, navigating to signup');
      _navigateToSignup();
    } else {
      _logger.w('Email not verified, navigating to verification');
      _navigateToVerification(refreshedUser.email);
    }
  }

  void _handleError(dynamic e) {
    if (e is FirebaseAuthException && e.code == 'user-not-found') {
      _navigateToSignup();
    } else {
      _logger.e('Error checking user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking user data: ${e.toString()}')),
      );
    }
  }

  // Navigate to the home screen
  void _navigateToHome() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  });
}

  void _navigateToSignup() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Signup()),
        (Route<dynamic> route) => false, // Clear all routes
      );
    }
  });
}


  // Navigate to the verification screen
  void _navigateToVerification(String? email) {
    if (user != null && email != null && email.isNotEmpty) {
      _navigateToScreen(Verification(userId: user!.uid, email: email));
    } else {
      _logger.e('User is not authenticated or email is null.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User is not authenticated or email is missing.')),
      );
    }
  }

  // General method to handle screen navigation
  void _navigateToScreen(Widget screen) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  // Set loading state
  void _setLoadingState(bool loading) {
    if (mounted) {
      setState(() {
        isLoading = loading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const Signup(); // Default screen when not loading
  }
}
