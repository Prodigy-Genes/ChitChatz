import 'package:chatapp/navigations/route.dart';
import 'package:chatapp/screens/forgotpassword.dart';
import 'package:chatapp/screens/login.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:chatapp/screens/verification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  final logger = Logger();

  try {
    // Replace with your Firebase project credentials
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDps3aN9Cb13byXAwe635uAPccUBArbSiU",              // From Firebase console
        appId: "1:267685075885:android:a553eddd042d7228421f24",                // From Firebase console
        messagingSenderId: "267685075885", 
        projectId: "chitchatz-623e6",        // From Firebase console
      ),
    );
    logger.i("Firebase initialized successfully.");
  } catch (e) {
    logger.e("Error initializing Firebase: $e");
    return;
  }

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/signup': (context) => const Signup(),
        '/signin': (context) => const Login(),
        '/verification': (context) => const Verification(),
        '/forgotpassword': (context) => const Forgotpassword(),
      },
      home: const AuthRoute(),
    );
  }
}
