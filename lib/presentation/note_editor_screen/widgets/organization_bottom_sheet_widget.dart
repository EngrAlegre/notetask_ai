import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrganizationBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> note;
  final Function(Map<String, dynamic>) onUpdate;

  const OrganizationBottomSheetWidget({
    Key? key,
    required this.note,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<OrganizationBottomSheetWidget> createState() =>
      _OrganizationBottomSheetWidgetState();
}

class _OrganizationBottomSheetWidgetState
    extends State<OrganizationBottomSheetWidget> {
  late Map<String, dynamic> _localNote;
  final TextEditingController _tagController = TextEditingController();

  final List<String> _folders = [
    'personal',
    'work',
    'ideas',
    'projects',
    'archive',
  ];

  @override
  void initState() {
    super.initState();
    _localNote = Map<String, dynamic>.from(widget.note);
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
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
                  'Organization',
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
                  // Pin Toggle
                  _buildToggleSection(
                    'Pin Note',
                    'Keep this note at the top',
                    'push_pin',
                    _localNote['is_pinned'] ?? false,
                    (value) => setState(() => _localNote['is_pinned'] = value),
                  ),

                  SizedBox(height: 3.h),

                  // Folder Selection
                  _buildSection(
                    'Folder',
                    _buildFolderSelector(),
                  ),

                  SizedBox(height: 3.h),

                  // Tags
                  _buildSection(
                    'Tags',
                    _buildTagsSection(),
                  ),

                  SizedBox(height: 3.h),

                  // Archive Toggle
                  _buildToggleSection(
                    'Archive Note',
                    'Move to archive folder',
                    'archive',
                    _localNote['is_archived'] ?? false,
                    (value) => setState(() => _localNote['is_archived'] = value),
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

  Widget _buildToggleSection(
    String title,
    String description,
    String iconName,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall,
                ),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSelector() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _folders.map((folder) {
        final isSelected = _localNote['folder'] == folder;
        return GestureDetector(
          onTap: () {
            setState(() {
              _localNote['folder'] = folder;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              folder.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagsSection() {
    final tags = List<String>.from(_localNote['tags'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Tag Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: _addTag,
              ),
            ),
            SizedBox(width: 2.w),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Current Tags
        if (tags.isNotEmpty)
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: AppTheme.lightTheme.textTheme.labelMedium,
                    ),
                    SizedBox(width: 1.w),
                    GestureDetector(
                      onTap: () => _removeTag(tag),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.grey.shade600,
                        size: 3.w,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addTag(String tag) {
    if (tag.trim().isEmpty) return;

    final tags = List<String>.from(_localNote['tags'] ?? []);
    if (!tags.contains(tag.trim())) {
      tags.add(tag.trim());
      setState(() {
        _localNote['tags'] = tags;
      });
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    final tags = List<String>.from(_localNote['tags'] ?? []);
    tags.remove(tag);
    setState(() {
      _localNote['tags'] = tags;
    });
  }
}