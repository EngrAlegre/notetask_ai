import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/notes_service.dart';
import './widgets/task_card_widget.dart';
import './widgets/task_filter_widget.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final NotesService _notesService = NotesService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allTasks = [];
  String _currentFilter = 'pending';
  bool _isLoading = true;

  List<Map<String, dynamic>> get _filteredTasks {
    switch (_currentFilter) {
      case 'completed':
        return _allTasks.where((task) => task['completed'] == true).toList();
      case 'overdue':
        final now = DateTime.now();
        return _allTasks
            .where((task) =>
                task['completed'] != true &&
                task['due_date'] != null &&
                DateTime.parse(task['due_date']).isBefore(now))
            .toList();
      case 'today':
        final today = DateTime.now().toIso8601String().split('T')[0];
        return _allTasks
            .where((task) =>
                task['completed'] != true && task['due_date'] == today)
            .toList();
      case 'pending':
      default:
        return _allTasks.where((task) => task['completed'] != true).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() => _isLoading = true);

      final notes = await _notesService.getAllNotes();
      final tasks = notes.where((note) => note['is_task'] == true).toList();

      // Sort tasks by due date and completion status
      tasks.sort((a, b) {
        // Completed tasks go to bottom
        if (a['completed'] == true && b['completed'] != true) return 1;
        if (a['completed'] != true && b['completed'] == true) return -1;

        // Sort by due date
        if (a['due_date'] != null && b['due_date'] != null) {
          return DateTime.parse(a['due_date'])
              .compareTo(DateTime.parse(b['due_date']));
        }
        if (a['due_date'] != null) return -1;
        if (b['due_date'] != null) return 1;

        // Sort by creation date
        return DateTime.parse(b['created_at'])
            .compareTo(DateTime.parse(a['created_at']));
      });

      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Failed to load tasks: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _toggleTaskCompletion(String taskId, bool completed) async {
    try {
      await _notesService.updateNote(
        noteId: taskId,
        completed: completed,
      );

      setState(() {
        final taskIndex = _allTasks.indexWhere((task) => task['id'] == taskId);
        if (taskIndex != -1) {
          _allTasks[taskIndex]['completed'] = completed;
        }
      });

      HapticFeedback.lightImpact();

      Fluttertoast.showToast(
        msg: completed ? 'Task completed!' : 'Task marked as pending',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update task: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _editTask(Map<String, dynamic> task) {
    Navigator.pushNamed(
      context,
      '/note-editor',
      arguments: {
        'noteId': task['id'],
        'type': 'task',
      },
    ).then((_) => _loadTasks());
  }

  void _createNewTask() {
    Navigator.pushNamed(
      context,
      '/note-editor',
      arguments: {
        'type': 'task',
      },
    ).then((_) => _loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadTasks,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 5.w,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Widget
            TaskFilterWidget(
              currentFilter: _currentFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _currentFilter = filter;
                });
              },
            ),

            // Tasks List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTasks.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadTasks,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(4.w),
                            itemCount: _filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = _filteredTasks[index];
                              return TaskCardWidget(
                                task: task,
                                onToggleCompletion: (completed) =>
                                    _toggleTaskCompletion(task['id'], completed),
                                onEdit: () => _editTask(task),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTask,
        child: CustomIconWidget(
          iconName: 'add_task',
          color: Colors.white,
          size: 6.w,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'task_alt',
            color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.5),
            size: 20.w,
          ),
          SizedBox(height: 3.h),
          Text(
            _getEmptyStateTitle(),
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _getEmptyStateDescription(),
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: _createNewTask,
            child: const Text('Create Your First Task'),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    switch (_currentFilter) {
      case 'completed':
        return 'No Completed Tasks';
      case 'overdue':
        return 'No Overdue Tasks';
      case 'today':
        return 'No Tasks Due Today';
      default:
        return 'No Pending Tasks';
    }
  }

  String _getEmptyStateDescription() {
    switch (_currentFilter) {
      case 'completed':
        return 'Complete some tasks to see them here.';
      case 'overdue':
        return 'Great! You\'re all caught up.';
      case 'today':
        return 'No tasks are due today.';
      default:
        return 'Create your first task to get started with task management.';
    }
  }
}