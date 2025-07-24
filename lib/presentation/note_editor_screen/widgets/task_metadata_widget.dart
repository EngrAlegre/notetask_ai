import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskMetadataWidget extends StatelessWidget {
  final Map<String, dynamic> note;
  final Function(Map<String, dynamic>) onUpdate;

  const TaskMetadataWidget({
    Key? key,
    required this.note,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Status
          Row(
            children: [
              Checkbox(
                value: note['completed'] ?? false,
                onChanged: (value) {
                  onUpdate({'completed': value ?? false});
                },
              ),
              SizedBox(width: 2.w),
              Text(
                note['completed'] == true ? 'Completed' : 'Pending',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  decoration: note['completed'] == true
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Due Date
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDueDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note['due_date'] != null
                          ? _formatDate(DateTime.parse(note['due_date']))
                          : 'Set due date',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Category
          Row(
            children: [
              CustomIconWidget(
                iconName: 'label',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Category (e.g., Work, Personal)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) => onUpdate({'category': value}),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Reminder Toggle
          Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Enable Reminder',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
              Switch(
                value: note['enable_reminder'] ?? false,
                onChanged: (value) => onUpdate({'enable_reminder': value}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: note['due_date'] != null
          ? DateTime.parse(note['due_date'])
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      onUpdate({'due_date': picked.toIso8601String().split('T')[0]});
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return '${difference} days';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}