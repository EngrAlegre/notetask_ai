import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          if (kDebugMode) print('Speech status: $status');
          _isListening = status == 'listening';
        },
        onError: (error) {
          if (kDebugMode) print('Speech error: $error');
          _isListening = false;
        },
      );
      return _isInitialized;
    } catch (e) {
      if (kDebugMode) print('Speech initialization error: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isInitialized && !_isListening) {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
      );
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final locales = await _speech.locales();
    return locales.map((locale) => locale.localeId).toList();
  }
}