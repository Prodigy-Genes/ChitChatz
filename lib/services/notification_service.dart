import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/model/notification.dart';
import 'package:logger/logger.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'notifications';
  final Logger _logger = Logger();

  Future<String> _getSenderName(String senderId) async {
    if (senderId.isEmpty) {
      _logger.w('Sender ID is empty');
      return 'Unknown User';
    }

    try {
      final userDoc = await _firestore.collection('users').doc(senderId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final displayName = userDoc.data()!['displayName'];
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        } else {
          _logger.w('Display name is null or empty for sender ID: $senderId');
        }
      } else {
        _logger.w('User document does not exist for sender ID: $senderId');
      }
    } catch (e) {
      _logger.e('Error fetching sender name for ID $senderId: $e');
    }
    return 'Unknown User'; // Fallback
  }

  Future<void> sendFriendRequestNotification({
    required String receiverId,
    required String receiverName,
    required String type,
  }) async {
    try {
      final sender = _auth.currentUser;
      if (sender == null) throw Exception('User not authenticated');

      final senderName = await _getSenderName(sender.uid); // Get sender's name
      _logger.i('Sender Name: $senderName');

      // Create notification for receiver
      final receiverNotification = NotificationModel(
        id: '', // Firestore will generate this
        senderId: sender.uid,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        type: type,
        message: '$senderName sent you a friend request',
        status: 'unread',
        timestamp: DateTime.now(),
      );

      // Create notification for sender
      final senderNotification = NotificationModel(
        id: '', // Firestore will generate this
        senderId: sender.uid,
        senderName: senderName,
        receiverId: sender.uid, // Sender will receive this notification
        receiverName: senderName, // Use sender's name
        type: 'friend_request_sent',
        message: 'You sent a friend request to $receiverName',
        status: 'read', // Mark as read for sender
        timestamp: DateTime.now(),
      );

      // Use a batch write to ensure both notifications are created atomically
      final batch = _firestore.batch();

      // Create new documents with auto-generated IDs
      final receiverNotifRef = _firestore.collection(_collectionName).doc();
      final senderNotifRef = _firestore.collection(_collectionName).doc();

      // Set the documents in the batch
      batch.set(receiverNotifRef, receiverNotification.toFirestore());
      batch.set(senderNotifRef, senderNotification.toFirestore());

      // Commit the batch
      await batch.commit();

      _logger.i('Friend request notifications sent successfully');
    } catch (e) {
      _logger.e('Error sending friend request notifications: $e');
      rethrow; // Consider rethrowing with more context if needed
    }
  }

  // Rest of the methods remain the same...
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) {
              final data = doc.data();
              // Add the document ID to the data
              data['id'] = doc.id;
              return NotificationModel.fromFirestore(doc);
            }).toList());
  }

  // Update notification status
  Future<void> updateNotificationStatus(
      String notificationId, String status) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(notificationId)
          .update({'status': status});
    } catch (e) {
      _logger.e('Error updating notification status: $e');
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

      if (unreadNotifications.docs.isEmpty) return;

      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'status': 'read'});
      }

      await batch.commit();
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as unread
  Future<void> markAllNotificationsAsUnread(String userId) async {
    try {
      final batch = _firestore.batch();
      final readNotifications = await _firestore
          .collection(_collectionName)
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'read')
          .get();

      if (readNotifications.docs.isEmpty) return;

      for (var doc in readNotifications.docs) {
        batch.update(doc.reference, {'status': 'unread'});
      }

      await batch.commit();
    } catch (e) {
      _logger.e('Error marking all notifications as unread: $e');
      rethrow;
    }
  }

  // Delete a single notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collectionName).doc(notificationId).delete();
    } catch (e) {
      _logger.e('Error deleting notification: $e');
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

      if (userNotifications.docs.isEmpty) return;

      for (var doc in userNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      _logger.e('Error deleting all notifications: $e');
      rethrow;
    }
  }

  // Delete notifications older than 30 days (retention policy)
  Future<void> deleteOldNotifications(String userId) async {
    try {
      final oldNotifications = await _firestore
          .collection(_collectionName)
          .where('receiverId', isEqualTo: userId)
          .where('timestamp',
              isLessThan: DateTime.now().subtract(const Duration(days: 30)))
          .get();

      if (oldNotifications.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _logger.e('Error deleting old notifications: $e');
      rethrow;
    }
  }

  // Restore a deleted notification
  Future<void> restoreNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(_collectionName)
          .add(notification.toFirestore());
    } catch (e) {
      _logger.e('Error restoring notification: $e');
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
