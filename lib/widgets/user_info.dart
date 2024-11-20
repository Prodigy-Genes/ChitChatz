// ignore_for_file: avoid_print

import 'package:chatapp/widgets/userinfo_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Import your logging package if you have one
// import 'package:your_logging_package/logger.dart';

class UserInfo extends StatelessWidget {
  final String userId;
  const UserInfo({super.key, required this.userId});

  // Fetch user details from Firestore
  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return snapshot.data();
    } catch (e) {
      print("Error fetching user details: $e");
      return null; // Return null in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator with a message
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Handle error state
          return const Center(child: Text("Error fetching user details."));
        } else if (!snapshot.hasData || snapshot.data == null) {
          // Handle case where no data is returned
          return const Center(child: Text("No user found."));
        }

        // Get user data
        final userData = snapshot.data!;

        // Check if isEmailVerified exists and handle it accordingly
        final isEmailVerified = userData['isEmailVerified'] ?? false; // Default to false if not present
        if (!isEmailVerified) {
          // Replace with your logging logic
          // logger.e("Email is not verified for userId: $userId");
          print("Email is not verified for userId: $userId"); // Example of logging
        }

        final profilePictureUrl = userData['profilePictureUrl'];
        final isOnline = userData['isUserOnline'] ?? false; // Assuming 'isUserOnline' indicates the user's status

        return GestureDetector(
          onTap: () {
            // Show the bottom modal when tapped
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return UserInfoModal(userId: userId); // Show user info modal
              },
            );
          },
          child: Stack(
            alignment: Alignment.topRight, // Align the dot at the top right of the avatar
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : const AssetImage('assets/images/default_profile.png') as ImageProvider,
              ),
              if (isOnline) // Show the green dot only if the user is online
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.lightGreenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
