import 'dart:convert';

import 'package:chatapp/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http; 


class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();
  final String oneSignalAppId = dotenv.env['ONESIGNAL_APPID']??'';
  final String oneSignalRestApiKey = dotenv.env['ONESIGNAL_APIKEY']??'';

  String generateChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  // Method to send push notification
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
      'headings': {'en': 'New Message'},
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        logger.i('Push notification sent successfully: ${response.body}');
      } else {
        logger.e('Failed to send push notification: ${response.body}');
      }
    } catch (e) {
      logger.e('Error sending push notification: $e');
    }
  }


  Future<void> sendMessage({
  required String receiverId,
  required String content,
  MessageStatus status = MessageStatus.sent,
  MessageType type = MessageType.text,
}) async {
  try {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user logged in');

    final chatId = generateChatId(currentUser.uid, receiverId);
    final messageId = _firestore.collection('messages').doc().id;
    final timestamp = FieldValue.serverTimestamp();

    final message = MessageModel(
      messageId: messageId,
      senderId: currentUser.uid,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      status: status,
      type: type,
      isDeleted: false, // Explicitly set isDeleted
    );

    // Ensure the message has all required fields
    final messageMap = message.toMap();
    messageMap['timestamp'] = timestamp; // Use server timestamp

    // Update messages collection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(messageMap);

    // Update chat room with last message
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessageTime': timestamp,
      'lastMessageContent': content,
      'lastMessageSenderId': currentUser.uid,
      'lastMessageStatus': MessageStatus.sent.toString(),
      'users': [currentUser.uid, receiverId], // Add users to chat document
    }, SetOptions(merge: true));

    await sendPushNotification(
        receiverId: receiverId,
        message: '${currentUser .displayName} sent you a message: $content',
      );


  } catch (e) {
    logger.e('Error sending message: $e');
    rethrow;
  }
}

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isDeleted': true});
    } catch (e) {
      logger.e('Error deleting message: $e');
      rethrow;
    }
  }

  Future<void> updateMessageStatusToDelivered(String chatId) async {
    try {
      // Get current user ID (the receiver)
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      
      // Query for messages sent to the current user that are still in 'sent' status
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: MessageStatus.sent.toString())
          .get();

      // Create a batch to update multiple documents efficiently
      WriteBatch batch = _firestore.batch();

      // Update each message's status
      for (var doc in messagesQuery.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.delivered.toString(),
        });
      }

      // Commit the batch update
      await batch.commit();
    } catch (e) {
      print('Error updating message status to delivered: $e');
    }
  }

  // Method to update message status to read
  Future<void> updateMessageStatusToRead(String chatId) async {
    try {
      // Get current user ID (the receiver)
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      
      // Query for messages sent to the current user that are in 'sent' or 'delivered' status
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', whereIn: [
            MessageStatus.sent.toString(), 
            MessageStatus.delivered.toString()
          ])
          .get();

      // Create a batch to update multiple documents efficiently
      WriteBatch batch = _firestore.batch();

      // Update each message's status
      for (var doc in messagesQuery.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.read.toString(),
        });
      }

      // Commit the batch update
      await batch.commit();
    } catch (e) {
      print('Error updating message status to read: $e');
    }
  }


  // Method to bulk update unread messages to delivered
  Future<void> markUnreadMessagesAsDelivered(String chatId) async {
    try {
      // Get all unread messages in the chat
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('status', isEqualTo: MessageStatus.sent.toString())
          .where('receiverId', isEqualTo: _auth.currentUser!.uid)
          .get();

      // Batch update to improve performance
      WriteBatch batch = _firestore.batch();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.delivered.toString(),
        });
      }

      await batch.commit();

      // Update the last message status in the chat room if applicable
      if (unreadMessages.docs.isNotEmpty) {
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessageStatus': MessageStatus.delivered.toString(),
        });
      }
    } catch (e) {
      print('Error marking unread messages as delivered: $e');
    }
  }

   Future<void> markAllMessagesAsRead(String chatId) async {
    try {
      // Get all unread and delivered messages in the chat
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('status', whereIn: [
            MessageStatus.sent.toString(),
            MessageStatus.delivered.toString()
          ])
          .where('receiverId', isEqualTo: _auth.currentUser!.uid)
          .get();

      // Batch update to improve performance
      WriteBatch batch = _firestore.batch();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.read.toString(),
        });
      }

      await batch.commit();

      // Update the last message status in the chat room if applicable
      if (unreadMessages.docs.isNotEmpty) {
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessageStatus': MessageStatus.read.toString(),
        });
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }


  Future<void> markAllAsRead(String chatId, String senderId) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: senderId)
          .where('status', isNotEqualTo: MessageStatus.read.toString())
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'status': MessageStatus.read.toString()});
      }
      await batch.commit();
    } catch (e) {
      logger.e('Error marking messages as read: $e');
      rethrow;
    }
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<ChatRoom?> getChatRoom(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatRoom.fromMap(doc.data()!);
    });
  }

  Future<void> updateMessageStatus({
    required String chatId,
    required String messageId,
    required MessageStatus status,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'status': status.toString()});
    } catch (e) {
      logger.e('Error updating message status: $e');
      rethrow;
    }
  }
}