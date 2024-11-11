// friend_list_item_widget.dart
// ignore_for_file: avoid_print

import 'package:chatapp/screens/chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/model/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'profile_image_widget.dart';

class FriendListItemWidget extends StatelessWidget {
  final UserModel friend;

  const FriendListItemWidget({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            print('Opening chat with: ${friend.username}');
            // Navigate to InChatScreen on tap
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(friend: friend)));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ProfileImageWidget(friend: friend),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.username,
                        style: GoogleFonts.kavivanar(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend.isUserOnline
                            ? 'Online'
                            : 'Last seen ${timeago.format(friend.createdAt)}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: friend.isUserOnline
                              ? Colors.green[600]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (friend.isUserOnline)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
