import 'package:chatapp/services/friend_request_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Friends extends StatelessWidget {
  final String userId;
  const Friends({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
          title: Text(
        'Friends-[Tomodachi]',
        style: GoogleFonts.kavivanar(color: Colors.white),
      )),
      body: StreamBuilder<List<String>>(
        stream: FriendRequestService().getFriends(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final friends = snapshot.data ?? [];

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(friends[index]),
              );
            },
          );
        },
      ),
    );
  }
}
