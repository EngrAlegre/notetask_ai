import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/notes_service.dart';
import './widgets/auto_save_indicator_widget.dart';
import './widgets/editor_toolbar_widget.dart';
import './widgets/formatting_bottom_sheet_widget.dart';
import './widgets/organization_bottom_sheet_widget.dart';
import './widgets/task_metadata_widget.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  final String type; // 'note' or 'task'

  const NoteEditorScreen({
    Key? key,
    this.noteId,
    this.type = 'note',
  }) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final NotesService _notesService = NotesService();

  Map<String, dynamic> _note = {};
  bool _isNewNote = true;
  bool _isAutoSaving = false;
  bool _hasUnsavedChanges = false;
  bool _showFormattingMenu = false;
  bool _showOrganizationMenu = false;

  @override
  void initState() {
    super.initState();
    _initializeNote();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _initializeNote() {
    if (widget.noteId != null) {
      _isNewNote = false;
      _loadExistingNote();
    } else {
      _createNewNote();
    }
  }

  void _createNewNote() {
    _note = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': '',
      'content': '',
      'is_task': widget.type == 'task',
      'completed': false,
      'background_color': 'white',
      'font_family': 'Inter',
      'font_size': 'medium',
      'text_color': '#000000',
      'is_pinned': false,
      'is_archived': false,
      'tags': <String>[],
      'folder': 'personal',
      'subtasks': <Map<String, dynamic>>[],
      'due_date': null,
      'reminder_at': null,
      'enable_reminder': false,
      'category': '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _loadExistingNote() async {
    try {
      final note = await _notesService.getNoteById(widget.noteId!);
      setState(() {
        _note = note;
        _titleController.text = note['title'] ?? '';
        _contentController.text = note['content'] ?? '';
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load note: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pop(context);
    }
  }

  void _setupAutoSave() {
    _titleController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    setState(() {
      _hasUnsavedChanges = true;
      _note['title'] = _titleController.text;
      _note['content'] = _contentController.text;
      _note['updated_at'] = DateTime.now().toIso8601String();
    });

    // Auto-save after 2 seconds of inactivity
    Future.delayed(const Duration(seconds: 2), () {
      if (_hasUnsavedChanges && mounted) {
        _autoSave();
      }
    });
  }

  Future<void> _autoSave() async {
    if (!_hasUnsavedChanges) return;

    setState(() {
      _isAutoSaving = true;
    });

    try {
      if (_isNewNote) {
        await _notesService.createNote(
          title: _note['title'],
          content: _note['content'],
          backgroundColor: _note['background_color'],
          isPinned: _note['is_pinned'],
          isTask: _note['is_task'],
          tags: List<String>.from(_note['tags']),
          folder: _note['folder'],
        );
        _isNewNote = false;
      } else {
        await _notesService.updateNote(
          noteId: _note['id'],
          title: _note['title'],
          content: _note['content'],
        );
      }

      setState(() {
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      // Silent fail for auto-save
    } finally {
      setState(() {
        _isAutoSaving = false;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    try {
      if (_isNewNote) {
        await _notesService.createNote(
          title: _titleController.text,
          content: _contentController.text,
          backgroundColor: _note['background_color'],
          isPinned: _note['is_pinned'],
          isTask: _note['is_task'],
          tags: List<String>.from(_note['tags']),
          folder: _note['folder'],
        );
      } else {
        await _autoSave();
      }

      HapticFeedback.lightImpact();
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _handleDelete() {
    if (_isNewNote) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _notesService.deleteNote(_note['id']);
                Navigator.pop(context);
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'Failed to delete: $e',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    final colorName = _note['background_color'] as String? ?? 'white';
    switch (colorName) {
      case 'yellow':
        return const Color(0xFFFEF3C7);
      case 'green':
        return const Color(0xFFD1FAE5);
      case 'blue':
        return const Color(0xFFDBEAFE);
      case 'pink':
        return const Color(0xFFFCE7F3);
      case 'purple':
        return const Color(0xFFF3E8FF);
      case 'orange':
        return const Color(0xFFFED7AA);
      case 'white':
      default:
        return Colors.white;
    }
  }

  double _getFontSize() {
    final size = _note['font_size'] as String? ?? 'medium';
    switch (size) {
      case 'small':
        return 14.sp;
      case 'large':
        return 18.sp;
      case 'medium':
      default:
        return 16.sp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final fontSize = _getFontSize();
    final textColor = Color(int.parse(
        (_note['text_color'] as String? ?? '#000000').replaceFirst('#', '0xFF')));

    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          await _handleSave();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Editor Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (_hasUnsavedChanges) {
                          await _handleSave();
                        }
                        Navigator.pop(context);
                      },
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                    const Spacer(),
                    AutoSaveIndicatorWidget(isAutoSaving: _isAutoSaving),
                    SizedBox(width: 2.w),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'formatting':
                            setState(() => _showFormattingMenu = true);
                            break;
                          case 'organization':
                            setState(() => _showOrganizationMenu = true);
                            break;
                          case 'delete':
                            _handleDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'formatting',
                          child: Row(
                            children: [
                              Icon(Icons.format_paint),
                              SizedBox(width: 8),
                              Text('Formatting'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'organization',
                          child: Row(
                            children: [
                              Icon(Icons.folder),
                              SizedBox(width: 8),
                              Text('Organization'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: CustomIconWidget(
                        iconName: 'more_vert',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
              ),

              // Task Metadata (if task)
              if (_note['is_task'] == true)
                TaskMetadataWidget(
                  note: _note,
                  onUpdate: (updates) {
                    setState(() {
                      _note = {..._note, ...updates};
                      _hasUnsavedChanges = true;
                    });
                  },
                ),

              // Editor Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      // Title Input
                      TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        style: TextStyle(
                          fontSize: fontSize + 2.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontFamily: _note['font_family'],
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _contentFocusNode.requestFocus(),
                      ),

                      SizedBox(height: 2.h),

                      // Content Input
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          focusNode: _contentFocusNode,
                          style: TextStyle(
                            fontSize: fontSize,
                            color: textColor,
                            fontFamily: _note['font_family'],
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Take a note...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Editor Toolbar
              EditorToolbarWidget(
                note: _note,
                onVoiceInput: _handleVoiceInput,
                onAiEnhance: _handleAiEnhance,
                onFormatting: () => setState(() => _showFormattingMenu = true),
                onOrganization: () => setState(() => _showOrganizationMenu = true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleVoiceInput() {
    // TODO: Implement voice input
    Fluttertoast.showToast(
      msg: 'Voice input feature coming soon!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _handleAiEnhance() async {
    if (_contentController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Add some content to enhance with AI',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    try {
      final enhanced = await _notesService.enhanceNoteWithAi(
        title: _titleController.text,
        content: _contentController.text,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('AI Enhanced Content'),
          content: SingleChildScrollView(
            child: Text(enhanced),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _contentController.text = enhanced;
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'AI enhancement failed: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}