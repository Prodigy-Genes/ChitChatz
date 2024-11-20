import 'package:flutter/material.dart';

import '../features/notification_appBar.dart';
import '../widgets/notification_list.dart';

class NotificationsScreen extends StatelessWidget {
  final String currentUserId;

  const NotificationsScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithActions(currentUserId: currentUserId),
      body: NotificationList(currentUserId: currentUserId),
    );
  }
}
