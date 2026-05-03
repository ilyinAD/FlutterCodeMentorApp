import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/cubits/submissions/submissions_cubit.dart';
import '../../domain/cubits/submissions/submissions_state.dart';
import '../widgets/criteria_list.dart';
import '../widgets/submission_tile.dart';

class SubmissionsScreen extends StatefulWidget {
  final int taskId;

  const SubmissionsScreen({super.key, required this.taskId});

  @override
  State<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends State<SubmissionsScreen> {
  late Future<TaskModel> _taskFuture;

  @override
  void initState() {
    super.initState();
    _taskFuture = context.read<TaskRepository>().getTask(widget.taskId);
    context.read<SubmissionsCubit>().load();
  }

  Future<void> _refresh() async {
    setState(() {
      _taskFuture = context.read<TaskRepository>().getTask(widget.taskId);
    });
    await context.read<SubmissionsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task and submissions')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            FutureBuilder<TaskModel>(
              future: _taskFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(snapshot.error.toString()),
                  );
                }
                final task = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TaskInfo(task: task),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        'Grading criteria',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    CriteriaList(criteria: task.criteria),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Submissions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            BlocBuilder<SubmissionsCubit, SubmissionsState>(
              builder: (context, state) {
                return switch (state) {
                  SubmissionsInitial() || SubmissionsLoading() => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  SubmissionsError(:final message) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(message, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () =>
                                context.read<SubmissionsCubit>().load(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  SubmissionsLoaded(:final submissions)
                      when submissions.isEmpty =>
                    const _EmptyView(),
                  SubmissionsLoaded(:final submissions) => Column(
                      children: submissions
                          .map((s) => SubmissionTile(
                                submission: s,
                                onTap: () async {
                                  await context
                                      .push('/submissions/${s.submissionId}');
                                  if (context.mounted) {
                                    context.read<SubmissionsCubit>().load();
                                  }
                                },
                              ))
                          .toList(),
                    ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskInfo extends StatelessWidget {
  final TaskModel task;

  const _TaskInfo({required this.task});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final colorScheme = Theme.of(context).colorScheme;
    final isOverdue = task.deadline.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (task.description != null && task.description!.isNotEmpty) ...[
            Text(
              task.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: isOverdue ? colorScheme.error : colorScheme.outline,
              ),
              const SizedBox(width: 6),
              Text(
                'Deadline: ${dateFormat.format(task.deadline)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          isOverdue ? colorScheme.error : colorScheme.outline,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.star_outline, size: 16, color: colorScheme.outline),
              const SizedBox(width: 6),
              Text(
                'Max score: ${task.maxScore}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text('No submissions yet',
                style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
