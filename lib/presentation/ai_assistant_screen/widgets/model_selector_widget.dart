import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ModelSelectorWidget extends StatelessWidget {
  final String selectedModel;
  final List<String> models;
  final Function(String) onModelChanged;

  const ModelSelectorWidget({
    Key? key,
    required this.selectedModel,
    required this.models,
    required this.onModelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Model',
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
              value: selectedModel,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  onModelChanged(value);
                }
              },
              items: models.map((model) {
                return DropdownMenuItem<String>(
                  value: model,
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'psychology',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _getModelDescription(model),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
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

  String _getModelDescription(String model) {
    switch (model) {
      case 'sonar':
        return 'Fast and efficient';
      case 'sonar-pro':
        return 'Enhanced capabilities';
      case 'sonar-deep-research':
        return 'Deep analysis';
      case 'sonar-reasoning':
        return 'Advanced reasoning';
      case 'sonar-reasoning-pro':
        return 'Premium reasoning';
      default:
        return 'AI model';
    }
  }
}