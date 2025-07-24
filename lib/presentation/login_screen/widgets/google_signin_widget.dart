import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GoogleSignInWidget extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final bool isLoading;

  const GoogleSignInWidget({
    Key? key,
    required this.onGoogleSignIn,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Google Sign-In Button
        SizedBox(
          height: 6.h,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1.5,
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            child: isLoading
                ? SizedBox(
                    height: 4.w,
                    width: 4.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomImageWidget(
                        imageUrl:
                            'https://developers.google.com/identity/images/g-logo.png',
                        width: 5.w,
                        height: 5.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Continue with Google',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
