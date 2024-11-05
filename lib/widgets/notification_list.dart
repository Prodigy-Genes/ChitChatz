import 'package:chatapp/features/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/model/notification.dart';
import 'package:chatapp/services/notification_service.dart';

class NotificationList extends StatelessWidget {
  final String currentUserId;

  const NotificationList({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService().getNotifications(currentUserId), // Pass currentUserId here
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorContent(context, snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final notifications = snapshot.data!;
        if (notifications.isEmpty) {
          return _buildEmptyContent();
        }
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) => NotificationItem(notification: notifications[index]),
        );
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              (context as Element).markNeedsBuild();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
