
// ignore_for_file: avoid_print

import 'package:chatapp/widgets/inchat_input_widget.dart';
import 'package:chatapp/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/model/user.dart';
import 'package:google_fonts/google_fonts.dart';

class InChatScreen extends StatelessWidget {
  final UserModel friend;

  const InChatScreen({super.key, required this.friend});

  // Placeholder for send message function
  void _sendMessage(String message) {
    print("Message sent: $message");
    // Implement the logic to send a message to Firestore or backend
  }

  // Placeholder for handling voice note
  void _handleVoiceNote() {
    print("Voice note recorded");
    // Implement the logic to record and send a voice note
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: Row(
          children: [
            ProfileImageWidget(friend: friend),
            const SizedBox(width: 12),
            Text(
              friend.username,
              style: GoogleFonts.kavivanar(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Phone Call Icon
          IconButton(
            icon: const Icon(Icons.call,),
            onPressed: () {
              // Handle phone call action
            },
          ),
          // Video Call Icon
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Handle video call action
            },
          ),
          // More options icon
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle more actions here
              print(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Block User',
                  child: Text('Block User'),
                ),
                const PopupMenuItem<String>(
                  value: 'Report User',
                  child: Text('Report User'),
                ),
                const PopupMenuItem<String>(
                  value: 'Mute Notifications',
                  child: Text('Mute Notifications'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              // Add chat messages here
            ),
          ),
          InchatInputWidget(
            onSendMessage: _sendMessage,
            onVoiceNote: _handleVoiceNote,
          ),
        ],
      ),
    );
  }
}
