import 'package:flutter/material.dart';

class SignoutConfirmation extends StatelessWidget {
  const SignoutConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Image.asset(
            'assets/icons/sign_out.png',
            height: 30,
            width: 30,
          ),
          const SizedBox(width: 10),
          const Text('Wanna Sign Out?', style: TextStyle(fontFamily: 'Kavivanar', color: Colors.redAccent),),
        ],
      ),
      content: const Text(
        'Are you sure you want to sign out?',
        style: TextStyle(
            fontFamily: 'Kavivanar',
            fontWeight: FontWeight.w900),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text(
            'Nah',
            style: TextStyle(
              fontFamily: 'Kavivanar',
              color: Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('Sign Out',
              style: TextStyle(
                  fontFamily: 'Kavivanar',
                  color: Colors.red,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
