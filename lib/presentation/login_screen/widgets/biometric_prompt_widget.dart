import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricPromptWidget extends StatelessWidget {
  final VoidCallback onBiometricAuth;
  final bool isAvailable;

  const BiometricPromptWidget({
    Key? key,
    required this.onBiometricAuth,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 2.h),
      child: Column(
        children: [
          Text(
            'Or use biometric authentication',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),

          SizedBox(height: 2.h),

          // Biometric Button
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBiometricAuth,
                borderRadius: BorderRadius.circular(6.w),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'fingerprint',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
