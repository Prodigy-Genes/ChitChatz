// ignore_for_file: avoid_print

import 'package:chatapp/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage import commented out
import 'dart:io';
import 'dart:async';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // FirebaseStorage instance commented out

  // Generate a unique chat ID for two users
  String generateChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  // Send a new message
  Future<String> sendMessage(Message message) async {
    try {
      final chatId = generateChatId(message.senderId, message.receiverId!);

      // Create message document
      final docRef = await _firestore.collection('messages').add({
        ...message.toMap(),
        'chatId': chatId,
      });

      // Update chat metadata
      await _updateChatMetadata(chatId, message);

      return docRef.id;
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }

  // Upload media to Firebase Storage and get the URL
  // Future<String> uploadMedia(File file, String path) async { 
  //   try {
  //     final uploadTask = _storage.ref(path).putFile(file);
  //     final snapshot = await uploadTask;
  //     return await snapshot.ref.getDownloadURL();
  //   } catch (e) {
  //     throw Exception("Failed to upload media: $e");
  //   }
  // }

  // Get messages in a chat
  Stream<List<Message>> getMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        const senderUsername = ''; // Fetch from your users collection
        const receiverUsername = ''; // Fetch from your users collection
        return Message.fromFirestore(doc, senderUsername, receiverUsername);
      }).toList();
    });
  }

  // Update chat metadata when a message is sent
  Future<void> _updateChatMetadata(String chatId, Message message) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    await chatRef.update({
      'lastMessage': message.content,
      'lastMessageTimestamp': message.timestamp,
      'senderId': message.senderId,
    });
  }

  // Function to get the number of unread messages for a user
  Future<int> getUnreadMessages(String userId) async {
    try {
      // Fetch messages where the user is the receiver and the 'read' field is false
      QuerySnapshot querySnapshot = await _firestore
          .collection('messages') // Assume messages are stored in 'messages' collection
          .where('receiverId', isEqualTo: userId) // The user is the receiver
          .where('read', isEqualTo: false) // Unread messages
          .get();

      return querySnapshot.docs.length; // Return the count of unread messages
    } catch (e) {
      print("Error fetching unread messages: $e");
      return 0; // Return 0 in case of error
    }
  }

  // Function to get the number of friends with new messages
  Future<int> getFriendsWithNewMessages(String userId) async {
    try {
      // Fetch messages where the user is the receiver and the 'read' field is false
      QuerySnapshot querySnapshot = await _firestore
          .collection('messages') // Messages collection
          .where('receiverId', isEqualTo: userId) // The user is the receiver
          .where('read', isEqualTo: false) // Unread messages
          .get();

      // Create a set to track unique sender IDs (friends who have sent unread messages)
      Set<String> friendsWithNewMessages = {};

      // Iterate through the messages to find the senders
      for (var doc in querySnapshot.docs) {
        String senderId = doc['senderId']; // Get the senderId of the message
        friendsWithNewMessages.add(senderId); // Add the sender to the set
      }

      return friendsWithNewMessages.length; // Return the count of friends with unread messages
    } catch (e) {
      print("Error fetching friends with new messages: $e");
      return 0; // Return 0 in case of error
    }
  }
}
