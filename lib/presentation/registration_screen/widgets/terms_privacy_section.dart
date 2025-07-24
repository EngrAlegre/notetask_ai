import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TermsPrivacySection extends StatefulWidget {
  final bool isAccepted;
  final ValueChanged<bool> onChanged;

  const TermsPrivacySection({
    Key? key,
    required this.isAccepted,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<TermsPrivacySection> createState() => _TermsPrivacySectionState();
}

class _TermsPrivacySectionState extends State<TermsPrivacySection> {
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Terms of Service',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Text(
              '''By using NoteTask AI, you agree to the following terms:

1. Account Security: You are responsible for maintaining the confidentiality of your account credentials.

2. Data Usage: We collect and process your notes and tasks to provide AI-powered features and synchronization across devices.

3. AI Processing: Your text content may be processed by AI services to provide summarization, grammar correction, and other enhancement features.

4. Offline Storage: Data is stored locally on your device and synchronized when online.

5. Service Availability: We strive to maintain service availability but cannot guarantee uninterrupted access.

6. Content Ownership: You retain ownership of your content. We do not claim rights to your notes and tasks.

7. Privacy: Your data is protected according to our Privacy Policy.

8. Prohibited Use: Do not use the service for illegal activities or to store harmful content.

9. Termination: We reserve the right to terminate accounts that violate these terms.

10. Updates: These terms may be updated periodically with notice to users.''',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Text(
              '''NoteTask AI Privacy Policy:

Data Collection:
- Account information (name, email)
- Notes and tasks content
- Usage analytics
- Device information

Data Usage:
- Provide core app functionality
- AI text processing and enhancement
- Cross-device synchronization
- Service improvement

Data Storage:
- Local device storage for offline access
- Encrypted cloud storage for synchronization
- AI processing through secure APIs

Data Sharing:
- We do not sell your personal data
- AI processing partners bound by strict agreements
- Anonymous analytics for service improvement

Your Rights:
- Access your data
- Delete your account and data
- Export your content
- Opt-out of analytics

Security:
- End-to-end encryption for sensitive data
- Regular security audits
- Secure authentication methods

Contact:
For privacy concerns, contact: privacy@notetask.ai

Last updated: July 16, 2025''',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 2.4.h,
              width: 2.4.h,
              child: Checkbox(
                value: widget.isAccepted,
                onChanged: (value) => widget.onChanged(value ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                  children: [
                    TextSpan(text: 'I agree to the '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: _showTermsDialog,
                        child: Text(
                          'Terms of Service',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                    TextSpan(text: ' and '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: _showPrivacyDialog,
                        child: Text(
                          'Privacy Policy',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
