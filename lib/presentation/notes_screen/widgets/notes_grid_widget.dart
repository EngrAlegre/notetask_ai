import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../overview_screen/widgets/empty_state_widget.dart';
import './note_card_widget.dart';

class NotesGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> notes;
  final bool isGridView;
  final Set<String> selectedNotes;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;
  final Function(String) onNoteArchive;
  final Function(String) onNoteDelete;
  final VoidCallback onRefresh;
  final ScrollController scrollController;

  const NotesGridWidget({
    Key? key,
    required this.notes,
    required this.isGridView,
    required this.selectedNotes,
    required this.onNoteTap,
    required this.onNoteLongPress,
    required this.onNoteArchive,
    required this.onNoteDelete,
    required this.onRefresh,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return EmptyStateWidget(
        title: 'No notes yet',
        description: 'Create your first note to get started',
        iconName: 'note_add',
        buttonText: 'Create Note',
        onButtonPressed: () {},
      );
    }

    return RefreshIndicator(
        onRefresh: () async {
          onRefresh();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: isGridView ? _buildGridView() : _buildListView());
  }

  Widget _buildGridView() {
    return GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.all(2.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.w,
            childAspectRatio: 0.85),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          final noteId = note['id'] as String;
          final isSelected = selectedNotes.contains(noteId);

          return NoteCardWidget(
              note: note,
              isSelected: isSelected,
              onTap: () => onNoteTap(noteId),
              onLongPress: () => onNoteLongPress(noteId),
              onArchive: () => onNoteArchive(noteId),
              onDelete: () => onNoteDelete(noteId));
        });
  }

  Widget _buildListView() {
    return ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          final noteId = note['id'] as String;
          final isSelected = selectedNotes.contains(noteId);

          return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: NoteCardWidget(
                  note: note,
                  isSelected: isSelected,
                  isListView: true,
                  onTap: () => onNoteTap(noteId),
                  onLongPress: () => onNoteLongPress(noteId),
                  onArchive: () => onNoteArchive(noteId),
                  onDelete: () => onNoteDelete(noteId)));
        });
  }
}
