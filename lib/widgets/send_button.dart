// send_button.dart

import 'package:flutter/material.dart';

class SendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTextEmpty;

  const SendButton({super.key, required this.onPressed, required this.isTextEmpty});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.send,
        color: isTextEmpty ? Colors.grey : Colors.blue,
      ),
      onPressed: isTextEmpty ? null : onPressed,
    );
  }
}
