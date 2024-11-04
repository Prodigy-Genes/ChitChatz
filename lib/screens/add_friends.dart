// ignore_for_file: avoid_print

import 'package:chatapp/widgets/user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFriends extends StatefulWidget {
  const AddFriends({super.key});

  @override
  State<AddFriends> createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> _getUsersStream() {
    return _firestore.collection('users').snapshots().asyncMap((snapshot) async {
      List<Map<String, dynamic>> usersData = [];
      for (var doc in snapshot.docs) {
        try {
          final userDoc = await _firestore.collection('users').doc(doc.id).get();
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            data['userId'] = doc.id; // Add the user ID to the data
            usersData.add(data);
          }
        } catch (e) {
          print("Error fetching details for user ${doc.id}: $e");
        }
      }
      return usersData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Friends',
          style: GoogleFonts.kavivanar(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("StreamBuilder error: ${snapshot.error}");
            return Center(
              child: Text(
                'Error loading users',
                style: GoogleFonts.kavivanar(fontSize: 18, color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: GoogleFonts.kavivanar(fontSize: 18, color: Colors.black),
              ),
            );
          }

          final usersData = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: usersData.length,
            itemBuilder: (context, index) {
              final userData = usersData[index];
              return UserTile(userData: userData, currentUserId:currentUserId! ); 
            },
          );
        },
      ),
    );
  }
}
