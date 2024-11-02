// ignore_for_file: use_build_context_synchronously, unused_element, avoid_print

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
        MaterialPageRoute(builder: (context) => Home(userId:user!.uid ,)),
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
