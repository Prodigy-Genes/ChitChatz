// ignore_for_file: library_private_types_in_public_api

import 'package:chatapp/authentication/signout.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ChitChatz',
          style: TextStyle(
            fontFamily: 'Kavivanar',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Signout(),
          ),
        ],
      ),
      body: const Center(child: Text('Home')),
    );
  }
}
