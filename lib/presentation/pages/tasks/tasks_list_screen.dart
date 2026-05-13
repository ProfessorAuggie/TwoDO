import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../data/models/task_model.dart';
import '../../providers/space_providers.dart';
import '../../widgets/common/app_widgets.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const TasksListScreen({required this.spaceId, super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  bool _showOverdueOnly = false;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(spaceTasksProvider(widget.spaceId));
    final isDesktop = context.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter tasks',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          if (!isDesktop)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildSummaryCard(
                    context,
                    'All',
                    tasks.maybeWhen(
                      data: (t) => t.length,
                      orElse: () => 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    context,
                    'Pending',
                    tasks.maybeWhen(
                      data: (t) => t
                          .where((task) => task.status == TaskStatus.pending)
                          .length,
                      orElse: () => 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    context,
                    'In Progress',
                    tasks.maybeWhen(
                      data: (t) => t
                          .where(
                            (task) =>
                                task.status == TaskStatus.inProgress,
                          )
                          .length,
                      orElse: () => 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    context,
                    'Completed',
                    tasks.maybeWhen(
                      data: (t) => t
                          .where((task) => task.status == TaskStatus.completed)
                          .length,
                      orElse: () => 0,
                    ),
                  ),
                ],
              ),
            ),

          // Tasks List
          Expanded(
            child: tasks.when(
              data: (allTasks) {
                var filteredTasks = allTasks;

                if (_filterStatus != null) {
                  filteredTasks = filteredTasks
                      .where((task) => task.status == _filterStatus)
                      .toList();
                }

                if (_filterPriority != null) {
                  filteredTasks = filteredTasks
                      .where((task) => task.priority == _filterPriority)
                      .toList();
                }

                if (_showOverdueOnly) {
                  filteredTasks = filteredTasks
                      .where((task) => task.isOverdue)
                      .toList();
                }

                if (filteredTasks.isEmpty) {
                  return EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'No tasks',
                    subtitle: 'Create a task to get started',
                    actionLabel: 'Create Task',
                    onAction: () =>
                        context.push('/spaces/${widget.spaceId}/tasks/create'),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 12,
                    vertical: 8,
                  ),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () => context.push(
                        '/spaces/${widget.spaceId}/tasks/${task.id}',
                      ),
                      onToggleStatus: () =>
                          _toggleTaskStatus(context, task),
                    );
                  },
                );
              },
              loading: () => const SkeletonLoader(),
              error: (error, _) => ErrorState(
                error: error.toString(),
                onRetry: () =>
                    ref.refresh(spaceTasksProvider(widget.spaceId)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/spaces/${widget.spaceId}/tasks/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    int count,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Status Filter
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterStatus == null,
                  onSelected: (_) =>
                      setState(() => _filterStatus = null),
                ),
                ...TaskStatus.values
                    .map(
                      (status) => FilterChip(
                        label: Text(status.label),
                        selected: _filterStatus == status,
                        onSelected: (_) =>
                            setState(() => _filterStatus = status),
                      ),
                    )
                    .toList(),
              ],
            ),
            const SizedBox(height: 20),

            // Priority Filter
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterPriority == null,
                  onSelected: (_) =>
                      setState(() => _filterPriority = null),
                ),
                ...TaskPriority.values
                    .map(
                      (priority) => FilterChip(
                        label: Text(priority.label),
                        selected: _filterPriority == priority,
                        onSelected: (_) =>
                            setState(() => _filterPriority = priority),
                      ),
                    )
                    .toList(),
              ],
            ),
            const SizedBox(height: 20),

            // Overdue Filter
            CheckboxListTile(
              title: const Text('Show overdue only'),
              value: _showOverdueOnly,
              onChanged: (value) =>
                  setState(() => _showOverdueOnly = value ?? false),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTaskStatus(BuildContext context, TaskModel task) {
    // TODO: Implement toggle task status via provider
    SnackBarHelper.showSuccess(context, 'Task status updated');
  }
}

class TaskCard extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;

  const TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggleStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.isOverdue && !isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isOverdue
                  ? Colors.red.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outlineVariant,
              width: isOverdue ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isCompleted
                ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
                : null,
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggleStatus,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Priority
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.priority.label,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color:
                                          _getPriorityColor(task.priority),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Due Date
                        if (task.dueDate != null) ...[
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: isOverdue ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.dueDate!.taskDueDate,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                              color: isOverdue ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.status.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(task.status),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
