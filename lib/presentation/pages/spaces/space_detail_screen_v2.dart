import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/extensions.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class SpaceDetailScreenNew extends ConsumerWidget {
  final String spaceId;

  const SpaceDetailScreenNew({required this.spaceId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceAsync = ref.watch(spaceProvider(spaceId));
    final notesAsync = ref.watch(spaceNotesProvider(spaceId));
    final tasksAsync = ref.watch(spaceTasksProvider(spaceId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Space'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
                onTap: () => SnackBarHelper.showInfo(
                  context,
                  'Settings coming soon',
                ),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.person_add, size: 20),
                    SizedBox(width: 12),
                    Text('Invite Members'),
                  ],
                ),
                onTap: () => SnackBarHelper.showInfo(
                  context,
                  'Invite members coming soon',
                ),
              ),
            ],
          ),
        ],
      ),
      body: spaceAsync.when(
        data: (space) {
          if (space == null) {
            return Center(
              child: Text(
                'Space not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Space Header
                Row(
                  children: [
                    if (space.photoUrl != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(space.photoUrl!),
                      )
                    else
                      CircleAvatar(
                        radius: 40,
                        child: Text(space.name.initials),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            space.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${space.members.length} members • ${space.type.label}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (space.description.isNotEmpty) ...[
                  Text(
                    space.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Notes',
                        notesAsync.maybeWhen(
                          data: (notes) => notes.length.toString(),
                          orElse: () => '-',
                        ),
                        Icons.note,
                        () => context.push('/spaces/$spaceId/notes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Tasks',
                        tasksAsync.maybeWhen(
                          data: (tasks) => tasks.length.toString(),
                          orElse: () => '-',
                        ),
                        Icons.assignment,
                        () => context.push('/spaces/$spaceId/tasks'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Files',
                        '0',
                        Icons.folder,
                        () => context.push('/spaces/$spaceId/files'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Recent Notes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push('/spaces/$spaceId/notes'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                notesAsync.when(
                  data: (notes) {
                    if (notes.isEmpty) {
                      return EmptyState(
                        icon: Icons.note_outlined,
                        title: 'No notes yet',
                        subtitle: 'Create your first note',
                        actionLabel: 'Create Note',
                        onAction: () =>
                            context.push('/spaces/$spaceId/notes/create'),
                      );
                    }

                    return Column(
                      children: notes.take(3).map((note) {
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
                                borderRadius: BorderRadius.circular(8),
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
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          note.updatedAt.relativeTime(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
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
                    );
                  },
                  loading: () => const SkeletonLoader(),
                  error: (error, _) => ErrorState(error: error.toString()),
                ),
                const SizedBox(height: 32),

                // Recent Tasks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending Tasks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push('/spaces/$spaceId/tasks'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                tasksAsync.when(
                  data: (tasks) {
                    final pendingTasks = tasks
                        .where((t) => t.status.label != 'completed')
                        .take(3)
                        .toList();

                    if (pendingTasks.isEmpty) {
                      return EmptyState(
                        icon: Icons.assignment_turned_in,
                        title: 'No pending tasks',
                        subtitle: 'Great job! All tasks are done',
                        actionLabel: 'Create Task',
                        onAction: () =>
                            context.push('/spaces/$spaceId/tasks/create'),
                      );
                    }

                    return Column(
                      children: pendingTasks.map((task) {
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
                                borderRadius: BorderRadius.circular(8),
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
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                    );
                  },
                  loading: () => const SkeletonLoader(),
                  error: (error, _) => ErrorState(error: error.toString()),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.refresh(spaceProvider(spaceId)),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
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
