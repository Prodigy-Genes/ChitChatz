// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:chatapp/services/friend_request_service.dart';
import 'package:chatapp/services/friend_request_status.dart';
import 'package:chatapp/services/notification_service.dart';
import 'package:chatapp/widgets/addfriend_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserTile extends StatefulWidget {
  final Map<String, dynamic> userData; // Receiver's data
  final String currentUserId; // ID of the current user
  final String currentUserDisplayName; // Display name of the current user

  const UserTile({
    super.key,
    required this.userData,
    required this.currentUserId,
    required this.currentUserDisplayName, 
  });

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  late FriendRequestStatus _friendRequestStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendRequestStatus();
  }

  Future<void> _loadFriendRequestStatus() async {
  try {
    final status = await FriendRequestService().checkFriendRequestStatus(widget.userData['userId']);
    if (mounted) {
      setState(() {
        _friendRequestStatus = status;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _friendRequestStatus = FriendRequestStatus.none;
        _isLoading = false;
      });
    }
  }
}

  Future<void> _sendFriendRequest() async {
    final shouldAddFriend = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const AddfriendConfirmation();
      },
    );

    if (shouldAddFriend == true) {
      try {
        await FriendRequestService().sendFriendRequest(widget.userData['userId']);
        await NotificationService().sendFriendRequestNotification(
          receiverId: widget.userData['userId'],
          receiverUsername: widget.userData['username'],
          type: 'friend_request',
        );

        print('Friend request sent and notification delivered to ${widget.userData['username']}');

        setState(() {
          _friendRequestStatus = FriendRequestStatus.pending;
        });
      } catch (e) {
        print('Failed to send friend request or notification: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sending friend request')),
        );
      }
    }
  }

  Color _getFriendButtonColor(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return Colors.yellow;
      case FriendRequestStatus.accepted:
        return Colors.green;
      case FriendRequestStatus.rejected:
        return Colors.red;
      case FriendRequestStatus.none:
      default:
        return const Color.fromARGB(255, 239, 246, 194);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilePictureUrl = widget.userData['profilePictureUrl'] as String?;
    final username = widget.userData['username'] as String? ?? 'Unknown User';
    final isOnline = widget.userData['isUserOnline'] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.2),
                    width: 4,
                  ),
                  image: DecorationImage(
                    image: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                        ? NetworkImage(profilePictureUrl)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isOnline)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.greenAccent : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            username,
            style: GoogleFonts.kavivanar(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: GoogleFonts.kavivanar(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getFriendButtonColor(_friendRequestStatus),
                  foregroundColor: Colors.purple,
                  elevation: 3,
                  shadowColor: Colors.yellow.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: (_friendRequestStatus == FriendRequestStatus.none ||
                        _friendRequestStatus == FriendRequestStatus.rejected)
                    ? _sendFriendRequest
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_alt_sharp, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _friendRequestStatus.toText(),
                      style: GoogleFonts.kavivanar(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
