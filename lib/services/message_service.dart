import 'dart:convert';

import 'package:chatapp/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart'; 


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


Future<String?> getOneSignalPlayerId() async {
  try {
    String? onesignalId = await OneSignal.User.getOnesignalId();
    logger.i('OneSignal id is $onesignalId');
    return onesignalId;
  } catch (e) {
    logger.e('error attaining OneSignal Id $e');
    return null;
  }
}

  // Method to send push notification
  Future<void> sendPushNotification({
    required String receiverId,
    required String message,
  }) async {

    String? currentDevicePlayerId = await getOneSignalPlayerId();

    if (currentDevicePlayerId == null) {
      logger.e('No OneSignal device token available');
      return;
    }
    else{
      logger.i('OneSignal device token available');
    }
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
      isDeleted: false, 
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
        message: '${currentUser.displayName} sent you a message: $content',
      );
  } catch (e) {
    logger.e('Error sending message: $e');
    if (e.toString().contains('PERMISSION_DENIED')) {
      // Handle permission error
      logger.e('Permission Denied while accessing Firestore');
    }
    rethrow;
  }
}

  Future<MessageStatus?> getMessageStatusForLastMessage(String chatId) async {
  try {
    // Get the latest message in the chat
    final lastMessageSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (lastMessageSnapshot.docs.isNotEmpty) {
      // Get the message data
      final lastMessage = lastMessageSnapshot.docs.first.data();
      
      // Extract the status of the last message
      final statusString = lastMessage['status'];
      if (statusString != null) {
        // Map the status string to the MessageStatus enum
        return MessageStatus.values.firstWhere(
          (status) => status.toString().split('.').last == statusString,
          orElse: () => MessageStatus.sent, // Default status if not found
        );
      }
    }
    return null; // Return null if no message is found
  } catch (e) {
    logger.e('Error getting status for last message: $e');
    return null; // Return null in case of error
  }
}


  Future<String?> getLastMessageId(String chatId) async {
    try {
      // Assuming you have a collection where messages are stored
      var querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['messageId'];
      }
    } catch (e) {
      print('Error fetching last message ID: $e');
    }
    return null;
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
      // Update the message status
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'status': status.toString()});

      // Get the chat document
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      // If this message is the last message in the chat, update the chat's last message status
      if (chatDoc.exists) {
        final lastMessageId = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first.id);

        if (lastMessageId == messageId) {
          await _firestore.collection('chats').doc(chatId).update({
            'lastMessageStatus': status.toString(),
          });
        }
      }
    } catch (e) {
      logger.e('Error updating message status: $e');
      rethrow;
    }
  }

  

  
}