// signout.dart
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:chatapp/authentication/auth.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:chatapp/widgets/signout_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signout extends StatefulWidget {
  const Signout({super.key});

  @override
  _SignoutState createState() => _SignoutState();
}

class _SignoutState extends State<Signout> {
  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'isUserOnline': isOnline});
      } catch (e) {
        debugPrint("Failed to update online status: $e");
      }
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    // Show sign out confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => const SignoutConfirmation(),
    );

    if (shouldSignOut == true) {
      try {
        // Update user status to offline before signing out
        await _updateUserOnlineStatus(false);
        
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign out failed: $e")),
        );
      }
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
              fontFamily: 'Kavivanar',
            ),
          ),
        ],
      ),
    );
  }
}
