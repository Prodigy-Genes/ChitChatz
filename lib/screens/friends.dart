// friends_widget.dart
// ignore_for_file: avoid_print

import 'package:chatapp/widgets/friend_list_item_widget.dart';
import 'package:chatapp/widgets/friend_search_widget.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/friend_request_service.dart';
import 'package:chatapp/model/user.dart';
import 'package:google_fonts/google_fonts.dart';

class Friends extends StatelessWidget {
  final String userId;
  const Friends({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        title: Row(
          children: [
            Text(
              'Friends',
              style: GoogleFonts.kavivanar(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'トモダチ',
                style: GoogleFonts.kavivanar(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Open the search screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendSearchWidget(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: FriendRequestService().getFriends(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            );
          }

          if (snapshot.hasError) {
            print('StreamBuilder error: ${snapshot.error}');
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final friends = snapshot.data ?? [];

          if (friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No friends yet',
                    style: GoogleFonts.kavivanar(
                      color: Colors.grey[600],
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start adding friends to chat with them!',
                    style: GoogleFonts.nunito(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return FriendListItemWidget(friend: friend);
            },
          );
        },
      ),
    );
  }
}
