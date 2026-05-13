import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../data/models/task_model.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({required this.taskId, super.key});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _commentController;
  late TextEditingController _checklistItemController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _commentController = TextEditingController();
    _checklistItemController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    _checklistItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskProvider(widget.taskId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
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
                onTap: () => _archiveTask(context),
              ),
            ],
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) {
          if (task == null) {
            return Center(
              child: Text(
                'Task not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          if (_titleController.text.isEmpty && !_isEditing) {
            _titleController.text = task.title;
            _descriptionController.text = task.description;
          }

          final progress = task.checklist.isEmpty
              ? 0.0
              : task.checklist.where((item) => item.isCompleted).length /
                  task.checklist.length;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Button
                    GestureDetector(
                      onTap: () => _toggleTaskStatus(context, task),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: task.status == TaskStatus.completed ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: task.status == TaskStatus.completed
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        child: task.status == TaskStatus.completed
                            ? Icon(
                                Icons.check,
                                color:
                                    Theme.of(context).colorScheme.onPrimary,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title & Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isEditing)
                            AppTextField(
                              controller: _titleController,
                              label: 'Title',
                              enabled: _isEditing,
                            )
                          else
                            Text(
                              task.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    decoration: task.status ==
                                            TaskStatus.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  task.status.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: _getStatusColor(task.status),
                                      ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task.priority)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  task.priority.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color:
                                            _getPriorityColor(task.priority),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Meta Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (task.dueDate != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: task.isOverdue
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Due: ${task.dueDate!.taskDueDate}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: task.isOverdue
                                        ? Colors.red
                                        : null,
                                  ),
                            ),
                            if (task.isOverdue)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Overdue',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.red),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Assigned: ${task.assigneeName ?? 'Unassigned'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                if (task.description.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 4,
                      minLines: 2,
                      enabled: _isEditing,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // Checklist
                if (task.checklist.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Checklist',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...task.checklist.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item.isCompleted,
                            onChanged: (_) =>
                                _toggleChecklistItem(context, task, item),
                          ),
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    decoration: item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _checklistItemController,
                            decoration: InputDecoration(
                              hintText: 'Add checklist item',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              _addChecklistItem(context, task),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],

                // Comments
                Text(
                  'Comments (${task.comments.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ...task.comments
                    .map(
                      (comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  child: Text(comment.userId.initials),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'User',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                      Text(
                                        comment.createdAt.relativeTime(),
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
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                comment.content,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _commentController,
                  label: 'Add a comment',
                  hint: 'Share your thoughts...',
                  maxLines: 3,
                  minLines: 1,
                  suffixIcon: Icons.send,
                  onSuffixTap: () => _addComment(context, task),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.refresh(taskProvider(widget.taskId)),
        ),
      ),
    );
  }

  void _toggleTaskStatus(BuildContext context, TaskModel task) {
    // TODO: Implement via provider
    SnackBarHelper.showSuccess(context, 'Task status updated');
  }

  void _toggleChecklistItem(
    BuildContext context,
    TaskModel task,
    TaskChecklist item,
  ) {
    // TODO: Implement via provider
    SnackBarHelper.showSuccess(context, 'Checklist item updated');
  }

  void _addChecklistItem(BuildContext context, TaskModel task) {
    if (_checklistItemController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Item cannot be empty');
      return;
    }

    // TODO: Implement via provider
    _checklistItemController.clear();
    SnackBarHelper.showSuccess(context, 'Item added to checklist');
  }

  void _addComment(BuildContext context, TaskModel task) {
    if (_commentController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Comment cannot be empty');
      return;
    }

    // TODO: Implement via provider
    _commentController.clear();
    SnackBarHelper.showSuccess(context, 'Comment added');
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement via provider
              Navigator.pop(context);
              context.pop();
              SnackBarHelper.showSuccess(context, 'Task deleted');
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

  void _archiveTask(BuildContext context) {
    // TODO: Implement via provider
    SnackBarHelper.showSuccess(context, 'Task archived');
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.deepOrange;
    }
  }
}
