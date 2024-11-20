// profile_image_widget.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:chatapp/model/user.dart';

class ProfileImageWidget extends StatelessWidget {
  final UserModel friend;

  const ProfileImageWidget({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF6C63FF),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: friend.profilePictureUrl.isNotEmpty
            ? Image.network(
                friend.profilePictureUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    color: const Color(0xFFE6E8F0),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                      color: const Color(0xFFE6E8F0),
                      child: Image.asset(
                        'assets/images/default_profile.png',
                        fit: BoxFit.cover,
                      ));
                },
              )
            : Container(
                color: const Color(0xFFE6E8F0),
                child: Image.asset(
                  'assets/images/default_profile.png',
                  fit: BoxFit.cover,
                )),
      ),
    );
  }
}
