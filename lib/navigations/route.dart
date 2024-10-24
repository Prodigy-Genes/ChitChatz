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
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if the user is signed in
        if (snapshot.hasData) {
          user = snapshot.data;

          // Only reload user once if not verified
          if (!isEmailVerified && user != null) {
            user!.reload().then((_) async {
              User? refreshedUser = FirebaseAuth.instance.currentUser;
              if (refreshedUser != null) {
                // Check email verification and user data only once
                if (!isEmailVerified) {
                  isEmailVerified = refreshedUser.emailVerified;
                  if (isEmailVerified) {
                    hasValidUserData = await Auth().isUserDataValid(refreshedUser.uid);
                  }
                }
                // Stop loading after user data is fetched
                setState(() {
                  isLoading = false;
                });
              }
            });
          }

          // Show loading spinner until the check completes
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // User flow based on email verification and user data
          return isEmailVerified
              ? (hasValidUserData ? const Home() : const Signup())
              : const Verification();
        } else {
          return const Signup(); // No user is signed in; navigate to the Signup screen
        }
      },
    );
  }
}

