import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommandSelectorWidget extends StatelessWidget {
  final String selectedCommand;
  final Map<String, String> commands;
  final Function(String) onCommandChanged;

  const CommandSelectorWidget({
    Key? key,
    required this.selectedCommand,
    required this.commands,
    required this.onCommandChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Command',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCommand,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  onCommandChanged(value);
                }
              },
              items: commands.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: _getCommandIcon(entry.key),
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        entry.value,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _getCommandIcon(String command) {
    switch (command) {
      case 'summarize':
        return 'summarize';
      case 'grammar':
        return 'spellcheck';
      case 'rewrite':
        return 'edit';
      case 'ideas':
        return 'lightbulb';
      default:
        return 'auto_awesome';
    }
  }
}