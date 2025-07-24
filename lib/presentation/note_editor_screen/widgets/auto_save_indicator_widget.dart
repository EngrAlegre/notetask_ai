import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AutoSaveIndicatorWidget extends StatelessWidget {
  final bool isAutoSaving;

  const AutoSaveIndicatorWidget({
    Key? key,
    required this.isAutoSaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isAutoSaving) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.getSuccessColor(true),
            size: 4.w,
          ),
          SizedBox(width: 1.w),
          Text(
            'Saved',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.getSuccessColor(true),
              fontSize: 10.sp,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 3.w,
          height: 3.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          'Saving...',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}