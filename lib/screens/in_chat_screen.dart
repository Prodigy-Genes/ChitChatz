// ignore_for_file: library_private_types_in_public_api

import 'package:chatapp/widgets/bubble.dart';
import 'package:chatapp/widgets/inchat_input_widget.dart';
import 'package:chatapp/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/model/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatapp/model/message.dart';  // Import the Message class
import 'package:chatapp/services/message_service.dart';  // Import MessageService
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InChatScreen extends StatefulWidget {
  final UserModel friend;

  const InChatScreen({super.key, required this.friend});

  @override
  _InChatScreenState createState() => _InChatScreenState();
}

class _InChatScreenState extends State<InChatScreen> {
  final List<Message> _messages = [];  // List to store messages
  final MessageService _messageService = MessageService(); // Create instance of MessageService
  bool _isSending = false;  // To control sending state
  String? _currentUserId;
  String? _currentUsername;

  // Fetch the current user's details from Firestore
  Future<void> _fetchCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _currentUserId = currentUser.uid;
          _currentUsername = userDoc['username'];
        });
      }
    }
  }

  // Fetch messages for the chat
  void _fetchMessages() async {
    if (_currentUserId == null) return;  // Wait until the user details are fetched

    final chatId = _messageService.generateChatId(_currentUserId!, widget.friend.uid); // Generate chat ID
    _messageService.getMessages(chatId).listen((messages) {
      setState(() {
        _messages.clear();  // Clear old messages
        _messages.addAll(messages); // Add new fetched messages
      });
    });
  }

  // Handle sending a message
  void _sendMessage(String messageContent) async {
    if (_currentUserId == null || _currentUsername == null || messageContent.isEmpty) return;

    final newMessage = Message(
      content: messageContent,
      senderId: _currentUserId!, 
      receiverId: widget.friend.uid, 
      isPending: true,
      timestamp: DateTime.now(),
      senderUsername: _currentUsername!, 
      receiverUsername: widget.friend.username,
      type: MessageType.text, 
      id: '',
    );

    setState(() {
      _isSending = true;  // Set sending state
      _messages.add(newMessage); // Add message to list
    });

    // Send message using MessageService
    final messageId = await _messageService.sendMessage(newMessage);

    // Update message with message ID after it has been sent
    setState(() {
      final index = _messages.indexOf(newMessage);
      if (index != -1) {
        _messages[index] = newMessage.copyWith(id: messageId, isPending: false);
      }
    });

    setState(() {
      _isSending = false;  // Reset sending state
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser().then((_) {
      _fetchMessages();  // Fetch messages when the chat screen is initialized and user data is available
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: Row(
          children: [
            ProfileImageWidget(friend: widget.friend),
            const SizedBox(width: 12),
            Text(
              widget.friend.username,
              style: GoogleFonts.kavivanar(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Displaying messages
          Expanded(
            child: ListView.builder(
              reverse: true,  // To show the latest message at the bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Bubble(
                  message: message,
                  isSending: _isSending,  // Pass the actual sending state
                );
              },
            ),
          ),
          // Input widget for sending messages
          InchatInputWidget(
            onSendMessage: _sendMessage,  // Pass the send message function
            onVoiceNote: () { 
              // You can implement voice note handling here
            },
          ),
        ],
      ),
    );
  }
}
