import 'package:flutter/material.dart';
import 'package:chatapp/model/message.dart';

class Bubble extends StatelessWidget {
  final Message message;
  final bool isSending;

  const Bubble({
    super.key,
    required this.message,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.senderId == 'currentUserId' // Compare with actual user ID
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: message.senderId == 'currentUserId' // Same check here
              ? Colors.blueAccent
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: message.senderId == 'currentUserId'
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            isSending
                ? const CircularProgressIndicator() // Show loading spinner
                : Text(
                    message.content ?? '',
                    style: TextStyle(
                      color: message.senderId == 'currentUserId'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
