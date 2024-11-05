// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:chatapp/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBarWithActions extends StatelessWidget implements PreferredSizeWidget {
  final String currentUserId;

  const AppBarWithActions({super.key, required this.currentUserId});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF6C63FF),
      title: Text('Notifications', style: GoogleFonts.kavivanar(color: Colors.white),),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_all_read':
                NotificationService().markAllNotificationsAsRead(currentUserId);
                break;
              case 'clear_all':
                _showDeleteAllConfirmation(context, currentUserId);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'mark_all_read',
              child: Text('Mark all as read'),
            ),
            const PopupMenuItem(
              value: 'clear_all',
              child: Text('Clear all notifications'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDeleteAllConfirmation(BuildContext context, String userId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (result == true) {
      NotificationService().deleteAllNotifications(userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications cleared')),
        );
      }
    }
  }
}
