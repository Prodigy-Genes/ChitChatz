// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:chatapp/authentication/auth.dart';
import 'package:chatapp/screens/home.dart';
import 'package:chatapp/screens/signup.dart';
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

    // Check if a user is already signed in on app startup
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _logger.i('User already signed in, validating user data...');
      // Validate user data and navigate accordingly
      _checkEmailAndUserData();
    } else {
      _logger.i('No user found at startup, listening for auth state changes...');
      // Subscribe to auth state changes for new sign-ins
      Auth().authStateChanges.listen((User? currentUser) {
        if (currentUser != null) {
          _logger.i('Auth state change detected: User signed in.');
          user = currentUser;
          _checkEmailAndUserData();
        } else {
          _logger.i('Auth state change detected: No user signed in, navigating to Signup.');
          _navigateToSignup();
        }
      });
    }
  }

  // Check email and user data validity
  Future<void> _checkEmailAndUserData() async {
    try {
      _logger.d('Reloading user data...');
      await user!.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null) {
        _logger.d('User reloaded. Checking user data in Firestore...');
        bool hasValidUserData = await Auth().isUserDataValid(refreshedUser.uid);
        if (hasValidUserData) {
          _logger.i('User has valid data. Navigating to Home screen.');
          _navigateToHome();
        } else {
          _logger.w('User data is invalid. Navigating to Signup screen.');
          _navigateToSignup();
        }
      }
    } catch (e) {
      _logger.e('Error during user data check: $e');
      _navigateToSignup(); // Redirect to Signup if an error occurs
    } finally {
      _setLoadingState(false); // Stop showing the loading indicator
    }
  }

  // Navigate to the home screen
  void _navigateToHome() {
    _logger.i('Navigating to Home screen.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(userId: user!.uid)),
        );
      }
    });
  }

  // Navigate to the signup screen
  void _navigateToSignup() {
    _logger.i('Navigating to Signup screen.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Signup()),
          (Route<dynamic> route) => false, // Clear all routes
        );
      }
    });
  }

  // General method to handle screen navigation
  void _navigateToScreen(Widget screen) {
    _logger.i('Navigating to screen: ${screen.runtimeType}');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  // Set loading state
  void _setLoadingState(bool loading) {
    _logger.d('Setting loading state to: $loading');
    if (mounted) {
      setState(() {
        isLoading = loading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    _logger.d('Rendering Signup screen as default.');
    return const Signup(); // Default screen when not loading
  }
}
