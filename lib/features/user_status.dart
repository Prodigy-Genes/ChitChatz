
import 'package:cloud_firestore/cloud_firestore.dart';

Stream<bool> getUserOnlineStatus(String userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.data()?['isUserOnline'] ?? false;
  });
}
