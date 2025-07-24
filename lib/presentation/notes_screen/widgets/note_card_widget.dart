import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NoteCardWidget extends StatelessWidget {
  final Map<String, dynamic> note;
  final bool isSelected;
  final bool isListView;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const NoteCardWidget({
    Key? key,
    required this.note,
    this.isSelected = false,
    this.isListView = false,
    required this.onTap,
    required this.onLongPress,
    required this.onArchive,
    required this.onDelete,
  }) : super(key: key);

  Color _getNoteBackgroundColor() {
    final colorName = note['background_color'] as String? ?? 'yellow';
    switch (colorName) {
      case 'yellow':
        return const Color(0xFFFFEB3B);
      case 'green':
        return const Color(0xFFE8F5E8);
      case 'blue':
        return const Color(0xFFE1F5FE);
      case 'pink':
        return const Color(0xFFFCE4EC);
      case 'purple':
        return const Color(0xFFF3E5F5);
      case 'orange':
        return const Color(0xFFFFF3E0);
      case 'white':
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = _getNoteBackgroundColor();
    final title = note['title'] as String? ?? '';
    final content = note['content'] as String? ?? '';
    final isPinned = note['is_pinned'] as bool? ?? false;
    final isArchived = note['is_archived'] as bool? ?? false;
    final tags = note['tags'] as List<dynamic>? ?? [];
    final createdAt = DateTime.parse(note['created_at'] as String);

    return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
            decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(width: 2)
                    : Border.all(color: Colors.grey.shade300, width: 0.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ]),
            child: Stack(children: [
              Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and pin indicator
                        Row(children: [
                          Expanded(
                              child: Text(title.isEmpty ? 'Untitled' : title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87),
                                  maxLines: isListView ? 2 : 1,
                                  overflow: TextOverflow.ellipsis)),
                          if (isPinned) ...[
                            SizedBox(width: 2.w),
                            CustomIconWidget(iconName: 'push_pin', size: 16),
                          ],
                        ]),
                        SizedBox(height: 2.h),

                        // Content
                        Expanded(
                            child: Text(content,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                        height: 1.4),
                                maxLines: isListView ? 3 : 6,
                                overflow: TextOverflow.ellipsis)),

                        SizedBox(height: 2.h),

                        // Tags
                        if (tags.isNotEmpty)
                          Wrap(
                              spacing: 1.w,
                              runSpacing: 0.5.h,
                              children: tags
                                  .take(3)
                                  .map((tag) => Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(tag.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(fontSize: 10.sp))))
                                  .toList()),

                        SizedBox(height: 1.h),

                        // Date
                        Text(_formatDate(createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    fontSize: 9.sp)),
                      ])),

              // Selection indicator
              if (isSelected)
                Positioned(
                    top: 2.w,
                    right: 2.w,
                    child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: CustomIconWidget(
                            iconName: 'check', color: Colors.white, size: 16))),

              // Archive indicator
              if (isArchived)
                Positioned(
                    top: 2.w,
                    left: 2.w,
                    child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4)),
                        child: CustomIconWidget(
                            iconName: 'archive',
                            color: Colors.white,
                            size: 12))),
            ])));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}