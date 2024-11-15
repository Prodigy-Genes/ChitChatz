// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/model/message.dart';
import 'package:chatapp/model/user.dart';
import 'package:chatapp/screens/chatscreen.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/services/messagestatushandler.dart';
import 'package:chatapp/widgets/profile_image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendsListItemWidgetHome extends StatelessWidget {
  final UserModel friend;
  final int unreadMessages;
  final MessagingService _messagingService = MessagingService();
  late final MessageStatusHandler _statusHandler;

  FriendsListItemWidgetHome({
    super.key,
    required this.friend,
    required this.unreadMessages,
  }) {
    _statusHandler = MessageStatusHandler(messagingService: _messagingService);
  }

  void _handleChatOpen(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final chatId =
        _messagingService.generateChatId(currentUser.uid, friend.uid);

    // Mark messages as read when opening the chat
    await _statusHandler.markMessagesAsRead(chatId);

    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(friend: friend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final chatId =
        _messagingService.generateChatId(currentUser.uid, friend.uid);

    return StreamBuilder<ChatRoom?>(
      stream: _messagingService.getChatRoom(chatId),
      builder: (context, chatRoomSnapshot) {
        // Default values if no chat room exists
        String lastMessage = 'No messages yet';
        DateTime? lastMessageTime;
        Future<MessageStatus?>? lastMessageStatusFuture;
        String? lastMessageId;

        // Extract data from snapshot if available
        if (chatRoomSnapshot.hasData && chatRoomSnapshot.data != null) {
          final chatRoom = chatRoomSnapshot.data!;
          lastMessage = chatRoom.lastMessageContent;
          lastMessageTime = chatRoom.lastMessageTime;

          // Fetch the last message id dynamically if it's not stored in ChatRoom
          lastMessageStatusFuture = _messagingService
              .getLastMessageId(chatRoom.chatId)
              .then((message) {
            if (message != null) {
              lastMessageId =
                  message; // Access id only if message is not null
              return _messagingService
                  .getMessageStatusForLastMessage(lastMessageId!);
            } else {
              // Handle the case where message is null
              return Future.value(null); // Or any default value you prefer
            }
          });
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.yellow.shade50,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _handleChatOpen(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ProfileImageWidget(friend: friend),
                        if (friend.isUserOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                friend.username,
                                style: GoogleFonts.kavivanar(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                              if (lastMessageTime != null)
                                Text(
                                  timeago.format(lastMessageTime,
                                      allowFromNow: true),
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: Colors.purple.shade300,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lastMessage,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (lastMessageStatusFuture != null)
                                FutureBuilder<MessageStatus?>(
                                  future: lastMessageStatusFuture,
                                  builder: (context, statusSnapshot) {
                                    if (statusSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox.shrink();
                                    }
                                    if (statusSnapshot.hasData) {
                                      return _buildMessageStatusIcon(
                                          statusSnapshot.data!);
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                            ],
                          ),
                          if (unreadMessages > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$unreadMessages new',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    Color iconColor = Colors.purple.shade300;
    IconData iconData;

    switch (status) {
      case MessageStatus.sent:
        iconData = Icons.check;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        iconColor = Colors.blue.shade600;
        break;
      case MessageStatus.unread:
        iconData = Icons.fiber_manual_record;
        iconColor = Colors.purple.shade600;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 18,
    );
  }
}
