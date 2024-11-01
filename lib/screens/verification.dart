// ignore_for_file: use_super_parameters, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:chatapp/services/email_otp_service.dart';

class Verification extends StatefulWidget {
  final String userId;
  final String email;

  const Verification({Key? key, required this.userId, required this.email}) : super(key: key);

  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final Logger logger = Logger();
  final TextEditingController _otpController = TextEditingController();
  final OtpService _otpService = OtpService();
  bool _isVerifying = false;
  String _errorMessage = '';

  Future<void> _verifyOtp() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      String otp = _otpController.text.trim();
      bool isVerified = await _otpService.verifyOtp(widget.userId, otp);

      if (isVerified) {
        logger.i('OTP verified successfully for userId: ${widget.userId}');
        // Handle successful OTP verification (e.g., navigate to next screen or show success message)
        Navigator.pop(context); // You can change this to navigate to another screen if needed
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP. Please try again.';
        });
        logger.w('Invalid OTP entered for userId: ${widget.userId}');
      }
    } catch (e) {
      logger.e('Error verifying OTP: $e');
      setState(() {
        _errorMessage = 'An error occurred while verifying the OTP.';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the OTP sent to your email:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              child: _isVerifying 
                  ? const CircularProgressIndicator() 
                  : const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
