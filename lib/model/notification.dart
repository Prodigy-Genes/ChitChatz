class NotificationModel {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final String type; // "friend_request" or "friend_acceptance"

  NotificationModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.type,
  });
}
