import 'package:flutter/material.dart';

class Loginheader extends StatelessWidget {
  const Loginheader({super.key,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          // Bottom background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/components/cut.png',
              width: double.infinity,
              height: MediaQuery.of(context).size.height *
                  0.25, // 25% of screen height
              fit: BoxFit.cover,
            ),
          ),
          // Top background image
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/components/oval_cut.png',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.25,
              fit: BoxFit.cover,
            ),
          ),
          // Profile image in the center
          Positioned(
              top: 90,
              left: 90,
              child: Image.asset(
                'assets/images/sign.png',
                width: 240,
                height: 240,
              )),
        ],
      ),
    );
  }
}
