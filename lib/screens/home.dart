// ignore_for_file: library_private_types_in_public_api

import 'package:chatapp/widgets/user_info.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String userId;
  const Home({super.key, required this.userId});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'ChitChatz',
          style: TextStyle(
            fontFamily: 'Kavivanar',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
         actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: UserInfo(userId: widget.userId),
          )
        ],
      ),
      body: const Center(
        child: Text('Home'), // Display UserInfo widget with the userId
      ),
    );
  }
}
