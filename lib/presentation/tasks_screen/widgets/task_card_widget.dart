import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskCardWidget extends StatelessWidget {
  final Map<String, dynamic> task;
  final Function(bool) onToggleCompletion;
  final VoidCallback onEdit;

  const TaskCardWidget({
    Key? key,
    required this.task,
    required this.onToggleCompletion,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = task['completed'] ?? false;
    final String title = task['title'] ?? 'Untitled Task';
    final String content = task['content'] ?? '';
    final String? dueDate = task['due_date'];
    final String? category = task['category'];
    final List<dynamic> tags = task['tags'] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => onToggleCompletion(!isCompleted),
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isCompleted
                        ? Center(
                            child: CustomIconWidget(
                              iconName: 'check',
                              color: Colors.white,
                              size: 3.w,
                            ),
                          )
                        : null,
                  ),
                ),

                SizedBox(width: 3.w),

                // Task Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Content
                      if (content.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Text(
                          content,
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: isCompleted
                                ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      SizedBox(height: 2.h),

                      // Metadata Row
                      Row(
                        children: [
                          // Due Date
                          if (dueDate != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getDueDateColor(dueDate).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'schedule',
                                    color: _getDueDateColor(dueDate),
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    _formatDueDate(dueDate),
                                    style: AppTheme.lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: _getDueDateColor(dueDate),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.w),
                          ],

                          // Category
                          if (category != null && category.isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.secondaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Priority Indicator
                          Container(
                            width: 1.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),

                      // Tags
                      if (tags.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 1.w,
                          runSpacing: 0.5.h,
                          children: tags.take(3).map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag.toString(),
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDueDateColor(String dueDate) {
    final due = DateTime.parse(dueDate);
    final now = DateTime.now();
    final difference = due.difference(now).inDays;

    if (difference < 0) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (difference == 0) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else if (difference <= 3) {
      return AppTheme.getWarningColor(true);
    } else {
      return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatDueDate(String dueDate) {
    final due = DateTime.parse(dueDate);
    final now = DateTime.now();
    final difference = due.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference <= 7) {
      return '${difference}d';
    } else {
      return '${due.month}/${due.day}';
    }
  }

  Color _getPriorityColor() {
    // This would be based on task priority if implemented
    final dueDate = task['due_date'];
    if (dueDate != null) {
      return _getDueDateColor(dueDate);
    }
    return AppTheme.lightTheme.colorScheme.outline;
  }
}