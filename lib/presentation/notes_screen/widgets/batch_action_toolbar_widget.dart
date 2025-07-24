import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BatchActionToolbarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final VoidCallback onArchiveSelected;
  final VoidCallback onDeleteSelected;
  final VoidCallback onPinSelected;
  final VoidCallback onClose;

  const BatchActionToolbarWidget({
    Key? key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onArchiveSelected,
    required this.onDeleteSelected,
    required this.onPinSelected,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '$selectedCount selected',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              _buildActionButton(
                context,
                'select_all',
                onSelectAll,
              ),
              SizedBox(width: 4.w),
              _buildActionButton(
                context,
                'push_pin',
                onPinSelected,
              ),
              SizedBox(width: 4.w),
              _buildActionButton(
                context,
                'archive',
                onArchiveSelected,
              ),
              SizedBox(width: 4.w),
              _buildActionButton(
                context,
                'delete',
                onDeleteSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
