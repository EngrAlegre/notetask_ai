import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/notes_service.dart';
import './widgets/batch_action_toolbar_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/floating_action_menu_widget.dart';
import './widgets/notes_grid_widget.dart';
import './widgets/search_bar_widget.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final NotesService _notesService = NotesService();

  String _searchQuery = '';
  String _currentFilter = 'all';
  bool _isGridView = true;
  Set<String> _selectedNotes = {};
  bool _isMultiSelectMode = false;
  bool _isOffline = false;
  bool _isLoading = true;

  List<Map<String, dynamic>> _allNotes = [];

  List<Map<String, dynamic>> get _filteredNotes {
    List<Map<String, dynamic>> filtered = List.from(_allNotes);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        final title = (note['title'] as String? ?? '').toLowerCase();
        final content = (note['content'] as String? ?? '').toLowerCase();
        final tags =
            (note['tags'] as List<dynamic>? ?? []).join(' ').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return title.contains(query) ||
            content.contains(query) ||
            tags.contains(query);
      }).toList();
    }

    // Apply category filter
    switch (_currentFilter) {
      case 'pinned':
        filtered = filtered.where((note) => note['is_pinned'] == true).toList();
        break;
      case 'archived':
        filtered =
            filtered.where((note) => note['is_archived'] == true).toList();
        break;
      case 'work':
      case 'personal':
      case 'ideas':
        filtered =
            filtered.where((note) => note['folder'] == _currentFilter).toList();
        break;
      case 'reminders':
        filtered = filtered
            .where((note) => (note['tags'] as List).contains('reminder'))
            .toList();
        break;
      default:
        filtered =
            filtered.where((note) => note['is_archived'] != true).toList();
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

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadNotes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkConnectivity() {
    // Simulate offline check
    setState(() {
      _isOffline = false; // In real app, use connectivity_plus package
    });
  }

  Future<void> _loadNotes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final notes = await _notesService.getAllNotes(
          searchQuery: _searchQuery,
          folder: _currentFilter == 'all' ? null : _currentFilter,
          includeArchived: _currentFilter == 'archived');

      setState(() {
        _allNotes = notes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Fluttertoast.showToast(
            msg: 'Failed to load notes: ${error.toString()}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadNotes();
  }

  void _onFilterTap() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FilterBottomSheetWidget(
            currentFilter: _currentFilter,
            onFilterChanged: (filter) {
              setState(() {
                _currentFilter = filter;
              });
              _loadNotes();
            }));
  }

  void _onViewToggle() {
    setState(() {
      _isGridView = !_isGridView;
    });

    HapticFeedback.lightImpact();
  }

  void _onNoteTap(String noteId) {
    if (_isMultiSelectMode) {
      _toggleNoteSelection(noteId);
    } else {
      // Navigate to note editor
      Navigator.pushNamed(context, '/note-editor', arguments: noteId);
    }
  }

  void _onNoteLongPress(String noteId) {
    HapticFeedback.mediumImpact();

    if (!_isMultiSelectMode) {
      setState(() {
        _isMultiSelectMode = true;
        _selectedNotes.add(noteId);
      });
    } else {
      _toggleNoteSelection(noteId);
    }
  }

  void _toggleNoteSelection(String noteId) {
    setState(() {
      if (_selectedNotes.contains(noteId)) {
        _selectedNotes.remove(noteId);
        if (_selectedNotes.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedNotes.add(noteId);
      }
    });
  }

  Future<void> _onNoteArchive(String noteId) async {
    try {
      final note = _allNotes.firstWhere((note) => note['id'] == noteId);
      final isCurrentlyArchived = note['is_archived'] ?? false;

      await _notesService.updateNote(
          noteId: noteId, isArchived: !isCurrentlyArchived);

      await _loadNotes();

      Fluttertoast.showToast(
          msg: isCurrentlyArchived ? 'Note unarchived' : 'Note archived',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    } catch (error) {
      Fluttertoast.showToast(
          msg: 'Failed to archive note: ${error.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  Future<void> _onNoteDelete(String noteId) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Delete Note'),
                content: Text(
                    'Are you sure you want to delete this note? This action cannot be undone.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await _notesService.deleteNote(noteId);
                          await _loadNotes();

                          Fluttertoast.showToast(
                              msg: 'Note deleted',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        } catch (error) {
                          Fluttertoast.showToast(
                              msg: 'Failed to delete note: ${error.toString()}',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        }
                      },
                      child: Text('Delete')),
                ]));
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadNotes();

    if (mounted) {
      Fluttertoast.showToast(
          msg: 'Notes synced',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  void _onSelectAll() {
    setState(() {
      _selectedNotes =
          _filteredNotes.map((note) => note['id'] as String).toSet();
    });
  }

  void _onDeselectAll() {
    setState(() {
      _selectedNotes.clear();
      _isMultiSelectMode = false;
    });
  }

  Future<void> _onArchiveSelected() async {
    try {
      await _notesService.bulkUpdateNotes(
          noteIds: _selectedNotes.toList(), isArchived: true);

      setState(() {
        _selectedNotes.clear();
        _isMultiSelectMode = false;
      });

      await _loadNotes();

      Fluttertoast.showToast(
          msg: 'Notes archived',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    } catch (error) {
      Fluttertoast.showToast(
          msg: 'Failed to archive notes: ${error.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  Future<void> _onDeleteSelected() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Delete Notes'),
                content: Text(
                    'Are you sure you want to delete ${_selectedNotes.length} notes? This action cannot be undone.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await _notesService
                              .bulkDeleteNotes(_selectedNotes.toList());

                          setState(() {
                            _selectedNotes.clear();
                            _isMultiSelectMode = false;
                          });

                          await _loadNotes();

                          Fluttertoast.showToast(
                              msg: 'Notes deleted',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        } catch (error) {
                          Fluttertoast.showToast(
                              msg:
                                  'Failed to delete notes: ${error.toString()}',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        }
                      },
                      child: Text('Delete')),
                ]));
  }

  Future<void> _onPinSelected() async {
    try {
      await _notesService.bulkUpdateNotes(
          noteIds: _selectedNotes.toList(), isPinned: true);

      setState(() {
        _selectedNotes.clear();
        _isMultiSelectMode = false;
      });

      await _loadNotes();

      Fluttertoast.showToast(
          msg: 'Notes pinned',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    } catch (error) {
      Fluttertoast.showToast(
          msg: 'Failed to pin notes: ${error.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  void _onTextNote() {
    Navigator.pushNamed(context, '/note-editor');
  }

  void _onVoiceNote() {
    Navigator.pushNamed(context, '/voice-note');
  }

  void _onAINote() {
    Navigator.pushNamed(context, '/ai-note');
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor:
            isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        body: SafeArea(
            child: Stack(children: [
          Column(children: [
            SearchBarWidget(
                searchQuery: _searchQuery,
                onSearchChanged: _onSearchChanged,
                onFilterTap: _onFilterTap,
                onViewToggle: _onViewToggle,
                isGridView: _isGridView),
            if (_isOffline)
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  color: AppTheme.warningLight,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                            iconName: 'cloud_off',
                            color: Colors.white,
                            size: 16),
                        SizedBox(width: 2.w),
                        Text('Offline mode - Changes will sync when connected',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white)),
                      ])),
            Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : NotesGridWidget(
                        notes: _filteredNotes,
                        isGridView: _isGridView,
                        selectedNotes: _selectedNotes,
                        onNoteTap: _onNoteTap,
                        onNoteLongPress: _onNoteLongPress,
                        onNoteArchive: _onNoteArchive,
                        onNoteDelete: _onNoteDelete,
                        onRefresh: _onRefresh,
                        scrollController: _scrollController)),
          ]),
          if (_isMultiSelectMode)
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BatchActionToolbarWidget(
                    selectedCount: _selectedNotes.length,
                    onSelectAll: _onSelectAll,
                    onDeselectAll: _onDeselectAll,
                    onArchiveSelected: _onArchiveSelected,
                    onDeleteSelected: _onDeleteSelected,
                    onPinSelected: _onPinSelected,
                    onClose: _onDeselectAll)),
          if (!_isMultiSelectMode)
            Positioned(
                bottom: 4.h,
                right: 4.w,
                child: FloatingActionMenuWidget(
                    onTextNote: _onTextNote,
                    onVoiceNote: _onVoiceNote,
                    onAINote: _onAINote)),
        ])));
  }
}
