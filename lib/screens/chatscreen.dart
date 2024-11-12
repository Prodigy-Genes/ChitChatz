// ignore_for_file: unused_field, use_build_context_synchronously

import 'package:chatapp/model/message.dart';
import 'package:chatapp/model/user.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/widgets/profile_image_widget.dart';
import 'package:chatapp/widgets/message_bubble.dart';
import 'package:chatapp/widgets/date_header.dart';
import 'package:chatapp/widgets/typing_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  final UserModel friend;

  const ChatScreen({
    super.key,
    required this.friend,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String _chatId;
  late String _receiverId;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final MessagingService _messagingService = MessagingService();
  final bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _chatId = MessagingService().generateChatId(
      FirebaseAuth.instance.currentUser!.uid,
      widget.friend.uid,
    );
    _receiverId = widget.friend.uid;
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();
    
    try {
      await _messagingService.sendMessage(
        receiverId: _receiverId,
        content: messageText,
        status: MessageStatus.sent,
        type: MessageType.text,
      );

      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send message: ${e.toString()}',
            style: GoogleFonts.kavivanar(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      // Triggering a refresh by re-fetching the messages.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: Row(
          children: [
            ProfileImageWidget(friend: widget.friend),
            const SizedBox(width: 10),
            Text(
              widget.friend.username,
              style: GoogleFonts.kavivanar(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple[50]!,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: MessagingService().getMessages(_chatId),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.purple,
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet.',
                          style: GoogleFonts.kavivanar(
                            color: Colors.purple,
                            fontSize: 18,
                          ),
                        ),
                      );
                    }
                    final messages = snapshot.data!.reversed.toList();
                    final groupedMessages = _groupMessagesByDate(messages);

                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: groupedMessages.length,
                      itemBuilder: (ctx, index) {
                        final messageGroup = groupedMessages[index];
                        final firstMessage = messageGroup.first;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DateHeader(date: firstMessage.timestamp),
                            ...messageGroup.map(
                              (message) {
                                return MessageBubble(
                                  key: ValueKey(message.messageId),
                                  message: message,
                                  isMe: message.senderId == FirebaseAuth.instance.currentUser!.uid,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const TypingIndicator(),
              _buildMessageInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.purple[300]),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.kavivanar(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.kavivanar(color: Colors.purple[300]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.purple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  List<List<MessageModel>> _groupMessagesByDate(List<MessageModel> messages) {
    final Map<DateTime, List<MessageModel>> groupedMessages = {};
    for (var message in messages) {
      final date = DateTime(message.timestamp.year, message.timestamp.month, message.timestamp.day);
      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }

    return groupedMessages.entries
        .map((entry) => entry.value)
        .toList()
      ..sort((a, b) => b.first.timestamp.compareTo(a.first.timestamp));
  }
}