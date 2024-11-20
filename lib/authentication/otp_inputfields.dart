// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class OtpInputFields extends StatelessWidget {
  final TextEditingController controller;

  const OtpInputFields({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 40,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '0',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
