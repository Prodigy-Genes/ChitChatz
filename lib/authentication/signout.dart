// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:chatapp/authentication/auth.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:flutter/material.dart';

class Signout extends StatefulWidget {
  const Signout({super.key});

  @override
  _SignoutState createState() => _SignoutState();
}

class _SignoutState extends State<Signout> {
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await Auth().signOut(); // Ensure signOut method is correctly defined
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signed out successfully")),
      );

      // Force navigation to Signup after signing out
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Signup()), // Change this to your Signup widget
        );
      }
      // Optionally, you might want to trigger a manual check here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign out failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleSignOut(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.logout,
            color: Colors.redAccent,
          ),
          SizedBox(width: 8),
          Text(
            'Sign-Out',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kavivanar'
            ),
          ),
        ],
      ),
    );
  }
}
