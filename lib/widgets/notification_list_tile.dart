import 'package:chatapp/screens/notfication.dart';
import 'package:chatapp/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class NotificationsListTile extends StatelessWidget {
  final String userId;
  final Logger logger = Logger();

  NotificationsListTile({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return ListTile(
          leading: Stack(
            children: [
              const Icon(Icons.notification_important),
              StreamBuilder<int>(
                stream: NotificationService().getUnreadNotificationsCount(userId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data! > 0) {
                    return Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          snapshot.data! > 99 ? '99+' : snapshot.data.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          title: Text(
            'Notifications',
            style: GoogleFonts.kavivanar(color: Colors.black),
          ),
          onTap: () async {
            logger.i("Navigating to Notifications");
            
            // Since we're in a modal bottom sheet, we should pop it first
            Navigator.pop(context);

            // Then navigate to notifications screen
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsScreen(
                  key: const Key('notifications_screen'),
                  currentUserId: userId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}