import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskFilterWidget extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const TaskFilterWidget({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  final Map<String, Map<String, dynamic>> _filters = const {
    'pending': {
      'label': 'Pending',
      'icon': 'pending_actions',
      'color': Colors.orange,
    },
    'today': {
      'label': 'Today',
      'icon': 'today',
      'color': Colors.blue,
    },
    'overdue': {
      'label': 'Overdue',
      'icon': 'warning',
      'color': Colors.red,
    },
    'completed': {
      'label': 'Completed',
      'icon': 'check_circle',
      'color': Colors.green,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filterKey = _filters.keys.elementAt(index);
          final filter = _filters[filterKey]!;
          final isSelected = currentFilter == filterKey;

          return GestureDetector(
            onTap: () => onFilterChanged(filterKey),
            child: Container(
              margin: EdgeInsets.only(right: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: filter['icon'],
                    color: isSelected
                        ? Colors.white
                        : filter['color'] as Color,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    filter['label'],
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}