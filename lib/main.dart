// ignore_for_file: library_private_types_in_public_api

import 'package:chatapp/navigations/route.dart';
import 'package:chatapp/screens/login.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  final logger = Logger();

  try {
    // Replace with your Firebase project credentials
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      ),
    );
    logger.i("Firebase initialized successfully.");
  } catch (e) {
    logger.e("Error initializing Firebase: $e");
    return;
  }
  try {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(dotenv.env['ONESIGNAL_APPID'] ?? '');
    OneSignal.Notifications.requestPermission(true);
    logger.i("OneSignal initialized successfully.");
  } catch (e) {
    logger.e("Error initializing OneSignal: $e");
  }

  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> with WidgetsBindingObserver {
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateUserOnlineStatus(true); // Set online when app starts
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateUserOnlineStatus(false); // Set offline when app closes
    super.dispose();
  }

  // Listen for app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _updateUserOnlineStatus(false); // Set offline when app goes to background
    } else if (state == AppLifecycleState.resumed) {
      _updateUserOnlineStatus(
          true); // Set online when app returns to foreground
    }
  }

  // Update user online status in Firestore
  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'isUserOnline': isOnline});
        _logger.i(
            "Updated online status to $isOnline for user ${currentUser.uid}");
      } catch (e) {
        _logger.e("Failed to update online status: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/signup': (context) => const Signup(),
        '/signin': (context) => const Login(),
      },
      home: const AuthRoute(),
    );
  }
}
