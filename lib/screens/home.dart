// ignore_for_file: library_private_types_in_public_api

import 'package:chatapp/widgets/friends_list_item_widget_home.dart';
import 'package:chatapp/widgets/user_info.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/friend_request_service.dart';
import 'package:chatapp/model/user.dart';

class Home extends StatefulWidget {
  final String userId;
  const Home({super.key, required this.userId});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Add a GlobalKey to refresh the stream
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // Function to manually trigger the refresh
  Future<void> _refresh() async {
    setState(() {}); // This will force the StreamBuilder to reload
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
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh, // The function to refresh the content
        child: StreamBuilder<List<UserModel>>(
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
                return FriendsListItemWidgetHome(
                  friend: friend,
                  unreadMessages: friend.unreadMessages,
                ); // Pass unreadMessages to the widget
              },
            );
          },
        ),
      ),
    );
  }
}
