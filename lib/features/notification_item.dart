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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => NotificationHelper.handleNotificationAction(context, notification, 'accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontFamily: 'Kavivanar',
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => NotificationHelper.handleNotificationAction(context, notification, 'reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          fontFamily: 'Kavivanar',
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
