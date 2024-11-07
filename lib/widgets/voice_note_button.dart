// voice_note_button.dart

import 'package:flutter/material.dart';

class VoiceNoteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const VoiceNoteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.mic),
      onPressed: onPressed,
    );
  }
}
