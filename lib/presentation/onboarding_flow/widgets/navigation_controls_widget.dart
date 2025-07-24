import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NavigationControlsWidget extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final bool isLastPage;
  final String nextButtonText;

  const NavigationControlsWidget({
    Key? key,
    required this.onSkip,
    required this.onNext,
    this.isLastPage = false,
    this.nextButtonText = 'Next',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            ),
            child: Text(
              'Skip',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Next button (only show if not last page)
          if (!isLastPage)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: onNext,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                ),
                icon: Text(
                  nextButtonText,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                label: CustomIconWidget(
                  iconName: 'arrow_forward',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
