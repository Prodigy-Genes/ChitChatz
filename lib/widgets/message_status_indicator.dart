// widgets/message_status_indicator.dart
import 'package:chatapp/model/message.dart';
import 'package:flutter/material.dart';

class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;

  const MessageStatusIndicator({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.pending:
        return const Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey,
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.check,
          size: 16,
          color: Colors.grey,
        );
      case MessageStatus.delivered:
        return const Icon(
          Icons.check_circle_outline,
          size: 16,
          color: Colors.grey,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.blue,
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 16,
          color: Colors.red,
        );
      default:
        return const SizedBox();
    }
  }
}
