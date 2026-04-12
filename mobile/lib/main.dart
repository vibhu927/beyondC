import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';
import 'app.dart';

bool isFirebaseConfigured = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System bars style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF0E141D),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xE6121A25),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Color(0x00000000),
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Keep app booting even if Firebase config is missing on device.
  try {
    await Firebase.initializeApp();
    isFirebaseConfigured = true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[BeyondC Firebase] Firebase not configured, continuing without push. $e');
    }
  }

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
      detectSessionInUri: false,
    ),
  );

  if (kDebugMode) {
    debugPrint('[BeyondC Config] ${ApiConstants.configSummary}');
  }

  runApp(
    const ProviderScope(
      child: BeyondCApp(),
    ),
  );
}
