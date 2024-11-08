// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'emoji_button.dart';
import 'voice_note_button.dart';
import 'send_button.dart';

class InchatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function() onVoiceNote;

  const InchatInputWidget({
    super.key,
    required this.onSendMessage,
    required this.onVoiceNote,
  });

  @override
  _InchatInputWidgetState createState() => _InchatInputWidgetState();
}

class _InchatInputWidgetState extends State<InchatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isTextEmpty = true;
  bool _isSending = false;

  // Handle sending message
  void _handleSendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _isSending = true; // Start sending state
      });

      // Call the parent widget's send message function
      widget.onSendMessage(_controller.text);

      // Simulate message sending delay (could be replaced with actual sending logic)
      await Future.delayed(const Duration(seconds: 1)); 

      // After message is sent, clear the input and reset the state
      setState(() {
        _isSending = false; // Reset sending state
      });

      _controller.clear(); // Clear the text field
    }
  }

  void _onRecordingComplete(String recordingPath, int duration) {
    // Handle completed recording (send the path and duration to the parent or upload)
    print('Recording completed: $recordingPath, Duration: $duration');
    widget.onVoiceNote(); // Call the parent function to handle the voice note if needed
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isTextEmpty = _controller.text.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const EmojiButton(),
          const SizedBox(width: 8),
          // Voice Note Button (Imported Widget)
          VoiceNoteButton(onRecordingComplete: _onRecordingComplete),
          const SizedBox(width: 8),
          // Send Button (Imported Widget)
          SendButton(
            onPressed: _handleSendMessage,
            isTextEmpty: _isTextEmpty,
            isSending: _isSending, // Pass the sending state to show loading spinner
          ),
        ],
      ),
    );
  }
}
