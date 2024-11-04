// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'package:chatapp/screens/add_friends.dart';
import 'package:chatapp/screens/friends.dart';
import 'package:chatapp/screens/notfication.dart';
import 'package:chatapp/services/email_otp_service.dart';
import 'package:chatapp/authentication/signout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

import '../screens/verification.dart';

class UserInfoModal extends StatefulWidget {
  final String userId;

  const UserInfoModal({Key? key, required this.userId}) : super(key: key);

  @override
  _UserInfoModalState createState() => _UserInfoModalState();
}

class _UserInfoModalState extends State<UserInfoModal> {
  final Logger logger = Logger();
  final otpService = OtpService();

  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    try {
      logger.i('Fetching user details for userId: ${widget.userId}');
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      logger.i('User details fetched successfully: ${snapshot.data()}');
      return snapshot.data();
    } catch (e) {
      logger.e("Error fetching user details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.e("Error in FutureBuilder: ${snapshot.error}");
          return const Center(child: Text("Error fetching user details."));
        } else if (!snapshot.hasData || snapshot.data == null) {
          logger.w('No user found for userId: ${widget.userId}');
          return const Center(child: Text("No user found."));
        }

        final userData = snapshot.data!;
        final username = userData['username'] ?? 'User';
        final userEmail = userData['email'] ?? '';

        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username
              Text(
                username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kavivanar',
                ),
              ),
              const SizedBox(height: 16),

              // Options List
              ListTile(
                leading: const Icon(Icons.people_sharp),
                title: Text('Add Friends',
                    style: GoogleFonts.kavivanar(
                      color: Colors.black,
                    )),
                onTap: () {
                  logger.i("Navigating to Add Friends Screen");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddFriends()));
                },
              ),

              ListTile(
                leading: const Icon(Icons.person_4_outlined),
                title: Text('Friends List',
                    style: GoogleFonts.kavivanar(
                      color: Colors.black,
                    )),
                onTap: () {
                  logger.i("Navigating to Friends Screen");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Friends(userId: widget.userId)));
                },
              ),

              ListTile(
                leading: const Icon(Icons.notification_important),
                title: Text('Notifications',
                    style: GoogleFonts.kavivanar(
                      color: Colors.black,
                    )),
                onTap: () {
                  logger.i("Navigating to Notifications");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsScreen(
                                userId: widget.userId,
                              )));
                },
              ),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(
                  'Verify Email',
                  style: TextStyle(fontFamily: 'Kavivanar'),
                ),
                onTap: () async {
                  logger.i('Verify Email tapped for userId: ${widget.userId}');

                  if (userEmail.isEmpty) {
                    logger.e('User email is empty. Cannot send OTP.');
                    return;
                  }

                  try {
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .get();

                    if (userDoc.exists &&
                        userDoc.data()?['isEmailVerified'] == true) {
                      logger.i(
                          'Email is already verified for userId: ${widget.userId}');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Email is already verified!🎉',
                              style: TextStyle(fontFamily: 'Kavivanar'),
                            ),
                            backgroundColor: Colors.greenAccent,
                          ),
                        );
                      }
                      return;
                    }

                    // Generate OTP
                    final otpCode = await otpService.generateOtp();
                    logger.i('Generated OTP: $otpCode');

                    // Send OTP to user's email
                    await otpService.sendOtpEmail(userEmail, otpCode);
                    logger.i('OTP sent successfully to $userEmail');

                    // Now close the modal
                    if (!mounted) return;
                    Navigator.pop(context);

                    // Navigate to verification screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Verification(
                          userEmail: userEmail,
                          otpCode: otpCode,
                        ),
                      ),
                    );
                  } catch (error) {
                    logger.e('Failed to send OTP: $error');
                    // Optionally show error message to user
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to send OTP: $error')),
                      );
                    }
                  }
                },
              ),

              // Using Signout widget here
              ListTile(
                title: const Signout(),
                onTap: () {
                  // Prevents default onTap behavior from ListTile
                  // Signout widget handles its own tap
                  logger.i('Sign out tapped.');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
