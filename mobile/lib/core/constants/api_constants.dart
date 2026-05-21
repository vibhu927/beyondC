import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // One manual switch point when not using --dart-define.
  // Allowed: local_device, local_emulator, hosted
  static const String defaultAppEnv = 'local_device';

  // Optional compile-time env switch:
  // flutter run --dart-define=APP_ENV=local_emulator
  // flutter run --dart-define=APP_ENV=local_device
  // flutter run --dart-define=APP_ENV=hosted
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: defaultAppEnv,
  );

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

  static const String instagramClientId = String.fromEnvironment(
    'INSTAGRAM_CLIENT_ID',
    defaultValue: '',
  );

  static const String instagramRedirectUri = String.fromEnvironment(
    'INSTAGRAM_REDIRECT_URI',
    defaultValue: 'https://beyondc.in/api/auth/instagram/callback',
  );

  // Local backend for physical device on same LAN.
  static const String localDeviceApiBaseUrl = 'http://192.168.1.16:3000/api';

  // Android emulator loopback to host machine backend.
  static const String localEmulatorApiBaseUrl = 'http://10.0.2.2:3000/api';

  // Hosted testing environment.
  static const String hostedApiBaseUrl = 'https://beyond-c.vercel.app/api';

  // Next.js API base URL
  // Priority order:
  // 1) API_BASE_URL override (if passed)
  // 2) debug APP_ENV switch
  // 3) hosted in release builds
  static String get apiBaseUrl {
    if (apiBaseUrlOverride.isNotEmpty) {
      return apiBaseUrlOverride;
    }

    if (!kDebugMode) {
      return hostedApiBaseUrl;
    }

    switch (appEnv) {
      case 'local_emulator':
        return localEmulatorApiBaseUrl;
      case 'hosted':
        return hostedApiBaseUrl;
      case 'local_device':
      default:
        return localDeviceApiBaseUrl;
    }
  }

  static String get configSummary =>
      'APP_ENV=$appEnv | API_BASE_URL=$apiBaseUrl | SUPABASE_URL=$supabaseUrl';
}
