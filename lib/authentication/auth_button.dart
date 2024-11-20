import 'package:flutter/material.dart';

class AuthButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuthButtonState createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _isLoading = false;

  void _handlePress() async {
    // Prevent multiple taps while loading
    if (_isLoading) return;

    setState(() {
      _isLoading = true; // Start loading
    });

    // Simulate a network request or a process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false; // End loading
    });

    // Call the provided onPressed callback
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : _handlePress, // Disable tap during loading
      borderRadius: BorderRadius.circular(20.0), // Ensure the ripple effect is rounded
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                widget.text,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Kavivanar'),
              ),
      ),
    );
  }
}
