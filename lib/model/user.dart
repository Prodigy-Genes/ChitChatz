import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final DateTime createdAt;
  final String profilePictureUrl;
  final bool isUserOnline;
  final bool isEmailVerified; 

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.profilePictureUrl,
    required this.isUserOnline,
    required this.isEmailVerified, 
  });

  // Factory constructor to create a UserModel from a Firestore document snapshot
  factory UserModel.fromDocumentSnapshot(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profilePictureUrl: data['profilePicture'] ?? '',
      isUserOnline: data['isUserOnline'] ?? false,
      isEmailVerified: data['isEmailVerified'] ?? false, 
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
    };
  }

  // Method to create a UserModel from a Map
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      profilePictureUrl: map['profilePicture'] ?? '',
      isUserOnline: map['isUserOnline'] ?? false,
      isEmailVerified: map['isEmailVerified'] ?? false, 
    );
  }
}
