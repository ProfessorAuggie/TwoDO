import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_exceptions.dart';
import '../../../../data/models/note_model.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class CreateNoteScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const CreateNoteScreen({required this.spaceId, super.key});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  late final TextEditingController _titleController;
  late final quill.QuillController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = quill.QuillController.basic();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createNote() async {
    if (_titleController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Please enter a title');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.watch(currentUserProvider).value;
      if (user == null) throw Exception('User not found');

      final note = NoteModel(
        id: '',
        spaceId: widget.spaceId,
        title: _titleController.text.trim(),
        content: _contentController.document.toPlainText(),
        htmlContent: _contentController.document.toDelta().toJson().toString(),
        createdBy: user.displayName,
        lastEditedBy: user.displayName,
        collaborators: [user.id],
        pinnedBy: [],
        reactions: {},
        comments: [],
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(createNoteControllerProvider.notifier).createNote(note);

      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Note created successfully');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Note'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ElevatedButton.icon(
                      onPressed: _createNote,
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            AppTextField(
              controller: _titleController,
              label: 'Note Title',
              hint: 'Give your note a title...',
              prefixIcon: Icons.subject,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),

            // Rich Text Editor
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Toolbar
                  quill.QuillToolbar.simple(
                    controller: _contentController,
                    configurations: const quill.QuillSimpleToolbarConfigurations(
                      showAlignmentButtons: true,
                      showColorButton: true,
                      showBackgroundColorButton: true,
                      showClearFormat: true,
                      showInlineCode: true,
                      showCodeBlock: true,
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  // Editor
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 300),
                    child: quill.QuillEditor.basic(
                      controller: _contentController,
                      readOnly: _isLoading,
                      configurations: quill.QuillEditorConfigurations(
                        textSelectionThemeData: TextSelectionThemeData(
                          selectionColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          selectionHandleColor:
                              Theme.of(context).colorScheme.primary,
                          cursorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Text
            Text(
              'Notes are auto-saved and synced across all devices.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
