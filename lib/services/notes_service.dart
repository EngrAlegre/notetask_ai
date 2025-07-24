import 'package:flutter/foundation.dart';

import './auth_service.dart';
import './supabase_service.dart';
import './ai_service.dart';

class NotesService {
  static final NotesService _instance = NotesService._internal();
  factory NotesService() => _instance;
  NotesService._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final AiService _aiService = AiService();

  // Fallback mock data for when services are unavailable
  final List<Map<String, dynamic>> _fallbackNotes = [
    {
      "id": "1",
      "title": "Welcome to NoteTask AI",
      "content":
          "This is your intelligent note-taking companion. Start by creating your first note or asking AI for suggestions to enhance your productivity.",
      "background_color": "yellow",
      "is_pinned": true,
      "is_archived": false,
      "is_task": false,
      "completed": false,
      "tags": ["welcome", "getting-started"],
      "folder": "personal",
      "reminder_at": null,
      "created_at": DateTime.now().toIso8601String(),
      "updated_at": DateTime.now().toIso8601String(),
    },
  ];

  // Get all notes for current user
  Future<List<Map<String, dynamic>>> getAllNotes({
    String searchQuery = '',
    String? folder,
    bool includeArchived = false,
  }) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Return filtered fallback data when services are unavailable
      return _getFilteredFallbackNotes(
        searchQuery: searchQuery,
        folder: folder,
        includeArchived: includeArchived,
      );
    }

    try {
      final client = await _supabaseService.client;
      final userId = _authService.currentUser!.id;

      final response = await client.rpc('search_user_notes', params: {
        'target_user_id': userId,
        'search_query': searchQuery,
        'note_folder': folder,
        'include_archived': includeArchived,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching notes: $error');
      }
      // Fallback to mock data on error
      return _getFilteredFallbackNotes(
        searchQuery: searchQuery,
        folder: folder,
        includeArchived: includeArchived,
      );
    }
  }

  // Get AI-enhanced suggestions for note improvement
  Future<List<Map<String, dynamic>>> getAiSuggestions() async {
    try {
      final recentNotes = await getAllNotes();
      final tasks = await _getUpcomingTasks();

      return await _aiService.generateSuggestions(
        recentNotes: recentNotes,
        tasks: tasks,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error getting AI suggestions: $error');
      }
      return [];
    }
  }

  // Enhance note content using AI
  Future<String> enhanceNoteWithAi({
    required String title,
    required String content,
    String enhancementType = 'improve',
  }) async {
    try {
      return await _aiService.enhanceNote(
        title: title,
        content: content,
        enhancementType: enhancementType,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error enhancing note with AI: $error');
      }
      return content; // Return original content if enhancement fails
    }
  }

  // Generate note ideas using AI
  Future<List<String>> generateNoteIdeas({
    List<String> tags = const [],
    String folder = 'personal',
  }) async {
    try {
      return await _aiService.generateNoteIdeas(tags: tags, folder: folder);
    } catch (error) {
      if (kDebugMode) {
        print('Error generating note ideas: $error');
      }
      return [
        'Daily journal entry',
        'Goal planning',
        'Book notes',
        'Meeting summary',
        'Creative ideas'
      ];
    }
  }

  // Ask AI about notes or productivity
  Future<String> askAi({
    required String question,
    List<Map<String, dynamic>>? context,
  }) async {
    try {
      return await _aiService.askQuestion(question: question, context: context);
    } catch (error) {
      if (kDebugMode) {
        print('Error asking AI: $error');
      }
      return 'AI service is currently unavailable. Please try again later.';
    }
  }

  // Get filtered fallback notes for offline/preview mode
  List<Map<String, dynamic>> _getFilteredFallbackNotes({
    String searchQuery = '',
    String? folder,
    bool includeArchived = false,
  }) {
    List<Map<String, dynamic>> filtered = List.from(_fallbackNotes);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        final title = (note['title'] as String? ?? '').toLowerCase();
        final content = (note['content'] as String? ?? '').toLowerCase();
        final tags =
            (note['tags'] as List<dynamic>? ?? []).join(' ').toLowerCase();
        final query = searchQuery.toLowerCase();

        return title.contains(query) ||
            content.contains(query) ||
            tags.contains(query);
      }).toList();
    }

    // Apply folder filter
    if (folder != null) {
      filtered = filtered.where((note) => note['folder'] == folder).toList();
    }

    // Apply archived filter
    if (!includeArchived) {
      filtered = filtered.where((note) => note['is_archived'] != true).toList();
    }

    // Sort by pinned first, then by creation date
    filtered.sort((a, b) {
      if (a['is_pinned'] == true && b['is_pinned'] != true) return -1;
      if (a['is_pinned'] != true && b['is_pinned'] == true) return 1;

      final aDate = DateTime.parse(a['created_at']);
      final bDate = DateTime.parse(b['created_at']);
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  // Get upcoming tasks (mock data for AI context)
  Future<List<Map<String, dynamic>>> _getUpcomingTasks() async {
    // This would typically fetch from a tasks service
    return [
      {
        "id": "1",
        "title": "Complete project report",
        "dueDate":
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        "priority": "high",
        "category": "Work",
      },
      {
        "id": "2",
        "title": "Review team proposals",
        "dueDate":
            DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        "priority": "medium",
        "category": "Work",
      },
    ];
  }

  // Create a new note
  Future<Map<String, dynamic>> createNote({
    required String title,
    required String content,
    String backgroundColor = 'yellow',
    bool isPinned = false,
    bool isTask = false,
    List<String> tags = const [],
    String folder = 'personal',
    DateTime? reminderAt,
  }) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock creation for preview mode
      final newNote = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": title,
        "content": content,
        "background_color": backgroundColor,
        "is_pinned": isPinned,
        "is_archived": false,
        "is_task": isTask,
        "completed": false,
        "tags": tags,
        "folder": folder,
        "reminder_at": reminderAt?.toIso8601String(),
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };
      _fallbackNotes.insert(0, newNote);
      return newNote;
    }

    try {
      final client = await _supabaseService.client;
      final userId = _authService.currentUser!.id;

      final response = await client
          .from('notes')
          .insert({
            'user_id': userId,
            'title': title,
            'content': content,
            'background_color': backgroundColor,
            'is_pinned': isPinned,
            'is_task': isTask,
            'tags': tags,
            'folder': folder,
            'reminder_at': reminderAt?.toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create note: ${error.toString()}');
    }
  }

  // Update an existing note
  Future<Map<String, dynamic>> updateNote({
    required String noteId,
    String? title,
    String? content,
    String? backgroundColor,
    bool? isPinned,
    bool? isArchived,
    bool? isTask,
    bool? completed,
    List<String>? tags,
    String? folder,
    DateTime? reminderAt,
  }) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock update for preview mode
      final noteIndex =
          _fallbackNotes.indexWhere((note) => note['id'] == noteId);
      if (noteIndex != -1) {
        final updatedNote =
            Map<String, dynamic>.from(_fallbackNotes[noteIndex]);
        if (title != null) updatedNote['title'] = title;
        if (content != null) updatedNote['content'] = content;
        if (backgroundColor != null)
          updatedNote['background_color'] = backgroundColor;
        if (isPinned != null) updatedNote['is_pinned'] = isPinned;
        if (isArchived != null) updatedNote['is_archived'] = isArchived;
        if (isTask != null) updatedNote['is_task'] = isTask;
        if (completed != null) updatedNote['completed'] = completed;
        if (tags != null) updatedNote['tags'] = tags;
        if (folder != null) updatedNote['folder'] = folder;
        if (reminderAt != null)
          updatedNote['reminder_at'] = reminderAt.toIso8601String();
        updatedNote['updated_at'] = DateTime.now().toIso8601String();

        _fallbackNotes[noteIndex] = updatedNote;
        return updatedNote;
      }
      throw Exception('Note not found');
    }

    try {
      final client = await _supabaseService.client;
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (backgroundColor != null)
        updates['background_color'] = backgroundColor;
      if (isPinned != null) updates['is_pinned'] = isPinned;
      if (isArchived != null) updates['is_archived'] = isArchived;
      if (isTask != null) updates['is_task'] = isTask;
      if (completed != null) updates['completed'] = completed;
      if (tags != null) updates['tags'] = tags;
      if (folder != null) updates['folder'] = folder;
      if (reminderAt != null)
        updates['reminder_at'] = reminderAt.toIso8601String();

      if (updates.isNotEmpty) {
        final response = await client
            .from('notes')
            .update(updates)
            .eq('id', noteId)
            .select()
            .single();

        return response;
      }

      // If no updates, return current note
      return await getNoteById(noteId);
    } catch (error) {
      throw Exception('Failed to update note: ${error.toString()}');
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock deletion for preview mode
      _fallbackNotes.removeWhere((note) => note['id'] == noteId);
      return;
    }

    try {
      final client = await _supabaseService.client;
      await client.from('notes').delete().eq('id', noteId);
    } catch (error) {
      throw Exception('Failed to delete note: ${error.toString()}');
    }
  }

  // Get a specific note by ID
  Future<Map<String, dynamic>> getNoteById(String noteId) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock fetch for preview mode
      final note = _fallbackNotes.firstWhere(
        (note) => note['id'] == noteId,
        orElse: () => throw Exception('Note not found'),
      );
      return note;
    }

    try {
      final client = await _supabaseService.client;
      final response =
          await client.from('notes').select().eq('id', noteId).single();

      return response;
    } catch (error) {
      throw Exception('Failed to get note: ${error.toString()}');
    }
  }

  // Get notes statistics
  Future<Map<String, dynamic>> getNotesStatistics() async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock statistics for preview mode
      final totalNotes = _fallbackNotes
          .where(
              (note) => note['is_task'] != true && note['is_archived'] != true)
          .length;
      final totalTasks = _fallbackNotes
          .where(
              (note) => note['is_task'] == true && note['is_archived'] != true)
          .length;
      final completedTasks = _fallbackNotes
          .where((note) =>
              note['is_task'] == true &&
              note['completed'] == true &&
              note['is_archived'] != true)
          .length;
      final pinnedNotes = _fallbackNotes
          .where((note) =>
              note['is_pinned'] == true && note['is_archived'] != true)
          .length;
      final archivedNotes =
          _fallbackNotes.where((note) => note['is_archived'] == true).length;

      return {
        'total_notes': totalNotes,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'pinned_notes': pinnedNotes,
        'archived_notes': archivedNotes,
        'completion_rate':
            totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0,
      };
    }

    try {
      final client = await _supabaseService.client;
      final userId = _authService.currentUser!.id;

      final response = await client.rpc('get_user_note_stats', params: {
        'target_user_id': userId,
      }).single();

      final totalNotes = response['total_notes'] ?? 0;
      final totalTasks = response['total_tasks'] ?? 0;
      final completedTasks = response['completed_tasks'] ?? 0;

      return {
        'total_notes': totalNotes,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'pinned_notes': response['pinned_notes'] ?? 0,
        'archived_notes': response['archived_notes'] ?? 0,
        'completion_rate':
            totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0,
      };
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching notes statistics: $error');
      }
      return {
        'total_notes': 0,
        'total_tasks': 0,
        'completed_tasks': 0,
        'pinned_notes': 0,
        'archived_notes': 0,
        'completion_rate': 0.0,
      };
    }
  }

  // Bulk operations
  Future<void> bulkUpdateNotes({
    required List<String> noteIds,
    bool? isPinned,
    bool? isArchived,
    String? folder,
  }) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock bulk update for preview mode
      for (String noteId in noteIds) {
        final noteIndex =
            _fallbackNotes.indexWhere((note) => note['id'] == noteId);
        if (noteIndex != -1) {
          final updatedNote =
              Map<String, dynamic>.from(_fallbackNotes[noteIndex]);
          if (isPinned != null) updatedNote['is_pinned'] = isPinned;
          if (isArchived != null) updatedNote['is_archived'] = isArchived;
          if (folder != null) updatedNote['folder'] = folder;
          updatedNote['updated_at'] = DateTime.now().toIso8601String();
          _fallbackNotes[noteIndex] = updatedNote;
        }
      }
      return;
    }

    try {
      final client = await _supabaseService.client;
      final updates = <String, dynamic>{};

      if (isPinned != null) updates['is_pinned'] = isPinned;
      if (isArchived != null) updates['is_archived'] = isArchived;
      if (folder != null) updates['folder'] = folder;

      if (updates.isNotEmpty) {
        await client.from('notes').update(updates).inFilter('id', noteIds);
      }
    } catch (error) {
      throw Exception('Failed to bulk update notes: ${error.toString()}');
    }
  }

  // Bulk delete
  Future<void> bulkDeleteNotes(List<String> noteIds) async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock bulk delete for preview mode
      _fallbackNotes.removeWhere((note) => noteIds.contains(note['id']));
      return;
    }

    try {
      final client = await _supabaseService.client;
      await client.from('notes').delete().inFilter('id', noteIds);
    } catch (error) {
      throw Exception('Failed to bulk delete notes: ${error.toString()}');
    }
  }

  // Get available folders
  Future<List<String>> getFolders() async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock folders for preview mode
      final folders = _fallbackNotes
          .map((note) => note['folder'] as String)
          .toSet()
          .toList();
      folders.sort();
      return folders;
    }

    try {
      final client = await _supabaseService.client;
      final userId = _authService.currentUser!.id;

      final response = await client
          .from('notes')
          .select('folder')
          .eq('user_id', userId)
          .not('folder', 'is', null);

      final folders =
          response.map((row) => row['folder'] as String).toSet().toList();
      folders.sort();
      return folders;
    } catch (error) {
      return ['personal', 'work', 'ideas'];
    }
  }

  // Get all unique tags
  Future<List<String>> getTags() async {
    if (!_supabaseService.isConfigured || !_authService.isAuthenticated) {
      // Mock tags for preview mode
      final allTags = <String>[];
      for (final note in _fallbackNotes) {
        final tags = note['tags'] as List<dynamic>? ?? [];
        allTags.addAll(tags.cast<String>());
      }
      final uniqueTags = allTags.toSet().toList();
      uniqueTags.sort();
      return uniqueTags;
    }

    try {
      final client = await _supabaseService.client;
      final userId = _authService.currentUser!.id;

      final response =
          await client.from('notes').select('tags').eq('user_id', userId);

      final allTags = <String>[];
      for (final row in response) {
        final tags = row['tags'] as List<dynamic>? ?? [];
        allTags.addAll(tags.cast<String>());
      }

      final uniqueTags = allTags.toSet().toList();
      uniqueTags.sort();
      return uniqueTags;
    } catch (error) {
      return [];
    }
  }
}
