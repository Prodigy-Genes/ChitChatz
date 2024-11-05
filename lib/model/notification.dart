import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String senderId;
  final String senderName; // Added senderName
  final String receiverId;
  final String receiverName; // Added receiverName
  final String message;
  final DateTime timestamp;
  final String type;
  final String status;
  final Map<String, dynamic> data;

  NotificationModel({
    this.id,
    required this.senderId,
    required this.senderName, // Added senderName
    required this.receiverId,
    required this.receiverName, // Added receiverName
    required this.message,
    required this.timestamp,
    required this.type,
    this.status = 'unread',
    this.data = const {},
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ) {
    final data = snapshot.data()!;
    return NotificationModel(
      id: snapshot.id,
      senderId: data['senderId'],
      senderName: data['senderName'], // Added senderName
      receiverId: data['receiverId'],
      receiverName: data['receiverName'], // Added receiverName
      message: data['message'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'],
      status: data['status'] ?? 'unread',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName, // Added senderName
      'receiverId': receiverId,
      'receiverName': receiverName, // Added receiverName
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'status': status,
      'data': data,
    };
  }

  // Create a copy of the notification with modified fields
  NotificationModel copyWith({
    String? id,
    String? senderId,
    String? senderName, // Added senderName
    String? receiverId,
    String? receiverName, // Added receiverName
    String? message,
    DateTime? timestamp,
    String? type,
    String? status,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName, // Added senderName
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName, // Added receiverName
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }

  // Helper method to check if notification is unread
  bool get isUnread => status == 'unread';

  // Helper method to get formatted timestamp
  String getFormattedTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to get notification type display text
  String getTypeDisplayText() {
    switch (type) {
      case 'friend_request':
        return 'Friend Request';
      case 'friend_acceptance':
        return 'Friend Request Accepted';
      case 'friend_rejection':
        return 'Friend Request Declined';
      default:
        return 'Notification';
    }
  }
}
