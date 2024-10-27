import 'package:chatapp/navigations/route.dart';
import 'package:chatapp/screens/forgotpassword.dart';
import 'package:chatapp/screens/login.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  final logger = Logger();

  try {
    // Replace with your Firebase project credentials
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']?? '',              
        appId: dotenv.env['FIREBASE_APP_ID']?? '',                
        messagingSenderId:dotenv.env['FIREBASE_MESSAGING_SENDER_ID']?? '', 
        projectId:dotenv.env['FIREBASE_PROJECT_ID']?? '',       
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
        '/forgotpassword': (context) => const Forgotpassword(),
      },
      home: const AuthRoute(),
    );
  }
}
