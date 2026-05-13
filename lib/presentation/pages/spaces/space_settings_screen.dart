import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/extensions.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class SpaceSettingsScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const SpaceSettingsScreen({required this.spaceId, super.key});

  @override
  ConsumerState<SpaceSettingsScreen> createState() => _SpaceSettingsScreenState();
}

class _SpaceSettingsScreenState extends ConsumerState<SpaceSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _inviteEmailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _inviteEmailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _inviteEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaceAsync = ref.watch(spaceProvider(spaceId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Settings'),
        elevation: 0,
      ),
      body: spaceAsync.when(
        data: (space) {
          if (space == null) {
            return const Center(child: Text('Space not found'));
          }

          if (_nameController.text.isEmpty) {
            _nameController.text = space.name;
            _descriptionController.text = space.description;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Settings
                Text(
                  'Basic Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: 'Space Name',
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                  minLines: 1,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveSettings(context),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 40),

                // Members Section
                Text(
                  'Members (${space.members.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...space.members.map(
                  (member) => _buildMemberItem(context, space, member),
                ),
                const SizedBox(height: 24),

                // Invite Member
                Text(
                  'Invite Member',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _inviteEmailController,
                        label: 'Email address',
                        hint: 'member@example.com',
                        prefixIcon: Icons.email,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.send),
                      onPressed: () => _inviteMember(context),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Danger Zone
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showDeleteDialog(context, space),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete Space'),
                        ),
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
          onRetry: () => ref.refresh(spaceProvider(spaceId)),
        ),
      ),
    );
  }

  Widget _buildMemberItem(
    BuildContext context,
    SpaceModel space,
    SpaceMember member,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(member.userId.initials),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.userId,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Joined ${member.joinedAt.relativeTime()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(member.role).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                member.role.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getRoleColor(member.role),
                    ),
              ),
            ),
            const SizedBox(width: 8),
            if (space.ownerId != member.userId)
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 12),
                        Text('Change Role'),
                      ],
                    ),
                    onTap: () => SnackBarHelper.showInfo(
                      context,
                      'Role change coming soon',
                    ),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Remove',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    onTap: () => _removeMember(context, member),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.editor:
        return Colors.orange;
      case UserRole.viewer:
        return Colors.blue;
      case UserRole.member:
        return Colors.green;
    }
  }

  void _saveSettings(BuildContext context) {
    setState(() => _isSaving = true);

    try {
      // TODO: Implement via provider
      SnackBarHelper.showSuccess(context, 'Settings saved');
    } catch (e) {
      SnackBarHelper.showError(context, e.toString());
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _inviteMember(BuildContext context) {
    if (_inviteEmailController.text.isEmpty) {
      SnackBarHelper.showError(context, 'Please enter an email address');
      return;
    }

    // TODO: Implement via provider
    _inviteEmailController.clear();
    SnackBarHelper.showSuccess(context, 'Invitation sent');
  }

  void _removeMember(BuildContext context, SpaceMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.userId} from this space?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement via provider
              Navigator.pop(context);
              SnackBarHelper.showSuccess(context, 'Member removed');
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SpaceModel space) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Space'),
        content: const Text(
          'Are you sure you want to delete this space? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement via provider
              Navigator.pop(context);
              context.go('/home');
              SnackBarHelper.showSuccess(context, 'Space deleted');
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
}
