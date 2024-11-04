import 'package:chatapp/services/friend_request_service.dart';
import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  final String userId;
  const Friends({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
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
