import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class OtpService {
  final Logger _logger = Logger();

  Future<String> generateOtp() async {
    final String otp = (100000 + (Random().nextInt(900000))).toString();
    _logger.d('Generated OTP: $otp'); // Log the generated OTP
    return otp; // Generates a 6-digit OTP
  }

  Future<void> sendOtpEmail(String email, String otpCode) async {
    
    String serviceId = dotenv.env['SERVICE_ID'] ?? '';
    String templateId = dotenv.env['TEMPLATE_ID'] ?? '';
    String userId = dotenv.env['USER_ID'] ?? '';

    if (serviceId.isEmpty || templateId.isEmpty || userId.isEmpty) {
      _logger.e('Email service configuration is missing. Check .env variables.');
      throw Exception('Email service configuration is missing.');
    }

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

      _logger.i('OTP sent successfully to $email'); // Log success
    } catch (e) {
      _logger.e('Error sending OTP: $e');
      throw Exception('An error occurred while sending OTP: $e');
    }
  }
}
