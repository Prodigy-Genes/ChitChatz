import 'package:chatapp/model/message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    required Key key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isMe 
                    ? [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)] // Purple gradient
                    : [Colors.yellow.shade100, Colors.yellow.shade50], // Light yellow gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(widget.isMe ? 24 : 4),
                  bottomRight: Radius.circular(widget.isMe ? 4 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                    color: widget.isMe 
                        ? Colors.purple.withOpacity(0.3)
                        : Colors.yellow.withOpacity(0.2),
                  ),
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
                border: Border.all(
                  color: widget.isMe 
                      ? Colors.purple.shade200
                      : Colors.yellow.shade200,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.message.content,
                    style: GoogleFonts.comicNeue(
                      color: widget.isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(widget.message.timestamp),
                        style: GoogleFonts.comicNeue(
                          color: widget.isMe ? Colors.white70 : Colors.black45,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (widget.isMe) ...[
                        _buildStatusIcon(widget.message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    IconData iconData;
    Color iconColor = Colors.yellow.shade100; // Yellow tint for status icons

    switch (status) {
      case MessageStatus.sent:
        iconData = Icons.check;
        break;
      case MessageStatus.delivered:
        iconData = Icons.check_circle;
        iconColor = Colors.yellow.shade200;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        iconColor = Colors.yellow;
        break;
      default:
        iconData = Icons.check;
    }

    return Icon(
      iconData,
      size: 16,
      color: iconColor,
    );
  }
}