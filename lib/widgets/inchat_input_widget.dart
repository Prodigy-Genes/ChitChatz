// inchat_input_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // ignore: library_private_types_in_public_api
  _InchatInputWidgetState createState() => _InchatInputWidgetState();
}

class _InchatInputWidgetState extends State<InchatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isTextEmpty = true;

  void _handleSendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.onSendMessage(_controller.text);
      _controller.clear();
    }
  }

  void _handleVoiceNote() {
    widget.onVoiceNote();
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
          // Text Area for typing messages
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle:
                    GoogleFonts.nunito(fontSize: 14, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (text) {
                setState(() {
                  _isTextEmpty = text.isEmpty;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Voice Note Button (Imported Widget)
          VoiceNoteButton(
            onPressed: _handleVoiceNote,
          ),
          const SizedBox(width: 8),
          // Send Button (Imported Widget)
          SendButton(
            onPressed: _handleSendMessage,
            isTextEmpty: _isTextEmpty,
          ),
        ],
      ),
    );
  }
}
