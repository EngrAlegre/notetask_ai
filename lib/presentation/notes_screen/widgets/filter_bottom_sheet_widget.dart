import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late String _selectedFilter;

  final List<Map<String, dynamic>> _filterOptions = [
    {'key': 'all', 'title': 'All Notes', 'icon': 'note'},
    {'key': 'pinned', 'title': 'Pinned', 'icon': 'push_pin'},
    {'key': 'archived', 'title': 'Archived', 'icon': 'archive'},
    {'key': 'work', 'title': 'Work', 'icon': 'work'},
    {'key': 'personal', 'title': 'Personal', 'icon': 'person'},
    {'key': 'ideas', 'title': 'Ideas', 'icon': 'lightbulb'},
    {'key': 'reminders', 'title': 'Reminders', 'icon': 'alarm'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.dividerColorDark
                  : AppTheme.dividerColorLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Notes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: isDark
                            ? AppTheme.textHighEmphasisDark
                            : AppTheme.textHighEmphasisLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 3.h),
                ...(_filterOptions.map((option) => _buildFilterOption(
                      context,
                      option['key'] as String,
                      option['title'] as String,
                      option['icon'] as String,
                      isDark,
                    ))),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onFilterChanged(_selectedFilter);
                          Navigator.pop(context);
                        },
                        child: Text('Apply'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String key, String title,
      String icon, bool isDark) {
    final bool isSelected = _selectedFilter == key;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : (isDark
                    ? AppTheme.dividerColorDark
                    : AppTheme.dividerColorLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor
                  : (isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight),
              size: 20,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : (isDark
                              ? AppTheme.textHighEmphasisDark
                              : AppTheme.textHighEmphasisLight),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
