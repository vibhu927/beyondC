import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'YOUR_RAZORPAY_KEY_ID',
  );

  static const String apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String defaultDebugApiBaseUrl =
      'http://192.168.1.7:3000/api';

  // Next.js API base URL
  // In debug, use LAN URL by default so physical devices can reach the backend.
  static String get apiBaseUrl {
    if (!kDebugMode) return 'https://beyond-c-78nm.vercel.app/api';

    if (apiBaseUrlOverride.isNotEmpty) {
      return apiBaseUrlOverride;
    }

    return defaultDebugApiBaseUrl;
  }
}
