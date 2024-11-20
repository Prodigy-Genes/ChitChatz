import 'package:chatapp/model/message.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageStatusHandler {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final MessagingService _messagingService;

  MessageStatusHandler({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required MessagingService messagingService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _messagingService = messagingService;

  // Listen to messages and update their status
  Stream<void> listenToMessages(String chatId) {
  final currentUser = _auth.currentUser;
  if (currentUser == null) return const Stream.empty();

  return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .where('receiverId', isEqualTo: currentUser.uid)
      .where('status', whereIn: [
        MessageStatus.sent.toString(),
        MessageStatus.delivered.toString()
      ])
      .snapshots()
      .asyncMap((snapshot) async {
    for (var doc in snapshot.docs) {
      final message = MessageModel.fromMap(doc.data());
      
      // If message is sent, mark it as delivered and update chat room lastMessageStatus
      if (message.status == MessageStatus.sent) {
        await _messagingService.updateMessageStatus(
          chatId: chatId,
          messageId: message.messageId,
          status: MessageStatus.delivered,
        );
        
        
      }
    }
  });
}

  

  // Mark messages as read when chat is opened
  Future<void> markMessagesAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final querySnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('status', whereIn: [
          MessageStatus.sent.toString(),
          MessageStatus.delivered.toString()
        ])
        .get();

    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {
        'status': MessageStatus.read.toString()
      });
    }

    await batch.commit();

  }

  // Initialize status handling for a specific chat
  void initializeStatusHandling(String otherUserId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final chatId = _messagingService.generateChatId(
      currentUser.uid,
      otherUserId,
    );

    // Start listening to messages
    listenToMessages(chatId);
  }
}