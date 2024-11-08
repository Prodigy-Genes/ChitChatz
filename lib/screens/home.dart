// ignore_for_file: library_private_types_in_public_api

import 'package:chatapp/widgets/friends_list_item_widget_home.dart';
import 'package:chatapp/widgets/user_info.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/friend_request_service.dart';
import 'package:chatapp/model/user.dart';
import 'package:chatapp/services/message_service.dart'; // Service to fetch last messages

class Home extends StatefulWidget {
  final String userId;
  const Home({super.key, required this.userId});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int unreadMessageCount = 0; // Track total unread messages
  int friendsWithNewMessages = 0; // Track how many friends have new messages

  @override
  void initState() {
    super.initState();
    _fetchUnreadMessages();
  }

  // Function to get unread messages count and friends with new messages
  void _fetchUnreadMessages() async {
    final unreadMessages = await MessageService().getUnreadMessages(widget.userId);
    final friendsWithMessages = await MessageService().getFriendsWithNewMessages(widget.userId);

    setState(() {
      unreadMessageCount = unreadMessages;
      friendsWithNewMessages = friendsWithMessages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'ChitChatz',
          style: TextStyle(
            fontFamily: 'Kavivanar',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: UserInfo(userId: widget.userId),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Stack(
              children: [
                const Icon(Icons.chat, color: Colors.white),
                if (unreadMessageCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadMessageCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: FriendRequestService().getFriends(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final friends = snapshot.data ?? [];

          if (friends.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No friends yet',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start adding friends to chat with them!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
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
              return FriendsListItemWidgetHome(friend: friend, unreadMessages: friend.unreadMessages); // Pass unreadMessages to the widget
            },
          );
        },
      ),
    );
  }
}
