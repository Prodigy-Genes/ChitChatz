import 'package:flutter/material.dart';
import 'package:chatapp/model/notification.dart';
import 'package:chatapp/features/notification_helper.dart';

class SelfNotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const SelfNotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          notification.message,
          style: TextStyle(
            fontFamily: 'Kavivanar',
            fontSize: 16,
            color: Colors.black,
            fontWeight: notification.status == 'unread' ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${NotificationHelper.getNotificationTypeText(notification.type)} • '
          '${NotificationHelper.formatTimestamp(notification.timestamp)}',
          style: TextStyle(
            fontFamily: 'Kavivanar',
            color: Colors.grey[600],
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: NotificationHelper.getNotificationColor(notification.type),
          child: Icon(
            NotificationHelper.getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        trailing: _buildTrailing(context),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (notification.status == 'unread')
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        PopupMenuButton<String>(
          onSelected: (value) => NotificationHelper.handleNotificationAction(context, notification, value),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: notification.status == 'unread' ? 'mark_read' : 'mark_unread',
              child: Text(
                notification.status == 'unread' ? 'Mark as read' : 'Mark as unread',
                style: const TextStyle(fontFamily: 'Kavivanar'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(fontFamily: 'Kavivanar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
