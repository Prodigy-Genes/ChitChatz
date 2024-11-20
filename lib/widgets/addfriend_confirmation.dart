import 'package:flutter/material.dart';

class AddfriendConfirmation extends StatelessWidget {
  const AddfriendConfirmation({super.key});

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
          const Text('Wanna Add User Up?', style: TextStyle(fontFamily: 'Kavivanar', color: Colors.redAccent),),
        ],
      ),
      content: const Text(
        'Add user up to be able to ChitChat?',
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
          child: const Text('Do It',
              style: TextStyle(
                  fontFamily: 'Kavivanar',
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}