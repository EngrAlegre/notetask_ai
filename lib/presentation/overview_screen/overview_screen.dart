import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/notes_service.dart';
import './widgets/ai_suggestion_card.dart';
import './widgets/empty_state_widget.dart';
import './widgets/note_card_widget.dart';
import './widgets/quick_action_card.dart';
import './widgets/section_header.dart';
import './widgets/task_card_widget.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _isRefreshing = false;
  bool _isOffline = false;
  final NotesService _notesService = NotesService();

  // Data loaded from services
  List<Map<String, dynamic>> _recentNotes = [];
  List<Map<String, dynamic>> _upcomingTasks = [];
  List<Map<String, dynamic>> _aiSuggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load notes from service (will use AI-enhanced data)
      final notes = await _notesService.getAllNotes();
      final aiSuggestions = await _notesService.getAiSuggestions();

      setState(() {
        _recentNotes = notes.take(6).toList();
        _aiSuggestions = aiSuggestions;
        _upcomingTasks = _getMockTasks(); // This would come from a TasksService
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  // Mock tasks - would be replaced with TasksService
  List<Map<String, dynamic>> _getMockTasks() {
    return [
      {
        "id": 1,
        "title": "Complete AI integration testing",
        "isCompleted": false,
        "dueDate": DateTime.now().add(const Duration(hours: 6)),
        "priority": "high",
        "category": "Work",
      },
      {
        "id": 2,
        "title": "Review Perplexity API documentation",
        "isCompleted": false,
        "dueDate": DateTime.now().add(const Duration(days: 1)),
        "priority": "medium",
        "category": "Learning",
      },
      {
        "id": 3,
        "title": "Implement AI-powered note suggestions",
        "isCompleted": false,
        "dueDate": DateTime.now().add(const Duration(days: 2)),
        "priority": "high",
        "category": "Development",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    _buildQuickActions(),
                    _buildRecentNotesSection(),
                    _buildUpcomingTasksSection(),
                    _buildAiSuggestionsSection(),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                  ],
                ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'NoteTask AI',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          const Spacer(),
          if (_isOffline)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_off',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 3.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Offline',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(width: 2.w),
          IconButton(
            onPressed: _handleSearch,
            icon: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: _handleProfile,
            icon: CircleAvatar(
              radius: 3.w,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Container(
        height: 14.h,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          children: [
            QuickActionCard(
              title: 'Create Note',
              iconName: 'note_add',
              backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.2),
              onTap: _handleCreateNote,
            ),
            QuickActionCard(
              title: 'New Task',
              iconName: 'add_task',
              backgroundColor: AppTheme
                  .lightTheme.colorScheme.secondaryContainer
                  .withValues(alpha: 0.2),
              onTap: _handleCreateTask,
            ),
            QuickActionCard(
              title: 'Voice Note',
              iconName: 'mic',
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiaryContainer
                  .withValues(alpha: 0.2),
              onTap: _handleVoiceNote,
            ),
            QuickActionCard(
              title: 'AI Assistant',
              iconName: 'auto_awesome',
              backgroundColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              onTap: _handleAiAssistant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotesSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SectionHeader(
            title: 'Recent Notes',
            iconName: 'note',
            actionText: 'View All',
            onActionTap: () => Navigator.pushNamed(context, '/notes-screen'),
          ),
          _recentNotes.isEmpty
              ? EmptyStateWidget(
                  title: 'No Notes Yet',
                  description:
                      'Create your first note to get started with AI-powered organization.',
                  buttonText: 'Create Your First Note',
                  iconName: 'note_add',
                  onButtonPressed: _handleCreateNote,
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: _buildMasonryGrid(_recentNotes),
                ),
        ],
      ),
    );
  }

  Widget _buildMasonryGrid(List<Map<String, dynamic>> notes) {
    return Column(
      children: [
        for (int i = 0; i < notes.length; i += 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NoteCardWidget(
                  note: notes[i],
                  onTap: () => _handleNoteEdit(notes[i]),
                  onLongPress: () => _handleNoteContextMenu(notes[i]),
                ),
              ),
              SizedBox(width: 2.w),
              if (i + 1 < notes.length)
                Expanded(
                  child: NoteCardWidget(
                    note: notes[i + 1],
                    onTap: () => _handleNoteEdit(notes[i + 1]),
                    onLongPress: () => _handleNoteContextMenu(notes[i + 1]),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
      ],
    );
  }

  Widget _buildUpcomingTasksSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SectionHeader(
            title: 'Upcoming Tasks',
            iconName: 'task_alt',
            actionText: 'View All',
            onActionTap: _handleViewAllTasks,
          ),
          _upcomingTasks.isEmpty
              ? EmptyStateWidget(
                  title: 'No Tasks Scheduled',
                  description:
                      'Add tasks with due dates to stay organized and productive.',
                  buttonText: 'Create Your First Task',
                  iconName: 'add_task',
                  onButtonPressed: _handleCreateTask,
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: _upcomingTasks
                        .map((task) => TaskCardWidget(
                              task: task,
                              onCheckboxChanged: (value) =>
                                  _handleTaskComplete(task, value),
                              onTap: () => _handleTaskEdit(task),
                              onSwipeLeft: () => _handleTaskOptions(task),
                            ))
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionsSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SectionHeader(
            title: 'AI Suggestions',
            iconName: 'auto_awesome',
          ),
          _aiSuggestions.isEmpty
              ? Container(
                  padding: EdgeInsets.all(4.w),
                  child: Text(
                    'AI suggestions will appear here based on your notes and activities.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: _aiSuggestions
                        .map((suggestion) => AiSuggestionCard(
                              suggestion: suggestion,
                              onTap: () => _handleAiSuggestion(suggestion),
                              onDismiss: () =>
                                  _handleDismissSuggestion(suggestion),
                            ))
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _handleFabPressed,
      child: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.lightTheme.colorScheme.onPrimary,
        size: 6.w,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: _handleBottomNavTap,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
          label: 'Overview',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'note',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          label: 'Notes',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'task_alt',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'auto_awesome',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          label: 'AI',
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadData();

    setState(() {
      _isRefreshing = false;
      _isOffline = false;
    });
  }

  void _handleSearch() {
    // Navigate to search screen or show search overlay
    showSearch(
      context: context,
      delegate: _SearchDelegate(),
    );
  }

  void _handleProfile() {
    // Navigate to profile screen
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
              title: const Text('Profile Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
              title: const Text('App Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'logout',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 5.w,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login-screen', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreateNote() async {
    // Show AI-powered note creation dialog
    final ideas = await _notesService.generateNoteIdeas();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create New Note',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 2.h),
            Text(
              'AI Suggestions:',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            ...ideas.take(3).map((idea) => ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(idea),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to note creation with the idea
                    Navigator.pushNamed(context, '/notes-screen');
                  },
                )),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notes-screen');
              },
              child: const Text('Create Blank Note'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreateTask() {
    // Navigate to task creation screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create New Task',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task description',
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleVoiceNote() {
    // Start voice recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording started')),
    );
  }

  void _handleAiAssistant() async {
    // Show AI assistant dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Assistant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Ask me anything about your notes...',
              ),
              onSubmitted: (question) async {
                Navigator.pop(context);
                final answer = await _notesService.askAi(question: question);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('AI Response'),
                    content: Text(answer),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleNoteEdit(Map<String, dynamic> note) {
    // Navigate to note editor
    Navigator.pushNamed(context, '/notes-screen');
  }

  void _handleNoteContextMenu(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _handleNoteEdit(note);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'auto_awesome',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              title: const Text('Enhance with AI'),
              onTap: () async {
                Navigator.pop(context);
                final enhanced = await _notesService.enhanceNoteWithAi(
                  title: note['title'],
                  content: note['content'],
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note enhanced! $enhanced')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'archive',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
              title: const Text('Archive'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 5.w,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTaskComplete(Map<String, dynamic> task, bool? value) {
    setState(() {
      task['isCompleted'] = value ?? false;
    });
  }

  void _handleTaskEdit(Map<String, dynamic> task) {
    // Navigate to task editor
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Task',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: task['title'],
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Update Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTaskOptions(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.pop(context);
                _handleTaskEdit(task);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
              title: const Text('Change Due Date'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 5.w,
              ),
              title: Text(
                'Delete Task',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleViewAllTasks() {
    // Navigate to tasks screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Tasks screen')),
    );
  }

  void _handleAiSuggestion(Map<String, dynamic> suggestion) async {
    // Handle AI suggestion action based on type
    final type = suggestion['type'] as String;

    switch (type) {
      case 'organize':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(suggestion['title']),
            content: Text(suggestion['description']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/notes-screen');
                },
                child: const Text('Let\'s Do It'),
              ),
            ],
          ),
        );
        break;
      case 'grammar':
      case 'rewrite':
      case 'summarize':
        if (_recentNotes.isNotEmpty) {
          final note = _recentNotes.first;
          final enhanced = await _notesService.enhanceNoteWithAi(
            title: note['title'],
            content: note['content'],
            enhancementType: type,
          );

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Enhanced: ${note['title']}'),
              content: SingleChildScrollView(
                child: Text(enhanced),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Update note with enhanced content
                    _notesService.updateNote(
                      noteId: note['id'],
                      content: enhanced,
                    );
                  },
                  child: const Text('Apply Changes'),
                ),
              ],
            ),
          );
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing: ${suggestion['title']}')),
        );
    }
  }

  void _handleDismissSuggestion(Map<String, dynamic> suggestion) {
    setState(() {
      _aiSuggestions.remove(suggestion);
    });
  }

  void _handleFabPressed() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create New',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'note_add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              title: const Text('Note'),
              onTap: () {
                Navigator.pop(context);
                _handleCreateNote();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'add_task',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              title: const Text('Task'),
              onTap: () {
                Navigator.pop(context);
                _handleCreateTask();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'mic',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 5.w,
              ),
              title: const Text('Voice Note'),
              onTap: () {
                Navigator.pop(context);
                _handleVoiceNote();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on Overview
        break;
      case 1:
        Navigator.pushNamed(context, '/notes-screen');
        break;
      case 2:
        // Navigate to tasks screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to Tasks screen')),
        );
        break;
      case 3:
        // Navigate to AI screen
        _handleAiAssistant();
        break;
    }
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: CustomIconWidget(
          iconName: 'clear',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 5.w,
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: CustomIconWidget(
        iconName: 'arrow_back',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 5.w,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        'Search results for: $query',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'Meeting notes',
      'Grocery list',
      'Travel plans',
      'Book ideas'
    ];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CustomIconWidget(
            iconName: 'search',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
