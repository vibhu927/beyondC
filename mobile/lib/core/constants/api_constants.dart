import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dewwodfpevclnvdrhmnt.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRld3dvZGZwZXZjbG52ZHJobW50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0MjI1MzQsImV4cCI6MjA4ODk5ODUzNH0.xAZj1-tmjmO58Y-VqCWFRkZuZK6bd7aLAL45l_3_4Dg',
  );

  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'YOUR_RAZORPAY_KEY_ID',
  );

  static const String apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String defaultDebugApiBaseUrl = 'http://192.168.1.7:3000/api';

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
