import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onViewToggle;
  final bool isGridView;

  const SearchBarWidget({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onViewToggle,
    required this.isGridView,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _searchController;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color:
                    isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _isSearchFocused
                      ? AppTheme.lightTheme.primaryColor
                      : (isDark
                          ? AppTheme.dividerColorDark
                          : AppTheme.dividerColorLight),
                  width: _isSearchFocused ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 4.w),
                  CustomIconWidget(
                    iconName: 'search',
                    color: isDark
                        ? AppTheme.textMediumEmphasisDark
                        : AppTheme.textMediumEmphasisLight,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                      onTap: () => setState(() => _isSearchFocused = true),
                      onEditingComplete: () =>
                          setState(() => _isSearchFocused = false),
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppTheme.textDisabledDark
                                      : AppTheme.textDisabledLight,
                                ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppTheme.textHighEmphasisDark
                                : AppTheme.textHighEmphasisLight,
                          ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                        setState(() {});
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 3.w),
                        child: CustomIconWidget(
                          iconName: 'clear',
                          color: isDark
                              ? AppTheme.textMediumEmphasisDark
                              : AppTheme.textMediumEmphasisLight,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: widget.onFilterTap,
            child: Container(
              width: 6.h,
              height: 6.h,
              decoration: BoxDecoration(
                color:
                    isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppTheme.dividerColorDark
                      : AppTheme.dividerColorLight,
                  width: 1,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'filter_list',
                  color: isDark
                      ? AppTheme.textHighEmphasisDark
                      : AppTheme.textHighEmphasisLight,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: widget.onViewToggle,
            child: Container(
              width: 6.h,
              height: 6.h,
              decoration: BoxDecoration(
                color:
                    isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppTheme.dividerColorDark
                      : AppTheme.dividerColorLight,
                  width: 1,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: widget.isGridView ? 'view_list' : 'grid_view',
                  color: isDark
                      ? AppTheme.textHighEmphasisDark
                      : AppTheme.textHighEmphasisLight,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
