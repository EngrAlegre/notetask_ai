import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  final Future<void> _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() : _initFuture = _initializeSupabase();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'your_supabase_url');
  static const String supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'your_supabase_anon_key');

  // Internal initialization logic
  static Future<void> _initializeSupabase() async {
    if (supabaseUrl.isEmpty ||
        supabaseAnonKey.isEmpty ||
        supabaseUrl == 'your_supabase_url' ||
        supabaseAnonKey == 'your_supabase_anon_key') {
      if (kDebugMode) {
        print(
            'Warning: SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.');
        print('Using preview mode with mock data.');
      }
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _instance._client = Supabase.instance.client;
    _instance._isInitialized = true;
  }

  // Client getter (async)
  Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      await _initFuture;
    }
    return _client;
  }

  // Sync client getter (use only after initialization)
  SupabaseClient get syncClient => _client;

  // Check if Supabase is properly configured
  bool get isConfigured =>
      _isInitialized &&
      supabaseUrl != 'your_supabase_url' &&
      supabaseAnonKey != 'your_supabase_anon_key';
}
