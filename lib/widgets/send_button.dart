
import 'package:flutter/material.dart';

class SendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTextEmpty;
  final bool isSending;

  const SendButton({
    super.key,
    required this.onPressed,
    required this.isTextEmpty,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: isSending
          ? const CircularProgressIndicator()  // Show a loading spinner when sending
          : Icon(
              Icons.send,
              color: isTextEmpty ? Colors.grey : Colors.blue,
            ),
      onPressed: isTextEmpty || isSending ? null : onPressed, // Disable button while sending
    );
  }
}
