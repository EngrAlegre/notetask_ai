import 'package:dio/dio.dart';

class PerplexityService {
  static final PerplexityService _instance = PerplexityService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('PERPLEXITY_API_KEY');

  // Factory constructor to return the singleton instance
  factory PerplexityService() {
    return _instance;
  }

  // Private constructor for singleton pattern
  PerplexityService._internal() {
    _initializeService();
  }

  void _initializeService() {
    if (apiKey.isEmpty) {
      throw Exception('PERPLEXITY_API_KEY must be provided via --dart-define');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.perplexity.ai',
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Dio get dio => _dio;

  bool get isConfigured => apiKey.isNotEmpty;
}
