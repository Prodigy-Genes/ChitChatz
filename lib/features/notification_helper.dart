import 'package:flutter/material.dart';
import 'package:chatapp/model/notification.dart';
import 'package:chatapp/services/notification_service.dart';

class NotificationHelper {
  static String getNotificationTypeText(String type) {
    switch (type) {
      case 'friend_request':
        return 'Friend Request';
      case 'friend_acceptance':
        return 'Friend Request Accepted';
      case 'friend_rejection':
        return 'Friend Request Declined';
      default:
        return 'Notification';
    }
  }

  static IconData getNotificationIcon(String type) {
    switch (type) {
      case 'friend_request':
        return Icons.person_add;
      case 'friend_acceptance':
        return Icons.people;
      case 'friend_rejection':
        return Icons.person_remove;
      default:
        return Icons.notifications;
    }
  }

  static Color getNotificationColor(String type) {
    switch (type) {
      case 'friend_request':
        return Colors.blue;
      case 'friend_acceptance':
        return Colors.green;
      case 'friend_rejection':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  static void handleNotificationTap(BuildContext context, NotificationModel notification) {
    if (notification.status == 'unread') {
      NotificationService().markAllNotificationsAsRead(notification.id!);
    }
  }

  static void handleNotificationAction(
      BuildContext context, NotificationModel notification, String action) {
    switch (action) {
      case 'mark_read':
        NotificationService().markAllNotificationsAsRead(notification.id!);
        break;
      case 'mark_unread':
        NotificationService().markAllNotificationsAsUnread(notification.id!);
        break;
      case 'delete':
        NotificationService().deleteNotification(notification.id!);
        break;
    }
  }
}
