import 'package:chatapp/screens/forgotpassword.dart';
import 'package:chatapp/screens/login.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:chatapp/screens/verification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   // Initialize Logger
  final logger = Logger();
  try{
    await Firebase.initializeApp();
    logger.i("Firebase initialized successfully.");
  }catch (e){
    logger.e("Error initializing Firebase: $e");
    return;
  }
  
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
    '/verification': (context) => const Verification(),
    '/forgotpassword': (context) => const Forgotpassword()
  },
      home:const Signup()
    );
  }
}
