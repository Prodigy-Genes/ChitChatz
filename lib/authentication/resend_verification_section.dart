// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ResendVerificationSection extends StatelessWidget {
  final bool isResendEnabled;
  final int countdownTime;
  final VoidCallback onResendEmail;

  const ResendVerificationSection({
    Key? key,
    required this.isResendEnabled,
    required this.countdownTime,
    required this.onResendEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: isResendEnabled ? onResendEmail : null,
          child: const Text(
            'Resend Email',
            style: TextStyle(color: Colors.purple),
          ),
        ),
        const SizedBox(width: 10),
        if (!isResendEnabled)
          Text(
            'Wait $countdownTime seconds',
            style: const TextStyle(color: Colors.grey),
          ),
      ],
    );
  }
}
