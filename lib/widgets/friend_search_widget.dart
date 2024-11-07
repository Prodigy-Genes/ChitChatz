// ignore_for_file: library_private_types_in_public_api

import 'package:chatapp/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/friend_request_service.dart';
import 'package:chatapp/model/user.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendSearchWidget extends StatefulWidget {
  final String userId;
  const FriendSearchWidget({super.key, required this.userId});

  @override
  _FriendSearchWidgetState createState() => _FriendSearchWidgetState();
}

class _FriendSearchWidgetState extends State<FriendSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search for your Friends...',
            hintStyle: TextStyle(color: Colors.white, fontFamily: 'Kavivanar'),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: FriendRequestService().getFriends(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final friends = snapshot.data ?? [];

          // Filter friends based on search query
          if (_searchController.text.isNotEmpty) {
            _searchResults = friends
                .where((friend) =>
                    friend.username
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                .toList();
          } else {
            _searchResults = friends;
          }

          if (_searchResults.isEmpty) {
            return const Center(
              child: Text('No friends found.',
                  style: TextStyle(
                      fontFamily: 'Kavivanar',
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final friend = _searchResults[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ProfileImageWidget(friend: friend,),
                  title: Text(
                    friend.username,
                    style: GoogleFonts.kavivanar(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        friend.isUserOnline
                            ? Icons.circle
                            : Icons.circle_outlined,
                        color: friend.isUserOnline
                            ? Colors.green
                            : Colors.grey,
                        size: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        friend.isUserOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.kavivanar(
                          fontSize: 14,
                          color: friend.isUserOnline
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Implement your onTap functionality here
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      // Will trigger a rebuild, and the list will be filtered
    });
  }
}
