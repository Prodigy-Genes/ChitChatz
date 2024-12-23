import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final DateTime createdAt;
  final String profilePictureUrl;
  final bool isUserOnline;
  final bool isEmailVerified;
  final String? lastMessage; // Nullable lastMessage
  final int unreadMessages; // Add unreadMessages field

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.profilePictureUrl,
    required this.isUserOnline,
    required this.isEmailVerified,
    this.lastMessage, // lastMessage field (nullable)
    required this.unreadMessages, // unreadMessages field
  });

  // Factory constructor to create a UserModel from a Firestore document snapshot
  factory UserModel.fromDocumentSnapshot(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      isUserOnline: data['isUserOnline'] ?? false,
      isEmailVerified: data['isEmailVerified'] ?? false,
      lastMessage: data['lastMessage'], // lastMessage from Firestore data
      unreadMessages: data['unreadMessages'] ?? 0, // unreadMessages from Firestore data
    );
  }

  // Convert UserModel to a Map (to save to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'createdAt': createdAt,
      'profilePictureUrl': profilePictureUrl,
      'isUserOnline': isUserOnline,
      'isEmailVerified': isEmailVerified,
      'lastMessage': lastMessage, // Include lastMessage in toMap
      'unreadMessages': unreadMessages, // Include unreadMessages in toMap
    };
  }

  // Method to create a UserModel from a Map
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      isUserOnline: map['isUserOnline'] ?? false,
      isEmailVerified: map['isEmailVerified'] ?? false,
      lastMessage: map['lastMessage'], // lastMessage when creating from Map
      unreadMessages: map['unreadMessages'] ?? 0, // unreadMessages when creating from Map
    );
  }
}
