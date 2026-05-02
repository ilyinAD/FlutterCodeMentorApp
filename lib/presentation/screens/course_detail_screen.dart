import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/course_model.dart';
import '../../domain/cubits/course_detail/course_detail_cubit.dart';
import '../../domain/cubits/course_detail/course_detail_state.dart';
import '../widgets/task_card.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourseDetailCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course')),
      body: BlocBuilder<CourseDetailCubit, CourseDetailState>(
        builder: (context, state) {
          return switch (state) {
            CourseDetailInitial() || CourseDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            CourseDetailError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<CourseDetailCubit>().load(),
              ),
            CourseDetailLoaded(:final course, :final tasks) =>
              RefreshIndicator(
                onRefresh: () => context.read<CourseDetailCubit>().load(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _CourseInfo(course: course),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Tasks',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    if (tasks.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyTasks(),
                      )
                    else
                      SliverList.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            task: task,
                            onTap: () => context.push(
                              '/courses/${widget.courseId}/tasks/${task.taskId}/submissions',
                            ),
                          );
                        },
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/courses/${widget.courseId}/create-task');
          if (context.mounted) {
            context.read<CourseDetailCubit>().load();
          }
        },
        icon: const Icon(Icons.add_task),
        label: const Text('New task'),
      ),
    );
  }
}

class _CourseInfo extends StatelessWidget {
  final CourseModel course;

  const _CourseInfo({required this.course});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (course.description != null && course.description!.isNotEmpty) ...[
            Text(
              course.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: colorScheme.outline),
              const SizedBox(width: 6),
              Text(
                course.endDate != null
                    ? '${dateFormat.format(course.startDate)} — ${dateFormat.format(course.endDate!)}'
                    : 'c ${dateFormat.format(course.startDate)}',
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

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text('No tasks yet',
                style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Repeat')),
          ],
        ),
      ),
    );
  }
}
