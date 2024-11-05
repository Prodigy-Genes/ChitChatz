// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'friend_request_status.dart';

class FriendRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();

  Future<FriendRequestStatus> checkFriendRequestStatus(
      String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return FriendRequestStatus.none;

    try {
      // Check both directions of friend requests
      final requests = await Future.wait([
        _firestore
            .collection('friendRequests')
            .where('senderId', isEqualTo: currentUserId)
            .where('receiverId', isEqualTo: targetUserId)
            .get(),
        _firestore
            .collection('friendRequests')
            .where('senderId', isEqualTo: targetUserId)
            .where('receiverId', isEqualTo: currentUserId)
            .get(),
      ]);

      for (var snapshot in requests) {
        if (snapshot.docs.isNotEmpty) {
          final status = snapshot.docs.first.data()['status'] as String;
          if (status == 'pending') return FriendRequestStatus.pending;
          if (status == 'accepted') return FriendRequestStatus.accepted;
          if (status == 'rejected') return FriendRequestStatus.rejected;
        }
      }

      return FriendRequestStatus.none;
    } catch (e) {
      logger.e('Error checking friend request status: $e');
      rethrow;
    }
  }

  Future<void> addFriend(String senderId, String receiverId) async {
    try {
      // Create a unique ID for friends relationship
      final friendDocId = senderId.compareTo(receiverId) < 0
          ? '${senderId}_${receiverId}'
          : '${receiverId}_${senderId}';

      // Update friends collection with both users
      await _firestore.collection('friends').doc(friendDocId).set({
        'users': [senderId, receiverId],
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update friend request status to accepted
      final requestQuery = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .get();

      if (requestQuery.docs.isNotEmpty) {
        await requestQuery.docs.first.reference.update({
          'status': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      logger.e('Error adding friend: $e');
      rethrow;
    }
  }

  Future<void> rejectFriendRequest(String senderId, String receiverId) async {
    try {
      final requestQuery = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .get();

      if (requestQuery.docs.isNotEmpty) {
        await requestQuery.docs.first.reference.update({
          'status': 'rejected',
          'rejectedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error rejecting friend request: $e');
      rethrow;
    }
  }

  Stream<List<String>> getFriends(String userId) {
    return _firestore
        .collection('friends')
        .where('users', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.expand((doc) {
        final users = List<String>.from(doc.data()['users'] ?? []);
        return users.where((id) => id != userId);
      }).toList();
    });
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      // Check if a request already exists
      final existingStatus = await checkFriendRequestStatus(targetUserId);
      if (existingStatus != FriendRequestStatus.none) {
        throw Exception(
            'A friend request already exists or users are already friends');
      }

      // Fetch sender's user data
      final senderDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      
      if (!senderDoc.exists) {
        throw Exception('Sender user data not found');
      }

      final senderData = senderDoc.data() as Map<String, dynamic>;
      final senderUsername = senderData['username'] ?? 'Unknown User';

      // Create a unique ID for the friend request
      final requestId = '${currentUserId}_${targetUserId}';

      // Create the friend request document
      await _firestore.collection('friendRequests').doc(requestId).set({
        'senderId': currentUserId,
        'receiverId': targetUserId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Create notification for the receiver with sender's username
      await _firestore.collection('notifications').add({
        'userId': targetUserId,
        'type': 'friendRequest',
        'senderId': currentUserId,
        'senderUsername': senderUsername,  // Add sender's username
        'status': 'unread',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      logger.i('Friend request sent successfully from $senderUsername');
    } catch (e) {
      logger.e('Error sending friend request: $e');
      rethrow;
    }
  }
}
