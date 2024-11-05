import 'package:chatapp/features/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/model/notification.dart';
import 'package:chatapp/services/notification_service.dart';


class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id!),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        NotificationService().deleteNotification(notification.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => NotificationService().restoreNotification(notification),
            ),
          ),
        );
      },
      child: ListTile(
        title: Text(
          notification.message,
          style: TextStyle(
            fontWeight: notification.status == 'unread' ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${NotificationHelper.getNotificationTypeText(notification.type)} • '
          '${NotificationHelper.formatTimestamp(notification.timestamp)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        leading: CircleAvatar(
          backgroundColor: NotificationHelper.getNotificationColor(notification.type),
          child: Icon(
            NotificationHelper.getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        trailing: _buildTrailing(context),
        onTap: () => NotificationHelper.handleNotificationTap(context, notification),
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
              child: Text(notification.status == 'unread' ? 'Mark as read' : 'Mark as unread'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ],
    );
  }
}
