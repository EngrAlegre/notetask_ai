import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FormattingBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> note;
  final Function(Map<String, dynamic>) onUpdate;

  const FormattingBottomSheetWidget({
    Key? key,
    required this.note,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<FormattingBottomSheetWidget> createState() =>
      _FormattingBottomSheetWidgetState();
}

class _FormattingBottomSheetWidgetState
    extends State<FormattingBottomSheetWidget> {
  late Map<String, dynamic> _localNote;

  final List<Map<String, dynamic>> _fontFamilies = [
    {'value': 'Inter', 'label': 'Inter (Default)'},
    {'value': 'Roboto', 'label': 'Roboto'},
    {'value': 'Arial', 'label': 'Arial'},
    {'value': 'Times New Roman', 'label': 'Times New Roman'},
    {'value': 'Georgia', 'label': 'Georgia'},
    {'value': 'Courier New', 'label': 'Courier New'},
  ];

  final List<Map<String, dynamic>> _fontSizes = [
    {'value': 'small', 'label': 'Small'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'large', 'label': 'Large'},
  ];

  final List<Map<String, dynamic>> _textColors = [
    {'value': '#000000', 'label': 'Default', 'color': Colors.black},
    {'value': '#6B7280', 'label': 'Muted', 'color': Colors.grey},
    {'value': '#DC2626', 'label': 'Red', 'color': Colors.red},
    {'value': '#EA580C', 'label': 'Orange', 'color': Colors.orange},
    {'value': '#65A30D', 'label': 'Green', 'color': Colors.green},
    {'value': '#0284C7', 'label': 'Blue', 'color': Colors.blue},
    {'value': '#7C3AED', 'label': 'Purple', 'color': Colors.purple},
  ];

  final List<Map<String, dynamic>> _backgroundColors = [
    {'value': 'white', 'label': 'Default', 'color': Colors.white},
    {'value': 'yellow', 'label': 'Yellow', 'color': Color(0xFFFEF3C7)},
    {'value': 'blue', 'label': 'Blue', 'color': Color(0xFFDBEAFE)},
    {'value': 'green', 'label': 'Green', 'color': Color(0xFFD1FAE5)},
    {'value': 'pink', 'label': 'Pink', 'color': Color(0xFFFCE7F3)},
    {'value': 'purple', 'label': 'Purple', 'color': Color(0xFFF3E8FF)},
    {'value': 'orange', 'label': 'Orange', 'color': Color(0xFFFED7AA)},
  ];

  @override
  void initState() {
    super.initState();
    _localNote = Map<String, dynamic>.from(widget.note);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Formatting Options',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.onUpdate(_localNote);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font Family
                  _buildSection(
                    'Font Family',
                    _buildFontFamilySelector(),
                  ),

                  SizedBox(height: 3.h),

                  // Font Size
                  _buildSection(
                    'Font Size',
                    _buildFontSizeSelector(),
                  ),

                  SizedBox(height: 3.h),

                  // Text Color
                  _buildSection(
                    'Text Color',
                    _buildColorSelector(_textColors, 'text_color'),
                  ),

                  SizedBox(height: 3.h),

                  // Background Color
                  _buildSection(
                    'Background Color',
                    _buildColorSelector(_backgroundColors, 'background_color'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        content,
      ],
    );
  }

  Widget _buildFontFamilySelector() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _fontFamilies.map((font) {
        final isSelected = _localNote['font_family'] == font['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _localNote['font_family'] = font['value'];
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              font['label'],
              style: TextStyle(
                fontFamily: font['value'],
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSelector() {
    return Row(
      children: _fontSizes.map((size) {
        final isSelected = _localNote['font_size'] == size['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _localNote['font_size'] = size['value'];
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                size['label'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector(List<Map<String, dynamic>> colors, String key) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: colors.map((colorOption) {
        final isSelected = key == 'text_color'
            ? _localNote[key] == colorOption['value']
            : _localNote[key] == colorOption['value'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _localNote[key] = colorOption['value'];
            });
          },
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: colorOption['color'],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Center(
                    child: CustomIconWidget(
                      iconName: 'check',
                      color: key == 'text_color' && colorOption['value'] == '#000000'
                          ? Colors.white
                          : Colors.black,
                      size: 4.w,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}