import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/extensions.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const SearchScreen({required this.spaceId, super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  String _filterType = 'all'; // all, notes, tasks

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(spaceNotesProvider(spaceId));
    final tasksAsync = ref.watch(spaceTasksProvider(spaceId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: AppTextField(
              controller: _searchController,
              label: 'Search space',
              hint: 'Search notes, tasks, files...',
              prefixIcon: Icons.search,
              suffixIcon: _searchController.text.isNotEmpty
                  ? Icons.clear
                  : null,
              onChanged: (value) => setState(() {}),
              onSuffixTap: () {
                _searchController.clear();
                setState(() {});
              },
            ),
          ),

          if (_searchController.text.isEmpty)
            Expanded(
              child: EmptyState(
                icon: Icons.search,
                title: 'Start searching',
                subtitle: 'Search notes, tasks, and files',
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Chips
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _filterType == 'all',
                          onSelected: (_) =>
                              setState(() => _filterType = 'all'),
                        ),
                        FilterChip(
                          label: const Text('Notes'),
                          selected: _filterType == 'notes',
                          onSelected: (_) =>
                              setState(() => _filterType = 'notes'),
                        ),
                        FilterChip(
                          label: const Text('Tasks'),
                          selected: _filterType == 'tasks',
                          onSelected: (_) =>
                              setState(() => _filterType = 'tasks'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Notes Results
                    if ((_filterType == 'all' || _filterType == 'notes'))
                      notesAsync.when(
                        data: (notes) {
                          final filteredNotes = notes
                              .where((note) =>
                                  note.title
                                      .toLowerCase()
                                      .contains(_searchController.text
                                          .toLowerCase()) ||
                                  note.content
                                      .toLowerCase()
                                      .contains(_searchController.text
                                          .toLowerCase()))
                              .toList();

                          if (filteredNotes.isEmpty && _filterType != 'tasks') {
                            return const SizedBox();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (filteredNotes.isNotEmpty)
                                Text(
                                  'Notes (${filteredNotes.length})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                              const SizedBox(height: 12),
                              ...filteredNotes.map((note) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: GestureDetector(
                                    onTap: () => context.push(
                                      '/spaces/$spaceId/notes/${note.id}',
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.note,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  note.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  note.content,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: Theme.of(
                                                                context)
                                                            .colorScheme
                                                            .outline,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                        loading: () => const SkeletonLoader(),
                        error: (_, __) => const SizedBox(),
                      ),

                    // Tasks Results
                    if ((_filterType == 'all' || _filterType == 'tasks'))
                      tasksAsync.when(
                        data: (tasks) {
                          final filteredTasks = tasks
                              .where((task) =>
                                  task.title
                                      .toLowerCase()
                                      .contains(_searchController.text
                                          .toLowerCase()) ||
                                  task.description
                                      .toLowerCase()
                                      .contains(_searchController.text
                                          .toLowerCase()))
                              .toList();

                          if (filteredTasks.isEmpty && _filterType != 'notes') {
                            return const SizedBox();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (filteredTasks.isNotEmpty)
                                Text(
                                  'Tasks (${filteredTasks.length})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                              const SizedBox(height: 12),
                              ...filteredTasks.map((task) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: GestureDetector(
                                    onTap: () => context.push(
                                      '/spaces/$spaceId/tasks/${task.id}',
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.assignment,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  task.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  task.priority.label,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: Colors.orange,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                        loading: () => const SkeletonLoader(),
                        error: (_, __) => const SizedBox(),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
