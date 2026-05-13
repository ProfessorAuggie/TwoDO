import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/task_model.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const CreateTaskScreen({required this.spaceId, super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  String? _assigneeId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (_titleController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Please enter a task title');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.watch(currentUserProvider).value;
      if (user == null) throw Exception('User not found');

      final task = TaskModel(
        id: '',
        spaceId: widget.spaceId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: TaskStatus.pending,
        priority: _priority,
        assigneeId: _assigneeId,
        assigneeName: null, // Will be fetched later
        assigneePhotoUrl: null,
        dueDate: _dueDate,
        createdBy: user.displayName,
        lastEditedBy: user.displayName,
        collaborators: [user.id],
        pinnedBy: [],
        reactions: {},
        comments: [],
        attachments: [],
        checklist: [],
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(createTaskControllerProvider.notifier).createTask(task);

      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Task created successfully');
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

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final space = ref.watch(spaceProvider(widget.spaceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
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
                      onPressed: _createTask,
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
            // Title
            AppTextField(
              controller: _titleController,
              label: 'Task Title',
              hint: 'What needs to be done?',
              prefixIcon: Icons.assignment,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 20),

            // Description
            AppTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              hint: 'Add more details...',
              maxLines: 3,
              minLines: 1,
              prefixIcon: Icons.description,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 20),

            // Priority
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: TaskPriority.values
                  .map(
                    (priority) => ChoiceChip(
                      label: Text(priority.label),
                      selected: _priority == priority,
                      onSelected: _isLoading
                          ? null
                          : (selected) =>
                              setState(() => _priority = priority),
                      avatar: _priority == priority
                          ? const Icon(Icons.check, size: 16)
                          : null,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Due Date
            Text(
              'Due Date (Optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isLoading ? null : _selectDueDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dueDate?.taskDueDate ?? 'Select a date',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (_dueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dueDate = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Assignee
            Text(
              'Assign To (Optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            space.when(
              data: (spaceData) {
                if (spaceData == null) return const SizedBox();

                return SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: spaceData.members.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final member = spaceData.members[index];
                      final isSelected = _assigneeId == member.userId;

                      return GestureDetector(
                        onTap: () => setState(
                          () => _assigneeId = isSelected ? null : member.userId,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: CircleAvatar(
                            radius: 23,
                            child: Text(member.userId.initials),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () =>
                  const SkeletonLoader(),
              error: (_, __) =>
                  const SizedBox(),
            ),

            const SizedBox(height: 32),

            // Info
            Text(
              'Tasks are shared with space members and sync in real-time.',
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
