import 'package:chatapp/screens/login.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
    '/signup': (context) => const Signup(),
    '/signin': (context) => const Login(),
  },
      home:const Signup()
    );
  }
}
