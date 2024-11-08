import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  voice,
  emoji,
  image,    // For sharing images
  video,    // For sharing videos
  file,     // For document sharing
  location, // For sharing locations
  reply,    // For reply messages
  system    // For system notifications
}

enum MessageStatus {
  pending,
  sent,
  delivered,
  read,
  failed
}

class Message {
  final String id;
  final String senderId;
  final String? receiverId;
  final String? content;
  final String? mediaUrl;
  final MessageType type;
  final DateTime timestamp;
  final DateTime? editedAt;      // Timestamp for edited messages
  final bool isRead;
  final bool isPending;
  final bool isSent;
  final bool isDelivered;
  final bool isEdited;           // Flag for edited messages
  final bool isDeleted;          // Flag for deleted messages
  final String senderUsername;
  final String receiverUsername;
  final int? duration;           // For voice/video messages
  final String? thumbnailUrl;    // For image/video messages
  final String? fileSize;        // For file messages
  final String? fileName;        // For file messages
  final String? fileType;        // For file messages
  final Map<String, dynamic>? metadata; // Additional metadata
  final Message? replyTo;        // Reference to replied message
  final List<String>? mentions;  // List of mentioned user IDs
  final Map<String, dynamic>? reactions; // User reactions to message
  final String? forwaredFrom;    // Original message sender if forwarded
  final Map<String, double>? location; // For location messages {lat, lng}

  Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.content,
    this.mediaUrl,
    required this.type,
    required this.timestamp,
    this.editedAt,
    this.isRead = false,
    this.isPending = false,
    this.isSent = false,
    this.isDelivered = false,
    this.isEdited = false,
    this.isDeleted = false,
    required this.senderUsername,
    required this.receiverUsername,
    this.duration,
    this.thumbnailUrl,
    this.fileSize,
    this.fileName,
    this.fileType,
    this.metadata,
    this.replyTo,
    this.mentions,
    this.reactions,
    this.forwaredFrom,
    this.location,
  });

  MessageStatus get status {
    if (isPending) return MessageStatus.pending;
    if (!isSent) return MessageStatus.failed;
    if (isRead) return MessageStatus.read;
    if (isDelivered) return MessageStatus.delivered;
    return MessageStatus.sent;
  }

  factory Message.fromFirestore(DocumentSnapshot doc, String senderUsername, String receiverUsername) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      content: data['content'],
      mediaUrl: data['mediaUrl'],
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      editedAt: data['editedAt'] != null ? (data['editedAt'] as Timestamp).toDate() : null,
      isRead: data['isRead'] ?? false,
      isPending: data['isPending'] ?? false,
      isSent: data['isSent'] ?? false,
      isDelivered: data['isDelivered'] ?? false,
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      senderUsername: senderUsername,
      receiverUsername: receiverUsername,
      duration: data['duration'],
      thumbnailUrl: data['thumbnailUrl'],
      fileSize: data['fileSize'],
      fileName: data['fileName'],
      fileType: data['fileType'],
      metadata: data['metadata'],
      mentions: List<String>.from(data['mentions'] ?? []),
      reactions: data['reactions'],
      forwaredFrom: data['forwaredFrom'],
      location: data['location'] != null ? Map<String, double>.from(data['location']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'mediaUrl': mediaUrl,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'isRead': isRead,
      'isPending': isPending,
      'isSent': isSent,
      'isDelivered': isDelivered,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
      'duration': duration,
      'thumbnailUrl': thumbnailUrl,
      'fileSize': fileSize,
      'fileName': fileName,
      'fileType': fileType,
      'metadata': metadata,
      'mentions': mentions,
      'reactions': reactions,
      'forwaredFrom': forwaredFrom,
      'location': location,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    String? mediaUrl,
    MessageType? type,
    DateTime? timestamp,
    DateTime? editedAt,
    bool? isRead,
    bool? isPending,
    bool? isSent,
    bool? isDelivered,
    bool? isEdited,
    bool? isDeleted,
    String? senderUsername,
    String? receiverUsername,
    int? duration,
    String? thumbnailUrl,
    String? fileSize,
    String? fileName,
    String? fileType,
    Map<String, dynamic>? metadata,
    Message? replyTo,
    List<String>? mentions,
    Map<String, dynamic>? reactions,
    String? forwaredFrom,
    Map<String, double>? location,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      isRead: isRead ?? this.isRead,
      isPending: isPending ?? this.isPending,
      isSent: isSent ?? this.isSent,
      isDelivered: isDelivered ?? this.isDelivered,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      senderUsername: senderUsername ?? this.senderUsername,
      receiverUsername: receiverUsername ?? this.receiverUsername,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      metadata: metadata ?? this.metadata,
      replyTo: replyTo ?? this.replyTo,
      mentions: mentions ?? this.mentions,
      reactions: reactions ?? this.reactions,
      forwaredFrom: forwaredFrom ?? this.forwaredFrom,
      location: location ?? this.location,
    );
  }
}
