// ignore_for_file: avoid_print, unused_import

import 'package:chatapp/model/notification.dart';
import 'package:chatapp/services/friend_request_service.dart';
import 'package:chatapp/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class NotificationsScreen extends StatelessWidget {
  final String userId;
  
  const NotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications', style: GoogleFonts.kavivanar(),)),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService().getUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification.message),
                subtitle: Text(formatTimestamp(notification.timestamp)),
                trailing: notification.type == 'friend_request'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Accept friend request logic here
                              acceptFriendRequest(
                                  notification.senderId, userId);
                            },
                            child: const Text('Accept'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Reject friend request logic here
                              rejectFriendRequest(
                                  notification.senderId, userId);
                            },
                            child: const Text('Reject'),
                          ),
                        ],
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

String formatTimestamp(DateTime timestamp) {
  // Format the timestamp using DateFormat from the intl package
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays == 0) {
    // Today
    if (difference.inHours == 0) {
      // Less than 1 hour ago
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      // Within the same day
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else {
    // More than a month ago, format it as 'MM/dd/yyyy'
    return DateFormat('MM/dd/yyyy').format(timestamp);
  }
  
}

void acceptFriendRequest(String senderId, String receiverId) async {
  // Add both users to each other's friend list in Firestore
  await FriendRequestService().addFriend(senderId, receiverId);
  
  // Send a notification to the sender
  final notification = NotificationModel(
    senderId: receiverId,
    receiverId: senderId,
    message: '$receiverId has accepted your friend request.',
    timestamp: DateTime.now(),
    type: 'friend_acceptance',
  );

  await NotificationService().sendNotification(notification);
}

void rejectFriendRequest(String senderId, String receiverId) async {
  // Create a unique ID for the friend request
  final requestId = '${senderId}_$receiverId';
   // Logic to reject the friend request, such as removing from Firestore
  try {
    await FriendRequestService().rejectRequest(requestId);
  } catch (e) {
    // Handle any errors that occur during rejection
    print('Error rejecting friend request: $e');
  }
  
  // Send a notification to the sender about rejection
  final notification = NotificationModel(
    senderId: receiverId,
    receiverId: senderId,
    message: '$receiverId has rejected your friend request.',
    timestamp: DateTime.now(),
    type: 'friend_rejection',
  );

  await NotificationService().sendNotification(notification);
}


