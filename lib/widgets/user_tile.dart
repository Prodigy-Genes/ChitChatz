// ignore_for_file: use_super_parameters

import 'package:chatapp/model/notification.dart';
import 'package:chatapp/services/friend_request_service.dart';
import 'package:chatapp/services/friend_request_status.dart';
import 'package:chatapp/services/notification_service.dart';
import 'package:chatapp/widgets/addfriend_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserTile extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String currentUserId;

  const UserTile({Key? key, required this.userData, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profilePictureUrl = userData['profilePictureUrl'] as String?;
    final username = userData['username'] as String? ?? 'Unknown User';
    final isOnline = userData['isUserOnline'] as bool? ?? false;
    final userId = userData['userId'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Profile Picture Section
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.2),
                    width: 4,
                  ),
                  image: DecorationImage(
                    image: profilePictureUrl != null &&
                            profilePictureUrl.isNotEmpty
                        ? NetworkImage(profilePictureUrl)
                        : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isOnline)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.greenAccent : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            username,
            style: GoogleFonts.kavivanar(fontSize: 18),
          ),
          const SizedBox(height: 4),
          // Online Status Text
          Text(
            isOnline ? 'Online' : 'Offline',
            style: GoogleFonts.kavivanar(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),

          FutureBuilder<FriendRequestStatus>(
            future: FriendRequestService().checkFriendRequestStatus(userId),
            builder: (context, snapshot) {
              final status = snapshot.data ?? FriendRequestStatus.none;
              final bool isEnabled = status == FriendRequestStatus.none ||
                  status == FriendRequestStatus.rejected;

              return Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getFriendButtonColor(status),
                    foregroundColor: Colors.purple,
                    elevation: 3,
                    shadowColor: Colors.yellow.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: isEnabled
                      ? () async {
                          // Show the confirmation dialog
                          final shouldAddFriend = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return const AddfriendConfirmation();
                            },
                          );

                          // If the user confirmed, send the friend request
                          if (shouldAddFriend == true) {
                            await FriendRequestService()
                                .sendFriendRequest(userId);
                            // Create a notification
                            final notification = NotificationModel(
                              senderId:
                                  currentUserId, // the ID of the user sending the request
                              receiverId:
                                  userId, // the ID of the user receiving the request
                              message:
                                  'You just sent a friend request to $username.',
                              timestamp: DateTime.now(),
                              type: 'friend_request',
                            );

                            // Send the notification
                            await NotificationService()
                                .sendNotification(notification);
                          }
                        }
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_alt_sharp, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        status.toText(),
                        style: GoogleFonts.kavivanar(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getFriendButtonColor(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return Colors.yellow; // Pending color
      case FriendRequestStatus.accepted:
        return Colors.green; // Friends color
      case FriendRequestStatus.rejected:
        return Colors.red; // Rejected color
      case FriendRequestStatus.none:
      default:
        return const Color.fromARGB(255, 239, 246, 194); // Default color
    }
  }
}
