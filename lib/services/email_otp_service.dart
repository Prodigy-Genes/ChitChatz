import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class OtpService {
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> generateOtp() async {
    final String otp = (100000 + (Random().nextInt(900000))).toString();
    return otp; // Generates a 6-digit OTP
  }

  Future<void> sendOtpEmail(String email, String otpCode) async {
    String serviceId = dotenv.env['SERVICE_ID'] ?? '';
    String templateId = dotenv.env['TEMPLATE_ID'] ?? '';
    String userId = dotenv.env['USER_ID'] ?? '';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_email': email,
            'otp_code': otpCode,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to send OTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('Error sending OTP: $e');
      throw Exception('An error occurred while sending OTP: $e');
    }
  }

  Future<void> storeOtp(String userId, String otp) async {
    try {
      final otpData = {
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(), // Store creation timestamp
      };

      await _firestore.collection('users').doc(userId).collection('otps').add(otpData);
      _logger.i('Stored OTP for userId: $userId');
    } catch (e) {
      _logger.e('Error storing OTP: $e');
      throw Exception('Failed to store OTP: $e');
    }
  }

  Future<bool> verifyOtp(String userId, String otp) async {
    try {
      final otpDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('otps')
          .where('otp', isEqualTo: otp)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (otpDocs.docs.isNotEmpty) {
        // OTP found, verify it here (you may want to add expiration logic)
        return true; // OTP is valid
      }
      return false; // OTP not found
    } catch (e) {
      _logger.e('Error verifying OTP: $e');
      return false; // Failed to verify OTP
    }
  }

  Future<void> cleanupExpiredOtps(String userId) async {
    final now = DateTime.now();
    const expirationDuration = Duration(minutes: 5); // Set expiration duration

    final expiredOtps = await _firestore
        .collection('users')
        .doc(userId)
        .collection('otps')
        .where('createdAt', isLessThan: now.subtract(expirationDuration))
        .get();

    for (var doc in expiredOtps.docs) {
      await doc.reference.delete();
      _logger.i('Deleted expired OTP for userId: $userId, OTP: ${doc.data()}');
    }
  }
}
