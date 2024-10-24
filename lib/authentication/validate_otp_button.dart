// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ValidateOtpButton extends StatelessWidget {
  final VoidCallback onValidateOtp;

  const ValidateOtpButton({Key? key, required this.onValidateOtp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 110, 39, 176),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onValidateOtp,
      child: const Text(
        'Validate OTP',
        style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Kavivanar'),
      ),
    );
  }
}
