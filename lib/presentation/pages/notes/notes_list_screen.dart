import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const NotesListScreen({required this.spaceId, super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  late TextEditingController _searchController;
  late TextEditingController _searchDebounceController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchDebounceController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(spaceNotesProvider(widget.spaceId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: AppTextField(
              controller: _searchController,
              label: 'Search notes',
              hint: 'Search by title or content...',
              prefixIcon: Icons.search,
              suffixIcon: _searchController.text.isNotEmpty
                  ? Icons.clear
                  : null,
              onChanged: (value) {
                setState(() {});
              },
              onSuffixTap: () {
                _searchController.clear();
                setState(() {});
              },
            ),
          ),
          // Notes List
          Expanded(
            child: notes.when(
              data: (allNotes) {
                final filteredNotes = _searchController.text.isEmpty
                    ? allNotes
                    : allNotes
                        .where((note) =>
                            note.title.toLowerCase().contains(
                                _searchController.text.toLowerCase()) ||
                            note.content
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase()))
                        .toList();

                if (filteredNotes.isEmpty) {
                  return EmptyState(
                    icon: Icons.note_outlined,
                    title: _searchController.text.isEmpty
                        ? 'No notes yet'
                        : 'No matching notes',
                    subtitle: _searchController.text.isEmpty
                        ? 'Create your first note to get started'
                        : 'Try different search terms',
                    actionLabel: _searchController.text.isEmpty ? 'Create Note' : null,
                    onAction: _searchController.text.isEmpty
                        ? () => context.push('/spaces/${widget.spaceId}/notes/create')
                        : null,
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: 8,
                  ),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return NoteCard(
                      note: note,
                      onTap: () => context.push(
                        '/spaces/${widget.spaceId}/notes/${note.id}',
                      ),
                    );
                  },
                );
              },
              loading: () => const SkeletonLoader(),
              error: (error, _) => ErrorState(
                error: error.toString(),
                onRetry: () => ref.refresh(spaceNotesProvider(widget.spaceId)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/spaces/${widget.spaceId}/notes/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}

class NoteCard extends ConsumerWidget {
  final dynamic note;
  final VoidCallback onTap;

  const NoteCard({required this.note, required this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.content,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.note,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${note.createdBy} • ${note.updatedAt.relativeTime()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (note.reactions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${note.reactions.keys.join()} ${note.reactions.values.fold<int>(0, (sum, list) => sum + list.length)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
