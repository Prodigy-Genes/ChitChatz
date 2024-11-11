import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final bool isDeleted;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.status,
    this.type = MessageType.text,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'status': status.toString(),
      'type': type.toString(),
      'isDeleted': isDeleted,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] is Timestamp 
        ? (map['timestamp'] as Timestamp).toDate() 
        : DateTime.now(), // Fallback to current time
      status: _parseMessageStatus(map['status']),
      type: _parseMessageType(map['type']),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  static MessageStatus _parseMessageStatus(dynamic status) {
    if (status == null) return MessageStatus.sent;
    
    try {
      return MessageStatus.values.firstWhere(
        (e) => e.toString() == status,
        orElse: () => MessageStatus.sent,
      );
    } catch (e) {
      return MessageStatus.sent;
    }
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.text;
    
    try {
      return MessageType.values.firstWhere(
        (e) => e.toString() == type,
        orElse: () => MessageType.text,
      );
    } catch (e) {
      return MessageType.text;
    }
  }
}

class ChatRoom {
  final String chatId;
  final List<String> participants;
  final List<String> participantUsernames;
  final DateTime? lastMessageTime;
  final String lastMessageContent;
  final String lastMessageSenderId;
  final MessageStatus lastMessageStatus;

  ChatRoom({
    required this.chatId,
    required this.participants,
    required this.participantUsernames,
    this.lastMessageTime,
    this.lastMessageContent = '',
    this.lastMessageSenderId = '',
    this.lastMessageStatus = MessageStatus.sent,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'participantUsernames': participantUsernames,
      'lastMessageTime': lastMessageTime,
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageStatus': lastMessageStatus.toString(),
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      participantUsernames: List<String>.from(map['participantUsernames'] ?? []),
      lastMessageTime: map['lastMessageTime'] is Timestamp 
        ? (map['lastMessageTime'] as Timestamp?)?.toDate()
        : null,
      lastMessageContent: map['lastMessageContent'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageStatus: _parseMessageStatus(map['lastMessageStatus']),
    );
  }

  static MessageStatus _parseMessageStatus(dynamic status) {
    if (status == null) return MessageStatus.sent;
    
    try {
      return MessageStatus.values.firstWhere(
        (e) => e.toString() == status,
        orElse: () => MessageStatus.sent,
      );
    } catch (e) {
      return MessageStatus.sent;
    }
  }
}

// Existing enums remain the same
enum MessageStatus {
  sent,
  delivered,
  read,
  unread
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file
}