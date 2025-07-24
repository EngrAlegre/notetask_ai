import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FloatingActionMenuWidget extends StatefulWidget {
  final VoidCallback onTextNote;
  final VoidCallback onVoiceNote;
  final VoidCallback onAINote;

  const FloatingActionMenuWidget({
    Key? key,
    required this.onTextNote,
    required this.onVoiceNote,
    required this.onAINote,
  }) : super(key: key);

  @override
  State<FloatingActionMenuWidget> createState() =>
      _FloatingActionMenuWidgetState();
}

class _FloatingActionMenuWidgetState extends State<FloatingActionMenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              width: 100.w,
              height: 100.h,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Opacity(
                    opacity: _animation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildMenuOption(
                          'AI Generated Note',
                          'auto_awesome',
                          AppTheme.successLight,
                          widget.onAINote,
                        ),
                        SizedBox(height: 2.h),
                        _buildMenuOption(
                          'Voice Note',
                          'mic',
                          AppTheme.secondaryLight,
                          widget.onVoiceNote,
                        ),
                        SizedBox(height: 2.h),
                        _buildMenuOption(
                          'Text Note',
                          'edit',
                          AppTheme.lightTheme.primaryColor,
                          widget.onTextNote,
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                );
              },
            ),
            FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: AppTheme.lightTheme.primaryColor,
              child: AnimatedRotation(
                turns: _isExpanded ? 0.125 : 0,
                duration: const Duration(milliseconds: 300),
                child: CustomIconWidget(
                  iconName: _isExpanded ? 'close' : 'add',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuOption(
      String label, String iconName, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        _toggleMenu();
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHighEmphasisLight,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          SizedBox(width: 3.w),
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
