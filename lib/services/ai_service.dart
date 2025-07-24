import 'package:flutter/foundation.dart';
import 'dart:convert';
import './perplexity_service.dart';
import './perplexity_client.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final PerplexityService _perplexityService = PerplexityService();
  late final PerplexityClient _client;
  bool _isInitialized = false;

  void _ensureInitialized() {
    if (!_isInitialized && _perplexityService.isConfigured) {
      _client = PerplexityClient(_perplexityService.dio);
      _isInitialized = true;
    }
  }

  bool get isAvailable => _perplexityService.isConfigured;

  /// Generate AI suggestions based on user's notes and tasks
  Future<List<Map<String, dynamic>>> generateSuggestions({
    required List<Map<String, dynamic>> recentNotes,
    required List<Map<String, dynamic>> tasks,
  }) async {
    if (!isAvailable) return _getFallbackSuggestions();

    try {
      _ensureInitialized();

      // Prepare context from notes and tasks
      final notesContext = recentNotes
          .take(5)
          .map((note) =>
              '- ${note['title']}: ${(note['content'] as String).substring(0, (note['content'] as String).length > 100 ? 100 : (note['content'] as String).length)}...')
          .join('\n');

      final tasksContext = tasks
          .take(3)
          .map((task) =>
              '- ${task['title']} (Due: ${task['dueDate']}, Priority: ${task['priority']})')
          .join('\n');

      final messages = [
        Message(
          role: 'system',
          text:
              'You are an AI assistant that helps users organize their notes and tasks. Based on the user\'s recent activity, provide 3 helpful suggestions.',
        ),
        Message(
          role: 'user',
          text:
              '''Based on my recent notes and tasks, provide me with 3 specific suggestions to improve my productivity. 

Recent Notes:
$notesContext

Upcoming Tasks:
$tasksContext

Please respond with exactly 3 suggestions in JSON format like this:
[
  {
    "title": "Brief title",
    "description": "Detailed description of the suggestion",
    "type": "organize|grammar|rewrite|ideas|summarize"
  }
]''',
        ),
      ];

      final completion = await _client.createChat(
        messages: messages,
        model: 'sonar-reasoning',
      );

      // Parse JSON response
      try {
        final suggestions = _parseSuggestionsFromResponse(completion.text);
        return suggestions
            .map((suggestion) => {
                  ...suggestion,
                  'id': DateTime.now().millisecondsSinceEpoch +
                      suggestions.indexOf(suggestion),
                })
            .toList();
      } catch (e) {
        if (kDebugMode) print('Error parsing AI suggestions: $e');
        return _getFallbackSuggestions();
      }
    } catch (e) {
      if (kDebugMode) print('Error generating AI suggestions: $e');
      return _getFallbackSuggestions();
    }
  }

  /// Enhance note content with AI
  Future<String> enhanceNote({
    required String title,
    required String content,
    String enhancementType = 'improve',
  }) async {
    if (!isAvailable) return content;

    try {
      _ensureInitialized();

      String prompt;
      switch (enhancementType) {
        case 'grammar':
          prompt =
              'Please improve the grammar and readability of this note while keeping the original meaning and structure:';
          break;
        case 'summarize':
          prompt =
              'Please create a concise summary of this note, highlighting the key points:';
          break;
        case 'expand':
          prompt =
              'Please expand on this note with additional relevant details and insights:';
          break;
        default:
          prompt =
              'Please improve and polish this note, enhancing clarity and organization:';
      }

      final messages = [
        Message(
          role: 'system',
          text:
              'You are a helpful AI assistant that enhances written content. Provide clean, well-structured improvements.',
        ),
        Message(
          role: 'user',
          text: '$prompt\n\nTitle: $title\n\nContent:\n$content',
        ),
      ];

      final completion = await _client.createChat(
        messages: messages,
        model: 'sonar-reasoning',
      );

      return completion.text.trim();
    } catch (e) {
      if (kDebugMode) print('Error enhancing note: $e');
      return content;
    }
  }

  /// Generate note ideas based on user's interests
  Future<List<String>> generateNoteIdeas({
    required List<String> tags,
    required String folder,
  }) async {
    if (!isAvailable) return _getFallbackNoteIdeas(folder);

    try {
      _ensureInitialized();

      final messages = [
        Message(
          role: 'system',
          text:
              'You are a creative AI assistant that helps users brainstorm note ideas based on their interests and context.',
        ),
        Message(
          role: 'user',
          text:
              '''Based on my interests in these topics: ${tags.join(', ')} and the fact that I organize them in the "$folder" folder, please suggest 5 creative note ideas I could write about.

Please respond with just a numbered list of ideas, one per line.''',
        ),
      ];

      final completion = await _client.createChat(
        messages: messages,
        model: 'sonar',
      );

      return _parseNoteIdeasFromResponse(completion.text);
    } catch (e) {
      if (kDebugMode) print('Error generating note ideas: $e');
      return _getFallbackNoteIdeas(folder);
    }
  }

  /// Ask AI a question about notes or tasks
  Future<String> askQuestion({
    required String question,
    List<Map<String, dynamic>>? context,
  }) async {
    if (!isAvailable)
      return 'AI service is not available. Please configure your Perplexity API key.';

    try {
      _ensureInitialized();

      String contextStr = '';
      if (context != null && context.isNotEmpty) {
        contextStr = '\n\nContext from your notes:\n' +
            context
                .take(3)
                .map((item) => '- ${item['title']}: ${item['content']}')
                .join('\n');
      }

      final messages = [
        Message(
          role: 'system',
          text:
              'You are a helpful AI assistant for a note-taking app. Answer questions about productivity, organization, and help with note-related tasks.',
        ),
        Message(
          role: 'user',
          text: question + contextStr,
        ),
      ];

      final completion = await _client.createChat(
        messages: messages,
        model: 'sonar',
      );

      return completion.text;
    } catch (e) {
      if (kDebugMode) print('Error asking AI question: $e');
      return 'Sorry, I encountered an error while processing your question. Please try again later.';
    }
  }

  List<Map<String, dynamic>> _getFallbackSuggestions() {
    return [
      {
        'id': 1,
        'title': 'Organize Your Notes',
        'description':
            'Group related notes into folders and add tags for better organization.',
        'type': 'organize',
      },
      {
        'id': 2,
        'title': 'Review Your Tasks',
        'description':
            'Update task priorities and set realistic due dates for better productivity.',
        'type': 'organize',
      },
      {
        'id': 3,
        'title': 'Create Weekly Summary',
        'description':
            'Summarize your weekly accomplishments and plan for the upcoming week.',
        'type': 'summarize',
      },
    ];
  }

  List<String> _getFallbackNoteIdeas(String folder) {
    final ideas = {
      'work': [
        'Meeting action items template',
        'Project milestone tracker',
        'Team communication guidelines',
        'Professional development goals',
        'Industry trend analysis',
      ],
      'personal': [
        'Daily gratitude journal',
        'Book recommendations and reviews',
        'Recipe collection',
        'Travel bucket list',
        'Fitness progress tracker',
      ],
      'ideas': [
        'Creative project brainstorming',
        'Problem-solving techniques',
        'Innovation opportunities',
        'Inspiration collection',
        'Future goal planning',
      ],
    };

    return ideas[folder] ?? ideas['personal']!;
  }

  List<Map<String, dynamic>> _parseSuggestionsFromResponse(String response) {
    try {
      // Try to extract JSON from the response
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final parsed = List<Map<String, dynamic>>.from(
            (jsonDecode(jsonStr) as List)
                .map((item) => Map<String, dynamic>.from(item)));
        return parsed;
      }
    } catch (e) {
      if (kDebugMode) print('JSON parsing failed, using fallback: $e');
    }

    return _getFallbackSuggestions();
  }

  List<String> _parseNoteIdeasFromResponse(String response) {
    return response
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(5)
        .toList();
  }
}