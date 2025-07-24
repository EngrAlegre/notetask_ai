import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditorToolbarWidget extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onVoiceInput;
  final VoidCallback onAiEnhance;
  final VoidCallback onFormatting;
  final VoidCallback onOrganization;

  const EditorToolbarWidget({
    Key? key,
    required this.note,
    required this.onVoiceInput,
    required this.onAiEnhance,
    required this.onFormatting,
    required this.onOrganization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarButton(
            iconName: 'mic',
            label: 'Voice',
            onTap: onVoiceInput,
          ),
          _buildToolbarButton(
            iconName: 'auto_awesome',
            label: 'AI',
            onTap: onAiEnhance,
          ),
          _buildToolbarButton(
            iconName: 'format_paint',
            label: 'Format',
            onTap: onFormatting,
          ),
          _buildToolbarButton(
            iconName: 'folder',
            label: 'Organize',
            onTap: onOrganization,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required String iconName,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}