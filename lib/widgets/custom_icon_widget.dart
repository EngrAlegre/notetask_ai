import 'package:flutter/material.dart';

/// A custom widget for displaying icons with consistent styling
class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double? size;

  const CustomIconWidget({
    Key? key,
    required this.iconName,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(iconName),
      color: color ?? Theme.of(context).iconTheme.color,
      size: size ?? 24.0,
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      // Navigation icons
      case 'home':
      case 'dashboard':
        return Icons.dashboard;
      case 'note':
      case 'note_add':
        return Icons.note_add;
      case 'task_alt':
      case 'add_task':
        return Icons.add_task;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'search':
        return Icons.search;
      case 'menu':
        return Icons.menu;
      case 'more_vert':
        return Icons.more_vert;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'settings':
        return Icons.settings;
      
      // Action icons
      case 'add':
        return Icons.add;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'archive':
        return Icons.archive;
      case 'unarchive':
        return Icons.unarchive;
      case 'push_pin':
        return Icons.push_pin;
      case 'share':
        return Icons.share;
      case 'copy':
      case 'content_copy':
        return Icons.content_copy;
      case 'save':
        return Icons.save;
      case 'refresh':
        return Icons.refresh;
      case 'sync':
        return Icons.sync;
      
      // Navigation arrows
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'arrow_upward':
        return Icons.arrow_upward;
      case 'arrow_downward':
        return Icons.arrow_downward;
      case 'expand_more':
        return Icons.expand_more;
      case 'expand_less':
        return Icons.expand_less;
      
      // Status icons
      case 'check':
      case 'check_circle':
        return Icons.check_circle;
      case 'close':
        return Icons.close;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'help':
        return Icons.help;
      
      // Media icons
      case 'mic':
        return Icons.mic;
      case 'mic_off':
        return Icons.mic_off;
      case 'volume_up':
        return Icons.volume_up;
      case 'volume_off':
        return Icons.volume_off;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'stop':
        return Icons.stop;
      
      // Authentication icons
      case 'person':
        return Icons.person;
      case 'email':
        return Icons.email;
      case 'lock':
        return Icons.lock;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'fingerprint':
        return Icons.fingerprint;
      case 'face':
        return Icons.face;
      case 'logout':
        return Icons.logout;
      
      // Organization icons
      case 'folder':
      case 'folder_open':
        return Icons.folder_open;
      case 'label':
        return Icons.label;
      case 'tag':
        return Icons.local_offer;
      case 'category':
        return Icons.category;
      case 'filter_list':
        return Icons.filter_list;
      case 'sort':
        return Icons.sort;
      
      // Time and scheduling
      case 'schedule':
      case 'access_time':
        return Icons.access_time;
      case 'today':
        return Icons.today;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'event':
        return Icons.event;
      case 'alarm':
      case 'notifications':
        return Icons.notifications;
      case 'notifications_off':
        return Icons.notifications_off;
      
      // Formatting icons
      case 'format_paint':
        return Icons.format_paint;
      case 'format_bold':
        return Icons.format_bold;
      case 'format_italic':
        return Icons.format_italic;
      case 'format_underlined':
        return Icons.format_underlined;
      case 'format_size':
        return Icons.format_size;
      case 'format_color_text':
        return Icons.format_color_text;
      case 'format_color_fill':
        return Icons.format_color_fill;
      case 'spellcheck':
        return Icons.spellcheck;
      
      // View options
      case 'view_list':
        return Icons.view_list;
      case 'grid_view':
        return Icons.grid_view;
      case 'view_module':
        return Icons.view_module;
      case 'fullscreen':
        return Icons.fullscreen;
      case 'fullscreen_exit':
        return Icons.fullscreen_exit;
      
      // Connectivity
      case 'wifi':
        return Icons.wifi;
      case 'wifi_off':
      case 'cloud_off':
        return Icons.cloud_off;
      case 'cloud_done':
        return Icons.cloud_done;
      case 'sync_problem':
        return Icons.sync_problem;
      
      // AI and smart features
      case 'psychology':
        return Icons.psychology;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'summarize':
        return Icons.summarize;
      case 'translate':
        return Icons.translate;
      
      // Selection and interaction
      case 'select_all':
        return Icons.select_all;
      case 'clear':
      case 'clear_all':
        return Icons.clear_all;
      case 'done':
        return Icons.done;
      case 'done_all':
        return Icons.done_all;
      
      // Task specific
      case 'pending_actions':
        return Icons.pending_actions;
      case 'assignment':
        return Icons.assignment;
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      case 'checklist':
        return Icons.checklist;
      
      // Priority indicators
      case 'priority_high':
        return Icons.priority_high;
      case 'flag':
        return Icons.flag;
      case 'star':
        return Icons.star;
      case 'star_border':
        return Icons.star_border;
      
      // Theme and appearance
      case 'dark_mode':
        return Icons.dark_mode;
      case 'light_mode':
        return Icons.light_mode;
      case 'palette':
        return Icons.palette;
      case 'color_lens':
        return Icons.color_lens;
      
      // Work and productivity
      case 'work':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'school':
        return Icons.school;
      case 'home_work':
        return Icons.home;
      
      default:
        return Icons.help_outline;
    }
  }
}