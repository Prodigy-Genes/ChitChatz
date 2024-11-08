import 'package:chatapp/model/user.dart';
import 'package:chatapp/screens/in_chat_screen.dart';
import 'package:chatapp/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;


class FriendsListItemWidgetHome extends StatelessWidget {
  final UserModel friend;
  final int unreadMessages;
  const FriendsListItemWidgetHome(
      {super.key, required this.friend, required this.unreadMessages});

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InChatScreen(friend: friend),
              ),
            );
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
                      const SizedBox(height: 8),
                      // Show the last message and unread message count
                      Text(
                        friend.lastMessage ?? 'No messages yet',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (unreadMessages > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$unreadMessages unread',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
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
