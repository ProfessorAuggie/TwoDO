import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:twodo/presentation/providers/auth_providers.dart';
import 'package:twodo/presentation/providers/space_providers.dart';
import 'package:twodo/presentation/widgets/common/app_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSpaces = ref.watch(userSpacesProvider);
    final currentUser = ref.watch(currentUserStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoदो'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.pushNamed('profile'),
          ),
        ],
      ),
      body: userSpaces.when(
        data: (spaces) => spaces.isEmpty
            ? EmptyState(
                title: 'No Spaces Yet',
                subtitle: 'Create your first collaborative space',
                icon: Icons.workspaces_outline,
                action: PrimaryButton(
                  label: 'Create Space',
                  onPressed: () => context.pushNamed('createSpace'),
                  width: 200,
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User Greeting
                  currentUser.when(
                    data: (user) => Text(
                      'Welcome back, ${user?.displayName}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    loading: () => const SkeletonLoader(width: 200, height: 24),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // Create Space Button
                  PrimaryButton(
                    label: '+ Create New Space',
                    onPressed: () => context.pushNamed('createSpace'),
                  ),

                  const SizedBox(height: 32),

                  // Spaces List
                  Text(
                    'Your Spaces',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...spaces.map((space) => AppCard(
                    onTap: () => context.pushNamed('space', pathParameters: {'spaceId': space.id}),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.workspaces,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    space.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${space.members.length} members',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ],
                    ),
                  )),
                ],
              ),
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(3, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SkeletonLoader(width: double.infinity, height: 100),
          )),
        ),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.refresh(userSpacesProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('createSpace'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
