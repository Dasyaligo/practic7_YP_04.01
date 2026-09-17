import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseClientHolder {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}