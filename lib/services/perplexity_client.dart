import 'package:dio/dio.dart';
import 'dart:convert';

class PerplexityClient {
  final Dio dio;

  PerplexityClient(this.dio);

  /// Generates a text response from a prompt (non-streaming).
  Future<Completion> createChat({
    required List<Message> messages,
    String model = 'sonar',
  }) async {
    final requestBody = {
      'model': model,
      'messages': _serializeMessages(messages),
      'stream': false,
    };

    try {
      final response = await dio.post('/chat/completions', data: requestBody);
      final data = response.data;
      final choice = data['choices'][0];
      final message = choice['message'];
      final text = message['content'];
      final citations = List<String>.from(data['citations'] ?? []);
      return Completion(text: text, citations: citations);
    } on DioException catch (e) {
      throw PerplexityException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']?['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }

  /// Streams a text response chunk by chunk.
  Stream<String> streamChat({
    required List<Message> messages,
    String model = 'sonar',
  }) async* {
    final requestBody = {
      'model': model,
      'messages': _serializeMessages(messages),
      'stream': true,
    };

    try {
      final response = await dio.post(
        '/chat/completions',
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );
      final stream = response.data as ResponseBody;
      await for (var line
          in LineSplitter().bind(utf8.decoder.bind(stream.stream))) {
        if (line.startsWith('data: ')) {
          final dataStr = line.substring(6).trim();
          if (dataStr.isNotEmpty && dataStr != '[DONE]') {
            final data = jsonDecode(dataStr) as Map<String, dynamic>;
            final choice = data['choices'][0];
            final delta = choice['delta'] as Map<String, dynamic>?;
            if (delta != null && delta['content'] != null) {
              yield delta['content'] as String;
            }
          }
        }
      }
    } on DioException catch (e) {
      throw PerplexityException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']?['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }

  List<Map<String, dynamic>> _serializeMessages(List<Message> messages) {
    return messages.map((m) {
      if (m.imageUrls.isEmpty) {
        return {'role': m.role, 'content': m.text ?? ''};
      } else {
        List<Map<String, dynamic>> content = [];
        if (m.text != null) {
          content.add({'type': 'text', 'text': m.text});
        }
        for (var url in m.imageUrls) {
          content.add({
            'type': 'image_url',
            'image_url': {'url': url}
          });
        }
        return {'role': m.role, 'content': content};
      }
    }).toList();
  }
}

class Message {
  final String role; // "system" or "user"
  final String? text;
  final List<String> imageUrls; // List of URLs or data URIs (base64)

  Message({required this.role, this.text, List<String>? imageUrls})
      : imageUrls = imageUrls ?? [];
}

class Completion {
  final String text;
  final List<String> citations;

  Completion({required this.text, required this.citations});
}

class PerplexityException implements Exception {
  final int statusCode;
  final String message;

  PerplexityException({required this.statusCode, required this.message});

  @override
  String toString() => 'PerplexityException: $statusCode - $message';
}
