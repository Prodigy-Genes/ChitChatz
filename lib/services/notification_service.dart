import 'dart:convert';

import 'package:chatapp/services/friend_request_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/model/notification.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http; 

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'notifications';
  final Logger _logger = Logger();
  final String oneSignalAppId = dotenv.env['ONESIGNAL_APPID']??'';
  final String oneSignalRestApiKey = dotenv.env['ONESIGNAL_APIKEY']??'';

  Future<void> sendPushNotification({
    required String receiverId,
    required String message,
  }) async {
    const url = 'https://onesignal.com/api/v1/notifications';
    
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Basic $oneSignalRestApiKey',
    };

    final body = jsonEncode({
      'app_id': oneSignalAppId,
      'include_external_user_ids': [receiverId],
      'contents': {'en': message},
      'headings': {'en': 'Friend Request'},
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        _logger.i('Push notification sent successfully: ${response.body}');
      } else {
        _logger.e('Failed to send push notification: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error sending push notification: $e');
    }
  }
  

  Future<String> _getUsername(String userId) async {
    if (userId.isEmpty) {
      _logger.w('User ID is empty');
      return 'Unknown User';
    }

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) {
        _logger.w('User document does not exist for ID: $userId');
        return 'Unknown User';
      }

      final userData = userDoc.data()!;
      final username = userData['username'] as String?;

      // Log the found data for debugging
      _logger.d('User data for $userId: ${userData.toString()}');

      if (username == null || username.isEmpty) {
        _logger.w('Username is null or empty for user ID: $userId');
        return 'Unknown User';
      }

      _logger.i('Found username for user $userId: $username');
      return username;
    } catch (e) {
      _logger.e('Error fetching username for ID $userId: $e');
      return 'Unknown User';
    }
  }

   // Method to check if a notification is a self-notification
  bool isSelfNotification(String senderId, String receiverId) {
    return senderId == receiverId;
  }

  // Example usage in getNotifications
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('receiverId', isEqualTo: userId)
        .where('senderId', isNotEqualTo: userId) // Exclude self-notifications
        .orderBy('senderId') // Required for compound query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return NotificationModel.fromFirestore(doc);
            })
            .toList());
  }

  Stream<List<NotificationModel>> getSelfNotifications(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('receiverId', isEqualTo: userId)
        .where('senderId', isEqualTo: userId) // Only self-notifications
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return NotificationModel.fromFirestore(doc);
            })
            .toList());
  }

  // Modify sendFriendRequestNotification to use the isSelfNotification method
  Future<void> sendFriendRequestNotification({
    required String receiverId,
    String? receiverUsername,
    required String type,
  }) async {
    try {
      final sender = _auth.currentUser;
      if (sender == null) throw Exception('User not authenticated');

      final senderUsername = await _getUsername(sender.uid);
      final finalReceiverUsername =
          receiverUsername ?? await _getUsername(receiverId);

      final receiverNotification = NotificationModel(
        id: '',
        senderId: sender.uid,
        senderName: senderUsername,
        receiverId: receiverId,
        receiverName: finalReceiverUsername,
        type: type,
        message: '$senderUsername sent you a friend request',
        status: 'unread',
        timestamp: DateTime.now(),
      );

      final senderNotification = NotificationModel(
        id: '',
        senderId: sender.uid,
        senderName: senderUsername,
        receiverId: sender.uid,
        receiverName: senderUsername,
        type: 'friend_request_sent',
        message: 'You sent a friend request to $finalReceiverUsername',
        status: 'read',
        timestamp: DateTime.now(),
      );

      final batch = _firestore.batch();
      final receiverNotifRef = _firestore.collection(_collectionName).doc();
      final senderNotifRef = _firestore.collection(_collectionName).doc();

      batch.set(receiverNotifRef, receiverNotification.toFirestore());
      batch.set(senderNotifRef, senderNotification.toFirestore());

      await batch.commit();

       // Send push notification
      await sendPushNotification(
        receiverId: receiverId,
        message: '$senderUsername sent you a friend request!',
      );

      _logger.i('Friend request notifications sent successfully');
    } catch (e) {
      _logger.e('Error sending friend request notifications: $e');
      rethrow;
    }
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

  // Send a reminder notification for pending friend requests older than 7 days
  Future<void> sendPendingRequestReminder() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final now = DateTime.now();

    try {
      // Fetch pending friend requests older than 7 days
      final pendingRequests = await _firestore
          .collection('friend_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .where('timestamp', isLessThan: now.subtract(const Duration(days: 7)))
          .get();

      for (var requestDoc in pendingRequests.docs) {
        final requestId = requestDoc.id;
        final senderId = requestDoc['senderId'];

        // Check if a reminder notification has already been sent in the last 7 days
        final recentReminder = await _firestore
            .collection(_collectionName)
            .where('requestId', isEqualTo: requestId)
            .where('senderId', isEqualTo: senderId)
            .where('receiverId', isEqualTo: currentUserId)
            .where('type', isEqualTo: 'friend_request_reminder')
            .where('timestamp', isGreaterThan: now.subtract(const Duration(days: 7)))
            .get();

        if (recentReminder.docs.isEmpty) {
          // Send reminder notification
          await sendFriendRequestNotification(
            receiverId: currentUserId,
            type: 'friend_request_reminder',
          );
          _logger.i('Sent reminder for pending friend request from $senderId');
        }
      }
    } catch (e) {
      _logger.e('Error sending reminder for pending requests: $e');
    }
  }

  // Expire friend requests older than 30 days and notify sender
  Future<void> expireOldFriendRequests() async {
    final now = DateTime.now();

    try {
      // Find pending requests older than 30 days
      final oldRequests = await _firestore
          .collection('friend_requests')
          .where('status', isEqualTo: 'pending')
          .where('timestamp', isLessThan: now.subtract(const Duration(days: 30)))
          .get();

      for (var requestDoc in oldRequests.docs) {
        final requestId = requestDoc.id;
        final senderId = requestDoc['senderId'];
        final receiverId = requestDoc['receiverId'];

        // Mark the request as expired
        await _firestore
            .collection('friend_requests')
            .doc(requestId)
            .update({'status': FriendRequestStatus.none.toText()});

        // Send a notification to the sender that the request expired
        await sendFriendRequestNotification(
          receiverId: senderId,
          type: 'friend_request_expired',
        );
        _logger.i('Expired friend request from $senderId to $receiverId');
      }
    } catch (e) {
      _logger.e('Error expiring old friend requests: $e');
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
