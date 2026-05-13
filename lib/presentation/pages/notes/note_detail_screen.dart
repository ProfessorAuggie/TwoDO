import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/note_model.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteDetailScreen({required this.noteId, super.key});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late quill.QuillController _contentController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = quill.QuillController.basic();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(noteProvider(widget.noteId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
                onTap: () => setState(() => _isEditing = !_isEditing),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 20),
                    SizedBox(width: 12),
                    Text('Delete'),
                  ],
                ),
                onTap: () => _showDeleteDialog(context),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.archive, size: 20),
                    SizedBox(width: 12),
                    Text('Archive'),
                  ],
                ),
                onTap: () => _archiveNote(context),
              ),
            ],
          ),
        ],
      ),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return Center(
              child: Text(
                'Note not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          if (_titleController.text.isEmpty && !_isEditing) {
            _titleController.text = note.title;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Note Content
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      if (_isEditing)
                        AppTextField(
                          controller: _titleController,
                          label: 'Title',
                          enabled: _isEditing,
                        )
                      else
                        Text(
                          note.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${note.createdBy} • ${note.updatedAt.relativeTime()}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Content
                      if (_isEditing)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              quill.QuillToolbar.simple(
                                controller: _contentController,
                                configurations: const quill
                                    .QuillSimpleToolbarConfigurations(
                                  showAlignmentButtons: true,
                                ),
                              ),
                              Divider(
                                height: 0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 300,
                                ),
                                child: quill.QuillEditor.basic(
                                  controller: _contentController,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            note.content,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),

                // Reactions
                if (note.reactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Wrap(
                      spacing: 8,
                      children: note.reactions.entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _toggleReaction(context, note, entry.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${entry.key} ${entry.value.length}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Add Reaction Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    width: 40,
                    child: IconButton.outlined(
                      icon: const Icon(Icons.add_reaction),
                      onPressed: () => _showEmojiPicker(context, note),
                      tooltip: 'Add reaction',
                    ),
                  ),
                ),

                const Divider(height: 32),

                // Comments Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comments (${note.comments.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // Comments List
                      ...note.comments
                          .map((comment) => _buildComment(context, comment))
                          .toList(),

                      const SizedBox(height: 16),

                      // Add Comment
                      AppTextField(
                        controller: _commentController,
                        label: 'Add a comment',
                        hint: 'Share your thoughts...',
                        maxLines: 3,
                        minLines: 1,
                        suffixIcon: Icons.send,
                        onSuffixTap: () => _addComment(context, note),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.refresh(noteProvider(widget.noteId)),
        ),
      ),
    );
  }

  Widget _buildComment(BuildContext context, NoteComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: comment.photoUrl != null
                    ? NetworkImage(comment.photoUrl!)
                    : null,
                child: comment.photoUrl == null
                    ? Text(comment.displayName.initials)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.displayName,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      comment.createdAt.relativeTime(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              comment.content,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _addComment(BuildContext context, NoteModel note) {
    if (_commentController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Comment cannot be empty');
      return;
    }

    // TODO: Implement add comment via provider
    _commentController.clear();
    SnackBarHelper.showSuccess(context, 'Comment added');
  }

  void _toggleReaction(
    BuildContext context,
    NoteModel note,
    String emoji,
  ) {
    // TODO: Implement reaction toggle via provider
    SnackBarHelper.showSuccess(context, 'Reaction updated');
  }

  void _showEmojiPicker(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reaction'),
        content: Wrap(
          spacing: 8,
          children: ['👍', '❤️', '😂', '🔥', '😍', '🎉', '😢', '😡']
              .map(
                (emoji) => GestureDetector(
                  onTap: () {
                    _toggleReaction(context, note, emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete via provider
              Navigator.pop(context);
              context.pop();
              SnackBarHelper.showSuccess(context, 'Note deleted');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _archiveNote(BuildContext context) {
    // TODO: Implement archive via provider
    SnackBarHelper.showSuccess(context, 'Note archived');
  }
}
