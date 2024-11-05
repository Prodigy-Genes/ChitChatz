// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/model/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'notifications';

  // Send friend request notification
   Future<void> sendFriendRequestNotification(NotificationModel notification) async {
    try {
      // Check if the user is authenticated
      final sender = _auth.currentUser;
      if (sender == null) throw Exception('User not authenticated');

      // Create notification for receiver using the notification model
      await _firestore.collection(_collectionName).add({
        'type': notification.type,
        'senderId': notification.senderId,
        'senderName': notification.senderName, // You can pass the sender's name directly from the model
        'receiverId': notification.receiverId,
        'receiverName': notification.receiverName,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error sending friend request notification: $e');
      rethrow;
    }
  }

  // Fetch notifications for current user
  Stream<List<NotificationModel>> getNotifications() {
    return _firestore.collection('notifications')
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return NotificationModel.fromFirestore(doc);
        }).toList();
      });
  }

  // Update notification status
  Future<void> updateNotificationStatus(String notificationId, String status) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(notificationId)
          .update({'status': status});
    } catch (e) {
      print('Error updating notification status: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final unreadNotifications = await _firestore
          .collection(_collectionName)
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'unread')
          .get();

      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'status': 'read'});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as unread
  Future<void> markAllNotificationsAsUnRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final readNotifications = await _firestore
          .collection(_collectionName)
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'read')
          .get();

      for (var doc in readNotifications.docs) {
        batch.update(doc.reference, {'status': 'unread'});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as unread: $e');
      rethrow;
    }
  }

  // Delete a single notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final userNotifications = await _firestore
          .collection(_collectionName)
          .where('receiverId', isEqualTo: userId)
          .get();

      for (var doc in userNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }

  // Delete old notifications (retention policy)
  Future<void> deleteOldNotifications(String userId) async {
    try {
      final oldNotifications = await _firestore
          .collection(_collectionName)
          .where('receiverId', isEqualTo: userId)
          .where('timestamp', isLessThan: DateTime.now().subtract(const Duration(days: 30)))
          .get();

      if (oldNotifications.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var doc in oldNotifications.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error deleting old notifications: $e');
      rethrow;
    }
  }

  // Restore a deleted notification
  Future<void> restoreNotification(NotificationModel notification) async {
    try {
      await _firestore.collection(_collectionName).add({
        'senderId': notification.senderId,
        'receiverId': notification.receiverId,
        'message': notification.message,
        'timestamp': notification.timestamp,
        'type': notification.type,
        'status': notification.status,
        'data': notification.data,
      });
    } catch (e) {
      print('Error restoring notification: $e');
      rethrow;
    }
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'unread')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
