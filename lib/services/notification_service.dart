import 'package:chatapp/model/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification(NotificationModel notification) async {
    await _firestore.collection('notifications').add({
      'senderId': notification.senderId,
      'receiverId': notification.receiverId,
      'message': notification.message,
      'timestamp': notification.timestamp.toIso8601String(),
      'type': notification.type,
    });
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return NotificationModel(
                senderId: doc['senderId'],
                receiverId: doc['receiverId'],
                message: doc['message'],
                timestamp: DateTime.parse(doc['timestamp']),
                type: doc['type'],
              );
            }).toList());
  }
  
}

