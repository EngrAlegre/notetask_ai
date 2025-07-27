import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/notes_service.dart';
import '../notes_screen/widgets/note_card_widget.dart';
import '../tasks_screen/widgets/task_card_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NotesService _notesService = NotesService();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _currentQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = query;
    });

    try {
      final results = await _notesService.getAllNotes(
        searchQuery: query,
        includeArchived: true,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search notes and tasks...',
            border: InputBorder.none,
            hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          onChanged: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              icon: CustomIconWidget(
                iconName: 'clear',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
            ),
        ],
      ),
      body: _buildSearchBody(),
    );
  }

  Widget _buildSearchBody() {
    if (_currentQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      'meeting notes',
      'grocery list',
      'project ideas',
      'travel plans',
      'book recommendations',
      'workout routine',
    ];

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...suggestions.map((suggestion) => ListTile(
            leading: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            title: Text(suggestion),
            onTap: () {
              _searchController.text = suggestion;
              _performSearch(suggestion);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 20.w,
          ),
          SizedBox(height: 3.h),
          Text(
            'No results found',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try searching with different keywords',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final notes = _searchResults.where((item) => item['is_task'] != true).toList();
    final tasks = _searchResults.where((item) => item['is_task'] == true).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_searchResults.length} results for "$_currentQuery"',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          if (notes.isNotEmpty) ...[
            Text(
              'Notes (${notes.length})',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            ...notes.map((note) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: NoteCardWidget(
                note: note,
                isListView: true,
                onTap: () => _navigateToNote(note),
                onLongPress: () => _showNoteOptions(note),
                onArchive: () => _archiveNote(note['id']),
                onDelete: () => _deleteNote(note['id']),
              ),
            )),
          ],

          if (tasks.isNotEmpty) ...[
            if (notes.isNotEmpty) SizedBox(height: 3.h),
            Text(
              'Tasks (${tasks.length})',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
            SizedBox(height: 2.h),
            ...tasks.map((task) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: TaskCardWidget(
                task: task,
                onToggleCompletion: (completed) => _toggleTaskCompletion(task['id'], completed),
                onEdit: () => _navigateToTask(task),
              ),
            )),
          ],
        ],
      ),
    );
  }

  void _navigateToNote(Map<String, dynamic> note) {
    Navigator.pushNamed(
      context,
      '/note-editor',
      arguments: {
        'noteId': note['id'],
        'type': 'note',
      },
    );
  }

  void _navigateToTask(Map<String, dynamic> task) {
    Navigator.pushNamed(
      context,
      '/note-editor',
      arguments: {
        'noteId': task['id'],
        'type': 'task',
      },
    );
  }

  void _showNoteOptions(Map<String, dynamic> note) {
    // Implementation for note options
  }

  void _archiveNote(String noteId) {
    // Implementation for archiving note
  }

  void _deleteNote(String noteId) {
    // Implementation for deleting note
  }

  void _toggleTaskCompletion(String taskId, bool completed) {
    // Implementation for toggling task completion
  }
}