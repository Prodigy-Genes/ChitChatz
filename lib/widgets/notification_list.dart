import 'package:chatapp/features/collaborative_notifcation_item.dart';
import 'package:chatapp/features/self_notification_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatapp/model/notification.dart';
import 'package:chatapp/services/notification_service.dart';

class NotificationList extends StatelessWidget {
  final String currentUserId;

  const NotificationList({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: TabBar(
              tabs: const [
                Tab(text: 'Notifications'),
                Tab(text: 'Your Activity'),
              ],
              labelStyle: GoogleFonts.kavivanar(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                color: const Color.fromARGB(255, 211, 211, 211),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationTab(context),
            _buildSelfNotificationTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTab(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService().getNotifications(currentUserId),
      builder: (context, snapshot) {
        return _buildNotificationContent(context, snapshot);
      },
    );
  }

  Widget _buildSelfNotificationTab(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService().getSelfNotifications(currentUserId),
      builder: (context, snapshot) {
        return _buildNotificationContent(
          context, 
          snapshot,
          emptyMessage: 'No activity yet',
          emptyIcon: Icons.history,
        );
      },
    );
  }

  Widget _buildNotificationContent(
  BuildContext context,
  AsyncSnapshot<List<NotificationModel>> snapshot, {
  String emptyMessage = 'No notifications yet',
  IconData emptyIcon = Icons.notifications_off,
}) {
  if (snapshot.hasError) {
    return _buildErrorContent(context, snapshot.error.toString());
  }

  if (!snapshot.hasData) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  final notifications = snapshot.data!;
  if (notifications.isEmpty) {
    return _buildEmptyContent(message: emptyMessage, icon: emptyIcon);
  }

  return RefreshIndicator(
    onRefresh: () async {
      (context as Element).markNeedsBuild();
    },
    child: ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        bool isSelfNotification = notification.isSelfNotification(currentUserId);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: isSelfNotification
                ? SelfNotificationItem(notification: notification,) // Display self-notification
                : CollaborativeNotificationItem(notification: notification),
          ),
        );
      },
    ),
  );
}

  Widget _buildErrorContent(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: GoogleFonts.kavivanar(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                (context as Element).markNeedsBuild();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent({
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.kavivanar(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
