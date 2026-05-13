import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/extensions.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class ActivityFeedScreen extends ConsumerWidget {
  final String spaceId;

  const ActivityFeedScreen({required this.spaceId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceAsync = ref.watch(spaceProvider(spaceId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
        elevation: 0,
      ),
      body: spaceAsync.when(
        data: (space) {
          if (space == null) {
            return const Center(child: Text('Space not found'));
          }

          // Mock activity data
          final activities = [
            {
              'user': 'You',
              'action': 'created the space',
              'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
              'icon': Icons.create,
              'color': Colors.blue,
            },
            {
              'user': 'You',
              'action': 'added a note',
              'timestamp':
                  DateTime.now().subtract(const Duration(minutes: 30)),
              'icon': Icons.note,
              'color': Colors.green,
            },
            {
              'user': 'You',
              'action': 'created a task',
              'timestamp':
                  DateTime.now().subtract(const Duration(minutes: 15)),
              'icon': Icons.assignment,
              'color': Colors.orange,
            },
          ];

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activities.isEmpty)
                  EmptyState(
                    icon: Icons.activity_icon,
                    title: 'No activities yet',
                    subtitle: 'Activities will appear here',
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      final timestamp = activity['timestamp'] as DateTime;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (activity['color'] as Color)
                                    .withOpacity(0.2),
                              ),
                              child: Icon(
                                activity['icon'] as IconData,
                                size: 20,
                                color: activity['color'] as Color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      children: [
                                        TextSpan(
                                          text: '${activity['user']} ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        TextSpan(
                                          text: activity['action'],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timestamp.relativeTime(),
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
                      );
                    },
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
}
