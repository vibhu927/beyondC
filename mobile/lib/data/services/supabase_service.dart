import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  const SupabaseService();

  SupabaseClient get client => Supabase.instance.client;

  Session? get currentSession => client.auth.currentSession;

  String? get accessToken => currentSession?.accessToken;
}

final supabaseServiceProvider = Provider<SupabaseService>(
  (ref) => const SupabaseService(),
);
